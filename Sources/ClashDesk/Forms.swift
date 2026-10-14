import SwiftUI
import ClashCore

struct VisualField: View {
    let field: EditorField
    @Binding var value: ConfigValue?
    var allowUnset = true
    var compact = false
    var inputEnabled = true
    var body: some View {
        if compact { compactRow.controlSize(.regular) }
        else { legacyRow }
    }
    var compactRow: some View {
        HStack(alignment: field.kind == "list" || field.kind == "map" || field.kind == "object" ? .top : .center, spacing: 12) {
            FieldKeyLabel(title: field.title + (field.required ? " *" : ""), key: field.path,
                          description: field.description, hint: field.hint, kind: field.kind)
                .frame(width: 200, alignment: .leading)
            VisualValue(field: field, value: Binding(get: {
                value ?? (field.kind == "boolean" ? .boolean(false) : field.kind == "list" || field.kind == "map" || field.kind == "object" ? emptyValue(field) : .string(""))
            }, set: { value = $0 }), compact: true).disabled(!inputEnabled)
            Spacer(minLength: 0)
        }.padding(.vertical, 3)
    }
    var legacyRow: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                FieldKeyLabel(title: field.title, key: field.path, description: field.description, hint: field.hint, kind: field.kind)
                if field.required { Text("必填").font(.caption).foregroundStyle(.orange) }
                Spacer()
                if allowUnset && !field.required {
                    Toggle("设置此项", isOn: Binding(get: { value != nil }, set: { value = $0 ? emptyValue(field) : nil }))
                        .toggleStyle(.checkbox).font(.caption).help("未设置时使用内核默认值")
                }
            }
            VisualValue(field: field, value: Binding(get: { value ?? emptyValue(field) }, set: { value = $0 }))
                .disabled(value == nil && !field.required && allowUnset)
            if !field.description.isEmpty {
                Text(field.description).font(.caption).foregroundStyle(.secondary).fixedSize(horizontal: false, vertical: true)
            }
        }.padding(.vertical, 3)
    }
}

struct VisualValue: View {
    let field: EditorField
    @Binding var value: ConfigValue
    var compact = false
    var body: some View { input }
    private var text: Binding<String> {
        Binding(get: { value.text }, set: {
            if field.kind == "integer", let integer = Int($0) { value = .integer(integer) }
            else if field.kind == "number", let number = Double($0) { value = .number(number) }
            else { value = .string($0) }
        })
    }
    private var input: AnyView {
        switch field.kind {
        case "boolean":
            return AnyView(Toggle(compact ? "" : value == .boolean(true) ? "开启" : "关闭", isOn: Binding(get: { value == .boolean(true) }, set: { value = .boolean($0) })))
        case "choice":
            return AnyView(Picker("", selection: text) {
                if !(field.choices ?? []).contains(value.text) { Text(value.text.isEmpty ? "请选择" : value.text).tag(value.text) }
                ForEach(field.choices ?? [], id: \.self) { Text($0).tag($0) }
            }.labelsHidden())
        case "secret": return AnyView(SecureField(field.hint, text: text).textFieldStyle(.roundedBorder))
        case "list": return AnyView(ValueList(field: field, value: $value, compact: compact))
        case "map": return AnyView(ValueMap(field: field, value: $value, compact: compact))
        case "object":
            return AnyView(VStack(alignment: .leading) {
                ForEach(field.children ?? []) { child in
                    VisualField(field: child, value: Binding(get: { typedPath(child.path, in: value.object) }, set: {
                        var object = value.object; setTypedPath(child.path, value: $0, in: &object); value = .object(object)
                    }), compact: compact)
                }
            })
        default: return AnyView(TextField(field.hint, text: text).textFieldStyle(.roundedBorder))
        }
    }
}

func typedPath(_ path: String, in object: [String: ConfigValue]) -> ConfigValue? {
    let parts = path.split(separator: ".", maxSplits: 1).map(String.init)
    if parts.count == 1 { return object[path] }
    return typedPath(parts[1], in: object[parts[0]]?.object ?? [:])
}

