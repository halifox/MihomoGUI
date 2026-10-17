import Foundation

public struct Connection: Decodable, Identifiable {
    public let id: String
    public let metadata: Metadata
    public let upload: Int64
    public let download: Int64
    public let chains: [String]?
    public let rule: String?
    public let rulePayload: String?
    public let start: String?
    public var downloadSpeed: Int64 = 0
    public var uploadSpeed: Int64 = 0
    private enum CodingKeys: String, CodingKey { case id, metadata, upload, download, chains, rule, rulePayload, start }
    public struct Metadata: Decodable {
        public let sourceIP: String?
        public let sourcePort: String?
        public let type: String?
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
    public let connections: [Connection]
    private enum CodingKeys: String, CodingKey { case connections }
    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        guard values.contains(.connections) else {
            throw DecodingError.keyNotFound(CodingKeys.connections,
                .init(codingPath: decoder.codingPath, debugDescription: "Missing connections field"))
        }
        // mihomo can encode an empty Go slice as null; the field must still be present.
        connections = try values.decodeIfPresent([Connection].self, forKey: .connections) ?? []
    }
}

public enum CoreAPIError: LocalizedError {
    case http(Int), invalidResponse, invalidConnections
    public var errorDescription: String? {
        switch self {
        case .http(let code): return "mihomo 请求失败（HTTP \(code)），请检查控制接口授权及服务日志"
        case .invalidResponse: return "mihomo 控制接口返回了无效的 HTTP 响应"
        case .invalidConnections: return "mihomo 连接数据格式无效或缺少必要字段，请检查内核版本及服务日志"
        }
    }
}

public struct CoreAPI {
    public let secret: String
    public let port: Int
    public let host: String
    public init(secret: String, port: Int = 19090, host: String = "127.0.0.1") { self.secret = secret; self.port = port; self.host = host }
    public init(settings: Settings) throws {
        let endpoint = try controllerEndpoint(settings)
        self.init(secret: endpoint.secret, port: endpoint.port, host: endpoint.host)
    }
    public func request(_ path: String, method: String = "GET", body: Data? = nil, timeout: TimeInterval = 15) async throws -> Data {
        let destination = host.contains(":") && !host.hasPrefix("[") ? "[\(host)]" : host
        guard (1...65535).contains(port), let url = URL(string: "http://\(destination):\(port)" + path) else { throw DeskError("无效 API 路径") }
        var request = URLRequest(url: url)
        request.cachePolicy = .reloadIgnoringLocalCacheData
        request.httpMethod = method; request.httpBody = body; request.timeoutInterval = timeout
        request.setValue("Bearer \(secret)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let response = response as? HTTPURLResponse else { throw CoreAPIError.invalidResponse }
        // Do not echo API response bodies: configuration errors can include subscription credentials.
        guard (200..<300).contains(response.statusCode) else { throw CoreAPIError.http(response.statusCode) }
        return data
    }
    public func connections() async throws -> [Connection] {
        let data = try await request("/connections")
        do { return try autoreleasepool { try JSONDecoder().decode(Connections.self, from: data).connections } }
        catch is DecodingError { throw CoreAPIError.invalidConnections }
    }
    public func nodes(providerOrder: [String] = []) async throws -> [Node] {
        struct Provider: Decodable { var proxies: [Proxy]? }
        struct Proxy: Decodable { var name: String; var type: String?; var udp: Bool? }
        struct Response: Decodable { var providers: [String: Provider] }
        let response = try JSONDecoder().decode(Response.self, from: await request("/providers/proxies"))
        let order = providerOrder.isEmpty ? response.providers.keys.filter { $0.hasPrefix("subscription-") }.sorted() : providerOrder
        return order.flatMap { provider in
            (response.providers[provider]?.proxies ?? []).map { proxy in
                var node = Node(provider: provider, name: proxy.name)
                node.protocolName = proxy.type; node.supportsUDP = proxy.udp
                return node
            }
        }
    }
    public func udpSupport() async throws -> [String: Bool] {
        struct Proxy: Decodable { var udp: Bool? }
        struct Response: Decodable { var proxies: [String: Proxy] }
        return try JSONDecoder().decode(Response.self, from: await request("/proxies")).proxies.compactMapValues(\.udp)
    }
    public func delay(_ node: Node, testURL: String = "https://www.gstatic.com/generate_204", timeoutMilliseconds: Int = 5000) async throws -> Int {
        let provider = node.provider.addingPercentEncoding(withAllowedCharacters: .alphanumerics) ?? ""
        let name = node.name.addingPercentEncoding(withAllowedCharacters: .alphanumerics) ?? ""
        let url = testURL.addingPercentEncoding(withAllowedCharacters: .alphanumerics) ?? ""
        struct Response: Decodable { let delay: Int }
        let route = node.provider == "manual" ? "/proxies/\(name)/delay" : "/providers/proxies/\(provider)/\(name)/healthcheck"
        let data = try await request(route + "?url=\(url)&timeout=\(timeoutMilliseconds)", timeout: max(15, Double(timeoutMilliseconds) / 1000 + 5))
        let result = try JSONDecoder().decode(Response.self, from: data)
        guard result.delay > 0 else { throw DeskError("节点延迟测试失败") }
        return result.delay
    }
    public func memory() async throws -> Int64 {
        struct Response: Decodable { let inuse: Int64 }
        let destination = host.contains(":") && !host.hasPrefix("[") ? "[\(host)]" : host
        guard let url = URL(string: "ws://\(destination):\(port)/memory") else { throw DeskError("内存接口地址无效") }
        var request = URLRequest(url: url); request.timeoutInterval = 5
        request.setValue("Bearer \(secret)", forHTTPHeaderField: "Authorization")
        let socket = URLSession.shared.webSocketTask(with: request)
        socket.resume(); defer { socket.cancel(with: .goingAway, reason: nil) }
        let data: Data
        switch try await socket.receive() {
        case .data(let value): data = value
        case .string(let value): data = Data(value.utf8)
        @unknown default: throw DeskError("无法解析内存数据")
        }
        return try JSONDecoder().decode(Response.self, from: data).inuse
    }
    public func version() async throws -> String {
        struct Response: Decodable { let version: String }
        return try JSONDecoder().decode(Response.self, from: await request("/version")).version
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
    public func closeAllConnections() async throws {
        _ = try await request("/connections", method: "DELETE")
    }
    public func closeConnection(_ id: String) async throws {
        let safe = id.addingPercentEncoding(withAllowedCharacters: .alphanumerics) ?? ""
        _ = try await request("/connections/" + safe, method: "DELETE")
    }
}
