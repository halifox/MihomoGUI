import Foundation

public struct Connection: Decodable, Identifiable {
    public let id: String
    public let metadata: Metadata
    public let upload: Int64
    public let download: Int64
    public let chains: [String]?
    public let rule: String?
    public struct Metadata: Decodable {
        public let host: String?
        public let destinationIP: String?
        public let process: String?
        public let processPath: String?
        public let network: String?
        public let destinationPort: String?
    }
    public var domain: String {
        if let host = metadata.host, !host.isEmpty { return host.lowercased() }
        return metadata.destinationIP ?? "未知目标"
    }
    public var process: String { metadata.processPath.flatMap { $0.isEmpty ? nil : $0 } ?? metadata.process ?? "未知程序" }
    public var outbound: String { chains?.first ?? "未知出口" }
}

public struct Connections: Decodable {
    public let connections: [Connection]?
}

public struct CoreAPI {
    public let secret: String
    public let port: Int
    public init(secret: String, port: Int = 19090) { self.secret = secret; self.port = port }
    public func request(_ path: String, method: String = "GET", body: Data? = nil) async throws -> Data {
        guard (1...65535).contains(port), let url = URL(string: "http://127.0.0.1:\(port)" + path) else { throw DeskError("无效 API 路径") }
        var request = URLRequest(url: url)
        request.cachePolicy = .reloadIgnoringLocalCacheData
        request.httpMethod = method; request.httpBody = body; request.timeoutInterval = 15
        request.setValue("Bearer \(secret)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let response = response as? HTTPURLResponse, (200..<300).contains(response.statusCode) else {
            // Do not echo API response bodies: configuration errors can include subscription credentials.
            let code = (response as? HTTPURLResponse)?.statusCode ?? 0
            throw DeskError("mihomo 请求失败（HTTP \(code)），请检查内核日志")
        }
        return data
    }
    public func connections() async throws -> [Connection] {
        let data = try await request("/connections")
        return try autoreleasepool { try JSONDecoder().decode(Connections.self, from: data).connections ?? [] }
    }
    public func nodes(providerOrder: [String] = []) async throws -> [Node] {
        struct Provider: Decodable { var proxies: [Proxy]? }
        struct Proxy: Decodable { var name: String; var type: String? }
        struct Response: Decodable { var providers: [String: Provider] }
        let response = try JSONDecoder().decode(Response.self, from: await request("/providers/proxies"))
        let order = providerOrder.isEmpty ? response.providers.keys.filter { $0.hasPrefix("subscription-") }.sorted() : providerOrder
        return order.flatMap { provider in
            (response.providers[provider]?.proxies ?? []).map { proxy in
                var node = Node(provider: provider, name: proxy.name)
                node.protocolName = proxy.type
                return node
            }
        }
    }
    public func delay(_ node: Node, testURL: String = "https://www.gstatic.com/generate_204") async throws -> Int {
        let provider = node.provider.addingPercentEncoding(withAllowedCharacters: .alphanumerics) ?? ""
        let name = node.name.addingPercentEncoding(withAllowedCharacters: .alphanumerics) ?? ""
        let url = testURL.addingPercentEncoding(withAllowedCharacters: .alphanumerics) ?? ""
        struct Response: Decodable { let delay: Int }
        let data = try await request("/providers/proxies/\(provider)/\(name)/healthcheck?url=\(url)&timeout=5000")
        let result = try JSONDecoder().decode(Response.self, from: data)
        guard result.delay > 0 else { throw DeskError("节点延迟测试失败") }
        return result.delay
    }
    public func reload(_ config: Data) async throws {
        guard let payload = String(data: config, encoding: .utf8) else { throw DeskError("配置编码错误") }
        let body = try JSONSerialization.data(withJSONObject: ["payload": payload])
        _ = try await request("/configs?force=true", method: "PUT", body: body)
    }
    public func updateSubscriptions(_ subscriptions: [Subscription]) async throws {
        for subscription in subscriptions {
            _ = try await request("/providers/proxies/" + subscription.provider, method: "PUT")
        }
    }
    public func closeConnection(_ id: String) async throws {
        let safe = id.addingPercentEncoding(withAllowedCharacters: .alphanumerics) ?? ""
        _ = try await request("/connections/" + safe, method: "DELETE")
    }
}
