import Foundation

public let coreLabel = "local.mihomo.core"
public let defaultGroup = "MH.Default"
public let rootDirectory = "/Library/Application Support/Mihomo"
public let installedCore = "/Library/PrivilegedHelperTools/Mihomo/mihomo"

// Both config generation and the GUI's reverse name mapping use this alias contract.
public func subscriptionProxyAlias(sourceIndex: Int, proxyIndex: Int) -> String {
    "MH.Proxy.\(sourceIndex).\(proxyIndex)"
}

public func dataDirectory() throws -> URL {
    let support = FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent("Library/Application Support")
    let url = support.appendingPathComponent("Mihomo")
    try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true,
                                          attributes: [.posixPermissions: 0o700])
    return url
}

public struct Subscription: Codable, Identifiable, Hashable {
    public var id: String = UUID().uuidString
    public var name: String
    public var url: String
    public var lastUpdatedAt: Date?
    public var usage: SubscriptionUsage?
    public init(name: String, url: String) { self.name = name; self.url = url }
    public var provider: String { "subscription-" + id }
}

public struct SubscriptionUsage: Codable, Hashable {
    public var upload: Int64?
    public var download: Int64?
    public var total: Int64?
    public var expiresAt: Date?
    public var used: Int64? {
        guard let upload, let download else { return nil }
        let (sum, overflow) = upload.addingReportingOverflow(download)
        return overflow ? nil : sum
    }
    public var remaining: Int64? {
        guard let total, let used else { return nil }
        return max(0, total - used)
    }
    public init(header: String) {
        var fields: [String: Int64] = [:]
        for part in header.split(separator: ";") {
            let pair = part.split(separator: "=", maxSplits: 1).map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            if pair.count == 2, let number = Int64(pair[1]), number >= 0 { fields[pair[0].lowercased()] = number }
        }
        upload = fields["upload"]; download = fields["download"]; total = fields["total"]
        if let expiry = fields["expire"], expiry > 0 { expiresAt = Date(timeIntervalSince1970: Double(expiry)) }
    }
}

public struct Node: Codable, Hashable, Identifiable {
    public var provider: String
    public var name: String
    public var protocolName: String?
    public var supportsUDP: Bool?
    public var server: String?
    public var port: String?
    public var delayMilliseconds: Int?
    public var delayFailed: Bool?
    public var id: String { provider + "/" + name }
    public init(provider: String, name: String) { self.provider = provider; self.name = name }
    public static func == (lhs: Node, rhs: Node) -> Bool { lhs.id == rhs.id }
    public func hash(into hasher: inout Hasher) { hasher.combine(id) }
}

