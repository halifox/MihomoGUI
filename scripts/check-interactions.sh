#!/bin/bash
# Run after bash scripts/build.sh. Uses isolated settings fixtures only.
set -euo pipefail
cd "$(dirname "$0")/.."
if [ ! -s .build/manual/MihomoGUICore.o ]; then
  printf 'Run bash scripts/build.sh first.\n' >&2
  exit 1
fi
CHECK_DIR="$(mktemp -d "${TMPDIR:-/tmp}/MihomoGUI-interactions.XXXXXX")"
DOWNLOAD_SERVER_PID=""
trap 'if [ -n "$DOWNLOAD_SERVER_PID" ]; then kill "$DOWNLOAD_SERVER_PID" 2>/dev/null || true; wait "$DOWNLOAD_SERVER_PID" 2>/dev/null || true; fi; rm -rf "$CHECK_DIR"' EXIT
python3 scripts/download-fixture.py "$CHECK_DIR/download-port" &
DOWNLOAD_SERVER_PID=$!
cat > "$CHECK_DIR/InteractionChecks.swift" <<'SWIFT'
import Foundation
import Darwin
import SwiftUI
import MihomoGUICore

func check(_ condition: @autoclosure () throws -> Bool, _ message: String) throws {
    if try !condition() { throw MihomoGUIError("CHECK FAILED: " + message) }
}
func expectFailure(_ message: String, _ operation: () throws -> Void) throws {
    do { try operation() } catch { return }
    throw MihomoGUIError("EXPECTED FAILURE: " + message)
}
func expectAsyncFailure(_ operation: () async throws -> Void) async throws {
    do { try await operation() } catch let error as MihomoGUIError {
        try check(error.message.contains("超时"), "process timeout is explicit")
        return
    }
    throw MihomoGUIError("expected process timeout")
}
@main struct InteractionChecks {
    @MainActor static func main() async throws {
        let directory = URL(fileURLWithPath: CommandLine.arguments[1]).appendingPathComponent("fixture")
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: directory) }
        try validateConfigurationCoreVersion("v" + configurationCoreVersion)
        try validateConfigurationCoreVersion(configurationCoreVersion)
        for version in ["v1.19.32", "v1.19.35", "v1.19.34-dirty", "", "unexpected"] {
            try expectFailure("unreviewed core version is rejected") { try validateConfigurationCoreVersion(version) }
        }
        let model = MihomoGUIModel(directory: directory)
        try check(model.error == nil, "isolated model initializes")
        let damaged = directory.appendingPathComponent("damaged")
        try FileManager.default.createDirectory(at: damaged, withIntermediateDirectories: true)
        let original = Data("broken settings fixture".utf8)
        try original.write(to: damaged.appendingPathComponent("settings.json"))
        try saveSettings(Settings(), to: damaged)
        let backups = try FileManager.default.contentsOfDirectory(at: damaged, includingPropertiesForKeys: nil)
            .filter { $0.lastPathComponent.hasPrefix("settings-unreadable-") }
        try check(backups.count == 1, "damaged settings are backed up before replacement")
        try check(try Data(contentsOf: backups[0]) == original, "damaged settings backup preserves original bytes")
        _ = try loadSettings(from: damaged)

        for path in ["type", "type.nested"] {
            let overridden = ManualProxy(type: "ss", fields: [path: .string("direct")])
            try expectFailure("extra fields cannot override protocol") { _ = try overridden.configuration() }
        }
        var controllerSettings = Settings()
        controllerSettings.options = ["secret": .string("")]
        for host in ["127.0.0.1", "127.2.3.4", "[::1]"] {
            controllerSettings.options?["external-controller"] = .string(host + ":19090")
            _ = try controllerEndpoint(controllerSettings)
        }
        for host in ["0.0.0.0", "[::]", "192.0.2.1", "localhost"] {
            controllerSettings.options?["external-controller"] = .string(host + ":19090")
            try expectFailure("non-loopback controller requires authentication") { _ = try controllerEndpoint(controllerSettings) }
            controllerSettings.options?["secret"] = .string("fixture-secret")
            _ = try controllerEndpoint(controllerSettings)
            controllerSettings.options?["secret"] = .string("")
        }
        // Accept a reload request and drop its response, without touching any system service.
        let listener = socket(AF_INET, SOCK_STREAM, 0)
        guard listener >= 0 else { throw MihomoGUIError("fixture socket failed") }
        defer { close(listener) }
        var address = sockaddr_in()
        address.sin_len = UInt8(MemoryLayout<sockaddr_in>.size)
        address.sin_family = sa_family_t(AF_INET)
        address.sin_addr.s_addr = inet_addr("127.0.0.1")
        let bound = withUnsafePointer(to: &address) { pointer in
            pointer.withMemoryRebound(to: sockaddr.self, capacity: 1) { bind(listener, $0, socklen_t(MemoryLayout<sockaddr_in>.size)) }
        }
        guard bound == 0, listen(listener, 4) == 0 else { throw MihomoGUIError("fixture bind failed") }
        var length = socklen_t(MemoryLayout<sockaddr_in>.size)
        let named = withUnsafeMutablePointer(to: &address) { pointer in
            pointer.withMemoryRebound(to: sockaddr.self, capacity: 1) { getsockname(listener, $0, &length) }
        }
        guard named == 0 else { throw MihomoGUIError("fixture port failed") }
        let lostResponse = Task.detached {
            // The schema gate must receive a matching version before reload.
            let versionPeer = accept(listener, nil, nil)
            guard versionPeer >= 0 else { return }
            var request = [UInt8](repeating: 0, count: 4096)
            _ = read(versionPeer, &request, request.count)
            let body = "{\"version\":\"v" + configurationCoreVersion + "\"}"
            let response = "HTTP/1.1 200 OK\r\nContent-Type: application/json\r\nContent-Length: \(body.utf8.count)\r\nConnection: close\r\n\r\n" + body
            _ = response.withCString { write(versionPeer, $0, response.utf8.count) }
            close(versionPeer)
            let peer = accept(listener, nil, nil)
            guard peer >= 0 else { return }
            var bytes = [UInt8](repeating: 0, count: 4096)
            _ = read(peer, &bytes, bytes.count)
            shutdown(peer, SHUT_RDWR)
            close(peer)
            shutdown(listener, SHUT_RDWR)
        }
        let uncertainDirectory = directory.appendingPathComponent("uncertain")
        try FileManager.default.createDirectory(at: uncertainDirectory, withIntermediateDirectories: true)
        var uncertainSettings = Settings()
        uncertainSettings.options = ["external-controller": .string("127.0.0.1:\(UInt16(bigEndian: address.sin_port))")]
        try saveSettings(uncertainSettings, to: uncertainDirectory)
        try saveRuntimeSettings(uncertainSettings, to: uncertainDirectory)
        let uncertainModel = MihomoGUIModel(directory: uncertainDirectory)
        uncertainModel.corePID = 123
        uncertainModel.settings.defaultPolicy = "REJECT"
        for _ in 0..<200 {
            if uncertainModel.error != nil && !uncertainModel.busy { break }
            try await Task.sleep(nanoseconds: 100_000_000)
        }
        try check(uncertainModel.error != nil && uncertainModel.runtimeConfigurationUncertain,
                  "lost reload response leaves running configuration uncertain")
        await lostResponse.value
        uncertainModel.error = nil
        try check(uncertainModel.hasUnappliedChanges, "dismissing an error preserves unapplied state")
        uncertainModel.retryLiveUpdate()
        for _ in 0..<200 {
            if uncertainModel.error != nil && !uncertainModel.busy { break }
            try await Task.sleep(nanoseconds: 100_000_000)
        }
        try check(uncertainModel.error != nil && uncertainModel.runtimeConfigurationUncertain,
                  "explicit retry submits again and retains uncertainty on failure")

        let pendingUpdate = uncertainDirectory.appendingPathComponent("runtime-update-pending")
        try check(FileManager.default.fileExists(atPath: pendingUpdate.path), "unconfirmed reload persists recovery marker")
        let recovered = MihomoGUIModel(directory: uncertainDirectory)
        try check(recovered.runtimeConfigurationUncertain && recovered.hasUnappliedChanges,
                  "reopened GUI preserves interrupted reload recovery state")
        try FileManager.default.removeItem(at: pendingUpdate)
        let confirmed = MihomoGUIModel(directory: uncertainDirectory)
        try check(!confirmed.runtimeConfigurationUncertain, "confirmed configuration needs no recovery marker")

        let commaProxy = ManualProxy(type: "ss", fields: ["name": .string("node,comma"), "server": .string("127.0.0.1"), "port": .integer(1), "cipher": .string("aes-128-gcm"), "password": .string("fixture")])
        try expectFailure("manual proxy names cannot break CSV rule targets") { _ = try commaProxy.configuration() }
        try check(replacingSubRuleTarget("DOMAIN,example.com,no-resolve", old: "no-resolve", new: "renamed") == "DOMAIN,example.com,renamed", "option-like proxy name remains a target")
        try check(replacingSubRuleTarget("DOMAIN,example.com,other,no-resolve", old: "no-resolve", new: "renamed") == "DOMAIN,example.com,other,no-resolve", "option is not mistaken for a proxy reference")
        try check(replacingSubRuleTarget("SUB-RULE,(NETWORK,tcp),old", old: "old", new: "new") == "SUB-RULE,(NETWORK,tcp),old", "sub-rule names are not proxy references")
        let referenceDirectory = directory.appendingPathComponent("proxy-references")
        try FileManager.default.createDirectory(at: referenceDirectory, withIntermediateDirectories: true)
        let referenceModel = MihomoGUIModel(directory: referenceDirectory)
        var referencedProxy = ManualProxy(type: "ss", fields: ["name": .string("old-proxy"), "server": .string("127.0.0.1"), "port": .integer(1), "cipher": .string("aes-128-gcm"), "password": .string("fixture")])
        try referenceModel.saveManualProxy(referencedProxy)
        referenceModel.settings.options = ["dns.enable": .boolean(false), "tun.enable": .boolean(false), "mixed-port": .integer(0), "sub-rules": .object(["nested": .array([.string("DOMAIN,example.com,old-proxy"), .string("IP-CIDR,192.0.2.0/24,old-proxy,no-resolve")])])]
        referencedProxy.fields["name"] = .string("new-proxy")
        try referenceModel.saveManualProxy(referencedProxy)
        let rewritten = referenceModel.settings.options?["sub-rules"]?.object["nested"]?.array.map(\.text)
        try check(rewritten == ["DOMAIN,example.com,new-proxy", "IP-CIDR,192.0.2.0/24,new-proxy,no-resolve"], "proxy rename preserves sub-rule references and options")
        referenceModel.deleteManualProxy(referencedProxy)
        try check(referenceModel.error != nil && referenceModel.settings.manualProxies?.count == 1, "sub-rule references prevent proxy deletion")
        try generateConfig(referenceModel.settings).write(to: URL(fileURLWithPath: CommandLine.arguments[1]).appendingPathComponent("subrule-renamed.yaml"))
        let deletionDirectory = directory.appendingPathComponent("subscription-deletion")
        try FileManager.default.createDirectory(at: deletionDirectory.appendingPathComponent("providers"), withIntermediateDirectories: true)
        let deletionModel = MihomoGUIModel(directory: deletionDirectory)
        let deletedSource = Subscription(name: "fixture", url: "https://example.com/sub")
        deletionModel.settings.subscriptions = [deletedSource]
        deletionModel.settings.subscriptionProxies = [deletedSource.id: []]
        let credentialFile = providerFile(deletedSource, directory: deletionDirectory)
        let credential = Data("fixture credential".utf8)
        try credential.write(to: credentialFile)
        try expectFailure("deletion rollback on write failure") {
            try commitFiles([("settings.json", Data())], directory: deletionDirectory,
                            removing: ["providers/" + deletedSource.id + ".yaml"], write: { _, _ in throw MihomoGUIError("injected failure") })
        }
        try check(try Data(contentsOf: credentialFile) == credential, "failed transaction restores deleted credentials")
        // Fail each write boundary after deleting a credential cache. Both old bytes
        // and newly-created files must recover as one transaction.
        let transactionDirectory = directory.appendingPathComponent("transaction-boundaries")
        try FileManager.default.createDirectory(at: transactionDirectory, withIntermediateDirectories: true)
        let oldSettings = Data("old-settings".utf8)
        let oldCache = Data("old-cache".utf8)
        for failureIndex in 0..<3 {
            try oldSettings.write(to: transactionDirectory.appendingPathComponent("settings.json"))
            try oldCache.write(to: transactionDirectory.appendingPathComponent("cache.yaml"))
            var writeIndex = 0
            try expectFailure("transaction failure at write boundary") {
                try commitFiles([("new.yaml", Data("new".utf8)), ("settings.json", Data("changed".utf8)),
                                 ("last.yaml", Data("last".utf8))], directory: transactionDirectory,
                                removing: ["cache.yaml"], write: { data, destination in
                    defer { writeIndex += 1 }
                    if writeIndex == failureIndex { throw MihomoGUIError("injected boundary failure") }
                    try data.write(to: destination, options: .atomic)
                })
            }
            try check(try Data(contentsOf: transactionDirectory.appendingPathComponent("settings.json")) == oldSettings,
                      "every failure boundary restores existing settings bytes")
            try check(try Data(contentsOf: transactionDirectory.appendingPathComponent("cache.yaml")) == oldCache,
                      "every failure boundary restores deleted cache bytes")
            for name in ["new.yaml", "last.yaml", "file-commit"] {
                try check(!FileManager.default.fileExists(atPath: transactionDirectory.appendingPathComponent(name).path),
                          "failed transaction removes new files and completed journal")
            }
        }
        // Reproduce the on-disk state left by an interrupted process, then recover
        // through the public recovery path twice to verify restart idempotence.
        let journal = transactionDirectory.appendingPathComponent("file-commit")
        try FileManager.default.createDirectory(at: journal, withIntermediateDirectories: false)
        try oldSettings.write(to: journal.appendingPathComponent("old-0"))
        try oldCache.write(to: journal.appendingPathComponent("old-2"))
        try JSONEncoder().encode(["settings.json", "new.yaml", "cache.yaml"]).write(to: journal.appendingPathComponent("manifest.json"))
        try Data().write(to: journal.appendingPathComponent("ready"))
        try Data("partial".utf8).write(to: transactionDirectory.appendingPathComponent("settings.json"))
        try Data("new".utf8).write(to: transactionDirectory.appendingPathComponent("new.yaml"))
        try FileManager.default.removeItem(at: transactionDirectory.appendingPathComponent("cache.yaml"))
        try recoverFileCommit(directory: transactionDirectory)
        try recoverFileCommit(directory: transactionDirectory)
        try check(try Data(contentsOf: transactionDirectory.appendingPathComponent("settings.json")) == oldSettings,
                  "restart restores original settings")
        try check(try Data(contentsOf: transactionDirectory.appendingPathComponent("cache.yaml")) == oldCache,
                  "restart restores removed credential cache")
        try check(!FileManager.default.fileExists(atPath: transactionDirectory.appendingPathComponent("new.yaml").path),
                  "restart removes partially committed new file")
        deletionModel.deleteSubscription(deletedSource)
        try check(deletionModel.error == nil && deletionModel.settings.subscriptions.isEmpty,
                  "subscription deletion commits settings")
        try check(!FileManager.default.fileExists(atPath: credentialFile.path), "subscription deletion removes credential cache")
        try check(try loadSettings(from: deletionDirectory).subscriptions.isEmpty, "subscription deletion persists")
        try expectFailure("transaction rejects removal outside data directory") {
            try commitFiles([], directory: deletionDirectory, removing: ["../outside"])
        }
        let nullSource = directory.appendingPathComponent("null-subscription.yaml")
        try "proxies:\n  - name: null-fixture\n    type: ss\n    explicit-null: null\n    empty-string: ''\n    zero: 0\n    disabled: false\n    values: [null, '', 0, false]\n".write(to: nullSource, atomically: true, encoding: .utf8)
        let nullProxy = try readSubscriptionProxies(nullSource)[0]
        let nullValue = ConfigValue(native: nullProxy)
        try check(nullValue.object["explicit-null"] == .null && nullValue.object["missing"] == nil, "explicit null remains distinct from missing field")
        try check(nullValue.object["values"]?.array == [.null, .string(""), .integer(0), .boolean(false)], "subscription array preserves null, empty, zero and false")
        let nullRoundTrip = try JSONDecoder().decode(ConfigValue.self, from: JSONEncoder().encode(nullValue))
        try check(nullRoundTrip == nullValue, "persistent values round-trip explicit null")
        let nullYAML = String(decoding: try yamlData(["proxy": nullRoundTrip.native]), as: UTF8.self)
        try check(nullYAML.contains("explicit-null: null") && nullYAML.contains("- null"), "generated YAML preserves explicit null")
        let timeoutStart = Date()
        try await expectAsyncFailure {
            _ = try await runCommand("/bin/sh", ["-c", "/bin/sleep 60; echo finished"], timeout: 0.1)
        }
        try check(Date().timeIntervalSince(timeoutStart) < 8, "process group timeout terminates waiting child")
        var expiredRequest: PrivilegedRequest?
        do {
            try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
                let request = PrivilegedRequest(connection: NSXPCConnection(machServiceName: "local.MihomoGUI.timeout-fixture"), continuation: continuation)
                expiredRequest = request
                request.startTimeout(after: 0.05)
            }
            throw MihomoGUIError("XPC request did not time out")
        } catch let error as MihomoGUIError {
            try check(error.message.contains("请求超时"), "XPC timeout reports unknown operation outcome")
        }
        expiredRequest?.finish() // A late reply must not resume the continuation twice.
        let cancelledDirectory = directory.appendingPathComponent("cancelled-subscription")
        try FileManager.default.createDirectory(at: cancelledDirectory, withIntermediateDirectories: true)
        let cancelledModel = MihomoGUIModel(directory: cancelledDirectory)
        let cancelledBefore = try Data(contentsOf: cancelledDirectory.appendingPathComponent("settings.json"))
        cancelledModel.startSubscriptionUpdate(Subscription(name: "cancelled", url: "https://example.invalid/subscription"))
        cancelledModel.cancelSubscriptionUpdate()
        for _ in 0..<100 {
            if !cancelledModel.busy { break }
            try await Task.sleep(nanoseconds: 10_000_000)
        }
        try check(!cancelledModel.busy && cancelledModel.subscriptionUpdatePhase == nil && cancelledModel.error == nil,
                  "subscription cancellation releases task and busy state without error")
        let cancelledAfter = try Data(contentsOf: cancelledDirectory.appendingPathComponent("settings.json"))
        try check(cancelledModel.settings.subscriptions.isEmpty && cancelledAfter == cancelledBefore,
                  "cancelled subscription cannot mutate persisted settings")
        let downloadDirectory = directory.appendingPathComponent("downloads")
        try FileManager.default.createDirectory(at: downloadDirectory, withIntermediateDirectories: true)
        let downloadPort = try String(contentsOf: URL(fileURLWithPath: CommandLine.arguments[1]).appendingPathComponent("download-port"), encoding: .utf8)
        func downloadRequest(_ path: String) throws -> URLRequest {
            guard let url = URL(string: "http://127.0.0.1:" + downloadPort + path) else { throw MihomoGUIError("invalid fixture URL") }
            return URLRequest(url: url)
        }
        let exact = try await downloadLimited(downloadRequest("/exact"), maximumBytes: 1024, directory: downloadDirectory)
        try check(try Data(contentsOf: exact.0).count == 1024, "download accepts exact size limit")
        try FileManager.default.removeItem(at: exact.0)
        for route in ["/declared", "/unknown?token=fixture-private-value", "/empty", "/error"] {
            do {
                let result = try await downloadLimited(downloadRequest(route), maximumBytes: 4096, directory: downloadDirectory)
                try? FileManager.default.removeItem(at: result.0)
                throw MihomoGUIError("invalid download accepted")
            } catch let error as MihomoGUIError {
                try check(!error.message.contains("fixture-private-value") && error.message != "invalid download accepted", "rejected downloads do not expose request credentials")
            }
            try check(try FileManager.default.contentsOfDirectory(atPath: downloadDirectory.path).isEmpty, "failed download removes partial file")
        }
        guard let fixturePort = Int(downloadPort) else { throw MihomoGUIError("invalid fixture port") }
        let oldCore = CoreAPI(secret: "fixture", port: fixturePort)
        do {
            try await oldCore.reload(Data("mixed-port: 0".utf8))
            throw MihomoGUIError("unreviewed API version accepted a reload")
        } catch let failure as MihomoGUIError {
            try check(failure.message.contains("版本与配置字段不匹配"), "mismatched running version reports compatibility error")
        }
        let putCount = try await oldCore.request("/put-count")
        try check(String(data: putCount, encoding: .utf8) == "0", "mismatched running core receives no mutation")
        let cancelRequest = try downloadRequest("/cancel")
        let activeDownload = Task { try await downloadLimited(cancelRequest, maximumBytes: 1024 * 1024, directory: downloadDirectory) }
        for _ in 0..<100 {
            let files = try FileManager.default.contentsOfDirectory(at: downloadDirectory, includingPropertiesForKeys: [.fileSizeKey])
            if let file = files.first, (try file.resourceValues(forKeys: [.fileSizeKey]).fileSize ?? 0) > 0 { break }
            try await Task.sleep(nanoseconds: 10_000_000)
        }
        activeDownload.cancel()
        do {
            let result = try await activeDownload.value
            try? FileManager.default.removeItem(at: result.0)
            throw MihomoGUIError("cancelled download accepted")
        } catch is CancellationError {}
        try check(try FileManager.default.contentsOfDirectory(atPath: downloadDirectory.path).isEmpty, "cancelled streaming download removes partial file")
        let versionDirectory = directory.appendingPathComponent("settings-version")
        try FileManager.default.createDirectory(at: versionDirectory, withIntermediateDirectories: true)
        guard var legacyObject = try JSONSerialization.jsonObject(with: JSONEncoder().encode(Settings())) as? [String: Any] else {
            throw MihomoGUIError("invalid settings fixture")
        }
        legacyObject.removeValue(forKey: "schemaVersion")
        let legacyData = try JSONSerialization.data(withJSONObject: legacyObject)
        try legacyData.write(to: versionDirectory.appendingPathComponent("settings.json"))
        try legacyData.write(to: versionDirectory.appendingPathComponent("runtime.json"))
        let migrated = try loadSettings(from: versionDirectory)
        try check(migrated.schemaVersion == 1, "known unversioned settings migrate in memory")
        try saveSettings(migrated, to: versionDirectory)
        try saveRuntimeSettings(migrated, to: versionDirectory)
        for name in ["settings", "runtime"] {
            try check(try Data(contentsOf: versionDirectory.appendingPathComponent(name + "-v0-backup.json")) == legacyData, "migration preserves original settings bytes")
        }
        legacyObject["schemaVersion"] = 99
        let futureData = try JSONSerialization.data(withJSONObject: legacyObject)
        try futureData.write(to: versionDirectory.appendingPathComponent("settings.json"))
        try futureData.write(to: versionDirectory.appendingPathComponent("runtime.json"))
        try expectFailure("future settings format is rejected") { _ = try loadSettings(from: versionDirectory) }
        try expectFailure("future runtime format is rejected") { _ = try loadRuntimeSettings(from: versionDirectory) }
        try expectFailure("future settings cannot be overwritten") { try saveSettings(Settings(), to: versionDirectory) }
        try expectFailure("future runtime cannot be overwritten") { try saveRuntimeSettings(Settings(), to: versionDirectory) }
        try check(try Data(contentsOf: versionDirectory.appendingPathComponent("settings.json")) == futureData, "future format remains untouched")
        let unsupportedModel = MihomoGUIModel(directory: versionDirectory)
        try check(unsupportedModel.configurationFormatUnsupported, "unknown format disables editing and service changes")
        unsupportedModel.startCore()
        try check(!unsupportedModel.busy, "unknown format cannot start a service")

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
        let providerFields: [String: ConfigValue] = ["behavior": .string("domain"), "payload": .array([.string("example.com")])]
        try model.saveRuleProvider(name: "fixture-set", type: "inline", fields: providerFields, oldName: nil)
        try check(model.settings.options?["rule-providers"]?.object["fixture-set"] != nil, "create provider while core is active")
        let providerRule = RouteRule(kind: .ruleSet, value: "fixture-set", node: nil)
        try model.saveRule(providerRule)
        try model.saveRuleProvider(name: "renamed-set", type: "inline", fields: providerFields, oldName: "fixture-set")
        try check(model.settings.rules.first(where: { $0.id == providerRule.id })?.value == "renamed-set", "renaming provider updates rule reference while active")
        let providerRow = ResourceRow(id: "renamed-set", name: "renamed-set", type: "inline", fields: providerFields)
        model.deleteResource(providerRow, groups: false)
        try check(model.error != nil && model.settings.options?["rule-providers"]?.object["renamed-set"] != nil, "referenced provider cannot be deleted")
        model.error = nil
        model.deleteRule(providerRule.id)
        model.busy = true
        model.deleteResource(providerRow, groups: false)
        try check(model.settings.options?["rule-providers"]?.object["renamed-set"] != nil, "busy provider deletion is blocked")
        try expectFailure("busy provider save") { try model.saveRuleProvider(name: "busy-set", type: "inline", fields: providerFields, oldName: nil) }
        model.busy = false
        model.deleteResource(providerRow, groups: false)
        try check(model.settings.options?["rule-providers"]?.object["renamed-set"] == nil, "delete provider while core is active")
        try check(try loadSettings(from: directory).options?["rule-providers"]?.object["renamed-set"] == nil, "provider deletion persists")
        var fileBefore = model.settings
        fileBefore.options?["rule-providers"] = .object(["file-set": .object(["type": .string("file"), "behavior": .string("domain"), "path": .string("/tmp/old.yaml")])])
        var fileAfter = fileBefore
        // Source path changes are absent from the generated YAML.
        var updatedProviders = fileAfter.options?["rule-providers"]?.object ?? [:]
        var updatedFile = updatedProviders["file-set"]?.object ?? [:]
        updatedFile["path"] = .string("/tmp/new.yaml")
        updatedProviders["file-set"] = .object(updatedFile)
        fileAfter.options?["rule-providers"] = .object(updatedProviders)
        try check(runtimeConfigurationChanged(fileAfter, applied: fileBefore), "file source path changes require application")
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
        var first: MihomoGUIModel? = MihomoGUIModel(directory: directory)
        for _ in 0..<30 {
            await first?.refresh()
            if first?.coreRunning == true { break }
            try await Task.sleep(nanoseconds: 100_000_000)
        }
        try check(first?.coreRunning == true, "GUI model connects to real existing core")
        let controller = try CoreAPI(settings: runtime)
        var selectorSettings = Settings()
        selectorSettings.options = runtime.options
        selectorSettings.options?["dns.enable"] = .boolean(false)
        selectorSettings.options?["tun.enable"] = .boolean(false)
        selectorSettings.options?["mixed-port"] = .integer(0)
        let selectorName = "选择 / fixture"
        selectorSettings.proxyGroups = [ProxyGroup(name: selectorName, targets: ["builtin:DIRECT", "builtin:REJECT"], fields: ["default-selected": .string("builtin:DIRECT")])]
        try await controller.reload(generateConfig(selectorSettings))
        try await controller.selectProxyGroup(selectorName, target: "REJECT")
        try await controller.reload(generateConfig(selectorSettings))
        let cachedSelection = try await controller.proxyGroupSelections()[selectorName]
        try check(cachedSelection == "REJECT", "real cached selection overrides default-selected on reload")
        try await controller.selectProxyGroup(selectorName, target: "DIRECT")
        try await controller.reload(generateConfig(selectorSettings))
        let confirmedSelection = try await controller.proxyGroupSelections()[selectorName]
        try check(confirmedSelection == "DIRECT", "confirmed selection updates the real cache and survives reload")
        do {
            try await controller.selectProxyGroup(selectorName, target: "missing-fixture")
            throw MihomoGUIError("invalid selector member accepted")
        } catch CoreAPIError.http(400) {}
        var filteredSettings = Settings()
        filteredSettings.options = runtime.options
        filteredSettings.options?["dns.enable"] = .boolean(false)
        filteredSettings.options?["tun.enable"] = .boolean(false)
        filteredSettings.options?["mixed-port"] = .integer(0)
        let filterSource = Subscription(name: "fixture", url: "https://example.com/sub")
        filteredSettings.subscriptions = [filterSource]
        func filterProxy(_ name: String) -> ConfigValue {
            .object(["name": .string(name), "type": .string("ss"), "server": .string("127.0.0.1"), "port": .integer(1), "cipher": .string("aes-128-gcm"), "password": .string("fixture")])
        }
        filteredSettings.subscriptionProxies = [filterSource.id: [filterProxy("HongKong-01"), filterProxy("Tokyo-01")]]
        let filteredGroup = ProxyGroup(name: "HK", fields: ["include-all-proxies": .boolean(true), "filter": .string("^HongKong")])
        filteredSettings.proxyGroups = [filteredGroup]
        try check(proxyGroupTargets(filteredGroup, settings: filteredSettings) == ["node:" + Node(provider: filterSource.provider, name: "HongKong-01").id], "group filtering matches original subscription name")
        try await controller.reload(generateConfig(filteredSettings))
        let filteredResponse = try JSONSerialization.jsonObject(with: await controller.request("/proxies/HK")) as? [String: Any]
        try check(filteredResponse?["all"] as? [String] == [subscriptionProxyAlias(sourceIndex: 0, proxyIndex: 0)], "real core group contains matching original-name alias only")
        filteredSettings.proxyGroups?[0].fields = ["include-all-proxies": .boolean(true), "exclude-filter": .string("^HongKong")]
        try await controller.reload(generateConfig(filteredSettings))
        var exclusionResponse = try JSONSerialization.jsonObject(with: await controller.request("/proxies/HK")) as? [String: Any]
        try check(exclusionResponse?["all"] as? [String] == [subscriptionProxyAlias(sourceIndex: 0, proxyIndex: 1)], "real core excludes subscription original name")
        filteredSettings.proxyGroups?[0].fields["default-selected"] = .string("node:" + Node(provider: filterSource.provider, name: "HongKong-01").id)
        try expectFailure("excluded default selection is rejected") { _ = try generateConfig(filteredSettings) }
        filteredSettings.proxyGroups?[0].fields["default-selected"] = nil
        filteredSettings.proxyGroups?[0].fields["exclude-type"] = .string("sHaDoWsOcKs")
        try check(proxyGroupTargets(filteredSettings.proxyGroups![0], settings: filteredSettings) == ["builtin:COMPATIBLE"], "type exclusion exposes actual empty fallback in GUI")
        try await controller.reload(generateConfig(filteredSettings))
        exclusionResponse = try JSONSerialization.jsonObject(with: await controller.request("/proxies/HK")) as? [String: Any]
        try check(exclusionResponse?["all"] as? [String] == ["COMPATIBLE"], "real core matches excluded-type fallback")
        filteredSettings.proxyGroups?[0].targets = ["node:" + Node(provider: filterSource.provider, name: "Tokyo-01").id]
        filteredSettings.proxyGroups?[0].fields = ["exclude-filter": .string("Tokyo"), "empty-fallback": .string("REJECT")]
        try await controller.reload(generateConfig(filteredSettings))
        exclusionResponse = try JSONSerialization.jsonObject(with: await controller.request("/proxies/HK")) as? [String: Any]
        try check(exclusionResponse?["all"] as? [String] == ["REJECT"], "explicit members obey name exclusion and configured fallback")
        filteredSettings.proxyGroups?[0].fields = ["include-all-proxies": .boolean(true)]
        filteredSettings.proxyGroups?[0].fields["filter"] = .string("[")
        try expectFailure("invalid original-name filter is reported") { _ = try generateConfig(filteredSettings) }
        var providerSettings = Settings()
        providerSettings.options = runtime.options
        providerSettings.options?["mixed-port"] = .integer(0)
        providerSettings.options?["tun.enable"] = .boolean(false)
        providerSettings.options?["dns.enable"] = .boolean(false)
        for name in ["live-set", "renamed-live-set", ""] {
            providerSettings.options?["rule-providers"] = .object(name.isEmpty ? [:] : [name: .object([
                "type": .string("inline"), "behavior": .string("domain"),
                "payload": .array([.string("example.com")])
            ])])
            try await controller.reload(generateConfig(providerSettings))
            let response = try JSONSerialization.jsonObject(with: await controller.request("/providers/rules")) as? [String: Any]
            let providers = response?["providers"] as? [String: Any]
            try check(providers != nil, "real core reports providers after reload")
            try check(Set(providers?.keys.map { $0 } ?? []) == Set(name.isEmpty ? [] : [name]), "real core applies provider creation, rename and deletion without restart")
        }
        let sourceRules = directory.appendingPathComponent("source-rules.yaml")
        try "payload:\n  - example.com\n".write(to: sourceRules, atomically: true, encoding: .utf8)
        let fileFields: [String: ConfigValue] = ["type": .string("file"), "behavior": .string("domain"), "path": .string(sourceRules.path)]
        providerSettings.options?["rule-providers"] = .object(["file-set": .object(fileFields)])
        let rulesDirectory = directory.appendingPathComponent("rules")
        let firstFiles = try stageRuleProviderFiles(providerSettings, directory: rulesDirectory)
        try check(firstFiles == ["set-0.yaml"], "live reload stages file provider at generated path")
        try check(try Data(contentsOf: rulesDirectory.appendingPathComponent("set-0.yaml")) == Data(contentsOf: sourceRules), "staged rules preserve source contents")
        try await controller.reload(generateConfig(providerSettings))
        var providersResponse = try JSONSerialization.jsonObject(with: await controller.request("/providers/rules")) as? [String: Any]
        var liveProviders = providersResponse?["providers"] as? [String: Any]
        try check((liveProviders?["file-set"] as? [String: Any])?["ruleCount"] as? Int == 1, "real core loads staged file provider")
        // A new earlier name changes generated indices for existing file providers.
        var mixedProviders = providerSettings.options?["rule-providers"]?.object ?? [:]
        mixedProviders["a-inline"] = .object(["type": .string("inline"), "behavior": .string("domain"), "payload": .array([.string("example.org")])])
        providerSettings.options?["rule-providers"] = .object(mixedProviders)
        let reorderedFiles = try stageRuleProviderFiles(providerSettings, directory: rulesDirectory)
        try check(reorderedFiles == ["set-1.yaml"], "provider index change restages existing local file")
        try await controller.reload(generateConfig(providerSettings))
        providersResponse = try JSONSerialization.jsonObject(with: await controller.request("/providers/rules")) as? [String: Any]
        liveProviders = providersResponse?["providers"] as? [String: Any]
        try check(liveProviders?.count == 2 && (liveProviders?["file-set"] as? [String: Any])?["ruleCount"] as? Int == 1, "real core preserves file provider after index change")
        providerSettings.options?["rule-providers"] = .object([:])
        try await controller.reload(generateConfig(providerSettings))
        let snapshot = try await controller.connectionSnapshot()
        try check(snapshot.uploadTotal == 0 && snapshot.downloadTotal == 0, "real core reports zero cumulative traffic")
        try check(first?.uploadTotal == snapshot.uploadTotal && first?.downloadTotal == snapshot.downloadTotal, "model exposes core totals")
        let memory = try await controller.memory()
        try check(memory >= 0, "real core memory response")
        var sample: CoreTraffic?
        let trafficTask = Task {
            try await controller.traffic { sample = $0 }
        }
        for _ in 0..<30 {
            if sample != nil { break }
            try await Task.sleep(nanoseconds: 100_000_000)
        }
        trafficTask.cancel()
        _ = await trafficTask.result
        try check(sample != nil, "real core traffic stream receives data and cancels")
        let missing = try JSONDecoder().decode(Connections.self, from: Data(#"{"connections":null}"#.utf8))
        try check(missing.uploadTotal == nil && missing.downloadTotal == nil, "missing counters remain unavailable")
        let pid = core.processIdentifier
        first = nil
        try check(core.isRunning && core.processIdentifier == pid, "releasing GUI model leaves core running")
        let reopened = MihomoGUIModel(directory: directory)
        await reopened.refresh()
        try check(reopened.coreRunning && core.processIdentifier == pid, "reopened GUI reconnects without restarting core")
        reopened.startCore()
        try check(!reopened.busy && core.isRunning, "existing core start is a no-op")
        try check(!FileManager.default.fileExists(atPath: directory.appendingPathComponent("traffic.sqlite").path), "monitoring creates no statistics database")
        print("PASS: active-core provider CRUD, reference and busy guards, file-source change detection, staged file reload and index changes, real-core provider reload, routing prefill, priority, atomic batch persistence, duplicate/busy guards, existing service detection, start guard, real-core reconnect, GUI model release, dashboard counters, memory and cancellable traffic")
    }
}
SWIFT
SOURCES=()
for source in Sources/MihomoGUI/*.swift; do
  if [ "$source" != Sources/MihomoGUI/App.swift ]; then SOURCES+=("$source"); fi
done
swiftc -parse-as-library -module-cache-path .build/manual/module-cache \
  -target "$(uname -m)-apple-macosx13.0" -I .build/manual \
  "${SOURCES[@]}" "$CHECK_DIR/InteractionChecks.swift" .build/manual/MihomoGUICore.o \
  -o "$CHECK_DIR/checks"
"$CHECK_DIR/checks" "$CHECK_DIR" "$(uname -m)"
"resources/core/$(uname -m)/mihomo" -t -d "$CHECK_DIR" -f "$CHECK_DIR/config.yaml"
"resources/core/$(uname -m)/mihomo" -t -d "$CHECK_DIR" -f "$CHECK_DIR/subrule-renamed.yaml"
cat > "$CHECK_DIR/PrivilegedChecks.swift" <<'SWIFT'
import Foundation
import Security
import MihomoGUICore

@main struct PrivilegedChecks {
    static func main() throws {
        let decoder = JSONDecoder()
        do {
            _ = try decoder.decode(PrivilegedOperation.self, from: Data(#"{"execute":{"command":"touch /tmp/forbidden"}}"#.utf8))
            throw MihomoGUIError("arbitrary command accepted")
        } catch is DecodingError {}
        let source = URL(fileURLWithPath: CommandLine.arguments[1])
        for name in ["../config.yaml", "set-0.yaml\n/bin/false", "/tmp/other"] {
            do {
                _ = try executeOperation(.prepareRules(staging: source.path, id: UUID(), filenames: [name]), owner: getuid(), coreRequirement: "invalid")
                throw MihomoGUIError("unsafe rule filename accepted")
            } catch let error as MihomoGUIError {
                guard error.message == "规则文件标识无效" else { throw error }
            }
        }
        let target = source.appendingPathComponent("mihomo")
        try FileManager.default.createSymbolicLink(atPath: target.path, withDestinationPath: "/bin/sh")
        do {
            _ = try executeOperation(.install(staging: source.path, settings: Settings()), owner: getuid(), coreRequirement: "invalid")
            throw MihomoGUIError("symlink input accepted")
        } catch let error as MihomoGUIError {
            guard error.message == "无法读取操作输入" else { throw error }
        }
        let core = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
            .appendingPathComponent("dist/MihomoGUI.app/Contents/Helpers/mihomo")
        var code: SecStaticCode?
        var information: CFDictionary?
        guard SecStaticCodeCreateWithPath(core as CFURL, [], &code) == errSecSuccess, let code,
              SecCodeCopySigningInformation(code, [], &information) == errSecSuccess,
              let digest = (information as? [String: Any])?[kSecCodeInfoUnique as String] as? Data else {
            throw MihomoGUIError("missing fixture signature")
        }
        let requirement = "cdhash H\"" + digest.map { String(format: "%02x", $0) }.joined() + "\""
        try verifyCore(at: core, requirement: requirement)
        do {
            try verifyCore(at: core, requirement: "cdhash H\"0000000000000000000000000000000000000000\"")
            throw MihomoGUIError("mismatched core signature accepted")
        } catch let error as MihomoGUIError {
            guard error.message.contains("签名") else { throw error }
        }
        let diagnostic = safePrivilegedDiagnostic(status: 5, output: "password=fixture-private-value\nhttps://example.com/private-subscription\nBootstrap failed: 5: Input/output error\nlast exit code = 78")
        guard diagnostic.contains("launchd 加载失败"), diagnostic.contains("last exit code = 78"),
              !diagnostic.contains("fixture-private-value"), !diagnostic.contains("https://") else {
            throw MihomoGUIError("privileged diagnostics leak input or omit failure category")
        }
        let timeoutStart = Date()
        do {
            _ = try runPrivilegedScript("trap '' TERM; /bin/sleep 60", timeout: 0.1)
            throw MihomoGUIError("privileged script did not time out")
        } catch let error as MihomoGUIError {
            guard error.message.contains("超时"), Date().timeIntervalSince(timeoutStart) < 8 else { throw error }
        }
        let bounded = try runPrivilegedScript("/usr/bin/head -c 65536 /dev/zero; echo 'No space left on device' >&2; exit 7")
        guard bounded.status == 7, bounded.diagnostic.contains("磁盘空间不足") else {
            throw MihomoGUIError("bounded diagnostics lost final failure")
        }
        print("PASS: privileged boundary rejects arbitrary commands, path traversal and symlink inputs")
    }
}
SWIFT
swiftc -parse-as-library -module-cache-path .build/manual/module-cache \
  -target "$(uname -m)-apple-macosx13.0" -I .build/manual \
  Sources/MihomoGUIHelper/Operations.swift "$CHECK_DIR/PrivilegedChecks.swift" .build/manual/MihomoGUICore.o \
  -o "$CHECK_DIR/privileged-checks"
"$CHECK_DIR/privileged-checks" "$CHECK_DIR"
