import Foundation

public let coreLabel = "local.clashdesk.mihomo"
public let statsLabel = "local.clashdesk.stats"
public let defaultGroup = "CD.Default"
public let rootDirectory = "/Library/Application Support/ClashDesk"
public let installedCore = "/Library/PrivilegedHelperTools/ClashDesk/mihomo"

public func dataDirectory() throws -> URL {
    let url = FileManager.default.homeDirectoryForCurrentUser
        .appendingPathComponent("Library/Application Support/ClashDesk")
    try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true,
                                          attributes: [.posixPermissions: 0o700])
    return url
}

public struct Subscription: Codable, Identifiable, Hashable {
    public var id: String = UUID().uuidString
    public var name: String
    public var url: String
    public init(name: String, url: String) { self.name = name; self.url = url }
    public var provider: String { "subscription-" + id }
}

public struct Node: Codable, Hashable, Identifiable {
    public var provider: String
    public var name: String
    public var protocolName: String?
    public var delayMilliseconds: Int?
    public var delayFailed: Bool?
    public var id: String { provider + "/" + name }
    public init(provider: String, name: String) { self.provider = provider; self.name = name }
    public static func == (lhs: Node, rhs: Node) -> Bool { lhs.id == rhs.id }
    public func hash(into hasher: inout Hasher) { hasher.combine(id) }
}

public enum RuleKind: String, Codable, CaseIterable {
    case domain = "DOMAIN", suffix = "DOMAIN-SUFFIX"
    case processName = "PROCESS-NAME", processPath = "PROCESS-PATH"
    public var title: String {
        switch self {
        case .domain: return "精确域名"
        case .suffix: return "域名及子域名"
        case .processName: return "进程名称"
        case .processPath: return "进程路径"
        }
    }
    public var isProcess: Bool { self == .processName || self == .processPath }
}

public struct RouteRule: Codable, Identifiable {
    public var id = UUID().uuidString
    public var kind: RuleKind
    public var value: String
    // nil means DIRECT. Default routing is represented by the final MATCH rule only.
    public var node: Node?
    public init(kind: RuleKind, value: String, node: Node?) {
        self.kind = kind; self.value = value; self.node = node
    }
}

public struct Settings: Codable {
    public var corePath = ""
    public var secret = UUID().uuidString + UUID().uuidString
    public var subscriptions: [Subscription] = []
    public var rules: [RouteRule] = []
    public var defaultNode: Node?
    public var defaultDirect: Bool?
    public var tun = true
    public init() {}
}

public func loadSettings(from directory: URL) throws -> Settings {
    let url = directory.appendingPathComponent("settings.json")
    guard FileManager.default.fileExists(atPath: url.path) else { return Settings() }
    return try JSONDecoder().decode(Settings.self, from: Data(contentsOf: url))
}

public func saveSettings(_ settings: Settings, to directory: URL) throws {
    let encoder = JSONEncoder(); encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
    let url = directory.appendingPathComponent("settings.json")
    try encoder.encode(settings).write(to: url, options: .atomic)
    try FileManager.default.setAttributes([.posixPermissions: 0o600], ofItemAtPath: url.path)
}

public struct DeskError: LocalizedError {
    public var message: String
    public init(_ message: String) { self.message = message }
    public var errorDescription: String? { message }
}

