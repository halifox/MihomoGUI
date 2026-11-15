#!/bin/bash
# Run after bash scripts/build.sh. Uses isolated settings fixtures only.
set -euo pipefail
cd "$(dirname "$0")/.."
if [ ! -s .build/manual/ClashCore.o ]; then
  printf 'Run bash scripts/build.sh first.\n' >&2
  exit 1
fi
CHECK_DIR="$(mktemp -d "${TMPDIR:-/tmp}/clash-interactions.XXXXXX")"
trap 'rm -rf "$CHECK_DIR"' EXIT
cat > "$CHECK_DIR/InteractionChecks.swift" <<'SWIFT'
import Foundation
import SwiftUI
import ClashCore

func check(_ condition: @autoclosure () throws -> Bool, _ message: String) throws {
    if try !condition() { throw DeskError("CHECK FAILED: " + message) }
}
func expectFailure(_ message: String, _ operation: () throws -> Void) throws {
    do { try operation() } catch { return }
    throw DeskError("EXPECTED FAILURE: " + message)
}
@main struct InteractionChecks {
    @MainActor static func main() async throws {
        let directory = URL(fileURLWithPath: CommandLine.arguments[1]).appendingPathComponent("fixture")
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: directory) }
        let model = DeskModel(directory: directory)
        try check(model.error == nil, "isolated model initializes")
        let seed = RouteRule(kind: .suffix, value: "example.com", node: nil)
        try model.saveRule(seed)
        let single = RouteRule(kind: .domain, value: "api.example.com", node: nil)
        try check(rulePriorityNotice(single, preceding: [seed]) != nil, "suffix overlap is reported")
        try check(rulePriorityNotice(RouteRule(kind: .domain, value: "notexample.com", node: nil), preceding: [seed]) == nil, "suffix respects dot boundary")
        try model.saveRule(single, atTop: true)
        try check(model.settings.rules.first?.id == single.id, "top insertion")
        try check(try loadSettings(from: directory).rules.first?.id == single.id, "top insertion persists")
        try expectFailure("duplicate batch rule") { try model.addRules([RouteRule(kind: .domain, value: single.value, node: nil)], atTop: false) }
        var edited = single
        edited.noResolve = false; edited.sourceIP = false; edited.subRuleTarget = ""
        try check(sameRuleMatch(single, edited), "irrelevant empty sub-rule target does not bypass duplicate detection")
        let before = try Data(contentsOf: directory.appendingPathComponent("settings.json"))
        let beforeIDs = model.settings.rules.map(\.id)
        let valid = RouteRule(kind: .destinationPort, value: "443", node: nil)
        let invalid = RouteRule(kind: .destinationPort, value: "70000", node: nil)
        try expectFailure("batch validation") { try model.addRules([valid, invalid], atTop: true) }
        try check(model.settings.rules.map(\.id) == beforeIDs, "failed batch leaves state intact")
        try check(try Data(contentsOf: directory.appendingPathComponent("settings.json")) == before, "failed batch leaves disk intact")
        try expectFailure("duplicate inside batch") { try model.addRules([valid, valid], atTop: true) }
        try model.addRules([valid], atTop: false)
        try check(model.settings.rules.last?.id == valid.id, "batch append preserves order")
        let config = try generateConfig(model.settings)
        try check(String(decoding: config, as: UTF8.self).contains("DST-PORT,443,DIRECT"), "batch uses standard serialization")
        model.busy = true
        try expectFailure("busy guard") { try model.addRules([RouteRule(kind: .domain, value: "other.example", node: nil)], atTop: false) }
        model.busy = false
        try check(quickRouteRule(kind: .domain, value: "2001:db8::1")?.value == "2001:db8::1/128", "IPv6 exact address prefill")
        try check(quickRouteRule(kind: .domain, value: "192.0.2.1")?.value == "192.0.2.1/32", "IPv4 exact address prefill")
        try check(quickRouteRule(kind: .domain, value: "未知目标") == nil, "placeholder excluded")
        let ipv6Menu = RouteMenu(kind: .domain, value: "2001:db8::1234")
        try check(ipv6Menu.isIPv6 && !ipv6Menu.isIPv4 && ipv6Menu.subnet == "2001:db8::/64", "IPv6 menu and subnet family")
        try check(!model.coreActive, "new model starts disconnected")
        model.corePID = 123
        try check(model.coreActive && model.configurationLocked, "existing service locks configuration before API connects")
        model.startCore()
        try check(!model.busy, "start does not reinstall an existing core")
        model.corePID = nil
        try model.addRules([
            RouteRule(kind: .sourceCIDR, value: "2001:db8::2/128", node: nil),
            RouteRule(kind: .and, value: "((PROCESS-PATH,/Applications/Fixture (Test).app/Contents/MacOS/Fixture (Test)),(DOMAIN,api.example.com))", node: nil),
            RouteRule(kind: .and, value: "((PROCESS-NAME,Fixture),(DST-PORT,443))", node: nil)
        ], atTop: true)
        try generateConfig(model.settings).write(to: URL(fileURLWithPath: CommandLine.arguments[1]).appendingPathComponent("config.yaml"), options: .atomic)
        // Use a separate, unprivileged real core; never touch the installed system service.
        let port = Int.random(in: 30000...60000)
        var runtime = model.settings
        runtime.options = ["external-controller": .string("127.0.0.1:\(port)"), "secret": .string(UUID().uuidString)]
        try saveRuntimeSettings(runtime, to: directory)
        let liveConfig = directory.appendingPathComponent("live.yaml")
        let secret = runtime.options?["secret"]?.text ?? ""
        try "external-controller: 127.0.0.1:\(port)\nsecret: \(secret)\nmode: direct\nrules: []\n".write(to: liveConfig, atomically: true, encoding: .utf8)
        let core = Process()
        core.executableURL = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
            .appendingPathComponent("resources/core/" + (CommandLine.arguments[2]) + "/mihomo")
        core.arguments = ["-d", directory.path, "-f", liveConfig.path]
        core.standardOutput = FileHandle.nullDevice; core.standardError = FileHandle.nullDevice
        try core.run()
        defer { if core.isRunning { core.terminate(); core.waitUntilExit() } }
        var first: DeskModel? = DeskModel(directory: directory)
        for _ in 0..<30 {
            await first?.refresh()
            if first?.coreRunning == true { break }
            try await Task.sleep(nanoseconds: 100_000_000)
        }
        try check(first?.coreRunning == true, "GUI model connects to real existing core")
        let pid = core.processIdentifier
        first = nil
        try check(core.isRunning && core.processIdentifier == pid, "releasing GUI model leaves core running")
        let reopened = DeskModel(directory: directory)
        await reopened.refresh()
        try check(reopened.coreRunning && core.processIdentifier == pid, "reopened GUI reconnects without restarting core")
        reopened.startCore()
        try check(!reopened.busy && core.isRunning, "existing core start is a no-op")
        try check(!FileManager.default.fileExists(atPath: directory.appendingPathComponent("traffic.sqlite").path), "monitoring creates no statistics database")
        print("PASS: routing prefill, priority, atomic batch persistence, duplicate/busy guards, existing service detection, start guard, real-core reconnect and GUI model release")
    }
}
SWIFT
SOURCES=()
for source in Sources/ClashDesk/*.swift; do
  if [ "$source" != Sources/ClashDesk/App.swift ]; then SOURCES+=("$source"); fi
done
swiftc -parse-as-library -module-cache-path .build/manual/module-cache \
  -target "$(uname -m)-apple-macosx13.0" -I .build/manual \
  "${SOURCES[@]}" "$CHECK_DIR/InteractionChecks.swift" .build/manual/ClashCore.o \
  -o "$CHECK_DIR/checks"
"$CHECK_DIR/checks" "$CHECK_DIR" "$(uname -m)"
"resources/core/$(uname -m)/mihomo" -t -d "$CHECK_DIR" -f "$CHECK_DIR/config.yaml"
