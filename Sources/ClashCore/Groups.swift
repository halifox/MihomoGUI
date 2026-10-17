import Foundation

public struct ProxyGroup: Codable, Identifiable {
    public var id = UUID().uuidString
    public var name: String
    public var type: String
    public var targets: [String]
    public var fields: [String: ConfigValue]
    public init(name: String, type: String = "select", targets: [String] = [], fields: [String: ConfigValue] = [:]) {
        self.name = name; self.type = type; self.targets = targets; self.fields = fields
    }
}

public func groupEditorFields(_ type: String) -> [EditorField] {
    var fields: [EditorField] = [
        EditorField("disable-udp", kind: "boolean"),
        EditorField("include-all-proxies", kind: "boolean"),
        EditorField("filter"), EditorField("exclude-filter"), EditorField("exclude-type"),
        EditorField("empty-fallback", kind: "choice", choices: ["REJECT", "REJECT-DROP", "DIRECT"]),
        EditorField("default-selected"), EditorField("hidden", kind: "boolean"), EditorField("icon")
    ]
    fields.insert(contentsOf: [EditorField("url", hint: "https://www.gstatic.com/generate_204"),
            EditorField("interval", kind: "integer", hint: "300"), EditorField("timeout", kind: "integer", hint: "5000"),
            EditorField("lazy", kind: "boolean"), EditorField("max-failed-times", kind: "integer"), EditorField("expected-status", hint: "204")], at: 0)
    if type == "url-test" { fields.append(EditorField("tolerance", kind: "integer", hint: "50")) }
    if type == "load-balance" { fields.append(EditorField("strategy", kind: "choice", choices: ["consistent-hashing", "round-robin", "sticky-sessions"])) }
    // mihomo v1.19.32 adapter/outboundgroup/parser.go and provider/healthcheck.go.
    for index in fields.indices {
        switch fields[index].path {
        case "lazy": fields[index].defaultValue = .boolean(true)
        case "url": fields[index].defaultValue = .string("https://www.gstatic.com/generate_204")
        case "interval": fields[index].defaultValue = .integer(type == "select" ? 0 : 300)
        case "timeout": fields[index].defaultValue = .integer(5000)
        default: break
        }
    }
    return fields
}

public func ruleProviderEditorFields(_ type: String) -> [EditorField] {
    var fields: [EditorField] = [EditorField("behavior", kind: "choice", required: true, choices: ["domain", "ipcidr", "classical"])]
    if type != "inline" {
        var format = EditorField("format", kind: "choice", choices: ["yaml", "text", "mrs"])
        format.defaultHint = "yaml"
        fields.append(format)
    }
    if type == "http" {
        fields += [EditorField("url", hint: "https://example.com/rules.yaml", required: true),
            EditorField("interval", kind: "integer", hint: "600"), EditorField("size-limit", kind: "integer"),
            EditorField("header", kind: "map", elementKind: "list")]
    }
    if type == "file" { fields.append(EditorField("path", hint: "本地规则文件路径", required: true)) }
    if type == "inline" { fields.append(EditorField("payload", kind: "list", required: true, elementKind: "string")) }
    return fields
}

public func referencedNode(_ target: String) -> Node? {
    guard target.hasPrefix("node:") else { return nil }
    let parts = target.dropFirst(5).split(separator: "/", maxSplits: 1).map(String.init)
    guard parts.count == 2 else { return nil }
    return Node(provider: parts[0], name: parts[1])
}

