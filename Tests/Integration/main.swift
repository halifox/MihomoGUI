import Foundation
import ClashCore

@main
struct Integration {
    static func main() async throws {
        guard CommandLine.arguments.count == 3, let proxyPort = Int(CommandLine.arguments[2]) else { throw DeskError("需要传入 mihomo 二进制路径和测试代理端口") }
        let core = CommandLine.arguments[1]
        let fixtureName = "🇯🇵 Fixture's [1]"
        let directory = FileManager.default.temporaryDirectory.appendingPathComponent("clashdesk-test-" + UUID().uuidString)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: directory) }
        var settings = Settings()
        let subscription = Subscription(name: "Fixture", url: "https://example.com/unused")
        settings.subscriptions = [subscription]
        settings.defaultNode = Node(provider: subscription.provider, name: fixtureName)
        settings.tun = false
        let processPath = "/Applications/Test's App.app/Contents/MacOS/Test"
        settings.rules = [RouteRule(kind: .domain, value: "example.org", node: nil),
                          RouteRule(kind: .processPath, value: processPath, node: settings.defaultNode)]
        let fixture = directory.appendingPathComponent("provider.yaml")
        try """
        proxies:
          - name: '\(fixtureName.replacingOccurrences(of: "'", with: "''"))'
            type: http
            server: 127.0.0.1
            port: \(proxyPort)
          - name: 'Alphabetically Earlier'
            type: http
            server: 127.0.0.1
            port: \(proxyPort)
        """.write(to: fixture, atomically: true, encoding: .utf8)
        var imported = try await withProviderCore(corePath: core, providers: [(subscription.provider, fixture)]) { api in
            try await api.nodes(providerOrder: [subscription.provider])
        }
        guard imported.count == 2, imported.first == settings.defaultNode else { throw DeskError("节点导入没有保留订阅顺序") }
        guard imported.allSatisfy({ $0.supportsUDP == false }) else { throw DeskError("HTTP 节点 UDP 能力解析错误") }
        settings.subscriptionProxies = [subscription.id: try readSubscriptionProxies(fixture).map { ConfigValue(native: $0) }]
        try populateNodeEndpoints(&imported, provider: subscription.provider, file: fixture)
        guard imported.allSatisfy({ $0.server == "127.0.0.1" && $0.port == String(proxyPort) }) else {
            throw DeskError("订阅真实服务器与端口提取失败")
        }
        try saveNodeCache(imported, directory: directory)
        guard try loadNodeCache(directory: directory) == imported else { throw DeskError("节点本地缓存错误") }
        let previewDelay = try await withProviderCore(corePath: core, providers: [(subscription.provider, fixture)]) { api in
            try await api.delay(imported[0], testURL: "http://127.0.0.1:\(proxyPort)/generate_204")
        }
        guard previewDelay >= 20 else { throw DeskError("离线内核节点延迟测试异常") }
        print("PASS: unprivileged node import, subscription order, local cache and latency without TUN")
        try await prepareGeoAssets(corePath: core, directory: directory)
        let fullConfig = directory.appendingPathComponent("defaults.yaml")
        try generateConfig(settings).write(to: fullConfig)
        let defaultValidation = Process()
        defaultValidation.executableURL = URL(fileURLWithPath: core)
        defaultValidation.arguments = ["-t", "-d", directory.path, "-f", fullConfig.path]
        defaultValidation.standardOutput = FileHandle.standardOutput
        defaultValidation.standardError = FileHandle.standardError
        try defaultValidation.run(); defaultValidation.waitUntilExit()
        guard defaultValidation.terminationStatus == 0 else { throw DeskError("mihomo 不接受用户指定的 DNS / TUN 默认配置") }
        print("PASS: YAML defaults and DNS geodata validation")
        var config = try configurationObject(settings)
        config["external-controller"] = "127.0.0.1:19191"
        config["mixed-port"] = 0
        config["dns"] = ["enable": false]
        guard config["proxy-providers"] == nil,
              !String(decoding: try yamlData(config), as: UTF8.self).contains(subscription.url) else { throw DeskError("订阅地址泄露到运行配置") }
        let configURL = directory.appendingPathComponent("config.yaml")
        try yamlData(config).write(to: configURL)
        func process(_ arguments: [String]) throws -> Process {
            let process = Process(); process.executableURL = URL(fileURLWithPath: core)
            process.arguments = arguments
            process.standardOutput = FileHandle.standardOutput; process.standardError = FileHandle.standardError
            try process.run(); return process
        }
        let validation = try process(["-t", "-d", directory.path, "-f", configURL.path])
        validation.waitUntilExit()
        guard validation.terminationStatus == 0 else { throw DeskError("mihomo 不接受生成的配置") }
        print("PASS: real mihomo config validation")
        let running = try process(["-d", directory.path, "-f", configURL.path])
        defer { if running.isRunning { running.terminate(); running.waitUntilExit() } }
        let api = CoreAPI(secret: settings.secret, port: 19191)
        var ready = false
        for _ in 0..<30 {
            guard running.isRunning else { throw DeskError("隔离内核退出；请确认 19191 端口未占用") }
            if (try? await api.request("/version")) != nil { ready = true; break }
            try await Task.sleep(nanoseconds: 100_000_000)
        }
        guard ready else { throw DeskError("隔离内核未就绪") }
        let runtimeProxies = try JSONSerialization.jsonObject(with: await api.request("/proxies")) as! [String: Any]
        let available = runtimeProxies["proxies"] as! [String: Any]
        guard available["CD.Proxy.0.0"] != nil, available["CD.Proxy.0.1"] != nil else { throw DeskError("内联节点没有加载") }
        let groupData = try await api.request("/proxies/CD.Node.0")
        let group = try JSONSerialization.jsonObject(with: groupData) as! [String: Any]
        guard group["all"] as? [String] == ["CD.Proxy.0.0"] else { throw DeskError("精确节点过滤未生效") }
        let rulesObject = try JSONSerialization.jsonObject(with: await api.request("/rules")) as! [String: Any]
        let loadedRules = rulesObject["rules"] as! [[String: Any]]
        guard loadedRules.contains(where: { $0["payload"] as? String == processPath }),
              loadedRules.first?["payload"] as? String == "example.org" else { throw DeskError("YAML 规则顺序或进程路径发生变化") }
        print("PASS: YAML emoji, apostrophes, regex and process path round trip")
        _ = try await api.connections()
        let memory = try await api.memory()
        guard memory >= 0 else { throw DeskError("内核内存统计无效") }
        _ = try await api.version()
        print("PASS: debug memory WebSocket and version API")
        print("PASS: real mihomo provider, exact node group and connections API")
        try await api.reload(yamlData(config))
        print("PASS: real mihomo live config reload")
        let unauthorized = CoreAPI(secret: "incorrect", port: 19191)
        do { _ = try await unauthorized.request("/version"); throw DeskError("控制接口没有拒绝错误密钥") }
        catch let error as DeskError {
            guard error.message.contains("401") else { throw error }
        }
        print("PASS: controller authentication")
        // Removing a pinned node must never silently select another subscription node or DIRECT.
        try """
        proxies:
          - name: 'Other Node'
            type: http
            server: 127.0.0.1
            port: 9
        """.write(to: fixture, atomically: true, encoding: .utf8)
        settings.subscriptionProxies = [subscription.id: try readSubscriptionProxies(fixture).map { ConfigValue(native: $0) }]
        let changed = try configurationObject(settings)
        config["proxies"] = changed["proxies"]; config["proxy-groups"] = changed["proxy-groups"]
        try await api.reload(yamlData(config))
        let missing = try JSONSerialization.jsonObject(with: await api.request("/proxies/CD.Node.0")) as! [String: Any]
        guard missing["all"] as? [String] == ["REJECT"] else { throw DeskError("节点失效时没有使用 REJECT") }
        print("PASS: disappeared node rejects instead of rerouting")
        let manualHTTP = ManualProxy(type: "http", fields: ["name": .string("Manual,HTTP"), "server": .string("127.0.0.1"), "port": .integer(proxyPort)])
        let manualHY = ManualProxy(type: "hysteria2", fields: ["name": .string("手动 Hysteria2"), "server": .string("127.0.0.1"), "port": .integer(443), "password": .string("fixture-only")])
        var manualSettings = Settings()
        manualSettings.secret = settings.secret
        manualSettings.manualProxies = [manualHTTP, manualHY]
        manualSettings.defaultNode = manualHTTP.node
        manualSettings.tun = false
        manualSettings.options = [
            "external-controller": .string("127.0.0.1:19191"), "mixed-port": .integer(0), "dns.enable": .boolean(false),
            "sniffer.enable": .boolean(true), "sniffer.sniff.HTTP.ports": .array([.integer(80), .string("8080-8880")]),
            "rule-providers": .object(["fixture": .object(["type": .string("inline"), "behavior": .string("domain"), "payload": .array([.string("+.fixture.test")])])]),
            "sub-rules": .object(["nested": .array([.string("NETWORK,tcp,DIRECT"), .string("MATCH,REJECT")])])
        ]
        var cidr = RouteRule(kind: .ipCIDR, value: "192.0.2.0/24", node: manualHY.node); cidr.noResolve = true
        var sub = RouteRule(kind: .subRule, value: "(NETWORK,udp)", node: nil); sub.subRuleTarget = "nested"
        manualSettings.rules = [cidr, RouteRule(kind: .and, value: "((DOMAIN,example.net),(NETWORK,tcp))", node: manualHTTP.node),
                                RouteRule(kind: .ruleSet, value: "fixture", node: manualHTTP.node), sub]
        let manualYAML = try generateConfig(manualSettings)
        try await api.reload(manualYAML)
        let manualAPI = try CoreAPI(settings: manualSettings)
        let encodedName = manualHTTP.name.addingPercentEncoding(withAllowedCharacters: .alphanumerics)!
        let manualInfo = try JSONSerialization.jsonObject(with: await manualAPI.request("/proxies/" + encodedName)) as! [String: Any]
        guard manualInfo["type"] as? String == "Http" else { throw DeskError("手动 HTTP 代理没有被内核加载") }
        let importedManualRules = try JSONSerialization.jsonObject(with: await manualAPI.request("/rules")) as! [String: Any]
        let manualRules = importedManualRules["rules"] as! [[String: Any]]
        guard manualRules.first?["payload"] as? String == "192.0.2.0/24", manualRules.count == 5 else { throw DeskError("CIDR、逻辑规则或规则集合没有正确加载") }
        let manualDelay = try await withProviderCore(corePath: core, providers: [], proxies: [try manualHTTP.configuration()]) { api in
            try await api.delay(manualHTTP.node, testURL: "http://127.0.0.1:\(proxyPort)/generate_204", timeoutMilliseconds: 25000)
        }
        guard manualDelay >= 20 else { throw DeskError("手动代理延迟接口异常") }
        print("PASS: manual Hysteria2, manual proxy latency, nested sniffer options, CIDR, logic, rule providers and sub-rules")
    }
}