public enum RuleKind: String, Codable, CaseIterable {
    case domain = "DOMAIN", suffix = "DOMAIN-SUFFIX", keyword = "DOMAIN-KEYWORD"
    case wildcard = "DOMAIN-WILDCARD", domainRegex = "DOMAIN-REGEX", geosite = "GEOSITE"
    case ipCIDR = "IP-CIDR", ipCIDR6 = "IP-CIDR6", ipSuffix = "IP-SUFFIX", ipASN = "IP-ASN", geoIP = "GEOIP"
    case sourceGeoIP = "SRC-GEOIP", sourceASN = "SRC-IP-ASN", sourceCIDR = "SRC-IP-CIDR", sourceSuffix = "SRC-IP-SUFFIX"
    case destinationPort = "DST-PORT", sourcePort = "SRC-PORT", inboundPort = "IN-PORT"
    case inboundType = "IN-TYPE", inboundUser = "IN-USER", inboundName = "IN-NAME", rematchName = "REMATCH-NAME"
    case processName = "PROCESS-NAME", processPath = "PROCESS-PATH"
    case processNameWildcard = "PROCESS-NAME-WILDCARD", processNameRegex = "PROCESS-NAME-REGEX"
    case processPathWildcard = "PROCESS-PATH-WILDCARD", processPathRegex = "PROCESS-PATH-REGEX"
    case network = "NETWORK", ruleSet = "RULE-SET", and = "AND", or = "OR", not = "NOT", subRule = "SUB-RULE"
    public var title: String { rawValue }
    public var isProcess: Bool { rawValue.hasPrefix("PROCESS-") }
    public var isCIDR: Bool { [.ipCIDR, .ipCIDR6, .sourceCIDR, .ipSuffix, .sourceSuffix].contains(self) }
    public var isPort: Bool { [.destinationPort, .sourcePort, .inboundPort].contains(self) }
    public var isLogic: Bool { [.and, .or, .not, .subRule].contains(self) }
    public var supportsIPOptions: Bool { [.ipCIDR, .ipCIDR6, .ipSuffix, .ipASN, .geoIP].contains(self) }
    public var hint: String {
        if isCIDR { return "192.168.1.0/24 或 2001:db8::/32" }
        if isPort { return "80 或 8000-9000，可用 / 分隔" }
        if isProcess {
            if rawValue.contains("REGEX") { return ".*Chrome.*" }
            if rawValue.contains("WILDCARD") { return rawValue.contains("PATH") ? "/Applications/*/Contents/MacOS/*" : "*Chrome*" }
            return rawValue.contains("PATH") ? "/Applications/App.app/Contents/MacOS/App" : "curl"
        }
        switch self {
        case .network: return "tcp 或 udp"
        case .geoIP, .sourceGeoIP: return "CN"
        case .ipASN, .sourceASN: return "13335"
        case .geosite: return "gfw 或 youtube"
        case .ruleSet: return "已配置规则集合名称"
        case .and, .or: return "((DOMAIN,example.com),(NETWORK,tcp))"
        case .not: return "((DOMAIN,example.com))"
        case .subRule: return "(NETWORK,tcp)"
        case .domainRegex: return "^.*\\.example\\.com$"
        case .wildcard: return "*.example.com"
        case .inboundType: return "SOCKS/HTTP/TUN"
        case .inboundUser: return "用户名，可用 / 分隔"
        case .inboundName, .rematchName: return "已配置的入站 / rematch 名称"
        default: return "example.com"
        }
    }
}

public struct RouteRule: Codable, Identifiable {
    public var id = UUID().uuidString
    public var kind: RuleKind
    public var value: String
    // nil means DIRECT. Default routing is represented by the final MATCH rule only.
    public var node: Node?
    public var builtin: String?
    public var proxyGroup: String?
    public var noResolve: Bool?
    public var sourceIP: Bool?
    public var subRuleTarget: String?
    public init(kind: RuleKind, value: String, node: Node?) {
        self.kind = kind; self.value = value; self.node = node
    }
}

