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
    public var document: String?
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
    public var configuration: [EditorField]
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
        try validateFieldValues(fields, schema: ruleProviderEditorFields(fields["type"]?.text ?? ""))
        if let target = fields["proxy"]?.text {
            if target.hasPrefix("group:") {
                guard (settings.proxyGroups ?? []).contains(where: { $0.name == String(target.dropFirst(6)) }) else { throw DeskError("规则集合下载出口引用了不存在的代理组") }
            } else if let node = referencedNode(target) {
                guard node.provider == "manual" ? (settings.manualProxies ?? []).contains(where: { $0.name == node.name }) : settings.subscriptions.contains(where: { $0.provider == node.provider }) else { throw DeskError("规则集合下载出口的节点来源已删除") }
            } else {
                let name = target.hasPrefix("builtin:") ? String(target.dropFirst(8)) : target
                guard ["DIRECT", "REJECT", "REJECT-DROP"].contains(name) || (settings.proxyGroups ?? []).contains(where: { $0.name == name }) || (settings.manualProxies ?? []).contains(where: { $0.name == name }) else { throw DeskError("规则集合下载出口无效") }
            }
        }
        if let format = fields["format"]?.text {
            guard ["yaml", "text", "mrs"].contains(format), !(format == "mrs" && fields["behavior"]?.text == "classical") else { throw DeskError("mrs 格式仅支持 domain / ipcidr") }
        }
        for key in ["interval", "size-limit"] {
            if let value = fields[key], case .integer(let number) = value, number < 0 { throw DeskError("规则集合 \(key) 不能为负数") }
        }
        if fields["type"]?.text == "http" {
            guard let url = URL(string: fields["url"]?.text ?? ""), ["http", "https"].contains(url.scheme ?? ""), url.host != nil else { throw DeskError("规则集合 \(name) 需要 HTTP / HTTPS url") }
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

// Chinese labels follow the local Meta-Docs config descriptions. Unknown keys stay unchanged.
private let configFieldTitles: [String: String] = [
    "profile": "缓存",
    "external-controller-cors": "API 跨域访问配置",
    "geox-url": "GEO 下载地址",
    "dns.fallback-filter": "后备 DNS 筛选",
    "fallback-filter": "后备 DNS 筛选",
    "sniff.HTTP": "HTTP 嗅探",
    "sniff.TLS": "TLS 嗅探",
    "sniff.QUIC": "QUIC 嗅探",
    "allow-lan": "允许局域网",
    "bind-address": "绑定地址",
    "lan-allowed-ips": "允许连接的 IP 地址段",
    "lan-disallowed-ips": "禁止连接的 IP 地址段",
    "authentication": "用户验证",
    "skip-auth-prefixes": "允许跳过验证的 IP 地址段",
    "mode": "运行模式",
    "log-level": "日志级别",
    "ipv6": "接受 IPv6 流量",
    "keep-alive-interval": "TCP 保活间隔（秒）",
    "keep-alive-idle": "TCP 保活最大空闲时间（秒）",
    "disable-keep-alive": "禁用 TCP 保活",
    "find-process-mode": "进程匹配模式",
    "external-controller": "API 监听地址",
    "external-controller-cors.allow-origins": "API 允许的来源",
    "external-controller-cors.allow-private-network": "API 允许私有网络访问",
    "external-controller-unix": "Unix Socket API 监听地址",
    "external-controller-tls": "HTTPS API 监听地址",
    "external-doh-server": "DOH 服务器路径",
    "secret": "API 访问密钥",
    "external-ui": "外部用户界面路径",
    "external-ui-name": "外部用户界面名字",
    "external-ui-url": "外部用户界面下载地址",
    "profile.store-selected": "保存策略组选择",
    "profile.store-fake-ip": "保存 Fake-IP 映射",
    "unified-delay": "统一延迟",
    "tcp-concurrent": "TCP 并发",
    "interface-name": "出站接口",
    "routing-mark": "路由标记",
    "tls.certificate": "API TLS 证书",
    "tls.private-key": "API TLS 私钥",
    "tls.ech-key": "API ECH 密钥",
    "geodata-mode": "GEOIP 数据模式",
    "geodata-loader": "GEO 文件加载模式",
    "geo-auto-update": "自动更新 GEO",
    "geo-update-interval": "GEO 更新间隔（小时）",
    "geox-url.geoip": "GEOIP 下载地址",
    "geox-url.geosite": "GEOSITE 下载地址",
    "geox-url.mmdb": "MMDB 下载地址",
    "geox-url.asn": "ASN 下载地址",
    "global-ua": "全局用户代理（UA）",
    "etag-support": "ETag 支持",
    "port": "服务器端口",
    "socks-port": "SOCKS 代理端口",
    "mixed-port": "混合代理端口",
    "dns.enable": "启用 DNS",
    "dns.cache-algorithm": "DNS 缓存算法",
    "dns.prefer-h3": "DOH 优先使用 HTTP/3",
    "dns.listen": "DNS 监听地址",
    "dns.ipv6": "解析 IPv6",
    "dns.enhanced-mode": "DNS 处理模式",
    "dns.fake-ip-range": "Fake-IP IPv4 地址段",
    "dns.fake-ip-range6": "Fake-IP IPv6 地址段",
    "dns.fake-ip-filter": "Fake-IP 过滤列表",
    "dns.fake-ip-filter-mode": "Fake-IP 过滤模式",
    "dns.fake-ip-ttl": "Fake-IP 查询 TTL",
    "dns.use-hosts": "使用配置中的 hosts",
    "dns.use-system-hosts": "使用系统 hosts",
    "dns.respect-rules": "DNS 连接遵守路由规则",
    "dns.default-nameserver": "DNS 服务器域名解析服务器",
    "dns.nameserver-policy": "域名解析策略",
    "dns.proxy-server-nameserver": "代理节点域名解析服务器",
    "dns.proxy-server-nameserver-policy": "代理节点域名解析策略",
    "dns.direct-nameserver": "直连域名解析服务器",
    "dns.direct-nameserver-follow-policy": "直连解析遵循域名解析策略",
    "dns.nameserver": "默认域名解析服务器",
    "dns.fallback": "后备域名解析服务器",
    "dns.fallback-filter.geoip": "启用 GEOIP 判断",
    "dns.fallback-filter.geoip-code": "采用解析结果的国家代码",
    "dns.fallback-filter.geosite": "使用后备解析的 GEOSITE 集合",
    "dns.fallback-filter.ipcidr": "视为污染的 IP 地址段",
    "dns.fallback-filter.domain": "使用后备解析的域名",
    "dns.fallback-lazy-query": "按需发起后备 DNS 查询",
    "hosts": "静态域名映射",
    "tun.enable": "启用 TUN",
    "tun.stack": "TUN 协议栈",
    "tun.device": "TUN 网卡名称",
    "tun.auto-route": "自动配置路由",
    "tun.auto-detect-interface": "自动识别出站接口",
    "tun.dns-hijack": "DNS 劫持",
    "tun.strict-route": "严格路由",
    "tun.mtu": "最大传输单元（MTU）",
    "tun.gso": "通用分段卸载（GSO）",
    "tun.gso-max-size": "GSO 最大分段大小",
    "tun.inet6-address": "TUN IPv6 地址",
    "tun.udp-timeout": "UDP 超时时间（秒）",
    "tun.endpoint-independent-nat": "独立于端点的 NAT",
    "tun.congestion-controller": "拥塞控制算法",
    "tun.route-address": "路由地址段",
    "tun.route-exclude-address": "排除的路由地址段",
    "tun.include-interface": "包含的网络接口",
    "tun.exclude-interface": "排除的网络接口",
    "sniffer.enable": "启用域名嗅探",
    "sniffer.force-dns-mapping": "强制嗅探 DNS 映射流量",
    "sniffer.parse-pure-ip": "强制嗅探纯 IP 流量",
    "sniffer.override-destination": "使用嗅探结果作为访问目标",
    "sniffer.force-domain": "强制嗅探的域名",
    "sniffer.skip-domain": "跳过嗅探的域名",
    "sniffer.skip-src-address": "跳过嗅探的来源 IP 地址段",
    "sniffer.skip-dst-address": "跳过嗅探的目标 IP 地址段",
    "sniffer.sniff.HTTP.ports": "HTTP 嗅探端口",
    "sniffer.sniff.TLS.ports": "TLS 嗅探端口",
    "sniffer.sniff.QUIC.ports": "QUIC 嗅探端口",
    "sniffer.sniff.HTTP.override-destination": "HTTP 嗅探结果覆盖访问目标",
    "name": "名称",
    "type": "类型",
    "server": "服务器地址",
    "username": "用户名",
    "password": "密码",
    "cipher": "加密方式",
    "uuid": "用户 UUID",
    "udp": "启用 UDP",
    "tfo": "TCP 快速打开",
    "mptcp": "多路径 TCP",
    "ip-version": "IP 版本",
    "network": "传输协议",
    "dialer-proxy": "拨号代理",
    "tls": "启用 TLS",
    "sni": "服务器名称指示（SNI）",
    "servername": "服务器名称指示（SNI）",
    "fingerprint": "证书指纹",
    "client-fingerprint": "客户端 TLS 指纹",
    "alpn": "应用层协议协商列表",
    "skip-cert-verify": "跳过证书验证",
    "name-cert-verify": "证书域名校验目标",
    "certificate": "证书",
    "private-key": "私钥",
    "public-key": "公钥",
    "pre-shared-key": "预共享密钥",
    "psk": "预共享密钥",
    "token": "认证令牌",
    "auth-str": "认证字符串",
    "obfs": "混淆方式",
    "obfs-password": "混淆密码",
    "obfs-param": "混淆参数",
    "protocol": "协议",
    "protocol-param": "协议参数",
    "ports": "端口范围",
    "up": "上传带宽",
    "down": "下载带宽",
    "mtu": "最大传输单元（MTU）",
    "headers": "HTTP 请求头",
    "reality-opts.public-key": "Reality 公钥",
    "reality-opts.short-id": "Reality 短 ID",
    "reality-opts.support-x25519mlkem768": "支持 X25519-MLKEM768 密钥交换",
    "ech-opts.enable": "启用 ECH",
    "ech-opts.config": "ECH 配置",
    "ech-opts.query-server-name": "ECH DNS 查询域名",
    "shadow-tls-opts.version": "ShadowTLS 版本",
    "shadow-tls-opts.password": "ShadowTLS 密码",
    "restls-opts.password": "Restls 密码",
    "restls-opts.version-hint": "Restls TLS 版本提示",
    "jls-opts.username": "JLS 用户名",
    "jls-opts.password": "JLS 密码",
    "smux.enabled": "启用多路复用",
    "smux.protocol": "多路复用协议",
    "smux.max-connections": "多路复用最大连接数",
    "smux.min-streams": "多路复用最小流数",
    "smux.max-streams": "多路复用最大流数",
    "smux.statistic": "多路复用统计",
    "smux.only-tcp": "仅复用 TCP",
    "smux.padding": "多路复用填充",
    "smux.brutal-opts.enabled": "启用 Brutal",
    "smux.brutal-opts.up": "Brutal 上传带宽",
    "smux.brutal-opts.down": "Brutal 下载带宽",
    "ws-opts.path": "WebSocket 路径",
    "ws-opts.headers": "WebSocket 请求头",
    "ws-opts.max-early-data": "WebSocket 最大早期数据",
    "ws-opts.early-data-header-name": "WebSocket 早期数据标头",
    "ws-opts.v2ray-http-upgrade": "WebSocket HTTP 升级",
    "ws-opts.v2ray-http-upgrade-fast-open": "HTTP 升级快速打开",
    "http-opts.method": "HTTP 请求方法",
    "http-opts.path": "HTTP 请求路径",
    "http-opts.headers": "HTTP 请求头",
    "h2-opts.host": "HTTP/2 主机",
    "h2-opts.path": "HTTP/2 路径",
    "grpc-opts.grpc-service-name": "gRPC 服务名称",
    "grpc-opts.grpc-user-agent": "gRPC 用户代理",
    "congestion-controller": "拥塞控制算法",
    "udp-relay-mode": "UDP 转发模式",
    "packet-encoding": "数据包编码",
    "hop-interval": "端口跳跃间隔",
    "bbr-profile": "BBR 配置档位",
    "flow": "流控方式",
    "plugin": "插件",
    "proxies": "代理成员",
    "use": "引入代理集合",
    "url": "地址",
    "interval": "间隔（秒）",
    "timeout": "超时时间（毫秒）",
    "lazy": "未选中时不测试",
    "max-failed-times": "最大失败次数",
    "expected-status": "期望 HTTP 状态码",
    "disable-udp": "禁用 UDP",
    "include-all-proxies": "引入所有代理节点",
    "filter": "节点筛选表达式",
    "exclude-filter": "节点排除表达式",
    "exclude-type": "排除的节点类型",
    "empty-fallback": "空组回退代理",
    "default-selected": "默认选择的节点",
    "hidden": "隐藏代理组",
    "icon": "图标",
    "tolerance": "延迟容差（毫秒）",
    "strategy": "负载均衡策略",
    "behavior": "规则集合行为",
    "format": "文件格式",
    "path": "文件路径",
    "proxy": "下载出口",
    "size-limit": "下载大小限制（字节）",
    "header": "HTTP 请求头",
    "payload": "规则内容",
]

public func configFieldTitle(_ key: String, document: String = "") -> String {
    if document == "general.md", key == "port" { return "HTTP(S) 代理端口" }
    if document.hasPrefix("proxy-groups/") {
        if key == "url" { return "健康检查测试地址" }
        if key == "interval" { return "健康检查间隔（秒）" }
    }
    if document.hasPrefix("rule-providers/") {
        if key == "url" { return "规则集合下载地址" }
        if key == "interval" { return "更新间隔（秒）" }
    }
    if document == "subscription", key == "url" { return "订阅地址" }
    if let title = configFieldTitles[key] { return title }
    // Nested options require an exact match to avoid translating unrelated or user-defined keys.
    return key
}