// Shared by the member pickers and default-selection validation.
public func proxyGroupTargets(_ group: ProxyGroup, settings: Settings) -> [String] {
    var targets = group.targets
    if group.fields["include-all-proxies"] == .boolean(true) {
        var imported: [(target: String, name: String)] = (settings.manualProxies ?? []).map {
            ("node:" + $0.node.id, $0.name)
        }
        for (sourceIndex, source) in settings.subscriptions.enumerated() {
            for (index, entry) in (settings.subscriptionProxies?[source.id] ?? []).enumerated() {
                guard let name = entry.object["name"]?.text else { continue }
                imported.append(("node:" + Node(provider: source.provider, name: name).id,
                                 subscriptionProxyAlias(sourceIndex: sourceIndex, proxyIndex: index)))
            }
        }
        let filter = group.fields["filter"]?.text ?? ""
        for entry in imported.sorted(by: { $0.name < $1.name }) {
            if filter.isEmpty || filter.components(separatedBy: "`").contains(where: {
                entry.name.range(of: $0, options: .regularExpression) != nil
            }) {
                targets.append(entry.target)
            }
        }
    }
    var seen = Set<String>()
    return targets.filter { seen.insert($0).inserted }
}

public func validateProxyGroups(_ settings: Settings) throws {
    let groups = settings.proxyGroups ?? []
    let names = Set(groups.map(\.name))
    guard names.count == groups.count else { throw DeskError("代理组名称不能重复") }
    let manualNames = Set((settings.manualProxies ?? []).map(\.name))
    for group in groups {
        guard !group.name.isEmpty, !group.name.hasPrefix("CD."), !group.name.contains(","),
              !group.name.unicodeScalars.contains(where: { CharacterSet.controlCharacters.contains($0) }),
              !["DIRECT", "REJECT", "REJECT-DROP", "GLOBAL", "PASS", "COMPATIBLE"].contains(group.name),
              !manualNames.contains(group.name) else { throw DeskError("代理组名称无效或与代理名称重复") }
        guard ["select", "url-test", "fallback", "load-balance"].contains(group.type) else { throw DeskError("不支持的代理组类型") }
        try validateFieldValues(group.fields, schema: groupEditorFields(group.type))
        guard !group.targets.isEmpty || group.fields["include-all-proxies"] == .boolean(true) else { throw DeskError("代理组至少需要一个成员") }
        guard Set(group.targets).count == group.targets.count else { throw DeskError("代理组成员不能重复") }
        for target in group.targets {
            if target.hasPrefix("group:") {
                guard names.contains(String(target.dropFirst(6))) else { throw DeskError("代理组引用了不存在的代理组") }
            } else if let node = referencedNode(target) {
                guard node.provider == "manual" ? manualNames.contains(node.name) : settings.subscriptions.contains(where: { $0.provider == node.provider }) else {
                    throw DeskError("代理组引用了已删除的节点来源")
                }
            } else if !["builtin:DIRECT", "builtin:REJECT", "builtin:REJECT-DROP"].contains(target) { throw DeskError("代理组成员无效") }
        }
        if let selected = group.fields["default-selected"]?.text, !selected.isEmpty, !proxyGroupTargets(group, settings: settings).contains(selected) {
            throw DeskError("默认成员必须在代理组成员列表中")
        }
        for key in ["interval", "timeout", "tolerance", "max-failed-times"] {
            if let value = group.fields[key], case .integer(let number) = value, number < 0 { throw DeskError("\(key) 不能为负数") }
        }
        if let address = group.fields["url"]?.text, !address.isEmpty {
            guard let url = URL(string: address), ["http", "https"].contains(url.scheme ?? ""), url.host != nil else { throw DeskError("代理组测速地址无效") }
        }
    }
    var visiting: Set<String> = []; var done: Set<String> = []
    func visit(_ name: String) throws {
        guard !done.contains(name) else { return }
        guard visiting.insert(name).inserted else { throw DeskError("代理组不能循环引用") }
        for target in groups.first(where: { $0.name == name })?.targets ?? [] where target.hasPrefix("group:") { try visit(String(target.dropFirst(6))) }
        visiting.remove(name); done.insert(name)
    }
    for name in names { try visit(name) }
    if let name = settings.defaultProxyGroup, !names.contains(name) { throw DeskError("MATCH 引用了不存在的代理组") }
    for rule in settings.rules { if let name = rule.proxyGroup, !names.contains(name) { throw DeskError("路由规则引用了不存在的代理组") } }
}