func setTypedPath(_ path: String, value: ConfigValue?, in object: inout [String: ConfigValue]) {
    let parts = path.split(separator: ".", maxSplits: 1).map(String.init)
    if parts.count == 1 { object[path] = value; return }
    var nested = object[parts[0]]?.object ?? [:]
    setTypedPath(parts[1], value: value, in: &nested)
    object[parts[0]] = nested.isEmpty ? nil : .object(nested)
}

struct ValueList: View {
    let field: EditorField
    @Binding var value: ConfigValue
    var compact = false
    var item: EditorField {
        EditorField("item", kind: field.elementKind ?? "string", children: field.children)
    }
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            ForEach(value.array.indices, id: \.self) { index in
                HStack(alignment: .top) {
                    if item.kind == "object" {
                        DisclosureGroup("第 \(index + 1) 项") { element(index) }
                    } else { element(index) }
                    Button {
                        var array = value.array; guard array.indices.contains(index) else { return }
                        array.remove(at: index); value = .array(array)
                    } label: { formActionIcon("minus") }.buttonStyle(.bordered).controlSize(.regular).help("删除此项")
                }
            }
            Button {
                var array = value.array; array.append(emptyValue(item)); value = .array(array)
            } label: { Label("添加一项", systemImage: "plus") }.controlSize(.regular)
        }
    }
    func element(_ index: Int) -> some View {
        VisualValue(field: item, value: Binding(get: {
            value.array.indices.contains(index) ? value.array[index] : emptyValue(item)
        }, set: {
            var array = value.array; guard array.indices.contains(index) else { return }
            array[index] = $0; value = .array(array)
        }), compact: compact)
    }
}

struct ValueMap: View {
    let field: EditorField
    @Binding var value: ConfigValue
    var compact = false
    @State private var key = ""
    var item: EditorField { EditorField("value", kind: field.elementKind ?? "string", children: field.children) }
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            ForEach(value.object.keys.sorted(), id: \.self) { name in
                GroupBox {
                    HStack {
                        FieldKeyLabel(title: name, key: field.path + "." + name, description: "该键对应的配置值。可以按此项支持的格式填写单值或列表。")
                        Spacer()
                        if field.elementKind == "list" {
                            Picker("值类型", selection: Binding(get: {
                                if case .array = value.object[name] { return "list" }; return "string"
                            }, set: { kind in
                                var object = value.object
                                let current = object[name] ?? .string("")
                                if kind == "list" {
                                    if case .array = current { object[name] = current }
                                    else { object[name] = .array([current]) }
                                } else {
                                    if case .array = current { object[name] = current.array.first ?? .string("") }
                                    else { object[name] = current }
                                }
                                value = .object(object)
                            })) { Text("单值").tag("string"); Text("列表").tag("list") }.frame(width: 180)
                        }
                        Button { var object = value.object; object.removeValue(forKey: name); value = .object(object) }
                            label: { formActionIcon("minus") }.buttonStyle(.bordered).controlSize(.regular).help("删除此项")
                    }
                    VisualValue(field: itemSpec(name), value: Binding(get: { value.object[name] ?? emptyValue(item) }, set: {
                        var object = value.object; object[name] = $0; value = .object(object)
                    }), compact: compact)
                }
            }
            HStack {
                FieldKeyLabel(title: "key", key: "key", description: "新建键值条目的名称，不能与现有名称重复。").frame(width: 70, alignment: .leading)
                TextField("键 / 名称", text: $key).textFieldStyle(.roundedBorder)
                Button {
                    let name = key.trimmingCharacters(in: .whitespacesAndNewlines)
                    var object = value.object; object[name] = emptyValue(item); value = .object(object); key = ""
                } label: { Label("添加", systemImage: "plus") }.disabled(key.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || value.object[key] != nil)
            }
        }
    }
    func itemSpec(_ key: String) -> EditorField {
        if field.elementKind == "list", let value = value.object[key], case .array = value { return item }
        if field.elementKind == "list" { return EditorField("value", kind: "string") }
        return item
    }
}