public func configurationObject(_ settings: Settings) throws -> [String: Any] {
    guard !settings.subscriptions.isEmpty else { throw DeskError("请先添加 Clash / mihomo 格式订阅") }
    for subscription in settings.subscriptions {
        guard let url = URL(string: subscription.url), url.scheme == "https", url.host != nil else {
            throw DeskError("订阅地址必须是有效 HTTPS URL")
        }
    }
    let providers = Set(settings.subscriptions.map(\.provider))
    let selected = settings.rules.compactMap(\.node) + [settings.defaultNode].compactMap { $0 }
    guard selected.allSatisfy({ providers.contains($0.provider) }) else {
        throw DeskError("规则引用了已删除的订阅，请重新选择节点")
    }
    var providerConfig: [String: Any] = [:]
    for subscription in settings.subscriptions {
        providerConfig[subscription.provider] = [
            "type": "http", "url": subscription.url, "path": "./providers/\(subscription.id).yaml",
            "interval": 3600, "proxy": "DIRECT",
            "health-check": ["enable": false]
        ] as [String: Any]
    }
    var groups: [[String: Any]] = []
    var nodeGroups: [Node: String] = [:]
    for node in selected where nodeGroups[node] == nil {
        let name = "CD.Node.\(groups.count)"
        nodeGroups[node] = name
        groups.append(["name": name, "type": "select", "use": [node.provider],
                       "filter": "^" + NSRegularExpression.escapedPattern(for: node.name) + "$",
                       "empty-fallback": "REJECT"])
    }
    if settings.defaultDirect == true {
        groups.append(["name": defaultGroup, "type": "select", "proxies": ["DIRECT"]])
    } else if let node = settings.defaultNode {
        groups.append(["name": defaultGroup, "type": "select", "proxies": [nodeGroups[node]!]])
    } else {
        groups.append(["name": defaultGroup, "type": "select",
                       "use": settings.subscriptions.map(\.provider), "empty-fallback": "REJECT"])
    }
    var rules: [String] = []
    let ordered = settings.rules.filter { $0.kind.isProcess } + settings.rules.filter { !$0.kind.isProcess }
    for rule in ordered {
        guard !rule.value.isEmpty, !rule.value.contains(","),
              !rule.value.unicodeScalars.contains(where: { CharacterSet.controlCharacters.contains($0) }) else {
            throw DeskError("规则内容不能为空，且不能包含逗号或控制字符")
        }
        if !rule.kind.isProcess {
            guard !rule.value.contains("/"), !rule.value.contains(":"), !rule.value.contains(" ") else {
                throw DeskError("请输入域名，不要输入 URL、端口或路径")
            }
        }
        rules.append("\(rule.kind.rawValue),\(rule.value),\(rule.node.flatMap { nodeGroups[$0] } ?? "DIRECT")")
    }
    rules.append("MATCH,\(defaultGroup)")
    let config: [String: Any] = [
        "mode": "rule", "mixed-port": 7890, "allow-lan": false, "log-level": "info",
        "external-controller": "127.0.0.1:19090", "secret": settings.secret,
        "unified-delay": true, "tcp-concurrent": true, "bind-address": "*",
        "external-controller-cors": ["allow-private-network": true, "allow-origins": [
            "tauri://localhost", "http://tauri.localhost", "https://yacd.metacubex.one",
            "https://metacubex.github.io", "https://board.zash.run.place"]],
        "find-process-mode": "always", "ipv6": false,
        "profile": ["store-selected": true],
        "tun": ["enable": settings.tun, "stack": "mips", "auto-route": true,
                "auto-detect-interface": true, "device": "utun1024", "dns-hijack": ["any:53"],
                "mtu": 1500, "route-exclude-address": [], "strict-route": false],
        "dns": ["enable": true, "ipv6": false,
                "enhanced-mode": "fake-ip", "fake-ip-range": "198.18.0.1/16",
                "use-hosts": true, "respect-rules": true,
                "default-nameserver": ["223.5.5.5", "119.29.29.29", "114.114.114.114"],
                "nameserver": ["223.5.5.5", "119.29.29.29", "114.114.114.114"],
                "proxy-server-nameserver": ["223.5.5.5", "119.29.29.29", "114.114.114.114"],
                "fallback": ["1.1.1.1", "8.8.8.8"],
                "fallback-filter": ["geoip": true, "geoip-code": "CN", "geosite": ["gfw"],
                                    "ipcidr": ["240.0.0.0/4"], "domain": ["+.google.com", "+.facebook.com", "+.youtube.com"]]],
        "proxy-providers": providerConfig, "proxy-groups": groups, "rules": rules
    ]
    return config
}

public func generateConfig(_ settings: Settings) throws -> Data {
    try yamlData(configurationObject(settings), keyOrder: [
        "mode", "mixed-port", "allow-lan", "log-level", "ipv6", "external-controller", "secret",
        "unified-delay", "external-controller-cors", "bind-address", "profile", "tun", "tcp-concurrent",
        "dns", "find-process-mode", "proxy-providers", "proxy-groups", "rules"
    ])
}
