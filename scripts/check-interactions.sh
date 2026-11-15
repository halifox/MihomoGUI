#!/bin/bash
# Run after bash scripts/build.sh. Uses isolated settings and SQLite fixtures only.
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
import CSQLite
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
        let database = try TrafficDatabase(url: directory.appendingPathComponent("traffic.sqlite"))
        let now = Date()
        let json = #"{"id":"fixture","metadata":{"host":"api.example.com","sourceIP":"2001:db8::2","sourcePort":"12345","destinationIP":"192.0.2.1","destinationPort":"443","processPath":"/Applications/Fixture.app/Contents/MacOS/Fixture","network":"tcp","type":"TUN"},"upload":10,"download":20,"chains":["DIRECT"],"rule":"Domain","rulePayload":"api.example.com"}"#
        let connection = try JSONDecoder().decode(Connection.self, from: Data(json.utf8))
        var tracker = TrafficTracker()
        try database.record(tracker.consume([connection]), at: now)
        let injection = "quote' or 1=1 --"
        var delta = tracker.consume([connection])
        try check(delta.isEmpty, "no repeated traffic counted")
        let otherJSON: [String: Any] = ["id": "second", "metadata": ["host": injection, "process": "other", "destinationIP": "2001:db8::1", "destinationPort": "53"], "upload": 5, "download": 6, "chains": ["REJECT"]]
        let other = try JSONDecoder().decode(Connection.self, from: JSONSerialization.data(withJSONObject: otherJSON))
        delta = tracker.consume([connection, other])
        try database.record(delta, at: now)
        for grouping in TrafficGrouping.allCases {
            let value = grouping.key(for: connection)
            let rows = try database.rows(since: now.addingTimeInterval(-3600), matching: grouping, value: value)
            try check(rows.count == 1 && rows[0].upload == 10 && rows[0].download == 20, "filtered detail query: " + grouping.rawValue)
            try check(rows[0].ip == "192.0.2.1" && rows[0].port == "443", "detail preserves IP and port")
        }
        let exact = try database.rows(since: now.addingTimeInterval(-3600), matching: .domain, value: injection)
        try check(exact.count == 1 && exact[0].domain == injection, "filter uses bound parameter")
        try expectFailure("incomplete filter") { _ = try database.rows(since: now, matching: .domain) }
        let limited = try database.rows(since: now.addingTimeInterval(-3600), limit: 1)
        try check(limited.count == 1 && limited[0].domain == "api.example.com", "detail ranks before limit")
        await model.refreshStatistics()
        try check(model.traffic.count == 2 && model.statisticsError == nil && model.statisticsLoaded, "statistics refresh success")
        try FileManager.default.moveItem(at: directory.appendingPathComponent("traffic.sqlite"), to: directory.appendingPathComponent("saved.sqlite"))
        model.connectionsError = "fixture error" // force a missing database to be reported
        await model.refreshStatistics()
        try check(model.traffic.count == 2 && model.statisticsError != nil, "statistics failure preserves previous rows and reports error")
        let legacy = directory.appendingPathComponent("legacy.sqlite")
        var raw: OpaquePointer?
        try check(sqlite3_open(legacy.path, &raw) == SQLITE_OK, "legacy fixture opens")
        let sql = "CREATE TABLE traffic(bucket INTEGER,domain TEXT,process TEXT,outbound TEXT,upload INTEGER,download INTEGER); INSERT INTO traffic VALUES(\(Int64(now.timeIntervalSince1970)/3600*3600),'legacy.example','legacy','DIRECT',7,9);"
        try check(sqlite3_exec(raw, sql, nil, nil, nil) == SQLITE_OK, "legacy fixture created")
        sqlite3_close(raw)
        let old = try TrafficDatabase(url: legacy, readOnly: true)
        let oldRows = try old.rows(since: now.addingTimeInterval(-3600), matching: .ip, value: "未知 IP")
        try check(oldRows.count == 1 && oldRows[0].ip == "未知 IP" && oldRows[0].port == "未知端口", "known legacy schema keeps explicit missing data")
        try model.addRules([
            RouteRule(kind: .sourceCIDR, value: "2001:db8::2/128", node: nil),
            RouteRule(kind: .and, value: "((PROCESS-PATH,/Applications/Fixture (Test).app/Contents/MacOS/Fixture (Test)),(DOMAIN,api.example.com))", node: nil),
            RouteRule(kind: .and, value: "((PROCESS-NAME,Fixture),(DST-PORT,443))", node: nil)
        ], atTop: true)
        try generateConfig(model.settings).write(to: URL(fileURLWithPath: CommandLine.arguments[1]).appendingPathComponent("config.yaml"), options: .atomic)
        print("PASS: routing prefill, priority, atomic batch persistence, duplicate/busy guards, all four detail filters, bound SQL, limits, legacy schema, and refresh error retention")
    }
}
SWIFT
SOURCES=()
for source in Sources/ClashDesk/*.swift; do
  if [ "$source" != Sources/ClashDesk/App.swift ]; then SOURCES+=("$source"); fi
done
swiftc -parse-as-library -module-cache-path .build/manual/module-cache \
  -target "$(uname -m)-apple-macosx13.0" -I .build/manual -I Sources/CSQLite \
  "${SOURCES[@]}" "$CHECK_DIR/InteractionChecks.swift" .build/manual/ClashCore.o \
  -lsqlite3 -o "$CHECK_DIR/checks"
"$CHECK_DIR/checks" "$CHECK_DIR"
"resources/core/$(uname -m)/mihomo" -t -d "$CHECK_DIR" -f "$CHECK_DIR/config.yaml"