public struct Settings: Codable {
    public var delayTestURL: String?
    public var delayTestTimeoutMilliseconds: Int?
    public var corePath = ""
    public var secret = UUID().uuidString + UUID().uuidString
    public var subscriptions: [Subscription] = []
    public var subscriptionProxies: [String: [ConfigValue]]?
    public var rules: [RouteRule] = []
    public var defaultNode: Node?
    public var defaultDirect: Bool?
    // Retained only to read the TUN choice saved by earlier versions.
    public var tun: Bool?
    public var options: [String: ConfigValue]?
    public var manualProxies: [ManualProxy]?
    public var proxyGroups: [ProxyGroup]?
    public var defaultProxyGroup: String?
    public var defaultPolicy: String?
    public var ruleOrderMigrated: Bool? = true
    public init() {}
    public func delayTestParameters() throws -> (url: String, timeout: Int) {
        let configuredAddress = (delayTestURL ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        let address = configuredAddress.isEmpty ? "https://www.gstatic.com/generate_204" : configuredAddress
        guard let parsed = URL(string: address), ["http", "https"].contains(parsed.scheme?.lowercased() ?? ""),
              parsed.host != nil, parsed.user == nil, parsed.password == nil,
              !address.unicodeScalars.contains(where: { CharacterSet.whitespacesAndNewlines.contains($0) || CharacterSet.controlCharacters.contains($0) }) else {
            throw MihomoError("测试地址必须是有效的 HTTP / HTTPS URL")
        }
        let timeout = delayTestTimeoutMilliseconds ?? 5000
        guard (1...120000).contains(timeout) else { throw MihomoError("测速超时应为 1–120000 毫秒") }
        return (address, timeout)
    }
}

// Used before committing subscription changes or deleting a manual proxy.
public func rejectUnavailableRouteNodes(_ settings: inout Settings, nodes: [Node]) {
    let available = Set(nodes + (settings.manualProxies ?? []).map(\.node))
    for index in settings.rules.indices {
        if let node = settings.rules[index].node, !available.contains(node) {
            settings.rules[index].node = nil
            settings.rules[index].proxyGroup = nil
            settings.rules[index].builtin = "REJECT"
        }
    }
    if let node = settings.defaultNode, !available.contains(node) {
        settings.defaultNode = nil
        settings.defaultProxyGroup = nil
        settings.defaultDirect = false
        settings.defaultPolicy = "REJECT"
    }
}

public func loadSettings(from directory: URL) throws -> Settings {
    try recoverFileCommit(directory: directory)
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

public struct MihomoError: LocalizedError {
    public var message: String
    public init(_ message: String) { self.message = message }
    public var errorDescription: String? { message }
}

// The global editor and generated YAML share these values; hints are examples, not defaults.
public func generalConfigurationDefaults(_ settings: Settings) -> [String: ConfigValue] {
    var values: [String: ConfigValue] = [:]
    func collect(_ fields: [EditorField]) {
        for field in fields where field.unavailableReason == nil {
            if field.kind == "group" {
                collect(field.children ?? [])
            } else if let value = field.initialValue {
                values[field.path] = value
            } else if field.kind == "boolean" {
                values[field.path] = .boolean(false)
            }
        }
    }
    collect(documentSchemas.configuration)
    // Application defaults override mihomo defaults without replacing saved user choices.
    values["dns.enable"] = .boolean(true)
    values["dns.enhanced-mode"] = .string("fake-ip")
    values["ipv6"] = .boolean(false)
    values["tun.device"] = .string("utun1024")
    values["external-controller"] = .string("127.0.0.1:19090")
    values["secret"] = .string(settings.secret)
    if let tun = settings.tun { values["tun.enable"] = .boolean(tun) }
    return values
}

public func configurationObject(_ settings: Settings) throws -> [String: Any] {
    for subscription in settings.subscriptions {
        guard UUID(uuidString: subscription.id) != nil else { throw MihomoError("订阅标识无效，请重新添加订阅") }
        guard let url = URL(string: subscription.url), url.scheme == "https", url.host != nil else {
            throw MihomoError("订阅地址必须是有效 HTTPS URL")
        }
    }
    try validateProxyGroups(settings)
    let manual = settings.manualProxies ?? []
    let manualNames = manual.map(\.name)
    guard Set(manualNames).count == manualNames.count else { throw MihomoError("手动代理名称不能重复") }
    let manualObjects = try manual.map { try $0.configuration() }
    let providers = Set(settings.subscriptions.map(\.provider))
    let selected = settings.rules.compactMap(\.node) + [settings.defaultNode].compactMap { $0 }
    guard selected.allSatisfy({ ($0.provider == "manual" ? manualNames.contains($0.name) : providers.contains($0.provider)) }) else {
        throw MihomoError("规则引用了已删除的订阅，请重新选择节点")
    }
    var proxyObjects = manualObjects
    var aliases: [Node: String] = [:]
    for (sourceIndex, subscription) in settings.subscriptions.enumerated() {
        let entries = settings.subscriptionProxies?[subscription.id] ?? []
        var names: [String: String] = [:]
        for (index, entry) in entries.enumerated() {
            guard let name = entry.object["name"]?.text, !name.isEmpty, names[name] == nil else {
                throw MihomoError("订阅包含空名称或重复名称节点")
            }
            names[name] = subscriptionProxyAlias(sourceIndex: sourceIndex, proxyIndex: index)
        }
        for entry in entries {
            var proxy = entry.object.mapValues(\.native)
            let name = entry.object["name"]!.text
            proxy["name"] = names[name]!
            if let dialer = proxy["dialer-proxy"] as? String, let renamed = names[dialer] { proxy["dialer-proxy"] = renamed }
            aliases[Node(provider: subscription.provider, name: name)] = names[name]!
            proxyObjects.append(proxy)
        }
    }
    var groups: [[String: Any]] = []
    func nodeTarget(_ node: Node) throws -> String {
        if node.provider == "manual", manualNames.contains(node.name) { return node.name }
        guard let alias = aliases[node] else { throw MihomoError("引用的代理节点已失效，请重新选择出口：" + node.name) }
        return alias
    }
    func resolve(_ target: String) throws -> String {
        if let node = referencedNode(target) { return try nodeTarget(node) }
        if target.hasPrefix("group:") { return String(target.dropFirst(6)) }
        return String(target.dropFirst(8))
    }
    for group in settings.proxyGroups ?? [] {
        var object = group.fields.filter { $0.value != .string("") }.mapValues(\.native)
        object["name"] = group.name; object["type"] = group.type
        object["proxies"] = try group.targets.map(resolve)
        if let selected = group.fields["default-selected"]?.text, !selected.isEmpty { object["default-selected"] = try resolve(selected) }
        groups.append(object)
    }
    let defaultTarget: String?
    if let name = settings.defaultProxyGroup {
        defaultTarget = name
    } else if let policy = settings.defaultPolicy {
        guard ["DIRECT", "REJECT", "REJECT-DROP"].contains(policy) else { throw MihomoError("默认出口策略无效") }
        defaultTarget = policy
    } else if settings.defaultDirect == true {
        defaultTarget = "DIRECT"
    } else if let node = settings.defaultNode {
        defaultTarget = try nodeTarget(node)
    } else {
        let targets = proxyObjects.compactMap { $0["name"] as? String }
        if targets.count > 1 {
            groups.append(["name": defaultGroup, "type": "select", "proxies": targets])
            defaultTarget = defaultGroup
        } else {
            defaultTarget = targets.first
        }
    }
    let dialerTargets = Set(proxyObjects.compactMap { $0["name"] as? String }
        + groups.compactMap { $0["name"] as? String }
        + ["DIRECT", "REJECT", "REJECT-DROP", "PASS", "GLOBAL", "COMPATIBLE"])
    for proxy in proxyObjects {
        if let dialer = proxy["dialer-proxy"] as? String, !dialerTargets.contains(dialer) {
            throw MihomoError("拨号代理引用的出口不存在，请重新选择：" + dialer)
        }
    }
    var rules: [String] = []
    let ordered = settings.ruleOrderMigrated == nil
        ? settings.rules.filter { $0.kind.isProcess } + settings.rules.filter { !$0.kind.isProcess } : settings.rules
    for rule in ordered {
        try validateRule(rule, settings: settings)
        if rule.kind == .subRule {
            rules.append("SUB-RULE,\(rule.value),\(rule.subRuleTarget!)")
            continue
        }
        let target = try rule.proxyGroup ?? rule.node.map(nodeTarget) ?? rule.builtin ?? "DIRECT"
        var line = "\(rule.kind.rawValue),\(rule.value),\(target)"
        if rule.noResolve == true { line += ",no-resolve" }
        if rule.sourceIP == true { line += ",src" }
        rules.append(line)
    }
    if let defaultTarget { rules.append("MATCH,\(defaultTarget)") }
    var config: [String: Any] = [:]
    for (path, value) in generalConfigurationDefaults(settings) {
        setConfigPath(path, value: value.native, in: &config)
    }
    if !proxyObjects.isEmpty { config["proxies"] = proxyObjects }
    if !groups.isEmpty { config["proxy-groups"] = groups }
    if !rules.isEmpty { config["rules"] = rules }
    // Apply parent objects before individual fields so overlapping paths are deterministic.
    for path in (settings.options ?? [:]).keys.sorted() {
        guard let value = settings.options?[path] else { continue }
        guard validConfigPath(path) else { throw MihomoError("配置字段路径无效") }
        // An empty visual input omits an optional field.
        let omitted = value == .string("") && path != "external-controller" && path != "secret"
        setConfigPath(path, value: omitted ? nil : value.native, in: &config)
    }
    if var resources = config["rule-providers"] as? [String: [String: Any]] {
        for (index, name) in resources.keys.sorted().enumerated() {
            if let target = resources[name]?["proxy"] as? String, target.hasPrefix("node:") || target.hasPrefix("group:") || target.hasPrefix("builtin:") { resources[name]?["proxy"] = try resolve(target) }
            if resources[name]?["type"] as? String == "file" {
                let format = resources[name]?["format"] as? String ?? "yaml"
                resources[name]?["path"] = "./rules/set-\(index)." + format
            } else if resources[name]?["type"] as? String == "http" {
                resources[name]?.removeValue(forKey: "path")
            }
        }
        config["rule-providers"] = resources
    }
    config.removeValue(forKey: "proxy-providers")
    try validateFieldValues(settings.options ?? [:], schema: documentSchemas.sections.flatMap(\.fields))
    try validateRuleResources(settings)
    try validateGeneralOptions(config)
    _ = try controllerEndpoint(settings)
    return config
}

public func generateConfig(_ settings: Settings) throws -> Data {
    try yamlData(configurationObject(settings), keyOrder: [
        "mode", "mixed-port", "allow-lan", "log-level", "ipv6", "external-controller", "secret",
        "unified-delay", "external-controller-cors", "bind-address", "profile", "tun", "tcp-concurrent",
        "dns", "sniffer", "find-process-mode", "proxies", "proxy-providers", "proxy-groups", "rule-providers", "sub-rules", "rules"
    ])
}

public func runtimeConfigurationChanged(_ settings: Settings, applied: Settings) -> Bool {
    if settings.corePath != applied.corePath { return true }
    // File provider source paths are rewritten in generated YAML, but changing
    // the source still requires copying and reloading the rules.
    if settings.options?["rule-providers"] != applied.options?["rule-providers"] { return true }
    guard let current = try? generateConfig(settings), let previous = try? generateConfig(applied) else { return true }
    return current != previous
}

// A journal survives interrupted commits; readers recover before loading settings.
public func recoverFileCommit(directory: URL) throws {
    let journal = directory.appendingPathComponent("file-commit")
    guard FileManager.default.fileExists(atPath: journal.appendingPathComponent("ready").path) else { return }
    let names = try JSONDecoder().decode([String].self, from: Data(contentsOf: journal.appendingPathComponent("manifest.json")))
    for (index, name) in names.enumerated() {
        let target = directory.appendingPathComponent(name)
        let backup = journal.appendingPathComponent("old-\(index)")
        if FileManager.default.fileExists(atPath: backup.path) {
            try Data(contentsOf: backup).write(to: target, options: .atomic)
            try FileManager.default.setAttributes([.posixPermissions: 0o600], ofItemAtPath: target.path)
        } else if FileManager.default.fileExists(atPath: target.path) { try FileManager.default.removeItem(at: target) }
    }
    let retired = directory.appendingPathComponent("file-commit-done-" + UUID().uuidString)
    try FileManager.default.moveItem(at: journal, to: retired)
    try? FileManager.default.removeItem(at: retired)
}

public func commitFiles(_ files: [(String, Data)], directory: URL, write: (Data, URL) throws -> Void = { try $0.write(to: $1, options: .atomic) }) throws {
    try recoverFileCommit(directory: directory)
    for file in files {
        let target = directory.appendingPathComponent(file.0)
        if FileManager.default.fileExists(atPath: target.path),
           try target.resourceValues(forKeys: [.isRegularFileKey]).isRegularFile != true {
            throw MihomoError("保存目标不是普通文件：" + file.0)
        }
    }
    let journal = directory.appendingPathComponent("file-commit")
    if FileManager.default.fileExists(atPath: journal.path) { try FileManager.default.removeItem(at: journal) }
    try FileManager.default.createDirectory(at: journal, withIntermediateDirectories: false, attributes: [.posixPermissions: 0o700])
    for (index, file) in files.enumerated() {
        let target = directory.appendingPathComponent(file.0)
        try FileManager.default.createDirectory(at: target.deletingLastPathComponent(), withIntermediateDirectories: true, attributes: [.posixPermissions: 0o700])
        if FileManager.default.fileExists(atPath: target.path) { try FileManager.default.copyItem(at: target, to: journal.appendingPathComponent("old-\(index)")) }
    }
    try JSONEncoder().encode(files.map { $0.0 }).write(to: journal.appendingPathComponent("manifest.json"))
    try Data().write(to: journal.appendingPathComponent("ready"))
    do {
        for file in files {
            let target = directory.appendingPathComponent(file.0)
            try write(file.1, target)
            try FileManager.default.setAttributes([.posixPermissions: 0o600], ofItemAtPath: target.path)
        }
        let retired = directory.appendingPathComponent("file-commit-done-" + UUID().uuidString)
        try FileManager.default.moveItem(at: journal, to: retired)
        try? FileManager.default.removeItem(at: retired)
    } catch {
        let original = error
        do { try recoverFileCommit(directory: directory) }
        catch { throw MihomoError("保存失败且恢复未完成：\(original.localizedDescription)；\(error.localizedDescription)") }
        throw original
    }
}
