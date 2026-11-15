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
    selected = "REJECT"
    def log_message(self, *_args):
        pass
    def do_GET(self):
        if self.path == '/version':
            value = {'version': 'v' + version}
        elif self.path == '/proxies':
            value = {'proxies': {'fixture': {'type': 'Selector', 'now': Handler.selected}}}
        elif self.path.startswith('/proxies/'):
            value = {'now': Handler.selected}
        else:
            value = {'connections': []}
        body = json.dumps(value).encode()
        self.send_response(200)
        self.send_header('Content-Length', str(len(body)))
        self.end_headers()
        self.wfile.write(body)
    def do_PUT(self):
        body = json.loads(self.rfile.read(int(self.headers['Content-Length'])))
        if self.path.startswith('/proxies/'):
            if (root / 'reject-selection').exists():
                self.send_response(503)
                self.end_headers()
                return
            if not (root / 'ignore-selection').exists():
                Handler.selected = body['name']
        else:
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

enum FailureMode: String, CaseIterable { case afterWrite, beforeWrite, restoreFailure, startupSnapshotFailure, markerCleanupFailure, selectionSuccess, selectionFailure, selectionReadbackFailure, legacyAliasMigration, legacyMigrationFailure, futureFormatStop, prepareLostReply, ruleRestoreFailure, ruleCleanupFailure }
@MainActor var failureMode = FailureMode.afterWrite
@MainActor var persistCalls = 0
@MainActor var installCalls = 0
@MainActor var stopCalls = 0
@MainActor var markerPresentAtInstallation = false
@MainActor var rulesRestored: Bool?
@MainActor var previousRuleData = Data()
@MainActor var prepareCalls = 0
@MainActor var restoreCalls = 0
@MainActor var finishCalls = 0
@MainActor var pendingRuleID: UUID?
@MainActor var fixtureDirectory = URL(fileURLWithPath: "/")

