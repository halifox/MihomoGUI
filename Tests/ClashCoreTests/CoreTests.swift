#if canImport(XCTest)
import XCTest
#endif
import Foundation
import CSQLite
@testable import ClashCore

final class CoreTests: XCTestCase {
    func testConfigIgnoresSubscriptionRulesAndKeepsTableOrder() throws {
        var settings = Settings()
        let subscription = Subscription(name: "Test", url: "https://example.com/sub?token=secret")
        settings.subscriptions = [subscription]
        let node = Node(provider: subscription.provider, name: "Node [1], \"quoted\"")
        settings.defaultNode = node
        settings.subscriptionProxies = [subscription.id: [.object(["name": .string(node.name), "type": .string("http"), "server": .string("127.0.0.1"), "port": .integer(8080)])]]
        settings.rules = [RouteRule(kind: .suffix, value: "example.com", node: node),
                          RouteRule(kind: .processPath, value: "/Applications/Test App.app/Contents/MacOS/Test", node: nil)]
        let data = try generateConfig(settings)
        XCTAssertTrue(!String(decoding: data, as: UTF8.self).contains(subscription.url))
        XCTAssertTrue(!String(decoding: data, as: UTF8.self).contains(subscription.id))
        XCTAssertTrue(!String(decoding: data, as: UTF8.self).contains("proxy-providers:"))
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
        XCTAssertEqual(groups.first?["proxies"] as? [String], ["CD.Proxy.0.0"])
        let proxies = try XCTUnwrap(json["proxies"] as? [[String: Any]])
        XCTAssertEqual(proxies.first?["server"] as? String, "127.0.0.1")
        let second = Subscription(name: "Other", url: "https://example.net/private")
        settings.subscriptions.append(second)
        let duplicated = settings.subscriptionProxies?[subscription.id]
        settings.subscriptionProxies?[second.id] = duplicated
        let collision = try configurationObject(settings)["proxies"] as! [[String: Any]]
        XCTAssertEqual(collision.map { $0["name"] as! String }, ["CD.Proxy.0.0", "CD.Proxy.1.0"])

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
        let legacyURL = dir.appendingPathComponent("legacy.sqlite")
        var legacy: OpaquePointer?
        XCTAssertEqual(sqlite3_open(legacyURL.path, &legacy), SQLITE_OK)
        XCTAssertEqual(sqlite3_exec(legacy, """
            CREATE TABLE traffic (bucket INTEGER NOT NULL, domain TEXT NOT NULL, process TEXT NOT NULL,
                outbound TEXT NOT NULL, upload INTEGER NOT NULL, download INTEGER NOT NULL,
                PRIMARY KEY(bucket,domain,process,outbound)) WITHOUT ROWID;
            CREATE TABLE collector (id INTEGER PRIMARY KEY, sampled_at INTEGER NOT NULL);
            INSERT INTO traffic VALUES(1800000000,'old.example','curl','DIRECT',11,22);
            """, nil, nil, nil), SQLITE_OK)
        sqlite3_close(legacy)
        do {
            let oldReader = try TrafficDatabase(url: legacyURL, readOnly: true)
            XCTAssertEqual(try oldReader.groupedRows(since: .distantPast, by: .ip).first?.domain, "未知 IP")
            let migrated = try TrafficDatabase(url: legacyURL)
            XCTAssertEqual(try migrated.domainRows(since: .distantPast).first?.download, 22)
            XCTAssertEqual(try migrated.groupedRows(since: .distantPast, by: .port).first?.domain, "未知端口")
            try migrated.record([TrafficDelta(domain: "old.example", process: "curl", outbound: "DIRECT", upload: 1, download: 2, ip: "1.1.1.1", port: "443")], at: Date(timeIntervalSince1970: 1800000000))
            XCTAssertEqual(try migrated.domainRows(since: .distantPast).first?.download, 24)
        }
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
        let detailed = TrafficDelta(domain: "example.com", process: "curl", outbound: "Node", upload: 3, download: 4, ip: "1.2.3.4", port: "443")
        let secondIP = TrafficDelta(domain: "example.com", process: "curl", outbound: "Node", upload: 6, download: 8, ip: "1.2.3.5", port: "443")
        try database.record([detailed, secondIP], at: now)
        let ips = try reader.groupedRows(since: .distantPast, by: .ip)
        XCTAssertEqual(Set(ips.map(\.domain)), ["未知 IP", "1.2.3.4", "1.2.3.5"])
        XCTAssertEqual(ips.first { $0.domain == "1.2.3.4" }?.download, 4)
        let ports = try reader.groupedRows(since: .distantPast, by: .port)
        XCTAssertEqual(ports.first { $0.domain == "443" }?.download, 12)
        let processes = try reader.groupedRows(since: .distantPast, by: .process)
        XCTAssertEqual(processes.first { $0.domain == "curl" }?.upload, 29)
        XCTAssertEqual(try reader.domainRows(since: .distantPast).first?.download, 59)
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

    func testPlatformSpecificGeneralOptions() throws {
        let fields = documentSchemas.sections.flatMap(\.fields)
        XCTAssertTrue(!documentSchemas.configuration.contains { $0.path == "proxies" })
        XCTAssertTrue(documentSchemas.configuration.contains { $0.path == "unified-delay" })
        XCTAssertTrue(fields.contains { $0.path == "unified-delay" })
        XCTAssertEqual(try XCTUnwrap(fields.first { $0.path == "tun.udp-timeout" }).defaultHint, "300")
        XCTAssertEqual(try XCTUnwrap(fields.first { $0.path == "global-ua" }).defaultHint, "clash.meta")
        for path in ["port", "redir-port", "tproxy-port", "dns.fake-ip-range", "interface-name"] {
            XCTAssertTrue(try XCTUnwrap(fields.first { $0.path == path }).defaultHint == nil)
        }
        for section in documentSchemas.sections {
            for field in section.fields {
                let document = ["port", "socks-port", "mixed-port", "redir-port", "tproxy-port"].contains(field.path) ? "inbound/port.md" : section.document
                let leaf = field.path.split(separator: ".").last!.lowercased()
                let help = documentedFieldHelp[document + "|" + field.path] ?? documentedFieldHelp[document + "|" + leaf] ?? field.description
                XCTAssertTrue(!help.isEmpty)
            }
        }
        XCTAssertTrue(try XCTUnwrap(fields.first { $0.path == "redir-port" }).unavailableReason == nil)
        for path in ["tproxy-port", "routing-mark", "external-controller-pipe", "external-controller-routing-mark",
                     "tun.auto-redirect", "tun.include-uid", "tun.include-package", "tun.include-mac-address",
                     "tun.iproute2-table-index", "tun.route-address-set"] {
            XCTAssertNotNil(try XCTUnwrap(fields.first { $0.path == path }).unavailableReason)
        }
        XCTAssertTrue(try XCTUnwrap(fields.first { $0.path == "tun.inet4-route-address" }).unavailableReason == nil)
        var settings = Settings()
        settings.options = ["redir-port": .integer(7892), "tproxy-port": .integer(7893),
                            "tun.include-uid": .array([.integer(1000)])]
        let config = try configurationObject(settings)
        XCTAssertEqual(config["redir-port"] as? Int, 7892)
        XCTAssertEqual(config["tproxy-port"] as? Int, 7893)
        XCTAssertEqual(configPath("tun.include-uid", in: config) as? [Int], [1000])
        for port in ["redir-port", "tproxy-port"] {
            XCTAssertThrowsError(try validateGeneralOptions([port: -1]))
            XCTAssertThrowsError(try validateGeneralOptions([port: 65536]))
        }
    }

    func testManualHysteria2AndNestedGeneralOptions() throws {
        let schema = try XCTUnwrap(documentSchemas.proxies.first { $0.key == "hysteria2" })
        XCTAssertTrue(schema.fields.contains { $0.path == "realm-opts.server-url" })
        XCTAssertTrue(schema.fields.contains { $0.path == "obfs-password" })
        XCTAssertTrue(!schema.fields.contains { $0.path == "client-fingerprint" || $0.path.hasPrefix("smux.") })
        let vless = try XCTUnwrap(documentSchemas.proxies.first { $0.key == "vless" })
        XCTAssertTrue(!vless.fields.contains { $0.path == "alterId" || $0.path == "cipher" })
        XCTAssertTrue(vless.fields.contains { $0.path == "ech-opts.enable" })
        XCTAssertTrue((documentedFieldHelp["general.md|unified-delay"] ?? "").contains("RTT"))
        XCTAssertTrue((documentedFieldHelp["general.md|bind-address"] ?? "").contains("绑定地址"))
        XCTAssertTrue((documentedFieldHelp["general.md|store-selected"] ?? "").contains("策略组"))
        XCTAssertTrue((documentedFieldHelp["rule-providers/index.md|behavior"] ?? "").contains("domain"))
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
        let firstGroup = ProxyGroup(name: "Choose", targets: ["node:" + proxy.node.id], fields: ["default-selected": .string("node:" + proxy.node.id)])
        let balance = ProxyGroup(name: "Balance", type: "load-balance", targets: ["group:Choose"], fields: ["strategy": .string("round-robin")])
        settings.proxyGroups = [firstGroup, balance]; settings.defaultProxyGroup = "Balance"
        let grouped = try configurationObject(settings)
        let customGroups = try XCTUnwrap(grouped["proxy-groups"] as? [[String: Any]])
        XCTAssertTrue(customGroups.contains { $0["name"] as? String == "Choose" && $0["default-selected"] as? String == proxy.name })
        XCTAssertEqual(customGroups.last?["proxies"] as? [String], ["Balance"])
        settings.proxyGroups?[0].targets = ["group:Balance"]
        XCTAssertThrowsError(try generateConfig(settings))
        settings.proxyGroups = [firstGroup, balance]
        settings.options?["rule-providers"] = .object(["TestRules": .object(["type": .string("inline"), "behavior": .string("domain"), "payload": .array([.string("+.example.org")])])])
        var groupRule = RouteRule(kind: .ruleSet, value: "TestRules", node: nil); groupRule.proxyGroup = "Choose"
        settings.rules = [groupRule]
        XCTAssertEqual((try configurationObject(settings)["rules"] as? [String])?.first, "RULE-SET,TestRules,Choose")
        settings.proxyGroups = []; XCTAssertThrowsError(try generateConfig(settings))
        settings.proxyGroups = nil; settings.defaultProxyGroup = nil; settings.rules = []; settings.options?.removeValue(forKey: "rule-providers")
        let usage = SubscriptionUsage(header: "upload=100; download=200; total=1000; expire=1800000000")
        XCTAssertEqual(usage.used, 300)
        XCTAssertEqual(usage.remaining, 700)
        XCTAssertEqual(usage.expiresAt, Date(timeIntervalSince1970: 1800000000))
        let partial = SubscriptionUsage(header: "upload=bad; download=-1; total=100; expire=0")
        XCTAssertEqual(partial.used, nil)
        XCTAssertEqual(partial.expiresAt, nil)
        XCTAssertEqual(SubscriptionUsage(header: "upload=100;download=200;total=10").remaining, 0)
        settings.subscriptions = [Subscription(name: "Usage", url: "https://example.org/sub")]
        settings.subscriptions[0].usage = usage
        let persistedUsage = try JSONDecoder().decode(Settings.self, from: JSONEncoder().encode(settings))
        XCTAssertEqual(persistedUsage.subscriptions[0].usage, usage)
        let applied = settings
        XCTAssertTrue(!runtimeConfigurationChanged(settings, applied: applied))
        settings.delayTestTimeoutMilliseconds = 9000
        XCTAssertTrue(!runtimeConfigurationChanged(settings, applied: applied))
        settings.options?["unified-delay"] = .boolean(false)
        XCTAssertTrue(runtimeConfigurationChanged(settings, applied: applied))
        settings.options?.removeValue(forKey: "unified-delay")
        settings.corePath = "/tmp/different-mihomo"
        XCTAssertTrue(runtimeConfigurationChanged(settings, applied: applied))
        settings.corePath = applied.corePath; settings.delayTestTimeoutMilliseconds = nil
        XCTAssertEqual(try settings.delayTestParameters().timeout, 5000)
        settings.delayTestURL = "https://example.org/health"
        settings.delayTestTimeoutMilliseconds = 25000
        let restored = try JSONDecoder().decode(Settings.self, from: JSONEncoder().encode(settings))
        XCTAssertEqual(try restored.delayTestParameters().url, "https://example.org/health")
        XCTAssertEqual(try restored.delayTestParameters().timeout, 25000)
        XCTAssertTrue(!String(decoding: try generateConfig(restored), as: UTF8.self).contains("https://example.org/health"))
        settings.delayTestTimeoutMilliseconds = 0
        XCTAssertThrowsError(try settings.delayTestParameters())
        settings.delayTestTimeoutMilliseconds = 5000; settings.delayTestURL = "file:///tmp/test"
        XCTAssertThrowsError(try settings.delayTestParameters())
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

    func testEmptyChoiceValidationAndOmission() throws {
        let required = EditorField("behavior", kind: "choice", required: true, choices: ["domain"])
        XCTAssertThrowsError(try validateFieldValues([:], schema: [required]))
        XCTAssertThrowsError(try validateFieldValues(["behavior": .string("")], schema: [required]))
        try validateFieldValues(["behavior": .string("domain")], schema: [required])
        let ipVersion = documentSchemas.proxies.first { $0.key == "http" }!.fields.first { $0.path == "ip-version" }!
        XCTAssertEqual(ipVersion.defaultHint, "dual")
        for (path, expected) in [("mode", "rule"), ("find-process-mode", "strict"), ("geodata-loader", "memconservative")] {
            XCTAssertEqual(documentSchemas.sections.flatMap(\.fields).first { $0.path == path }?.defaultHint, expected)
        }
        XCTAssertEqual(groupEditorFields("select").first { $0.path == "empty-fallback" }?.defaultHint, "REJECT")
        let dnsMode = documentSchemas.sections.flatMap(\.fields).first { $0.path == "dns.enhanced-mode" }!
        XCTAssertEqual(dnsMode.defaultHint, "redir-host")
        XCTAssertEqual(ruleProviderEditorFields("http").first { $0.path == "format" }?.defaultHint, "yaml")
        let optional = EditorField("mode", kind: "choice", choices: ["rule"])
        XCTAssertEqual(emptyValue(optional), .string(""))
        try validateFieldValues(["mode": .string("")], schema: [optional])
        let proxy = ManualProxy(type: "http", fields: ["name": .string("Test"), "server": .string("127.0.0.1"), "port": .integer(8080), "ip-version": .string("")])
        XCTAssertTrue(try proxy.configuration()["ip-version"] == nil)
        let hysteria = ManualProxy(type: "hysteria2", fields: ["name": .string("Test"), "server": .string("127.0.0.1"), "port": .integer(443), "password": .string("test"), "obfs": .string("")])
        XCTAssertTrue(try hysteria.configuration()["obfs"] == nil)
        var settings = Settings(); settings.defaultDirect = true; settings.options = ["mode": .string("")]
        XCTAssertTrue(try configurationObject(settings)["mode"] == nil)
        settings.proxyGroups = [ProxyGroup(name: "Test", targets: ["builtin:DIRECT"], fields: ["default-selected": .string("")])]
        let groups = try configurationObject(settings)["proxy-groups"] as! [[String: Any]]
        XCTAssertTrue(groups.first { $0["name"] as? String == "Test" }?["default-selected"] == nil)
    }

    func testSubscriptionRejectsAliasesAndDeepNesting() throws {
        let directory = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: directory) }
        let file = directory.appendingPathComponent("nodes.yaml")
        try "proxies: &p\n  - name: loop\n    type: ss\n    extra: *p\n".write(to: file, atomically: true, encoding: .utf8)
        XCTAssertThrowsError(try readSubscriptionProxies(file))
        let nested = "proxies:\n  - name: deep\n    type: ss\n    extra: " + String(repeating: "[", count: 70) + "0" + String(repeating: "]", count: 70) + "\n"
        try nested.write(to: file, atomically: true, encoding: .utf8)
        XCTAssertThrowsError(try readSubscriptionProxies(file))
        try "proxies:\n  - name: valid\n    type: ss\n    server: localhost\n    port: 443\n".write(to: file, atomically: true, encoding: .utf8)
        XCTAssertEqual(try readSubscriptionProxies(file).count, 1)
    }
    func testFileCommitRestoresAllFilesAfterWriteFailure() throws {
        let directory = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: directory) }
        let old = Data("old".utf8), new = Data("new".utf8)
        try old.write(to: directory.appendingPathComponent("settings.json"))
        var writes = 0
        XCTAssertThrowsError(try commitFiles([("settings.json", new), ("nodes.json", new), ("providers/test.yaml", new)], directory: directory) { data, url in
            writes += 1
            if writes == 3 { throw DeskError("injected failure") }
            try data.write(to: url, options: .atomic)
        })
        XCTAssertEqual(try Data(contentsOf: directory.appendingPathComponent("settings.json")), old)
        XCTAssertTrue(!FileManager.default.fileExists(atPath: directory.appendingPathComponent("nodes.json").path))
        XCTAssertTrue(!FileManager.default.fileExists(atPath: directory.appendingPathComponent("file-commit").path))
        try commitFiles([("settings.json", new), ("nodes.json", new)], directory: directory)
        XCTAssertEqual(try Data(contentsOf: directory.appendingPathComponent("settings.json")), new)
        XCTAssertEqual(try Data(contentsOf: directory.appendingPathComponent("nodes.json")), new)
    }
    func testInterruptedFileCommitRecoversOnSettingsLoad() throws {
        let directory = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        let journal = directory.appendingPathComponent("file-commit")
        try FileManager.default.createDirectory(at: journal, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: directory) }
        var old = Settings(); old.secret = "previous-secret"
        let data = try JSONEncoder().encode(old)
        try data.write(to: journal.appendingPathComponent("old-0"))
        try JSONEncoder().encode(["settings.json", "nodes.json"]).write(to: journal.appendingPathComponent("manifest.json"))
        try Data().write(to: journal.appendingPathComponent("ready"))
        try Data("partial write".utf8).write(to: directory.appendingPathComponent("settings.json"))
        try Data("new cache".utf8).write(to: directory.appendingPathComponent("nodes.json"))
        XCTAssertEqual(try loadSettings(from: directory).secret, "previous-secret")
        XCTAssertTrue(!FileManager.default.fileExists(atPath: directory.appendingPathComponent("nodes.json").path))
    }
    func testReviewedHelpKeepsFullPathsAndSources() throws {
        func check(_ fields: [EditorField], prefix: String = "") throws {
            for field in fields {
                if field.kind == "group" { try check(field.children ?? [], prefix: prefix); continue }
                let path = prefix + field.path
                let document = try XCTUnwrap(field.document)
                XCTAssertEqual(field.description, try XCTUnwrap(documentedFieldHelp[document + "|" + path]))
                XCTAssertTrue(!field.description.isEmpty)
                if let defaultValue = field.defaultHint, field.kind == "choice" {
                    XCTAssertTrue((field.choices ?? []).contains(defaultValue))
                }
                try check(field.children ?? [], prefix: path + ".")
            }
        }
        for section in documentSchemas.sections + documentSchemas.proxies { try check(section.fields) }
        try check(documentSchemas.configuration)
        XCTAssertTrue((documentedHelp(document: "general.md", key: "geo-auto-update") ?? "").contains("是否自动更新"))
        XCTAssertTrue((documentedHelp(document: "general.md", key: "tls.certificate") ?? "").contains("PEM"))
        XCTAssertTrue((documentedHelp(document: "proxies/trojan.md", key: "ss-opts.password") ?? "").contains("与节点 password 含义不同"))
        XCTAssertTrue(documentedHelp(document: "proxies/trojan.md", key: "unknown.password") == nil)
        XCTAssertTrue(documentedHelp(document: "proxies/wg.md", key: "unknown.mode") == nil)
        XCTAssertTrue((documentedHelp(document: "proxies/wg.md", key: "amnezia-wg-option.h1") ?? "").contains("v2+"))
        XCTAssertTrue((documentedHelp(document: "proxies/wg.md", key: "peers.server") ?? "").contains("此 peer"))
        XCTAssertTrue((documentedHelp(document: "dns/index.md", key: "fake-ip-filter") ?? "").contains("rule 模式"))
        XCTAssertTrue((documentedHelp(document: "sniff/index.md", key: "sniffer.sniff.HTTP.override-destination") ?? "").contains("覆盖"))
        XCTAssertTrue((documentedHelp(document: "proxy-groups/fallback.md", key: "empty-fallback") ?? "").contains("客户端未设置时写入 REJECT"))
        for type in ["select", "url-test", "fallback", "load-balance"] {
            for field in groupEditorFields(type) { XCTAssertNotNil(documentedHelp(document: "proxy-groups/" + type + ".md", key: field.path)) }
        }
        for type in ["http", "file", "inline"] {
            for field in ruleProviderEditorFields(type) { XCTAssertNotNil(documentedHelp(document: "rule-providers/index.md", key: field.path)) }
        }
        for kind in RuleKind.allCases { XCTAssertNotNil(documentedHelp(document: "rules/index.md", key: kind.rawValue)) }
    }

    func testReviewedProtocolOptionsAndRequirements() throws {
        func field(_ type: String, _ path: String) throws -> EditorField {
            try XCTUnwrap(documentSchemas.proxies.first { $0.key == type }?.fields.first { $0.path == path })
        }
        XCTAssertEqual(try field("tuic", "congestion-controller").choices, ["cubic", "new_reno", "bbr"])
        XCTAssertEqual(try field("shadowquic", "congestion-controller").choices, ["cubic", "new_reno", "bbr"])
        XCTAssertEqual(try field("masque", "network").choices, ["quic", "h2", "h3-l4proxy"])
        XCTAssertEqual(try field("zerotier", "network").kind, "string")
        XCTAssertEqual(try field("ss", "plugin-opts.mode").kind, "string")
        XCTAssertEqual(try field("trusttunnel", "congestion-controller").kind, "string")
        for type in ["wireguard", "masque", "openvpn", "zerotier"] {
            XCTAssertEqual(try field(type, "ip-stack.mode").choices, ["auto", "gvisor", "mips"])
            XCTAssertEqual(try field(type, "ip-stack.mode").defaultHint, "auto")
        }
        XCTAssertEqual(try field("anytls", "idle-session-timeout").defaultHint, "30")
        XCTAssertTrue(try field("openvpn", "ca").required)
        XCTAssertTrue(try field("easytier", "network-name").required)
        XCTAssertTrue(try field("vmess", "cipher").required)
        XCTAssertTrue(try field("vmess", "alterId").required)
        XCTAssertEqual(try field("tailscale", "auth-key").kind, "secret")
        XCTAssertTrue(!(documentSchemas.sections.first { $0.key == "dns" }?.fields.contains { $0.path == "proxies" } ?? true))
        let mieru = ManualProxy(type: "mieru", fields: ["name": .string("range"), "server": .string("example.com"),
            "port-range": .string("2090-2099"), "username": .string("user"), "password": .string("pass")])
        XCTAssertEqual(try mieru.configuration()["port-range"] as? String, "2090-2099")
        let vmess = ManualProxy(type: "vmess", fields: ["name": .string("vmess"), "server": .string("example.com"),
            "port": .integer(443), "uuid": .string("00000000-0000-0000-0000-000000000001")])
        XCTAssertThrowsError(try vmess.configuration())
        var configured = vmess
        configured.fields["alterId"] = .integer(0); configured.fields["cipher"] = .string("auto")
        XCTAssertEqual(try configured.configuration()["alterId"] as? Int, 0)
    }

    static var allTests = [
        ("testReviewedHelpKeepsFullPathsAndSources", testReviewedHelpKeepsFullPathsAndSources),
        ("testReviewedProtocolOptionsAndRequirements", testReviewedProtocolOptionsAndRequirements),
        ("testInterruptedFileCommitRecoversOnSettingsLoad", testInterruptedFileCommitRecoversOnSettingsLoad),
        ("testSubscriptionRejectsAliasesAndDeepNesting", testSubscriptionRejectsAliasesAndDeepNesting),
        ("testFileCommitRestoresAllFilesAfterWriteFailure", testFileCommitRestoresAllFilesAfterWriteFailure),
        ("testEmptyChoiceValidationAndOmission", testEmptyChoiceValidationAndOmission),
        ("testConfigIgnoresSubscriptionRulesAndKeepsTableOrder", testConfigIgnoresSubscriptionRulesAndKeepsTableOrder),
        ("testRejectsRuleInjectionAndDeletedSubscription", testRejectsRuleInjectionAndDeletedSubscription),
        ("testTrafficDeltasResetAndPruneInactiveConnections", testTrafficDeltasResetAndPruneInactiveConnections),
        ("testSQLiteAggregatesAcrossProcessesAndRetention", testSQLiteAggregatesAcrossProcessesAndRetention),
        ("testExistingSettingsMigrationAndDirectMatch", testExistingSettingsMigrationAndDirectMatch),
        ("testPlatformSpecificGeneralOptions", testPlatformSpecificGeneralOptions),
        ("testManualHysteria2AndNestedGeneralOptions", testManualHysteria2AndNestedGeneralOptions),
        ("testCIDRRuleOptionsAndLogicalValidation", testCIDRRuleOptionsAndLogicalValidation),
        ("testRuntimeSettingsStayIndependentOfDraftEdits", testRuntimeSettingsStayIndependentOfDraftEdits)
    ]
}