struct CustomFieldEditor: View {
    @Binding var fields: [String: ConfigValue]
    @State private var path = ""
    @State private var kind = "string"
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            formRow("key") { TextField("字段路径，例如 realm-opts.handshake-timeout", text: $path) }
            formRow("type", help: "额外字段的数据类型，可选择文本、整数、开关、列表或键值表。") {
                Picker("类型", selection: $kind) {
                    Text("文本").tag("string"); Text("整数").tag("integer"); Text("开关").tag("boolean")
                    Text("列表").tag("list"); Text("键值表").tag("map")
                }.labelsHidden()
            }
            HStack {
                Spacer()
                Button("添加字段") {
                    fields[path] = emptyValue(EditorField(path, kind: kind, elementKind: "string")); path = ""
                }.disabled(path.isEmpty || fields[path] != nil)
            }
        }
    }
}

// Icon-only controls need a square label so thin symbols cannot collapse the button height.
func formActionIcon(_ symbol: String) -> some View {
    Image(systemName: symbol).font(.system(size: 12, weight: .medium))
        .frame(width: 14, height: 14)
}

func formRow<Content: View>(_ title: String, help: String = "", @ViewBuilder content: () -> Content) -> some View {
    HStack(alignment: .center, spacing: 12) {
        FieldKeyLabel(title: title, key: title.replacingOccurrences(of: " *", with: ""), description: help).frame(width: 200, alignment: .leading)
        content().frame(maxWidth: .infinity, alignment: .leading)
    }.padding(.vertical, 3)
}

private struct FormHelpDocumentKey: EnvironmentKey { static let defaultValue = "" }
extension EnvironmentValues {
    var formHelpDocument: String {
        get { self[FormHelpDocumentKey.self] }
        set { self[FormHelpDocumentKey.self] = newValue }
    }
}

struct FieldKeyLabel: View {
    let title: String
    let key: String
    var description = ""
    var hint = ""
    var kind = ""
    var body: some View {
        HStack(spacing: 6) {
            Text(title).font(.system(.body, design: .monospaced)).textSelection(.enabled)
            FieldHelpButton(key: key, description: description, hint: hint, kind: kind)
            Spacer(minLength: 0)
        }
    }
}

