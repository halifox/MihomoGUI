#if canImport(XCTest)
import XCTest
#endif
import Foundation
@testable import ClashCore

final class CoreTests: XCTestCase {
    func testConfigIgnoresSubscriptionRulesAndKeepsTableOrder() throws {
        var settings = Settings()
        let subscription = Subscription(name: "Test", url: "https://example.com/sub?token=secret")
        settings.subscriptions = [subscription]
        let node = Node(provider: subscription.provider, name: "Node [1], \"quoted\"")
        settings.defaultNode = node
        settings.rules = [RouteRule(kind: .suffix, value: "example.com", node: node),
                          RouteRule(kind: .processPath, value: "/Applications/Test App.app/Contents/MacOS/Test", node: nil)]
        let data = try generateConfig(settings)
        XCTAssertTrue(String(decoding: data, as: UTF8.self).contains("https://example.com/"))
        XCTAssertTrue(String(decoding: data, as: UTF8.self).hasPrefix("mode: rule\n"))
        let json = try configurationObject(settings)
        XCTAssertEqual(json["mode"] as? String, "rule")
        XCTAssertEqual(json["log-level"] as? String, "info")
        XCTAssertEqual(json["unified-delay"] as? Bool, true)
        let tun = try XCTUnwrap(json["tun"] as? [String: Any])
        XCTAssertEqual(tun["stack"] as? String, "mips")
        XCTAssertEqual(tun["device"] as? String, "utun1024")
        XCTAssertEqual(tun["mtu"] as? Int, 1500)
        let dns = try XCTUnwrap(json["dns"] as? [String: Any])
        XCTAssertEqual(dns["respect-rules"] as? Bool, true)
        XCTAssertEqual(dns["nameserver"] as? [String], ["223.5.5.5", "119.29.29.29", "114.114.114.114"])
        let rules = try XCTUnwrap(json["rules"] as? [String])
        XCTAssertTrue(rules[0].hasPrefix("DOMAIN-SUFFIX,"))
        XCTAssertTrue(rules[1].hasPrefix("PROCESS-PATH,"))
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
        let json = try configurationObject(settings)
        let groups = try XCTUnwrap(json["proxy-groups"] as? [[String: Any]])
        XCTAssertEqual(groups.last?["proxies"] as? [String], ["DIRECT"])
        XCTAssertEqual(json["rules"] as? [String], ["MATCH,CD.Default"])
        var node = Node(provider: "subscription-fixture", name: "First")
        let original = node
        node.protocolName = "Http"; node.delayMilliseconds = 42
        XCTAssertEqual(node, original)
        let restored = try JSONDecoder().decode(Node.self, from: JSONEncoder().encode(node))
        XCTAssertEqual(restored.delayMilliseconds, 42)
        XCTAssertEqual(settings.ruleOrderMigrated, nil)
        settings.rules = [RouteRule(kind: .domain, value: "example.com", node: nil), RouteRule(kind: .processName, value: "curl", node: nil)]
        let migratedRules = try configurationObject(settings)["rules"] as! [String]
        XCTAssertTrue(migratedRules[0].hasPrefix("PROCESS-NAME,"))
    }

    func testManualHysteria2AndNestedGeneralOptions() throws {
        let schema = try XCTUnwrap(documentSchemas.proxies.first { $0.key == "hysteria2" })
        XCTAssertTrue(schema.fields.contains { $0.path == "realm-opts.server-url" })
        XCTAssertTrue(schema.fields.contains { $0.path == "obfs-password" })
        XCTAssertTrue(!schema.fields.contains { $0.path == "client-fingerprint" || $0.path.hasPrefix("smux.") })
        let vless = try XCTUnwrap(documentSchemas.proxies.first { $0.key == "vless" })
        XCTAssertTrue(!vless.fields.contains { $0.path == "alterId" || $0.path == "cipher" })
        XCTAssertTrue(vless.fields.contains { $0.path == "ech-opts.enable" })
        XCTAssertEqual(ConfigValue(native: 1), .integer(1))
        XCTAssertEqual(ConfigValue(native: true), .boolean(true))
        let proxy = ManualProxy(type: "hysteria2", fields: [
            "name": .string("日本,手动"), "server": .string("127.0.0.1"), "port": .integer(443),
            "password": .string("fixture-only"), "sni": .string("example.com"),
            "realm-opts.enable": .boolean(false)
        ])
        var settings = Settings(); settings.manualProxies = [proxy]; settings.defaultNode = proxy.node
        settings.options = ["mixed-port": .integer(8000), "tun.mtu": .integer(1400), "dns.enable": .boolean(false),
                            "dns.nameserver-policy": .object(["+.example.com": .array([.string("1.1.1.1")])]),
                            "sniffer.enable": .boolean(true), "sniffer.sniff.HTTP.ports": .array([.integer(80), .string("8080-8880")])]
        let object = try configurationObject(settings)
        XCTAssertEqual(object["mixed-port"] as? Int, 8000)
        XCTAssertEqual(configPath("tun.mtu", in: object) as? Int, 1400)
        let proxies = try XCTUnwrap(object["proxies"] as? [[String: Any]])
        XCTAssertEqual(proxies.first?["type"] as? String, "hysteria2")
        XCTAssertEqual(configPath("realm-opts.enable", in: proxies[0]) as? Bool, false)
        let groups = object["proxy-groups"] as! [[String: Any]]
        XCTAssertEqual(groups[0]["proxies"] as? [String], [proxy.name])
        settings.manualProxies = [proxy, proxy]
        XCTAssertThrowsError(try generateConfig(settings))
        settings.manualProxies = [proxy]; settings.options?["mixed-port"] = .string("not a port")
        XCTAssertThrowsError(try generateConfig(settings))
    }