// Replace the XPC boundary only; the production model, API and persistence run unchanged.
@MainActor func privilegedOperation(_ operation: PrivilegedOperation) async throws {
    if case .stop = operation, failureMode == .futureFormatStop {
        stopCalls += 1
        return
    }
    if case .install = operation, failureMode == .startupSnapshotFailure {
        installCalls += 1
        markerPresentAtInstallation = FileManager.default.fileExists(atPath: fixtureDirectory.appendingPathComponent("runtime-update-pending").path)
        return
    }
    if case .prepareRules(let staging, let id, let filenames) = operation, [.prepareLostReply, .ruleRestoreFailure].contains(failureMode) {
        prepareCalls += 1
        let pending = try RuleFileUpdate.load(directory: fixtureDirectory)
        try check(pending?.id == id && pending?.filenames == filenames && pending?.committed == false, "transaction identity is durable before helper preparation")
        let active = fixtureDirectory.appendingPathComponent("active-rule.yaml")
        previousRuleData = try Data(contentsOf: active)
        try Data(contentsOf: URL(fileURLWithPath: staging).appendingPathComponent(filenames[0])).write(to: active, options: .atomic)
        pendingRuleID = id
        if prepareCalls == 1 { throw MihomoGUIError("injected lost preparation reply") }
        return
    }
    if case .finishRules(let id, _, let restore) = operation, [.prepareLostReply, .ruleRestoreFailure].contains(failureMode) {
        try check(id == pendingRuleID, "recovery reuses the original transaction ID")
        if restore {
            restoreCalls += 1
            if failureMode == .ruleRestoreFailure && restoreCalls == 1 { throw MihomoGUIError("injected rule restore failure") }
            try previousRuleData.write(to: fixtureDirectory.appendingPathComponent("active-rule.yaml"), options: .atomic)
        }
        return
    }
    if case .prepareRules(let staging, _, let filenames) = operation, [.markerCleanupFailure, .ruleCleanupFailure].contains(failureMode) {
        guard let name = filenames.first else { throw MihomoGUIError("missing fixture rule") }
        let active = fixtureDirectory.appendingPathComponent("active-rule.yaml")
        previousRuleData = try Data(contentsOf: active)
        try Data(contentsOf: URL(fileURLWithPath: staging).appendingPathComponent(name)).write(to: active, options: .atomic)
        return
    }
    if case .finishRules(_, _, let restore) = operation, [.markerCleanupFailure, .ruleCleanupFailure].contains(failureMode) {
        rulesRestored = restore
        finishCalls += 1
        if failureMode == .ruleCleanupFailure && finishCalls == 1 { throw MihomoGUIError("injected lost cleanup reply") }
        if restore { try previousRuleData.write(to: fixtureDirectory.appendingPathComponent("active-rule.yaml"), options: .atomic) }
        return
    }
    guard case .persist(let data) = operation else { throw MihomoGUIError("unexpected privileged operation in fixture") }
    persistCalls += 1
    if failureMode == .beforeWrite && persistCalls == 1 || failureMode == .restoreFailure && persistCalls == 2 {
        throw MihomoGUIError("injected write failure")
    }
    try data.write(to: fixtureDirectory.appendingPathComponent("disk.yaml"), options: .atomic)
    if failureMode == .markerCleanupFailure {
        try FileManager.default.setAttributes([.immutable: true], ofItemAtPath: fixtureDirectory.appendingPathComponent("runtime-update-pending").path)
    } else if persistCalls == 1 && ![FailureMode.selectionSuccess, .selectionFailure, .selectionReadbackFailure, .legacyAliasMigration, .legacyMigrationFailure, .prepareLostReply, .ruleRestoreFailure, .ruleCleanupFailure].contains(failureMode) {
        throw MihomoGUIError("injected lost reply after successful write")
    }
}
func check(_ condition: @autoclosure () throws -> Bool, _ message: String) throws {
    guard try condition() else { throw MihomoGUIError("CHECK FAILED: " + message) }
}
@main struct RecoveryChecks {
    @MainActor static func main() async throws {
        let root = URL(fileURLWithPath: CommandLine.arguments[1])
        let port = try String(contentsOf: root.appendingPathComponent("port"), encoding: .utf8)
        for mode in [FailureMode.afterWrite, .beforeWrite, .restoreFailure] {
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
        for mode in [FailureMode.selectionSuccess, .selectionFailure, .selectionReadbackFailure] {
            failureMode = mode; persistCalls = 0
            let directory = root.appendingPathComponent(mode.rawValue)
            fixtureDirectory = directory
            try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
            var settings = Settings()
            settings.corePath = Bundle.main.bundleURL.appendingPathComponent("Contents/Helpers/mihomo").path
            settings.defaultPolicy = "DIRECT"
            settings.options = ["dns.enable": .boolean(false), "tun.enable": .boolean(false), "mixed-port": .integer(0), "external-controller": .string("127.0.0.1:" + port)]
            let group = ProxyGroup(name: "fixture", targets: ["builtin:DIRECT", "builtin:REJECT"], fields: ["default-selected": .string("builtin:DIRECT")])
            settings.proxyGroups = [group]
            let controller = try CoreAPI(settings: settings)
            try await controller.selectProxyGroup(group.name, target: "REJECT")
            let failureFlag = root.appendingPathComponent(mode == .selectionFailure ? "reject-selection" : "ignore-selection")
            if mode != .selectionSuccess { try Data().write(to: failureFlag) }
            try saveSettings(settings, to: directory)
            try saveRuntimeSettings(settings, to: directory)
            let model = MihomoGUIModel(directory: directory)
            model.corePID = 123
            try check(!model.hasUnappliedChanges, "selection fixture begins with identical saved and runtime configuration")
            try model.selectProxyGroup(group, target: "builtin:DIRECT")
            for _ in 0..<200 {
                if persistCalls > 0 && !model.busy { break }
                try await Task.sleep(nanoseconds: 50_000_000)
            }
            try check(persistCalls == 1 && !model.busy, "explicit choice applies even when its saved default is unchanged")
            if mode != .selectionSuccess {
                try check(model.runtimeConfigurationUncertain && model.hasUnappliedChanges && model.error?.contains("代理组选择尚未确认") == true,
                          "rejected or unconfirmed selection keeps visible pending state")
                try check(model.message != "修改已自动应用。", "unconfirmed selector choice never reports application success")
                try check(FileManager.default.fileExists(atPath: directory.appendingPathComponent("runtime-update-pending").path), "selection failure keeps durable marker")
                try FileManager.default.removeItem(at: failureFlag)
                model.error = nil
                model.retryLiveUpdate()
                for _ in 0..<200 {
                    if persistCalls == 2 && !model.busy { break }
                    try await Task.sleep(nanoseconds: 50_000_000)
                }
                try check(persistCalls == 2 && !model.busy, "retry resubmits an unconfirmed selection")
            }
            let selected = try await controller.proxyGroupSelections()[group.name]
            try check(selected == "DIRECT" && model.error == nil && !model.runtimeConfigurationUncertain && !model.hasUnappliedChanges,
                      "only confirmed actual selection clears pending state")
        }

        for mode in [FailureMode.legacyAliasMigration, .legacyMigrationFailure] {
            failureMode = mode; persistCalls = 0
            let migrationDirectory = root.appendingPathComponent(mode.rawValue)
            fixtureDirectory = migrationDirectory
            try FileManager.default.createDirectory(at: migrationDirectory, withIntermediateDirectories: true)
            var legacy = Settings()
            legacy.stableProxyAliases = nil
            legacy.corePath = Bundle.main.bundleURL.appendingPathComponent("Contents/Helpers/mihomo").path
            legacy.defaultPolicy = "DIRECT"
            legacy.options = ["dns.enable": .boolean(false), "tun.enable": .boolean(false), "mixed-port": .integer(0), "external-controller": .string("127.0.0.1:" + port)]
            let source = Subscription(name: "fixture", url: "https://example.invalid/subscription")
            legacy.subscriptions = [source]
            legacy.subscriptionProxies = [source.id: [.object(["name": .string("A"), "type": .string("direct")]), .object(["name": .string("B"), "type": .string("direct")])]]
            legacy.proxyGroups = [ProxyGroup(name: "fixture", targets: ["node:" + Node(provider: source.provider, name: "A").id, "node:" + Node(provider: source.provider, name: "B").id])]
            try saveSettings(legacy, to: migrationDirectory)
            try saveRuntimeSettings(legacy, to: migrationDirectory)
            let legacyController = try CoreAPI(settings: legacy)
            let oldAlias = subscriptionProxyAlias(sourceIndex: 0, proxyIndex: 1)
            try await legacyController.selectProxyGroup("fixture", target: oldAlias)
            let migrationModel = MihomoGUIModel(directory: migrationDirectory)
            migrationModel.corePID = 123
            try check(migrationModel.settings.stableProxyAliases == true && migrationModel.runtimeSettings.stableProxyAliases == nil, "new draft and previous runtime keep separate alias contracts")
            try check(migrationModel.connectionProxyNames[oldAlias] == "B", "old running connections retain their original names")
            let rejectMigration = root.appendingPathComponent("reject-selection")
            if mode == .legacyMigrationFailure { try Data().write(to: rejectMigration) }
            migrationModel.retryLiveUpdate()
            for _ in 0..<200 {
                if persistCalls > 0 && !migrationModel.busy { break }
                try await Task.sleep(nanoseconds: 50_000_000)
            }
            let stableAlias = subscriptionProxyAlias(subscriptionID: source.id, proxyName: "B")
            try check(persistCalls == 1 && migrationModel.runtimeSettings.stableProxyAliases == true, "legacy update commits the stable runtime snapshot")
            try check(migrationModel.connectionProxyNames[oldAlias] == "B" && migrationModel.connectionProxyNames[stableAlias] == "B", "connections on both sides of migration use truthful labels")
            if mode == .legacyMigrationFailure {
                try check(migrationModel.error != nil && migrationModel.runtimeConfigurationUncertain, "failed alias selection remains uncertain")
                try check(try loadRuntimeUpdateSelections(directory: migrationDirectory)["fixture"] == stableAlias, "migration target is durable before selector mutation")
                try FileManager.default.removeItem(at: rejectMigration)
                let reopened = MihomoGUIModel(directory: migrationDirectory)
                reopened.corePID = 123
                reopened.retryLiveUpdate()
                for _ in 0..<200 {
                    if persistCalls == 2 && !reopened.busy { break }
                    try await Task.sleep(nanoseconds: 50_000_000)
                }
                try check(persistCalls == 2 && reopened.error == nil && !reopened.hasUnappliedChanges, "reopened GUI replays the saved migration target")
            } else {
                try check(migrationModel.error == nil && !migrationModel.hasUnappliedChanges, "legacy live update is confirmed as one transaction")
            }
            let migratedChoice = try await legacyController.proxyGroupSelections()["fixture"]
            try check(migratedChoice == stableAlias, "actual old cached choice is remapped before confirmation")
        }

        for mode in [FailureMode.prepareLostReply, .ruleRestoreFailure] {
            failureMode = mode; prepareCalls = 0; restoreCalls = 0; persistCalls = 0
            let directory = root.appendingPathComponent(mode.rawValue)
            fixtureDirectory = directory
            try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
            let oldRule = directory.appendingPathComponent("old.yaml")
            let newRule = directory.appendingPathComponent("new.yaml")
            let active = directory.appendingPathComponent("active-rule.yaml")
            try Data("payload: [old.example]".utf8).write(to: oldRule)
            try Data("payload: [new.example]".utf8).write(to: newRule)
            try Data(contentsOf: oldRule).write(to: active)
            var settings = Settings()
            settings.defaultPolicy = "DIRECT"
            settings.options = ["dns.enable": .boolean(false), "tun.enable": .boolean(false), "mixed-port": .integer(0), "external-controller": .string("127.0.0.1:" + port),
                                "rule-providers": .object(["fixture": .object(["type": .string("file"), "behavior": .string("domain"), "path": .string(oldRule.path)])])]
            try saveSettings(settings, to: directory); try saveRuntimeSettings(settings, to: directory)
            let model = MihomoGUIModel(directory: directory); model.corePID = 123
            settings.defaultPolicy = "REJECT"
            settings.options?["rule-providers"] = .object(["fixture": .object(["type": .string("file"), "behavior": .string("domain"), "path": .string(newRule.path)])])
            model.settings = settings
            try saveSettings(settings, to: directory)
            for _ in 0..<200 {
                if model.error != nil && !model.busy { break }
                try await Task.sleep(nanoseconds: 50_000_000)
            }
            try check(model.error != nil && prepareCalls == 1, "lost prepare reply is surfaced")
            if mode == .prepareLostReply {
                try check(try Data(contentsOf: active) == Data(contentsOf: oldRule), "lost reply restores original rule bytes")
                try check(try RuleFileUpdate.load(directory: directory) == nil, "confirmed full rollback retires its journal")
            } else {
                try check(try RuleFileUpdate.load(directory: directory)?.id == pendingRuleID, "failed restore retains original durable recovery ID")
                let journalMode = try FileManager.default.attributesOfItem(atPath: directory.appendingPathComponent("rule-update-pending.json").path)[.posixPermissions] as? NSNumber
                try check(journalMode?.intValue == 0o600, "journal with prior settings is owner-only")
            }
            let reopened = MihomoGUIModel(directory: directory); reopened.corePID = 123
            reopened.retryLiveUpdate()
            for _ in 0..<200 {
                if !reopened.busy && !reopened.hasUnappliedChanges { break }
                try await Task.sleep(nanoseconds: 50_000_000)
            }
            try check(!reopened.hasUnappliedChanges, "reopened model recovers before retrying")
            try check(try Data(contentsOf: active) == Data(contentsOf: newRule), "retry installs desired rule contents")
            try check(try RuleFileUpdate.load(directory: directory) == nil, "confirmed retry retires durable transaction")
        }

        for cleanupMode in [FailureMode.markerCleanupFailure, .ruleCleanupFailure] {
        failureMode = cleanupMode; persistCalls = 0; finishCalls = 0
        let cleanupDirectory = root.appendingPathComponent(cleanupMode.rawValue)
        fixtureDirectory = cleanupDirectory
        try FileManager.default.createDirectory(at: cleanupDirectory, withIntermediateDirectories: true)
        let marker = cleanupDirectory.appendingPathComponent("runtime-update-pending")
        defer { try? FileManager.default.setAttributes([.immutable: false], ofItemAtPath: marker.path) }
        let oldRule = cleanupDirectory.appendingPathComponent("old-rule.yaml")
        let newRule = cleanupDirectory.appendingPathComponent("new-rule.yaml")
        let activeRule = cleanupDirectory.appendingPathComponent("active-rule.yaml")
        try Data("payload: [old.example]".utf8).write(to: oldRule)
        try Data("payload: [new.example]".utf8).write(to: newRule)
        try Data(contentsOf: oldRule).write(to: activeRule)
        var cleanupSettings = Settings()
        cleanupSettings.defaultPolicy = "DIRECT"
        cleanupSettings.options = ["dns.enable": .boolean(false), "tun.enable": .boolean(false), "mixed-port": .integer(0), "external-controller": .string("127.0.0.1:" + port),
                                   "rule-providers": .object(["fixture": .object(["type": .string("file"), "behavior": .string("domain"), "path": .string(oldRule.path)])])]
        try saveSettings(cleanupSettings, to: cleanupDirectory)
        try saveRuntimeSettings(cleanupSettings, to: cleanupDirectory)
        let cleanupModel = MihomoGUIModel(directory: cleanupDirectory)
        cleanupModel.corePID = 123
        cleanupSettings.defaultPolicy = "REJECT"
        cleanupSettings.options?["rule-providers"] = .object(["fixture": .object(["type": .string("file"), "behavior": .string("domain"), "path": .string(newRule.path)])])
        cleanupModel.settings = cleanupSettings
        try saveSettings(cleanupSettings, to: cleanupDirectory)
        for _ in 0..<200 {
            if cleanupModel.error != nil && !cleanupModel.busy { break }
            try await Task.sleep(nanoseconds: 50_000_000)
        }
        try check(cleanupModel.error?.contains(cleanupMode == .markerCleanupFailure ? "恢复标记清理失败" : "规则事务清理尚未完成") == true && !cleanupModel.busy, "cleanup failure is reported separately from commit failure")
        try check(persistCalls == 1 && rulesRestored == false, "completed update retires rule backup without restoring old rules")
        try check(try Data(contentsOf: activeRule) == Data(contentsOf: newRule), "active rule files retain the committed contents")
        try check(try loadRuntimeSettings(from: cleanupDirectory).defaultPolicy == "REJECT", "runtime snapshot remains committed")
        let committedDisk = try String(contentsOf: cleanupDirectory.appendingPathComponent("disk.yaml"), encoding: .utf8)
        let committedRunning = try String(contentsOf: root.appendingPathComponent("running.yaml"), encoding: .utf8)
        try check(committedDisk.contains("MATCH,REJECT") && committedRunning.contains("MATCH,REJECT"), "disk and core retain the committed configuration")
        try check(cleanupModel.runtimeConfigurationUncertain && FileManager.default.fileExists(atPath: marker.path), "failed cleanup retains a visible retry state")
        try FileManager.default.setAttributes([.immutable: false], ofItemAtPath: marker.path)
        if cleanupMode == .ruleCleanupFailure {
            try check(try RuleFileUpdate.load(directory: cleanupDirectory)?.committed == true, "cleanup failure retains durable committed phase")
            let reopened = MihomoGUIModel(directory: cleanupDirectory); reopened.corePID = 123
            reopened.retryLiveUpdate()
            for _ in 0..<200 {
                if !reopened.busy && !reopened.hasUnappliedChanges { break }
                try await Task.sleep(nanoseconds: 50_000_000)
            }
            try check(!reopened.hasUnappliedChanges && rulesRestored == false, "committed transaction cleanup never restores old files after reopen")
            try check(try Data(contentsOf: activeRule) == Data(contentsOf: newRule), "reopening retains committed rule bytes")
        }
        }

        failureMode = .startupSnapshotFailure
        let directory = root.appendingPathComponent("startup-snapshot")
        fixtureDirectory = directory
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        var settings = Settings()
        settings.defaultPolicy = "DIRECT"
        // No controller is listening here before the simulated service installation.
        settings.options = ["dns.enable": .boolean(false), "tun.enable": .boolean(false), "mixed-port": .integer(0), "external-controller": .string("127.0.0.1:1")]
        try saveSettings(settings, to: directory)
        try saveRuntimeSettings(settings, to: directory)
        let model = MihomoGUIModel(directory: directory)
        model.settings.corePath = FileManager.default.currentDirectoryPath + "/dist/MihomoGUI.app/Contents/Helpers/mihomo"
        // No GEO rules or DNS are enabled; these private cache seeds avoid network downloads.
        let geodata = directory.appendingPathComponent("geodata")
        try FileManager.default.createDirectory(at: geodata, withIntermediateDirectories: true)
        for name in ["Country.mmdb", "geosite.dat"] { try Data("unused fixture".utf8).write(to: geodata.appendingPathComponent(name)) }
        let runtime = directory.appendingPathComponent("runtime.json")
        try FileManager.default.removeItem(at: runtime)
        try FileManager.default.createDirectory(at: runtime, withIntermediateDirectories: false)
        model.startCore()
        for _ in 0..<400 {
            if model.error != nil && !model.busy { break }
            try await Task.sleep(nanoseconds: 50_000_000)
        }
        try check(installCalls == 1 && markerPresentAtInstallation, "startup persists recovery intent before installation")
        try check(model.error != nil && !model.busy && model.runtimeConfigurationUncertain, "runtime save failure leaves startup explicitly uncertain")
        try check(FileManager.default.fileExists(atPath: directory.appendingPathComponent("runtime-update-pending").path), "startup save failure keeps durable recovery marker")
        try check(model.message != "配置已校验并启动。", "unconfirmed startup never reports success")
        let reopened = MihomoGUIModel(directory: directory)
        try check(reopened.runtimeConfigurationUncertain, "reopening preserves unconfirmed startup recovery state")
        failureMode = .futureFormatStop
        for futureFile in ["settings.json", "runtime.json"] {
            let directory = root.appendingPathComponent("future-" + futureFile)
            try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
            var current = Settings()
            current.options = ["external-controller": .string("127.0.0.1:" + port)]
            var future = current; future.schemaVersion = 99
            let currentData = try JSONEncoder().encode(current)
            let futureData = try JSONEncoder().encode(future)
            for name in ["settings.json", "runtime.json"] {
                try (name == futureFile ? futureData : currentData).write(to: directory.appendingPathComponent(name))
            }
            let model = MihomoGUIModel(directory: directory)
            try check(model.configurationFormatUnsupported && !model.coreActive, "future format enters read-only state before service discovery")
            model.startCore()
            try check(!model.busy, "future format still refuses startup")
            model.startMonitor()
            try await Task.sleep(nanoseconds: 200_000_000)
            let previousStops = stopCalls
            model.toggleCore()
            for _ in 0..<200 {
                if stopCalls > previousStops && !model.busy { break }
                try await Task.sleep(nanoseconds: 50_000_000)
            }
            try check(stopCalls == previousStops + 1 && !model.busy, "stop remains available independently of configuration and initial service state")
            for name in ["settings.json", "runtime.json"] {
                try check(try Data(contentsOf: directory.appendingPathComponent(name)) == (name == futureFile ? futureData : currentData), "monitoring and stopping never rewrite either configuration")
            }
            try check(!FileManager.default.fileExists(atPath: directory.appendingPathComponent("runtime-update-pending").path), "stop does not create a configuration update transaction")
        }
        print("PASS: persistence, durable rule recovery, startup, cleanup, selectors, alias migration and future-format stop preserve runtime invariants")
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