struct FieldHelpButton: View {
    let key: String
    var description = ""
    var hint = ""
    var kind = ""
    @Environment(\.formHelpDocument) private var context
    @State private var presented = false
    var document: String {
        if context == "settings", key == "unified-delay" { return "general.md" }
        if !context.isEmpty { return context }
        if key.hasPrefix("dns.") || key == "hosts" { return "dns/index.md" }
        if key.hasPrefix("sniffer.") { return "sniff/index.md" }
        if key.hasPrefix("tun.") { return "inbound/tun.md" }
        return "general.md"
    }
    var explanation: String {
        if key == "allow-lan" { return "允许其他设备经过 Clash 的[代理端口](https://wiki.metacubex.one/config/inbound/port/)访问互联网。" }
        if context == "subscription" {
            return key == "name" ? "订阅在客户端中显示的名称，用于区分不同订阅来源。" : "提供 Clash YAML 节点配置的 HTTPS 订阅地址。成功拉取并解析节点后才会保存；地址不会传给 mihomo。"
        }
        if kind.isEmpty && !description.isEmpty { return description }
        let client: [String: String] = [
            "测试地址": "测速时通过所选节点访问的 HTTP / HTTPS 地址。默认使用返回 HTTP 204 的测试页面；仅用于客户端测速。",
            "超时（毫秒）": "单个节点测速请求的最长等待时间，单位毫秒。默认 5000，允许范围为 1–120000；超过该时间显示失败或超时。",
            "搜索字段": "按字段名称或说明筛选当前协议表单，不会写入 mihomo 配置。",
            "key": "额外配置字段的路径。嵌套字段使用点号分隔，例如 realm-opts.handshake-timeout。",
            "address": "CIDR 规则匹配的 IP 地址。IPv4 使用点分十进制，IPv6 使用冒号分隔的地址。",
            "prefix": "CIDR 网络前缀长度：IPv4 为 0–32，IPv6 为 0–128。",
            "expression-mode": "开启后直接输入逻辑表达式；关闭时通过条件列表组合表达式。",
            "expression": "填写完整的逻辑条件表达式，使用括号组合条件。例如 ((DOMAIN,example.com),(NETWORK,tcp))。",
            "conditions": "添加用于 AND / OR 等逻辑规则的匹配条件。NOT 和 SUB-RULE 使用单个条件。",
            "application": "选择应用程序后，填入其可执行文件路径，用于 PROCESS-PATH 规则。",
            "target": "匹配规则后使用的出口，可选择节点、代理组或 DIRECT / REJECT 等内置策略。",
            "sub-rule": "选择匹配条件满足后继续执行的子规则集合。",
            "no-resolve": "匹配目标 IP 的规则不主动触发域名解析。如果连接尚无目标 IP，将跳过需要解析的匹配。",
            "src": "将目标 IP 匹配改为匹配连接的来源 IP。"
        ]
        if let text = client[key] { return text }
        if key.hasPrefix("condition[") { return key.hasSuffix(".type") ? "选择此条件的规则类型。" : "填写此条件的匹配内容，格式取决于所选规则类型。" }
        if key == "type", document.hasPrefix("proxy-groups/") { return "代理组类型：select 手动选择；url-test 根据延迟自动选择；fallback 按顺序故障转移；load-balance 负载均衡。" }
        if key == "type", document.hasPrefix("rule-providers/") { return "规则集合来源：http 从网络下载；file 读取本地文件；inline 在配置中直接保存规则内容。" }
        if key == "type", document.hasPrefix("rules/") { return "选择路由规则类型。不同类型会显示对应的匹配条件输入项。" }
        if key == "type", document.hasPrefix("proxies/") { return "选择节点使用的代理协议。协议决定连接参数和表单中需要填写的字段。" }
        let leaf = key.split(separator: ".").last.map(String.init) ?? key
        if let text = documentedFieldHelp[document + "|" + key] ?? documentedFieldHelp[document + "|" + leaf.lowercased()] { return text }
        if document.hasPrefix("proxies/") {
            for common in ["proxies/index.md", "proxies/tls.md", "proxies/transport.md"] {
                if let text = documentedFieldHelp[common + "|" + key] ?? documentedFieldHelp[common + "|" + leaf] { return text }
            }
        }
        if document.hasPrefix("proxy-groups/"), let text = documentedFieldHelp["proxy-groups/index.md|" + leaf] { return text }
        if !description.isEmpty { return description }
        let types = ["boolean": "开关选项，开启为 true，关闭为 false。", "integer": "填写整数值。", "number": "填写数值。", "list": "列表配置，使用加减按钮管理条目。", "map": "键值配置，每个名称对应一个值或列表。", "secret": "填写节点连接所需的认证信息。", "choice": "从支持的选项中选择一个值。", "object": "填写此项下的子配置。"]
        return (types[kind] ?? "填写此配置项的值；具体格式请参阅对应配置文档。") + (hint.isEmpty || kind == "secret" ? "" : "\n\n示例：" + hint)
    }
    var body: some View {
        Button { presented.toggle() } label: {
            Image(systemName: "questionmark.circle").font(.system(size: 12)).foregroundStyle(.secondary)
        }.buttonStyle(.borderless).help("查看说明").accessibilityLabel(key + " 帮助")
            .popover(isPresented: $presented, arrowEdge: .trailing) {
                VStack(alignment: .leading, spacing: 8) {
                    if explanation.count > 260 {
                        ScrollView { Text(LocalizedStringKey(explanation)).fixedSize(horizontal: false, vertical: true).frame(maxWidth: .infinity, alignment: .leading) }.frame(height: 200)
                    } else { Text(LocalizedStringKey(explanation)).fixedSize(horizontal: false, vertical: true) }
                    if !["subscription", "settings"].contains(document) {
                        Link("配置文档", destination: URL(string: "https://wiki.metacubex.one/config/" + document.replacingOccurrences(of: "index.md", with: "").replacingOccurrences(of: ".md", with: "/"))!)
                    }
                }.padding(14).frame(width: 340, alignment: .leading)
            }
    }
}

private struct PageActionLabelStyle: LabelStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack(spacing: 5) {
            configuration.icon.font(.system(size: 12)).frame(width: 14, height: 14)
            configuration.title.font(.system(size: 13)).lineLimit(1)
        }.frame(height: 16)
    }
}

extension View {
    func pageActions() -> some View {
        self.controlSize(.regular).font(.system(size: 13))
            .buttonStyle(.bordered).labelStyle(PageActionLabelStyle())
    }
}
