import Foundation
import Darwin
import CoreFoundation

public indirect enum ConfigValue: Codable, Equatable {
    case string(String), integer(Int), number(Double), boolean(Bool)
    case array([ConfigValue]), object([String: ConfigValue])
    public init(from decoder: Decoder) throws {
        let value = try decoder.singleValueContainer()
        if let v = try? value.decode(Bool.self) { self = .boolean(v) }
        else if let v = try? value.decode(Int.self) { self = .integer(v) }
        else if let v = try? value.decode(Double.self) { self = .number(v) }
        else if let v = try? value.decode(String.self) { self = .string(v) }
        else if let v = try? value.decode([ConfigValue].self) { self = .array(v) }
        else { self = .object(try value.decode([String: ConfigValue].self)) }
    }
    public func encode(to encoder: Encoder) throws {
        var value = encoder.singleValueContainer()
        switch self {
        case .string(let v): try value.encode(v)
        case .integer(let v): try value.encode(v)
        case .number(let v): try value.encode(v)
        case .boolean(let v): try value.encode(v)
        case .array(let v): try value.encode(v)
        case .object(let v): try value.encode(v)
        }
    }
    public var native: Any {
        switch self {
        case .string(let v): return v
        case .integer(let v): return v
        case .number(let v): return v
        case .boolean(let v): return v
        case .array(let v): return v.map(\.native)
        case .object(let v): return v.mapValues(\.native)
        }
    }
    public var text: String {
        switch self {
        case .string(let v): return v
        case .integer(let v): return String(v)
        case .number(let v): return String(v)
        case .boolean(let v): return v ? "true" : "false"
        default: return ""
        }
    }
    public var array: [ConfigValue] { if case .array(let v) = self { return v }; return [] }
    public var object: [String: ConfigValue] { if case .object(let v) = self { return v }; return [:] }
    public init(native: Any) {
        if let v = native as? String { self = .string(v) }
        else if let v = native as? NSNumber {
            if CFGetTypeID(v) == CFBooleanGetTypeID() { self = .boolean(v.boolValue) }
            else if String(cString: v.objCType) == "d" || String(cString: v.objCType) == "f" { self = .number(v.doubleValue) }
            else { self = .integer(v.intValue) }
        }
        else if let v = native as? [Any] { self = .array(v.map { ConfigValue(native: $0) }) }
        else if let v = native as? [String: Any] { self = .object(v.mapValues { ConfigValue(native: $0) }) }
        else { self = .string("") }
    }
}

public struct EditorField: Codable, Identifiable {
    public var path: String
    public var title: String
    public var kind: String
    public var hint: String
    public var description: String
    public var required: Bool
    public var choices: [String]?
    public var elementKind: String?
    public var children: [EditorField]?
    public var id: String { path }
    public init(_ path: String, kind: String = "string", title: String? = nil, hint: String = "", required: Bool = false,
                choices: [String]? = nil, elementKind: String? = nil, children: [EditorField]? = nil, description: String = "") {
        self.path = path; self.title = title ?? path; self.kind = kind; self.hint = hint
        self.description = description; self.required = required; self.choices = choices
        self.elementKind = elementKind; self.children = children
    }
}

public struct EditorSchema: Codable, Identifiable {
    public var name: String
    public var key: String
    public var fields: [EditorField]
    public var document: String
    public var id: String { key }
}

public struct DocumentSchemas: Codable {
    public var sections: [EditorSchema]
    public var proxies: [EditorSchema]
}

public let documentSchemas: DocumentSchemas = {
    // Generated, checked-in JSON is immutable; runtime never reads the documentation checkout.
    try! JSONDecoder().decode(DocumentSchemas.self, from: Data(docSchemaJSON.utf8))
}()

