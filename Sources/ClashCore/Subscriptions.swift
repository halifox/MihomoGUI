import Foundation
import Darwin

public func providerFile(_ subscription: Subscription, directory: URL) -> URL {
    directory.appendingPathComponent("providers").appendingPathComponent(subscription.id + ".yaml")
}

public func loadNodeCache(directory: URL) throws -> [Node] {
    let url = directory.appendingPathComponent("nodes.json")
    guard FileManager.default.fileExists(atPath: url.path) else { return [] }
    return try JSONDecoder().decode([Node].self, from: Data(contentsOf: url))
}

public func saveNodeCache(_ nodes: [Node], directory: URL) throws {
    let url = directory.appendingPathComponent("nodes.json")
    try JSONEncoder().encode(nodes).write(to: url, options: .atomic)
    try FileManager.default.setAttributes([.posixPermissions: 0o600], ofItemAtPath: url.path)
}

public let geoAssetNames = ["Country.mmdb", "geosite.dat"]

public func prepareGeoAssets(corePath: String, directory: URL, names: [String] = geoAssetNames, urls: [String: String] = [:]) async throws {
    try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true, attributes: [.posixPermissions: 0o700])
    let coreFolder = URL(fileURLWithPath: corePath).deletingLastPathComponent()
    var sourceFolders = [coreFolder]
    if coreFolder.lastPathComponent == "MacOS", coreFolder.deletingLastPathComponent().lastPathComponent == "Contents" {
        sourceFolders.append(coreFolder.deletingLastPathComponent().appendingPathComponent("Resources/resources"))
    }
    for name in names {
        let target = directory.appendingPathComponent(name)
        let sourceMarker = directory.appendingPathComponent(name + ".source")
        let sourceURL = urls[name] ?? ""
        if ((try? target.resourceValues(forKeys: [.fileSizeKey]).fileSize ?? 0) ?? 0) > 0,
           ((try? String(contentsOf: sourceMarker, encoding: .utf8)) ?? "") == sourceURL { continue }
        let candidates = sourceURL.isEmpty ? sourceFolders.flatMap { [$0.appendingPathComponent(name), $0.appendingPathComponent(name.lowercased())] } : []
        if let source = candidates.first(where: { FileManager.default.isReadableFile(atPath: $0.path) }) {
            if FileManager.default.fileExists(atPath: target.path) { try FileManager.default.removeItem(at: target) }
            try FileManager.default.copyItem(at: source, to: target)
        } else {
            let defaultURL = name == "ASN.mmdb" ? "https://github.com/xishang0128/geoip/releases/download/latest/GeoLite2-ASN.mmdb"
                : "https://github.com/MetaCubeX/meta-rules-dat/releases/download/latest/" + name.lowercased()
            guard let url = URL(string: urls[name] ?? defaultURL), url.scheme == "https" else { throw DeskError("GEO 下载地址必须为 HTTPS") }
            var request = URLRequest(url: url); request.timeoutInterval = 45
            let (download, response) = try await URLSession.shared.download(for: request)
            defer { try? FileManager.default.removeItem(at: download) }
            guard let http = response as? HTTPURLResponse, (200..<300).contains(http.statusCode) else {
                throw DeskError("下载 DNS 地理数据 \(name) 失败，请检查网络后重试")
            }
            let size = try download.resourceValues(forKeys: [.fileSizeKey]).fileSize ?? 0
            guard size > 0, size <= 100 * 1024 * 1024 else { throw DeskError("DNS 地理数据文件大小无效") }
            try Data(contentsOf: download).write(to: target, options: .atomic)
        }
        try FileManager.default.setAttributes([.posixPermissions: 0o600], ofItemAtPath: target.path)
        try sourceURL.write(to: sourceMarker, atomically: true, encoding: .utf8)
        try FileManager.default.setAttributes([.posixPermissions: 0o600], ofItemAtPath: sourceMarker.path)
    }
}

private func availablePort() throws -> Int {
    let fd = socket(AF_INET, SOCK_STREAM, 0)
    guard fd >= 0 else { throw DeskError("无法分配节点预览端口") }
    defer { close(fd) }
    var address = sockaddr_in()
    address.sin_len = UInt8(MemoryLayout<sockaddr_in>.size)
    address.sin_family = sa_family_t(AF_INET)
    address.sin_addr.s_addr = inet_addr("127.0.0.1")
    let bound = withUnsafePointer(to: &address) { pointer in
        pointer.withMemoryRebound(to: sockaddr.self, capacity: 1) { bind(fd, $0, socklen_t(MemoryLayout<sockaddr_in>.size)) }
    }
    guard bound == 0 else { throw DeskError("无法绑定节点预览端口") }
    var size = socklen_t(MemoryLayout<sockaddr_in>.size)
    let result = withUnsafeMutablePointer(to: &address) { pointer in
        pointer.withMemoryRebound(to: sockaddr.self, capacity: 1) { getsockname(fd, $0, &size) }
    }
    guard result == 0 else { throw DeskError("无法读取节点预览端口") }
    return Int(UInt16(bigEndian: address.sin_port))
}

