import Foundation
import ClashCore

@main
struct Integration {
    static func main() async throws {
        guard CommandLine.arguments.count == 3, let proxyPort = Int(CommandLine.arguments[2]) else { throw DeskError("需要传入 mihomo 二进制路径和测试代理端口") }
        let core = CommandLine.arguments[1]
        let directory = FileManager.default.temporaryDirectory.appendingPathComponent("clashdesk-test-" + UUID().uuidString)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: directory) }
        var settings = Settings()
        let subscription = Subscription(name: "Fixture", url: "https://example.com/unused")
        settings.subscriptions = [subscription]
        settings.defaultNode = Node(provider: subscription.provider, name: "Fixture [1]")
        settings.tun = false
        settings.rules = [RouteRule(kind: .domain, value: "example.org", node: nil)]
        let fixture = directory.appendingPathComponent("provider.yaml")
        try """
        proxies:
          - name: 'Fixture [1]'
            type: http
            server: 127.0.0.1
            port: \(proxyPort)
          - name: 'Alphabetically Earlier'
            type: http
            server: 127.0.0.1
            port: \(proxyPort)
        """.write(to: fixture, atomically: true, encoding: .utf8)
        let imported = try await withProviderCore(corePath: core, providers: [(subscription.provider, fixture)]) { api in
            try await api.nodes(providerOrder: [subscription.provider])
        }
        guard imported.count == 2, imported.first == settings.defaultNode else { throw DeskError("节点导入没有保留订阅顺序") }
        try saveNodeCache(imported, directory: directory)
        guard try loadNodeCache(directory: directory) == imported else { throw DeskError("节点本地缓存错误") }
        let previewDelay = try await withProviderCore(corePath: core, providers: [(subscription.provider, fixture)]) { api in
            try await api.delay(imported[0], testURL: "http://127.0.0.1:\(proxyPort)/generate_204")
        }
        guard previewDelay >= 20 else { throw DeskError("离线内核节点延迟测试异常") }
        print("PASS: unprivileged node import, subscription order, local cache and latency without TUN")
        var config = try JSONSerialization.jsonObject(with: generateConfig(settings)) as! [String: Any]
        config["external-controller"] = "127.0.0.1:19191"
        config["mixed-port"] = 0
        config["dns"] = ["enable": false]
        config["proxy-providers"] = [subscription.provider: ["type": "file", "path": fixture.path]]
        let configURL = directory.appendingPathComponent("config.yaml")
        try JSONSerialization.data(withJSONObject: config, options: .withoutEscapingSlashes).write(to: configURL)
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
        let nodes = try await api.nodes()
        guard nodes == imported else { throw DeskError("节点集合解析错误") }
        let groupData = try await api.request("/proxies/CD.Node.0")
        let group = try JSONSerialization.jsonObject(with: groupData) as! [String: Any]
        guard group["all"] as? [String] == ["Fixture [1]"] else { throw DeskError("精确节点过滤未生效") }
        _ = try await api.connections()
        print("PASS: real mihomo provider, exact node group and connections API")
        try await api.reload(JSONSerialization.data(withJSONObject: config, options: .withoutEscapingSlashes))
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
        try await api.updateSubscriptions(settings.subscriptions)
        let missing = try JSONSerialization.jsonObject(with: await api.request("/proxies/CD.Node.0")) as! [String: Any]
        guard missing["all"] as? [String] == ["REJECT"] else { throw DeskError("节点失效时没有使用 REJECT") }
        print("PASS: disappeared node rejects instead of rerouting")
    }
}