public func emptyValue(_ field: EditorField) -> ConfigValue {
    switch field.kind {
    case "boolean": return .boolean(false)
    case "integer": return .integer(Int(field.hint) ?? 0)
    case "number": return .number(Double(field.hint) ?? 0)
    case "choice": return .string(field.choices?.first ?? "")
    case "list": return .array([])
    case "map": return .object([:])
    case "object":
        var object: [String: Any] = [:]
        for child in field.children ?? [] where child.required { setConfigPath(child.path, value: emptyValue(child).native, in: &object) }
        return ConfigValue(native: object)
    default: return .string("")
    }
}

public func setConfigPath(_ path: String, value: Any?, in object: inout [String: Any]) {
    let parts = path.split(separator: ".", maxSplits: 1).map(String.init)
    if parts.count == 1 { object[path] = value; return }
    var nested = object[parts[0]] as? [String: Any] ?? [:]
    setConfigPath(parts[1], value: value, in: &nested)
    object[parts[0]] = nested
}

public func configPath(_ path: String, in object: [String: Any]) -> Any? {
    let parts = path.split(separator: ".", maxSplits: 1).map(String.init)
    if parts.count == 1 { return object[path] }
    guard let nested = object[parts[0]] as? [String: Any] else { return nil }
    return configPath(parts[1], in: nested)
}

public struct ManualProxy: Codable, Identifiable {
    public var id = UUID().uuidString
    public var type: String
    public var fields: [String: ConfigValue]
    public var delayMilliseconds: Int?
    public var delayFailed: Bool?
    public var name: String { fields["name"]?.text ?? "" }
    public init(type: String, fields: [String: ConfigValue]) { self.type = type; self.fields = fields }
    public var node: Node {
        var node = Node(provider: "manual", name: name); node.protocolName = type
        node.delayMilliseconds = delayMilliseconds; node.delayFailed = delayFailed; return node
    }
    public func configuration() throws -> [String: Any] {
        guard !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty, !name.hasPrefix("CD."), !["DIRECT", "REJECT", "REJECT-DROP", "GLOBAL", "PASS"].contains(name),
              !name.unicodeScalars.contains(where: { CharacterSet.controlCharacters.contains($0) }) else { throw DeskError("代理名称不能为空，不能使用保留名称或控制字符") }
        guard let schema = documentSchemas.proxies.first(where: { $0.key == type }) else { throw DeskError("未知代理类型：\(type)") }
        for field in schema.fields where field.required {
            if type == "hysteria2", field.path == "port", !(fields["ports"]?.text ?? "").isEmpty { continue }
            guard let value = fields[field.path], !value.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
                throw DeskError("\(type) 缺少必填字段：\(field.path)")
            }
        }
        try validateFieldValues(fields, schema: schema.fields)
        if let port = fields["port"], !(1...65535).contains(Int(port.text) ?? 0) { throw DeskError("代理端口必须为 1–65535") }
        if ["vmess", "vless"].contains(type), UUID(uuidString: fields["uuid"]?.text ?? "") == nil { throw DeskError("uuid 格式无效") }
        if type == "tuic", (fields["token"]?.text ?? "").isEmpty,
           ((fields["uuid"]?.text ?? "").isEmpty || (fields["password"]?.text ?? "").isEmpty) { throw DeskError("TUIC 需要 token，或 uuid 与 password") }
        if type == "hysteria2", fields["obfs"] != nil, (fields["obfs-password"]?.text ?? "").isEmpty { throw DeskError("启用 Hysteria2 混淆需要 obfs-password") }
        var object: [String: Any] = ["type": type]
        for (path, value) in fields { setConfigPath(path, value: value.native, in: &object) }
        return object
    }
}

public func validateFieldValues(_ values: [String: ConfigValue], schema: [EditorField]) throws {
    for field in schema {
        guard let value = values[field.path] else { continue }
        if !field.required, value == .string("") { continue }
        switch (field.kind, value) {
        case ("integer", .integer), ("number", .number), ("number", .integer), ("boolean", .boolean),
             ("string", .string), ("secret", .string), ("choice", .string), ("list", .array), ("map", .object): break
        default: throw DeskError("\(field.path) 的值类型无效（需要 \(field.kind)）")
        }
        if case .number(let v) = value, !v.isFinite { throw DeskError("\(field.path) 必须为有限数字") }
    }
}