// Temporary unprivileged core: file providers only, no TUN, DNS, inbound proxy or system route changes.
// It exists only while parsing subscription nodes or testing latency; not an additional resident service.
public func withProviderCore<T>(corePath: String, providers: [(String, URL)],
                                proxies: [[String: Any]] = [],
                                unifiedDelay: Bool = true,
                                operation: (CoreAPI) async throws -> T) async throws -> T {
    guard FileManager.default.isExecutableFile(atPath: corePath) else {
        throw DeskError("请先配置可执行的 macOS mihomo 二进制文件")
    }
    guard !providers.isEmpty || !proxies.isEmpty else { throw DeskError("请先添加代理或拉取订阅节点") }
    let directory = FileManager.default.temporaryDirectory.appendingPathComponent("clashdesk-preview-" + UUID().uuidString)
    try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: false, attributes: [.posixPermissions: 0o700])
    defer { try? FileManager.default.removeItem(at: directory) }
    let port = try availablePort()
    let secret = UUID().uuidString
    let providerConfig = Dictionary(uniqueKeysWithValues: providers.map {
        ($0.0, ["type": "file", "path": $0.1.path])
    })
    let config: [String: Any] = [
        "mode": "rule", "log-level": "silent", "mixed-port": 0,
        "external-controller": "127.0.0.1:\(port)", "secret": secret,
        "tun": ["enable": false], "dns": ["enable": false], "find-process-mode": "off",
        "unified-delay": unifiedDelay,
        "proxy-providers": providerConfig,
        "proxies": proxies,
        "rules": ["MATCH,REJECT"]
    ]
    let configURL = directory.appendingPathComponent("config.yaml")
    try yamlData(config).write(to: configURL)
    var environment = ProcessInfo.processInfo.environment
    // Permit only the exact local provider files, not arbitrary user directories.
    environment["SAFE_PATHS"] = providers.map { $0.1.path }.joined(separator: ":")
    let process = Process()
    process.executableURL = URL(fileURLWithPath: corePath)
    process.arguments = ["-d", directory.path, "-f", configURL.path]
    process.environment = environment
    process.standardOutput = FileHandle.nullDevice; process.standardError = FileHandle.nullDevice
    try process.run()
    defer { if process.isRunning { process.terminate(); process.waitUntilExit() } }
    let api = CoreAPI(secret: secret, port: port)
    let deadline = Date().addingTimeInterval(15)
    while Date() < deadline {
        try Task.checkCancellation()
        guard process.isRunning else { throw DeskError("mihomo 无法解析订阅，请确认订阅返回 Clash YAML 节点配置") }
        if (try? await api.version()) != nil, let nodes = try? await api.nodes(providerOrder: providers.map { $0.0 }),
           providers.allSatisfy({ provider in nodes.contains { $0.provider == provider.0 } }) {
            return try await operation(api)
        }
        try await Task.sleep(nanoseconds: 100_000_000)
    }
    throw DeskError("订阅没有有效节点，或 mihomo 节点预览启动超时")
}

public func fetchSubscriptions(_ subscriptions: [Subscription], corePath: String, directory: URL) async throws -> [Node] {
    guard !subscriptions.isEmpty else { throw DeskError("请先添加订阅地址") }
    guard FileManager.default.isExecutableFile(atPath: corePath) else { throw DeskError("请先配置 mihomo 二进制文件路径") }
    let staging = FileManager.default.temporaryDirectory.appendingPathComponent("clashdesk-fetch-" + UUID().uuidString)
    try FileManager.default.createDirectory(at: staging, withIntermediateDirectories: false, attributes: [.posixPermissions: 0o700])
    defer { try? FileManager.default.removeItem(at: staging) }
    var providers: [(String, URL)] = []
    for subscription in subscriptions {
        guard let url = URL(string: subscription.url), url.scheme == "https", url.host != nil else { throw DeskError("订阅必须是 HTTPS 地址") }
        var request = URLRequest(url: url)
        request.timeoutInterval = 30; request.cachePolicy = .reloadIgnoringLocalCacheData
        request.setValue("clash.meta", forHTTPHeaderField: "User-Agent")
        let (download, response) = try await URLSession.shared.download(for: request)
        defer { try? FileManager.default.removeItem(at: download) }
        guard let http = response as? HTTPURLResponse, (200..<300).contains(http.statusCode) else {
            throw DeskError("订阅“\(subscription.name)”下载失败（HTTP \((response as? HTTPURLResponse)?.statusCode ?? 0)）")
        }
        let size = try download.resourceValues(forKeys: [.fileSizeKey]).fileSize ?? 0
        guard size > 0, size <= 16 * 1024 * 1024 else { throw DeskError("订阅为空或超过 16 MiB") }
        let target = staging.appendingPathComponent(subscription.id + ".yaml")
        try FileManager.default.moveItem(at: download, to: target)
        providers.append((subscription.provider, target))
    }
    let nodes = try await withProviderCore(corePath: corePath, providers: providers) { api in
        try await api.nodes(providerOrder: subscriptions.map(\.provider))
    }
    let cache = directory.appendingPathComponent("providers")
    try FileManager.default.createDirectory(at: cache, withIntermediateDirectories: true, attributes: [.posixPermissions: 0o700])
    for (index, subscription) in subscriptions.enumerated() {
        let target = providerFile(subscription, directory: directory)
        try Data(contentsOf: providers[index].1).write(to: target, options: .atomic)
        try FileManager.default.setAttributes([.posixPermissions: 0o600], ofItemAtPath: target.path)
    }
    return nodes
}
