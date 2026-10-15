import Foundation

public func readConfigurationYAML(_ file: URL) throws -> [String: Any] {
    let size = try file.resourceValues(forKeys: [.fileSizeKey]).fileSize ?? 0
    guard size > 0, size <= 16 * 1024 * 1024 else { throw DeskError("配置为空或超过 16 MiB") }
    let output = FileManager.default.temporaryDirectory.appendingPathComponent("clashdesk-import-" + UUID().uuidString)
    FileManager.default.createFile(atPath: output.path, contents: nil, attributes: [.posixPermissions: 0o600])
    defer { try? FileManager.default.removeItem(at: output) }
    let handle = try FileHandle(forWritingTo: output)
    defer { try? handle.close() }
    let process = Process(); process.executableURL = URL(fileURLWithPath: "/usr/bin/ruby")
    process.arguments = ["-ryaml", "-rjson", "-e", #"doc=YAML.safe_load(File.read(ARGV[0]), [], [], false); abort unless doc.is_a?(Hash); def clean(v,d=0); abort if d>64; case v; when Hash; v.each_with_object({}){|(k,x),h| h[k]=clean(x,d+1) unless x.nil?}; when Array; v.compact.map{|x|clean(x,d+1)}; else; v; end; end; puts JSON.generate(clean(doc))"#, file.path]
    process.standardOutput = handle; process.standardError = FileHandle.nullDevice
    try process.run(); process.waitUntilExit()
    guard process.terminationStatus == 0, let object = try JSONSerialization.jsonObject(with: Data(contentsOf: output)) as? [String: Any] else { throw DeskError("无法解析 YAML，请展开 aliases 并检查格式") }
    return object
}

public func importConfiguration(_ object: [String: Any], corePath: String) throws -> Settings {
    guard (object["proxy-providers"] as? [String: Any] ?? [:]).isEmpty else { throw DeskError("请先将 proxy-providers 展开为 proxies，再导入；不会忽略节点来源") }
    var settings = Settings(); settings.corePath = corePath
    settings.tun = (object["tun"] as? [String: Any])?["enable"] as? Bool ?? false
    let proxies = object["proxies"] as? [[String: Any]] ?? []
    var names: [String: String] = [:]
    for (index, proxy) in proxies.enumerated() {
        guard let name = proxy["name"] as? String else { throw DeskError("节点缺少名称") }
        guard names[name] == nil else { throw DeskError("节点名称重复") }
        names[name] = name.hasPrefix("CD.") ? "Imported-\(index)-" + name : name
    }
    settings.manualProxies = try proxies.map { proxy in
        guard let type = proxy["type"] as? String, let name = proxy["name"] as? String else { throw DeskError("节点缺少类型或名称") }
        var fields = proxy.mapValues { ConfigValue(native: $0) }; fields.removeValue(forKey: "type"); fields["name"] = .string(names[name]!)
        if let dialer = fields["dialer-proxy"]?.text, let mapped = names[dialer] { fields["dialer-proxy"] = .string(mapped) }
        return ManualProxy(type: type, fields: fields)
    }
    let groups = object["proxy-groups"] as? [[String: Any]] ?? []
    let groupNames = Set(groups.compactMap { $0["name"] as? String })
    var groupMapping: [String: String] = [:]
    for (index, group) in groups.enumerated() {
        if let name = group["name"] as? String { groupMapping[name] = name.hasPrefix("CD.") ? "Imported-Group-\(index)" : name }
    }
    func target(_ name: String) throws -> String {
        if ["DIRECT", "REJECT", "REJECT-DROP"].contains(name) { return "builtin:" + name }
        if groupNames.contains(name) { return "group:" + groupMapping[name]! }
        if let name = names[name] { return "node:manual/" + name }
        throw DeskError("出口不存在：" + name)
    }
    settings.proxyGroups = try groups.map { group in
        guard let name = group["name"] as? String, let type = group["type"] as? String else { throw DeskError("代理组缺少名称或类型") }
        guard (group["use"] as? [String] ?? []).isEmpty else { throw DeskError("请先展开代理组的 use 节点来源") }
        var fields = group.mapValues { ConfigValue(native: $0) }
        for key in ["name", "type", "proxies", "use"] { fields.removeValue(forKey: key) }
        if let selected = fields["default-selected"]?.text, !selected.isEmpty { fields["default-selected"] = .string(try target(selected)) }
        return ProxyGroup(name: groupMapping[name]!, type: type, targets: try (group["proxies"] as? [String] ?? []).map(target), fields: fields)
    }
    func apply(_ target: String, rule: inout RouteRule) {
        rule.node = referencedNode(target)
        rule.proxyGroup = target.hasPrefix("group:") ? String(target.dropFirst(6)) : nil
        rule.builtin = target.hasPrefix("builtin:") ? String(target.dropFirst(8)) : nil
    }
    var matched = false
    for raw in object["rules"] as? [String] ?? [] {
        var parts: [String] = []; var depth = 0; var piece = ""
        for char in raw {
            if char == "(" { depth += 1 }; if char == ")" { depth -= 1 }
            if char == "," && depth == 0 { parts.append(piece); piece = "" } else { piece.append(char) }
        }
        parts.append(piece)
        guard !matched else { throw DeskError("MATCH 后仍有规则，请先调整配置") }
        if parts.first == "MATCH", parts.count == 2 {
            let resolved = try target(parts[1]); settings.defaultNode = referencedNode(resolved)
            settings.defaultProxyGroup = resolved.hasPrefix("group:") ? String(resolved.dropFirst(6)) : nil
            settings.defaultPolicy = resolved.hasPrefix("builtin:") ? String(resolved.dropFirst(8)) : nil
            settings.defaultDirect = settings.defaultPolicy == "DIRECT"; matched = true; continue
        }
        guard parts.count >= 3, let kind = RuleKind(rawValue: parts[0]) else { throw DeskError("不支持的规则：" + (parts.first ?? "")) }
        var rule = RouteRule(kind: kind, value: parts[1], node: nil)
        if kind == .subRule { rule.subRuleTarget = parts[2] } else { apply(try target(parts[2]), rule: &rule) }
        let flags = parts.dropFirst(3)
        guard flags.allSatisfy({ ["no-resolve", "src"].contains($0) }) else { throw DeskError("不支持的规则选项") }
        rule.noResolve = flags.contains("no-resolve"); rule.sourceIP = flags.contains("src")
        settings.rules.append(rule)
    }
    if !matched { settings.defaultPolicy = "REJECT" }
    var options = object.filter { !["proxies", "proxy-groups", "proxy-providers", "rules"].contains($0.key) }.mapValues { ConfigValue(native: $0) }
    if let secret = object["secret"] as? String { settings.secret = secret }
    var providers = options["rule-providers"]?.object ?? [:]
    for name in providers.keys {
        var fields = providers[name]?.object ?? [:]
        if let proxy = fields["proxy"]?.text, !proxy.isEmpty { fields["proxy"] = .string(try target(proxy)) }
        providers[name] = .object(fields)
    }
    if !providers.isEmpty { options["rule-providers"] = .object(providers) }
    // Store editable documented leaves using the same paths as visual controls.
    func flatten(_ fields: [EditorField]) -> [EditorField] { fields.flatMap { $0.kind == "group" ? flatten($0.children ?? []) : [$0] } }
    for field in flatten(documentSchemas.configuration) where field.path.contains(".") {
        if let value = configPath(field.path, in: object) { options[field.path] = ConfigValue(native: value) }
    }
    for root in ["dns", "tun", "sniffer", "external-controller-cors"] {
        if let nested = object[root] as? [String: Any] {
            for (key, value) in nested {
                let path = root + "." + key
                // Preserve unknown fields; do not retain the parent alongside editable leaves.
                if !options.keys.contains(where: { $0 == path || $0.hasPrefix(path + ".") }) { options[path] = ConfigValue(native: value) }
            }
            options.removeValue(forKey: root)
        }
    }
    if object["dns"] == nil { options["dns.enable"] = .boolean(false) }
    settings.options = options
    _ = try generateConfig(settings)
    return settings
}

public func importNodeLinks(_ input: String) throws -> [ManualProxy] {
    func decode(_ text: String) -> Data? {
        var text = text.replacingOccurrences(of: "-", with: "+").replacingOccurrences(of: "_", with: "/")
        text += String(repeating: "=", count: (4 - text.count % 4) % 4)
        return Data(base64Encoded: text)
    }
    var text = input.trimmingCharacters(in: .whitespacesAndNewlines)
    guard text.utf8.count <= 1024 * 1024 else { throw DeskError("节点文本超过 1 MiB") }
    if !text.contains("://"), let data = decode(text.filter { !$0.isWhitespace }), let decoded = String(data: data, encoding: .utf8) { text = decoded }
    var result: [ManualProxy] = []
    for line in text.components(separatedBy: .newlines).map({ $0.trimmingCharacters(in: .whitespacesAndNewlines) }).filter({ !$0.isEmpty }) {
        guard let url = URLComponents(string: line), let scheme = url.scheme else { throw DeskError("节点链接格式无效") }
        var fields: [String: ConfigValue] = [:]
        let type = ["hy2": "hysteria2", "socks5": "socks5", "socks": "socks5" ][scheme] ?? scheme
        if scheme == "vmess" {
            let encoded = String(line.dropFirst("vmess://".count))
            guard let data = decode(encoded), let value = try JSONSerialization.jsonObject(with: data) as? [String: Any] else { throw DeskError("VMess Base64 JSON 无效") }
            let supported = Set(["v", "ps", "add", "port", "id", "aid", "scy", "net", "type", "host", "path", "tls", "sni", "alpn", "fp"])
            guard Set(value.keys).isSubset(of: supported) else { throw DeskError("VMess JSON 包含暂不支持的字段，请使用 YAML") }
            if let alpn = value["alpn"] as? String, !alpn.isEmpty { fields["alpn"] = .array(alpn.split(separator: ",").map { .string(String($0)) }) }
            if let fp = value["fp"] as? String, !fp.isEmpty { fields["client-fingerprint"] = .string(fp) }
            fields["name"] = .string(value["ps"] as? String ?? "VMess")
            fields["server"] = .string(value["add"] as? String ?? "")
            fields["port"] = .integer(Int(String(describing: value["port"] ?? "")) ?? 0)
            fields["uuid"] = .string(value["id"] as? String ?? "")
            fields["alterId"] = .integer(Int(String(describing: value["aid"] ?? "0")) ?? 0)
            fields["cipher"] = .string(value["scy"] as? String ?? "auto")
            fields["tls"] = .boolean(value["tls"] as? String == "tls")
            if let sni = value["sni"] as? String, !sni.isEmpty { fields["servername"] = .string(sni) }
            let network = value["net"] as? String ?? "tcp"
            guard ["tcp", "ws"].contains(network), (value["type"] as? String ?? "none") == "none" else { throw DeskError("VMess 链接目前支持 TCP / WebSocket，无额外伪装；其他传输请用 YAML") }
            if network == "ws" {
                fields["network"] = .string("ws")
                fields["ws-opts.path"] = .string(value["path"] as? String ?? "/")
                if let host = value["host"] as? String, !host.isEmpty { fields["ws-opts.headers"] = .object(["Host": .string(host)]) }
            }
        } else {
            guard ["ss", "vless", "trojan", "hysteria2", "hy2", "tuic", "socks", "socks5", "http", "https"].contains(scheme), let host = url.host, let port = url.port else { throw DeskError("不支持的节点链接或缺少服务器 / 端口，请使用 YAML") }
            fields["name"] = .string(url.fragment ?? host)
            fields["server"] = .string(host); fields["port"] = .integer(port)
            let user = url.user ?? ""
            switch type {
            case "ss":
                let credential = url.password.map { user + ":" + $0 } ?? decode(user).flatMap { String(data: $0, encoding: .utf8) } ?? ""
                let parts = credential.split(separator: ":", maxSplits: 1, omittingEmptySubsequences: false)
                guard parts.count == 2 else { throw DeskError("Shadowsocks 认证格式无效") }
                fields["cipher"] = .string(String(parts[0])); fields["password"] = .string(String(parts[1]))
            case "vless": fields["uuid"] = .string(user)
            case "tuic": fields["uuid"] = .string(user); fields["password"] = .string(url.password ?? "")
            case "trojan", "hysteria2": fields["password"] = .string(url.password.map { user + ":" + $0 } ?? user)
            default:
                fields["username"] = .string(user); fields["password"] = .string(url.password ?? "")
                if scheme == "https" { fields["tls"] = .boolean(true) }
            }
            for item in url.queryItems ?? [] {
                let value = item.value ?? ""
                switch item.name {
                case "sni", "peer": fields[["vmess", "vless"].contains(type) ? "servername" : "sni"] = .string(value)
                case "security":
                    guard ["tls", "none", "reality"].contains(value) else { throw DeskError("不支持的 security 参数") }
                    fields["tls"] = .boolean(value != "none")
                case "type":
                    guard ["tcp", "ws", "grpc"].contains(value) else { throw DeskError("不支持的传输参数，请用 YAML") }
                    if value != "tcp" { fields["network"] = .string(value) }
                case "path": fields["ws-opts.path"] = .string(value)
                case "host": fields["ws-opts.headers"] = .object(["Host": .string(value)])
                case "serviceName": fields["grpc-opts.grpc-service-name"] = .string(value)
                case "fp": fields["client-fingerprint"] = .string(value)
                case "pbk": fields["reality-opts.public-key"] = .string(value)
                case "sid": fields["reality-opts.short-id"] = .string(value)
                case "flow": fields["flow"] = .string(value)
                case "alpn": fields["alpn"] = .array(value.split(separator: ",").map { .string(String($0)) })
                case "insecure", "allowInsecure":
                    guard ["0", "1", "true", "false"].contains(value) else { throw DeskError("insecure 参数无效") }
                    fields["skip-cert-verify"] = .boolean(["1", "true"].contains(value))
                case "encryption": guard value == "none" else { throw DeskError("不支持的 encryption 参数") }
                default: throw DeskError("暂不支持链接参数：" + item.name + "，请使用 YAML 导入")
                }
            }
        }
        let proxy = ManualProxy(type: scheme == "https" ? "http" : type, fields: fields)
        let allowed = Set(documentSchemas.proxies.first { $0.key == proxy.type }?.fields.map(\.path) ?? [])
        guard Set(fields.keys).isSubset(of: allowed) else { throw DeskError("链接参数不适用于 " + proxy.type + "，请使用 YAML") }
        if fields.keys.contains(where: { $0.hasPrefix("ws-opts.") }), fields["network"]?.text != "ws" { throw DeskError("WebSocket 参数需要 type=ws") }
        if fields.keys.contains(where: { $0.hasPrefix("grpc-opts.") }), fields["network"]?.text != "grpc" { throw DeskError("gRPC 参数需要 type=grpc") }
        _ = try proxy.configuration(); result.append(proxy)
    }
    guard !result.isEmpty else { throw DeskError("没有可导入节点") }
    guard Set(result.map(\.name)).count == result.count else { throw DeskError("节点名称重复，请修改链接名称") }
    return result
}

public func configurationDifference(_ current: Settings, applied: Settings) throws -> [String] {
    let a = ConfigValue(native: try configurationObject(applied)), b = ConfigValue(native: try configurationObject(current))
    var result: [String] = []
    func summary(_ value: ConfigValue?, path: String) -> String {
        guard let value else { return "未设置" }
        let sensitive = ["secret", "password", "uuid", "private-key", "token", "public-key", "auth"].contains { path.lowercased().contains($0) }
        if sensitive || path.lowercased().contains("header") || path.lowercased().contains("authentication") || value.text.contains("://") { return "已设置（隐藏）" }
        switch value {
        case .array(let values): return "\(values.count) 项"
        case .object(let values): return "\(values.count) 个字段"
        default: return String(value.text.prefix(120))
        }
    }
    func compare(_ a: ConfigValue?, _ b: ConfigValue?, path: String) {
        guard a != b else { return }
        if case .object(let old)? = a, case .object(let new)? = b {
            for key in Set(old.keys).union(new.keys).sorted() { compare(old[key], new[key], path: path.isEmpty ? key : path + "." + key) }
        } else if case .array(let old)? = a, case .array(let new)? = b {
            let changed = zip(old, new).filter { $0 != $1 }.count + abs(old.count - new.count)
            result.append("• \(path)：\(old.count) 项 → \(new.count) 项，\(changed) 项变化")
            for index in 0..<max(old.count, new.count) {
                compare(old.indices.contains(index) ? old[index] : nil, new.indices.contains(index) ? new[index] : nil, path: path + "[\(index + 1)]")
            }
        } else { result.append("• \(path)：\(summary(a, path: path)) → \(summary(b, path: path))") }
    }
    compare(a, b, path: "")
    if current.corePath != applied.corePath { result.insert("• 内核文件已变更", at: 0) }
    return result
}

public func replacingNodeReferences(_ settings: Settings, old: String, target: String, nodes: [Node]) throws -> Settings {
    guard target != old else { throw DeskError("请选择有效出口") }
    var candidate = settings
    let node = nodes.first { "node:" + $0.id == target }
    let group = target.hasPrefix("group:") ? String(target.dropFirst(6)) : nil
    let builtin = target.hasPrefix("builtin:") ? String(target.dropFirst(8)) : nil
    guard node != nil || group != nil || builtin.map({ ["DIRECT", "REJECT", "REJECT-DROP"].contains($0) }) == true else { throw DeskError("替换出口不存在") }
    for index in candidate.rules.indices where candidate.rules[index].node.map({ "node:" + $0.id }) == old {
        candidate.rules[index].node = node; candidate.rules[index].proxyGroup = group; candidate.rules[index].builtin = builtin
    }
    if candidate.defaultNode.map({ "node:" + $0.id }) == old {
        candidate.defaultNode = node; candidate.defaultProxyGroup = group; candidate.defaultPolicy = builtin; candidate.defaultDirect = builtin == "DIRECT"
    }
    for index in candidate.proxyGroups?.indices ?? 0..<0 {
        let targets = candidate.proxyGroups?[index].targets ?? []
        candidate.proxyGroups?[index].targets = Array(NSOrderedSet(array: targets.map { $0 == old ? target : $0 })) as? [String] ?? []
        if candidate.proxyGroups?[index].fields["default-selected"]?.text == old { candidate.proxyGroups?[index].fields["default-selected"] = .string(target) }
    }
    var providers = candidate.options?["rule-providers"]?.object ?? [:]
    for name in providers.keys {
        var fields = providers[name]?.object ?? [:]
        if fields["proxy"]?.text == old { fields["proxy"] = .string(target) }
        providers[name] = .object(fields)
    }
    candidate.options?["rule-providers"] = .object(providers)
    _ = try generateConfig(candidate)
    return candidate
}