public func validCIDR(_ value: String) -> Bool {
    let parts = value.split(separator: "/", omittingEmptySubsequences: false)
    guard parts.count == 2, let prefix = Int(parts[1]) else { return false }
    var v4 = in_addr(); var v6 = in6_addr()
    if inet_pton(AF_INET, String(parts[0]), &v4) == 1 { return (0...32).contains(prefix) }
    if inet_pton(AF_INET6, String(parts[0]), &v6) == 1 { return (0...128).contains(prefix) }
    return false
}

public func validateRule(_ rule: RouteRule, settings: Settings) throws {
    let value = rule.value
    guard !value.isEmpty, !value.unicodeScalars.contains(where: { CharacterSet.controlCharacters.contains($0) }) else { throw DeskError("规则匹配内容不能为空或包含控制字符") }
    if value.contains(","), !rule.kind.isLogic { throw DeskError("此规则的匹配内容不能包含逗号") }
    if let builtin = rule.builtin, !["DIRECT", "REJECT", "REJECT-DROP"].contains(builtin) { throw DeskError("无效内置出口") }
    if !rule.kind.supportsIPOptions, rule.noResolve == true || rule.sourceIP == true { throw DeskError("no-resolve / src 仅支持目标 IP 规则") }
    if rule.kind.isCIDR, !validCIDR(value) { throw DeskError("CIDR 地址或掩码无效") }
    if [.domain, .suffix, .keyword, .wildcard].contains(rule.kind), value.contains("/") || value.contains(":") || value.contains(" ") { throw DeskError("请输入域名，不要输入 URL、端口或路径") }
    if [.ipASN, .sourceASN].contains(rule.kind), UInt32(value) == nil { throw DeskError("ASN 必须为非负整数") }
    if rule.kind.isPort {
        for range in value.split(separator: "/", omittingEmptySubsequences: false) {
            let ends = range.split(separator: "-", omittingEmptySubsequences: false)
            guard (1...2).contains(ends.count), ends.allSatisfy({ (1...65535).contains(Int($0) ?? 0) }),
                  ends.count == 1 || Int(ends[0])! <= Int(ends[1])! else { throw DeskError("端口范围无效") }
        }
    }
    if rule.kind == .network, !["tcp", "udp"].contains(value.lowercased()) { throw DeskError("NETWORK 只能选择 tcp / udp") }
    if rule.kind.isLogic {
        var depth = 0
        for char in value {
            if char == "(" { depth += 1 }
            if char == ")" { depth -= 1 }
            if depth < 0 { throw DeskError("逻辑规则括号不匹配") }
        }
        guard depth == 0, value.hasPrefix("("), value.hasSuffix(")") else { throw DeskError("逻辑规则需要完整括号表达式") }
    }
    if rule.kind == .ruleSet {
        guard settings.options?["rule-providers"]?.object[value] != nil else { throw DeskError("请先配置规则集合：\(value)") }
    }
    if rule.kind == .subRule {
        guard let name = rule.subRuleTarget, settings.options?["sub-rules"]?.object[name] != nil else { throw DeskError("请先配置并选择子规则") }
    }
}

public func controllerEndpoint(_ settings: Settings) throws -> (host: String, port: Int, secret: String) {
    let address = settings.options?["external-controller"]?.text ?? "127.0.0.1:19090"
    guard let url = URLComponents(string: "http://" + address), let host = url.host, let port = url.port,
          (1...65535).contains(port), url.path.isEmpty, url.query == nil, url.user == nil else {
        throw DeskError("external-controller 必须为有效 host:port，GUI 与统计后台需要这个接口")
    }
    let destination = host == "0.0.0.0" ? "127.0.0.1" : host == "::" || host == "[::]" ? "::1" : host
    let secret = settings.options?["secret"]?.text ?? settings.secret
    guard !secret.unicodeScalars.contains(where: { CharacterSet.controlCharacters.contains($0) }) else { throw DeskError("secret 不能包含控制字符") }
    return (destination, port, secret)
}

