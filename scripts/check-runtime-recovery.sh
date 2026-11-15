#!/bin/bash
# Fault-inject privileged replies using isolated files and a loopback controller only.
set -euo pipefail
cd "$(dirname "$0")/.."
test -s .build/manual/MihomoGUICore.o || { echo 'Run bash scripts/build.sh first.' >&2; exit 1; }
CHECK_DIR="$(mktemp -d "${TMPDIR:-/tmp}/MihomoGUI-recovery.XXXXXX")"
SERVER_PID=""
trap 'if [ -n "$SERVER_PID" ]; then kill "$SERVER_PID" 2>/dev/null || true; wait "$SERVER_PID" 2>/dev/null || true; fi; rm -rf "$CHECK_DIR"' EXIT
python3 - "$CHECK_DIR" <<'PY' &
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from pathlib import Path
import json
import re
import sys
root = Path(sys.argv[1])
version = re.search(r'^public let configurationCoreVersion = "([^"]+)"$', Path('Sources/MihomoGUICore/DocSchemas.swift').read_text(), re.M)[1]
class Handler(BaseHTTPRequestHandler):
    def log_message(self, *_args):
        pass
    def do_GET(self):
        body = json.dumps({'version': 'v' + version} if self.path == '/version' else {'connections': []}).encode()
        self.send_response(200)
        self.send_header('Content-Length', str(len(body)))
        self.end_headers()
        self.wfile.write(body)
    def do_PUT(self):
        body = json.loads(self.rfile.read(int(self.headers['Content-Length'])))
        (root / 'running.yaml').write_text(body['payload'])
        self.send_response(204)
        self.end_headers()
server = ThreadingHTTPServer(('127.0.0.1', 0), Handler)
(root / 'port').write_text(str(server.server_port))
server.serve_forever()
PY
SERVER_PID=$!
for attempt in {1..100}; do
    if [ -s "$CHECK_DIR/port" ]; then break; fi
    kill -0 "$SERVER_PID"
    sleep 0.05
done
test -s "$CHECK_DIR/port"
cat > "$CHECK_DIR/RecoveryChecks.swift" <<'SWIFT'
import Foundation
import MihomoGUICore

enum FailureMode: String, CaseIterable { case afterWrite, beforeWrite, restoreFailure }
@MainActor var failureMode = FailureMode.afterWrite
@MainActor var persistCalls = 0
@MainActor var fixtureDirectory = URL(fileURLWithPath: "/")

// Replace the XPC boundary only; the production model, API and persistence run unchanged.
@MainActor func privilegedOperation(_ operation: PrivilegedOperation) async throws {
    guard case .persist(let data) = operation else { throw MihomoGUIError("unexpected privileged operation in fixture") }
    persistCalls += 1
    if failureMode == .beforeWrite && persistCalls == 1 || failureMode == .restoreFailure && persistCalls == 2 {
        throw MihomoGUIError("injected write failure")
    }
    try data.write(to: fixtureDirectory.appendingPathComponent("disk.yaml"), options: .atomic)
    if persistCalls == 1 { throw MihomoGUIError("injected lost reply after successful write") }
}
func check(_ condition: @autoclosure () throws -> Bool, _ message: String) throws {
    guard try condition() else { throw MihomoGUIError("CHECK FAILED: " + message) }
}
@main struct RecoveryChecks {
    @MainActor static func main() async throws {
        let root = URL(fileURLWithPath: CommandLine.arguments[1])
        let port = try String(contentsOf: root.appendingPathComponent("port"), encoding: .utf8)
        for mode in FailureMode.allCases {
            failureMode = mode; persistCalls = 0
            let directory = root.appendingPathComponent(mode.rawValue)
            fixtureDirectory = directory
            try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
            var settings = Settings()
            settings.defaultPolicy = "DIRECT"
            settings.options = ["dns.enable": .boolean(false), "tun.enable": .boolean(false), "mixed-port": .integer(0), "external-controller": .string("127.0.0.1:" + port)]
            try saveSettings(settings, to: directory)
            try saveRuntimeSettings(settings, to: directory)
            let model = MihomoGUIModel(directory: directory)
            model.corePID = 123
            model.settings.defaultPolicy = "REJECT"
            for _ in 0..<200 {
                if model.error != nil && !model.busy { break }
                try await Task.sleep(nanoseconds: 50_000_000)
            }
            try check(model.error != nil && !model.busy, "fault returns an explicit failure and releases busy state")
            try check(persistCalls == 2, "every attempted disk mutation is followed by a restoration attempt")
            let disk = try String(contentsOf: directory.appendingPathComponent("disk.yaml"), encoding: .utf8)
            let running = try String(contentsOf: root.appendingPathComponent("running.yaml"), encoding: .utf8)
            let uncertain = mode == .restoreFailure
            try check(disk.contains(uncertain ? "MATCH,REJECT" : "MATCH,DIRECT"), "disk reflects confirmed restoration or unknown failure")
            try check(running.contains("MATCH,DIRECT"), "running configuration restored")
            try check(try loadRuntimeSettings(from: directory).defaultPolicy == "DIRECT", "confirmed runtime snapshot stays old")
            try check(model.runtimeConfigurationUncertain == uncertain, "failed disk restoration remains uncertain")
            try check(FileManager.default.fileExists(atPath: directory.appendingPathComponent("runtime-update-pending").path) == uncertain,
                      "recovery marker cleared only after confirmed restoration")
            try check(model.hasUnappliedChanges, "new draft remains unapplied after rollback")
        }
        print("PASS: lost persist replies, failures before writes, and failed restoration preserve disk/runtime recovery invariants")
    }
}
SWIFT
SOURCES=()
for source in Sources/MihomoGUI/*.swift; do
    if [ "$source" != Sources/MihomoGUI/App.swift ] && [ "$source" != Sources/MihomoGUI/PrivilegedService.swift ]; then SOURCES+=("$source"); fi
done
swiftc -parse-as-library -module-cache-path .build/manual/module-cache \
    -target "$(uname -m)-apple-macosx13.0" -I .build/manual \
    "${SOURCES[@]}" "$CHECK_DIR/RecoveryChecks.swift" .build/manual/MihomoGUICore.o -o "$CHECK_DIR/checks"
"$CHECK_DIR/checks" "$CHECK_DIR"