    func testCIDRRuleOptionsAndLogicalValidation() throws {
        var settings = Settings(); settings.defaultDirect = true
        var cidr = RouteRule(kind: .ipCIDR, value: "192.168.1.0/24", node: nil)
        cidr.noResolve = true; cidr.sourceIP = true; cidr.builtin = "REJECT"
        settings.rules = [cidr, RouteRule(kind: .network, value: "udp", node: nil)]
        let rules = try configurationObject(settings)["rules"] as! [String]
        XCTAssertEqual(rules[0], "IP-CIDR,192.168.1.0/24,REJECT,no-resolve,src")
        XCTAssertTrue(validCIDR("2001:db8::/64"))
        XCTAssertTrue(!validCIDR("192.168.1.0/40"))
        XCTAssertThrowsError(try validateRule(RouteRule(kind: .ipCIDR, value: "bad/24", node: nil), settings: settings))
        XCTAssertThrowsError(try validateRule(RouteRule(kind: .destinationPort, value: "9000-80", node: nil), settings: settings))
        XCTAssertThrowsError(try validateRule(RouteRule(kind: .and, value: "((DOMAIN,example.com)", node: nil), settings: settings))
        settings.options = ["rule-providers": .object(["fixture": .object(["type": .string("inline"), "behavior": .string("domain"), "payload": .array([.string("+.example.com")])])])]
        settings.rules = [RouteRule(kind: .ruleSet, value: "fixture", node: nil)]
        _ = try generateConfig(settings)
    }

    func testRuntimeSettingsStayIndependentOfDraftEdits() throws {
        let directory = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: directory) }
        var active = Settings(); active.options = ["external-controller": .string("127.0.0.1:19191"), "secret": .string("active-fixture")]
        try saveRuntimeSettings(active, to: directory)
        var draft = active; draft.options?["external-controller"] = .string("127.0.0.1:19292"); draft.options?["secret"] = .string("draft-fixture")
        try saveSettings(draft, to: directory)
        let endpoint = try controllerEndpoint(loadRuntimeSettings(from: directory))
        XCTAssertEqual(endpoint.port, 19191); XCTAssertEqual(endpoint.secret, "active-fixture")
        draft.options?["external-controller"] = .string("")
        XCTAssertThrowsError(try generateConfig(draft))
    }

    static var allTests = [
        ("testConfigIgnoresSubscriptionRulesAndKeepsTableOrder", testConfigIgnoresSubscriptionRulesAndKeepsTableOrder),
        ("testRejectsRuleInjectionAndDeletedSubscription", testRejectsRuleInjectionAndDeletedSubscription),
        ("testTrafficDeltasResetAndPruneInactiveConnections", testTrafficDeltasResetAndPruneInactiveConnections),
        ("testSQLiteAggregatesAcrossProcessesAndRetention", testSQLiteAggregatesAcrossProcessesAndRetention),
        ("testExistingSettingsMigrationAndDirectMatch", testExistingSettingsMigrationAndDirectMatch),
        ("testManualHysteria2AndNestedGeneralOptions", testManualHysteria2AndNestedGeneralOptions),
        ("testCIDRRuleOptionsAndLogicalValidation", testCIDRRuleOptionsAndLogicalValidation),
        ("testRuntimeSettingsStayIndependentOfDraftEdits", testRuntimeSettingsStayIndependentOfDraftEdits)
    ]
}