public func validateRuleResources(_ settings: Settings) throws {
    for (name, value) in settings.options?["rule-providers"]?.object ?? [:] {
        let fields = value.object
        guard !name.isEmpty, !name.contains(","), ["http", "file", "inline"].contains(fields["type"]?.text ?? ""),
              ["domain", "ipcidr", "classical"].contains(fields["behavior"]?.text ?? "") else {
            throw DeskError("规则集合 \(name) 需要有效的 type 与 behavior")
        }
        if fields["type"]?.text == "http" {
            guard let url = URL(string: fields["url"]?.text ?? ""), url.scheme == "https", url.host != nil else { throw DeskError("规则集合 \(name) 需要 HTTPS url") }
        }
        if fields["type"]?.text == "file", (fields["path"]?.text ?? "").isEmpty { throw DeskError("文件规则集合 \(name) 需要 path") }
        if fields["type"]?.text == "inline", fields["payload"] == nil { throw DeskError("内联规则集合 \(name) 需要 payload 列表") }
    }
}

public func geoAssetsNeeded(_ settings: Settings) -> [String] {
    var names = [settings.options?["geodata-mode"] == .boolean(true) ? "geoip.dat" : "Country.mmdb", "geosite.dat"]
    let nested = (settings.options?["sub-rules"]?.object.values.flatMap(\.array) ?? [])
        + (settings.options?["rule-providers"]?.object.values.flatMap { $0.object["payload"]?.array ?? [] } ?? [])
    if settings.rules.contains(where: { $0.kind == .ipASN || $0.kind == .sourceASN || $0.value.contains("IP-ASN,") })
        || nested.contains(where: { $0.text.contains("IP-ASN,") }) { names.append("ASN.mmdb") }
    return names
}

public func geoDownloadURLs(_ settings: Settings) -> [String: String] {
    let pairs = [("Country.mmdb", "mmdb"), ("geoip.dat", "geoip"), ("geosite.dat", "geosite"), ("ASN.mmdb", "asn")]
    return Dictionary(uniqueKeysWithValues: pairs.compactMap { name, key in
        guard let url = settings.options?["geox-url." + key]?.text else { return nil }
        return (name, url)
    })
}

public func validateGeneralOptions(_ config: [String: Any]) throws {
    for key in ["mixed-port", "port", "socks-port"] {
        if let value = config[key] as? Int, !(0...65535).contains(value) { throw DeskError("\(key) 必须为 0–65535") }
    }
    if let tun = config["tun"] as? [String: Any] {
        if let device = tun["device"] as? String, !device.hasPrefix("utun") { throw DeskError("macOS TUN 网卡名称必须以 utun 开头") }
        if let mtu = tun["mtu"] as? Int, !(576...65535).contains(mtu) { throw DeskError("TUN MTU 必须为 576–65535") }
        if tun["include-interface"] != nil, tun["exclude-interface"] != nil { throw DeskError("include-interface 与 exclude-interface 不能同时设置") }
    }
    if let dns = config["dns"] as? [String: Any], dns["enable"] as? Bool == true, dns["respect-rules"] as? Bool == true,
       (dns["proxy-server-nameserver"] as? [Any] ?? []).isEmpty { throw DeskError("DNS respect-rules 需要配置 proxy-server-nameserver") }
}

public func loadRuntimeSettings(from directory: URL) throws -> Settings {
    let url = directory.appendingPathComponent("runtime.json")
    guard FileManager.default.fileExists(atPath: url.path) else { return try loadSettings(from: directory) }
    return try JSONDecoder().decode(Settings.self, from: Data(contentsOf: url))
}

public func saveRuntimeSettings(_ settings: Settings, to directory: URL) throws {
    _ = try controllerEndpoint(settings)
    let url = directory.appendingPathComponent("runtime.json")
    try JSONEncoder().encode(settings).write(to: url, options: .atomic)
    try FileManager.default.setAttributes([.posixPermissions: 0o600], ofItemAtPath: url.path)
}
