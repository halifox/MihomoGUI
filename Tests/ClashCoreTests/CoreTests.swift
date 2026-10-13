#if canImport(XCTest)
import XCTest
#endif
import Foundation
@testable import ClashCore

final class CoreTests: XCTestCase {
    func testConfigIgnoresSubscriptionRulesAndOrdersProcessesFirst() throws {
        var settings = Settings()
        let subscription = Subscription(name: "Test", url: "https://example.com/sub?token=secret")
        settings.subscriptions = [subscription]
        let node = Node(provider: subscription.provider, name: "Node [1], \"quoted\"")
        settings.defaultNode = node
        settings.rules = [RouteRule(kind: .suffix, value: "example.com", node: node),
                          RouteRule(kind: .processPath, value: "/Applications/Test App.app/Contents/MacOS/Test", node: nil)]
        let data = try generateConfig(settings)
        XCTAssertTrue(String(decoding: data, as: UTF8.self).contains("https://example.com/"))
        let json = try XCTUnwrap(JSONSerialization.jsonObject(with: data) as? [String: Any])
        XCTAssertEqual(json["mode"] as? String, "rule")
        let rules = try XCTUnwrap(json["rules"] as? [String])
        XCTAssertTrue(rules[0].hasPrefix("PROCESS-PATH,"))
        XCTAssertTrue(rules[1].hasPrefix("DOMAIN-SUFFIX,"))
        XCTAssertEqual(rules.last, "MATCH,CD.Default")
        let groups = try XCTUnwrap(json["proxy-groups"] as? [[String: Any]])
        XCTAssertEqual(groups.first?["empty-fallback"] as? String, "REJECT")
        let regex = try NSRegularExpression(pattern: try XCTUnwrap(groups.first?["filter"] as? String))
        XCTAssertNotNil(regex.firstMatch(in: node.name, range: NSRange(node.name.startIndex..., in: node.name)))
    }

    func testRejectsRuleInjectionAndDeletedSubscription() throws {
        var settings = Settings()
        settings.subscriptions = [Subscription(name: "Test", url: "https://example.com/sub")]
        settings.rules = [RouteRule(kind: .domain, value: "example.com,DIRECT", node: nil)]
        XCTAssertThrowsError(try generateConfig(settings))
        settings.rules = []
        settings.defaultNode = Node(provider: "deleted", name: "Node")
        XCTAssertThrowsError(try generateConfig(settings))
        settings.defaultNode = nil
        settings.subscriptions[0].url = "http://example.com/sub"
        XCTAssertThrowsError(try generateConfig(settings))
    }

    func testTrafficDeltasResetAndPruneInactiveConnections() throws {
        let empty = try JSONDecoder().decode(Connections.self, from: Data("{\"connections\":null}".utf8))
        XCTAssertEqual(empty.connections?.count ?? 0, 0)
        func connection(_ up: Int, _ down: Int) throws -> Connection {
            let object: [String: Any] = ["id": "a", "upload": up, "download": down,
                                       "metadata": ["host": "EXAMPLE.com", "processPath": "/bin/curl"], "chains": ["Node"]]
            return try JSONDecoder().decode(Connection.self, from: JSONSerialization.data(withJSONObject: object))
        }
        var tracker = TrafficTracker()
        let initial = tracker.consume([try connection(100, 200)])
        XCTAssertEqual(initial.first?.domain, "example.com")
        let delta = tracker.consume([try connection(150, 260)])
        XCTAssertEqual(delta.first?.upload, 50); XCTAssertEqual(delta.first?.download, 60)
        XCTAssertTrue(tracker.consume([try connection(150, 260)]).isEmpty)
        XCTAssertEqual(tracker.consume([try connection(10, 20)]).first?.upload, 10)
        _ = tracker.consume([])
        XCTAssertEqual(tracker.activeCount, 0)
    }

    func testSQLiteAggregatesAcrossProcessesAndRetention() throws {
        let dir = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: dir) }
        let url = dir.appendingPathComponent("traffic.sqlite")
        let database = try TrafficDatabase(url: url)
        let now = Date(timeIntervalSince1970: 1_800_000_000)
        let delta = TrafficDelta(domain: "example.com", process: "curl", outbound: "Node", upload: 10, download: 20)
        try database.record([delta], at: now)
        try database.record([delta], at: now)
        let reader = try TrafficDatabase(url: url, readOnly: true)
        let rows = try reader.rows(since: now.addingTimeInterval(-3600))
        XCTAssertEqual(rows.count, 1); XCTAssertEqual(rows.first?.download, 40)
        XCTAssertEqual(try reader.lastSample(), now)
        let other = TrafficDelta(domain: "example.com", process: "browser", outbound: "DIRECT", upload: 5, download: 7)
        try database.record([other], at: now)
        let domains = try reader.domainRows(since: now.addingTimeInterval(-3600))
        XCTAssertEqual(domains.count, 1)
        XCTAssertEqual(domains.first?.upload, 25)
        XCTAssertEqual(domains.first?.download, 47)
        XCTAssertEqual(domains.first?.processCount, 2)
        XCTAssertEqual(domains.first?.outboundCount, 2)
        try database.prune(before: now.addingTimeInterval(3600))
        XCTAssertTrue(try reader.rows(since: .distantPast).isEmpty)
    }

    func testExistingSettingsMigrationAndDirectMatch() throws {
        let old = Data("{\"corePath\":\"/bin/test\",\"secret\":\"test\",\"subscriptions\":[],\"rules\":[],\"tun\":true}".utf8)
        var settings = try JSONDecoder().decode(Settings.self, from: old)
        XCTAssertEqual(settings.defaultDirect, nil)
        settings.subscriptions = [Subscription(name: "Test", url: "https://example.com/sub")]
        settings.defaultDirect = true
        let json = try XCTUnwrap(JSONSerialization.jsonObject(with: generateConfig(settings)) as? [String: Any])
        let groups = try XCTUnwrap(json["proxy-groups"] as? [[String: Any]])
        XCTAssertEqual(groups.last?["proxies"] as? [String], ["DIRECT"])
        XCTAssertEqual(json["rules"] as? [String], ["MATCH,CD.Default"])
        var node = Node(provider: "subscription-fixture", name: "First")
        let original = node
        node.protocolName = "Http"; node.delayMilliseconds = 42
        XCTAssertEqual(node, original)
        let restored = try JSONDecoder().decode(Node.self, from: JSONEncoder().encode(node))
        XCTAssertEqual(restored.delayMilliseconds, 42)
    }

    static var allTests = [
        ("testConfigIgnoresSubscriptionRulesAndOrdersProcessesFirst", testConfigIgnoresSubscriptionRulesAndOrdersProcessesFirst),
        ("testRejectsRuleInjectionAndDeletedSubscription", testRejectsRuleInjectionAndDeletedSubscription),
        ("testTrafficDeltasResetAndPruneInactiveConnections", testTrafficDeltasResetAndPruneInactiveConnections),
        ("testSQLiteAggregatesAcrossProcessesAndRetention", testSQLiteAggregatesAcrossProcessesAndRetention),
        ("testExistingSettingsMigrationAndDirectMatch", testExistingSettingsMigrationAndDirectMatch)
    ]
}
