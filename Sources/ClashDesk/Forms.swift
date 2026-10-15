import SwiftUI
import ClashCore

func optionLabel(_ value: String) -> String {
    let labels: [String: String] = [
        "select": "手动选择",
        "url-test": "自动测速",
        "fallback": "故障转移",
        "load-balance": "负载均衡",
        "http": "超文本传输",
        "file": "本地文件",
        "inline": "内嵌内容",
        "domain": "域名规则",
        "ipcidr": "网段规则",
        "classical": "经典规则",
        "yaml": "结构化格式",
        "text": "文本格式",
        "mrs": "二进制规则格式",
        "consistent-hashing": "一致性哈希",
        "round-robin": "轮询",
        "sticky-sessions": "会话保持",
        "DIRECT": "直连",
        "REJECT": "拒绝",
        "REJECT-DROP": "丢弃",
        "rule": "规则模式",
        "global": "全局模式",
        "direct": "直连",
        "debug": "调试",
        "info": "信息",
        "warning": "警告",
        "error": "错误",
        "silent": "静默",
        "none": "无",
        "off": "关闭",
        "auto": "自动",
        "random": "随机",
        "always": "始终",
        "system": "系统",
        "strict": "严格",
        "standard": "标准",
        "conservative": "保守",
        "aggressive": "激进",
        "memconservative": "节省内存",
        "dual": "双栈",
        "ipv4": "仅第四版地址",
        "ipv6": "仅第六版地址",
        "ipv4-prefer": "优先第四版地址",
        "ipv6-prefer": "优先第六版地址",
        "fake-ip": "虚拟地址",
        "redir-host": "真实地址",
        "blacklist": "黑名单",
        "whitelist": "白名单",
        "native": "原生",
        "mixed": "混合",
        "gvisor": "用户态网络栈",
        "lru": "最近最少使用",
        "arc": "自适应缓存",
        "mips": "mihomo IP 协议栈",
        "zero": "零值",
        "tcp": "传输控制协议",
        "udp": "用户数据报协议",
        "TCP": "传输控制协议",
        "UDP": "用户数据报协议",
        "ws": "网页套接字",
        "grpc": "远程过程调用",
        "quic": "快速传输协议",
        "h2": "第二版超文本传输",
        "h2mux": "第二版协议多路复用",
        "tls": "传输层安全",
        "tls12": "传输层安全版本一二",
        "tls13": "传输层安全版本一三",
        "smux": "流多路复用",
        "yamux": "流多路复用",
        "xudp": "扩展数据报",
        "packetaddr": "数据包地址",
        "aes-128-gcm": "高级加密标准",
        "chacha20-poly1305": "流加密与认证",
        "bbr": "带宽拥塞控制",
        "bbr3": "第三版带宽拥塞控制",
        "cubic": "立方拥塞控制",
        "reno": "雷诺拥塞控制",
        "chrome": "谷歌浏览器",
        "firefox": "火狐浏览器",
        "safari": "苹果浏览器",
        "edge": "微软浏览器",
        "android": "安卓系统",
        "ios": "苹果移动系统",
        "360": "三六零浏览器",
        "qq": "腾讯浏览器",
        "gecko": "Gecko 混淆器",
        "jls": "指纹伪装",
        "restls": "握手伪装",
        "shadow-tls": "影子传输层安全",
        "salamander": "混淆",
        "anytls": "任意传输层安全代理",
        "dns": "域名解析",
        "easytier": "易联组网",
        "hysteria": "歇斯底里代理",
        "hysteria2": "第二代歇斯底里代理",
        "masque": "隧道代理",
        "mieru": "弥尔代理",
        "openvpn": "开放虚拟专网",
        "rematch": "重新匹配",
        "shadowquic": "影子快速传输代理",
        "snell": "斯奈尔代理",
        "socks5": "第五版套接字代理",
        "ss": "影梭",
        "ssh": "安全外壳",
        "ssr": "影梭增强版",
        "sudoku": "数独代理",
        "tailscale": "虚拟组网",
        "trojan": "特洛伊代理",
        "trusttunnel": "可信隧道",
        "tuic": "快速传输代理",
        "vless": "轻量代理",
        "vmess": "加密代理",
        "wireguard": "轻量虚拟专网",
        "zerotier": "零层组网",
        "DOMAIN": "完整域名",
        "DOMAIN-SUFFIX": "域名后缀",
        "DOMAIN-KEYWORD": "域名关键词",
        "DOMAIN-WILDCARD": "域名通配符",
        "DOMAIN-REGEX": "域名正则",
        "GEOSITE": "域名分类",
        "IP-CIDR": "目标网段",
        "IP-CIDR6": "目标网段别名",
        "IP-SUFFIX": "目标地址后缀",
        "IP-ASN": "目标自治系统",
        "GEOIP": "目标地理位置",
        "SRC-GEOIP": "来源地理位置",
        "SRC-IP-ASN": "来源自治系统",
        "SRC-IP-CIDR": "来源网段",
        "SRC-IP-SUFFIX": "来源地址后缀",
        "DST-PORT": "目标端口",
        "SRC-PORT": "来源端口",
        "IN-PORT": "入站端口",
        "IN-TYPE": "入站类型",
        "IN-USER": "入站用户",
        "IN-NAME": "入站名称",
        "REMATCH-NAME": "重匹配名称",
        "PROCESS-NAME": "进程名称",
        "PROCESS-PATH": "进程路径",
        "PROCESS-NAME-WILDCARD": "进程名称通配符",
        "PROCESS-NAME-REGEX": "进程名称正则",
        "PROCESS-PATH-WILDCARD": "进程路径通配符",
        "PROCESS-PATH-REGEX": "进程路径正则",
        "NETWORK": "网络协议",
        "RULE-SET": "规则集合",
        "AND": "逻辑与",
        "OR": "逻辑或",
        "NOT": "逻辑非",
        "SUB-RULE": "子规则",
    ]
    guard let label = labels[value] else { return value }
    return "\(label)（\(value)）"
}

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
                          description: field.description, hint: field.hint, kind: field.kind, unavailableReason: field.unavailableReason, helpDocument: field.document)
                .frame(width: 200, alignment: .leading)
            VisualValue(field: field, value: Binding(get: {
                value ?? (field.kind == "choice" ? .string(field.defaultHint ?? "") : field.kind == "boolean" ? .boolean(false) : field.kind == "list" || field.kind == "map" || field.kind == "object" ? emptyValue(field) : .string(""))
            }, set: { value = $0 }), compact: true).disabled(!inputEnabled)
            Spacer(minLength: 0)
        }.padding(.vertical, 3)
    }
    var legacyRow: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                FieldKeyLabel(title: field.title, key: field.path, description: field.description, hint: field.hint, kind: field.kind, unavailableReason: field.unavailableReason, helpDocument: field.document)
                if field.required { Text("必填").font(.caption).foregroundStyle(.orange) }
                Spacer()
                if allowUnset && !field.required {
                    Toggle("设置此项", isOn: Binding(get: { value != nil }, set: { value = $0 ? emptyValue(field) : nil }))
                        .toggleStyle(.checkbox).font(.caption).help("未设置时使用内核默认值")
                }
            }
            VisualValue(field: field, value: Binding(get: { value ?? (field.kind == "choice" ? .string(field.defaultHint ?? "") : emptyValue(field)) }, set: { value = $0 }))
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
        Binding(get: {
            if field.kind == "choice", value.text.isEmpty,
               let defaultValue = field.defaultHint, (field.choices ?? []).contains(defaultValue) {
                return defaultValue
            }
            return value.text
        }, set: {
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
                if field.defaultHint == nil || !(field.choices ?? []).contains(field.defaultHint ?? "") {
                    Text(field.required ? "请选择（Select）" : "空（Empty）").tag("")
                }
                if !value.text.isEmpty, !(field.choices ?? []).contains(value.text) { Text(optionLabel(value.text)).tag(value.text) }
                ForEach(field.choices ?? [], id: \.self) { Text(optionLabel($0)).tag($0) }
            }.labelsHidden())
        case "secret": return AnyView(TextField("", text: text).textFieldStyle(.roundedBorder))
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
        default: return AnyView(TextField(field.defaultHint ?? "", text: text).textFieldStyle(.roundedBorder))
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
                    DeleteButton(message: "确定删除第 \(index + 1) 项吗？此操作无法撤销。") {
                        var array = value.array; guard array.indices.contains(index) else { return }
                        array.remove(at: index); value = .array(array)
                    }
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
                        FieldKeyLabel(title: name, key: field.path + "." + name, description: "该键对应的配置值。可以按此项支持的格式填写单值或列表。", translate: false)
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
                            })) { Text("单值（string）").tag("string"); Text("列表（list）").tag("list") }.frame(width: 180)
                        }
                        DeleteButton(message: "确定删除“\(name)”吗？此操作无法撤销。") {
                            var object = value.object; object.removeValue(forKey: name); value = .object(object)
                        }
                    }
                    VisualValue(field: itemSpec(name), value: Binding(get: { value.object[name] ?? emptyValue(item) }, set: {
                        var object = value.object; object[name] = $0; value = .object(object)
                    }), compact: compact)
                }
            }
            HStack {
                FieldKeyLabel(title: "键名", key: "key", description: "新建键值条目的名称，不能与现有名称重复。", translate: false).frame(width: 70, alignment: .leading)
                TextField("", text: $key).textFieldStyle(.roundedBorder)
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
            formRow("字段路径", help: "额外配置字段的路径。嵌套字段使用点号分隔，例如 realm-opts.realm-id。") { TextField("", text: $path) }
            formRow("type", help: "额外字段的数据类型，可选择文本、整数、开关、列表或键值表。") {
                Picker("类型", selection: $kind) {
                    Text("文本（string）").tag("string"); Text("整数（integer）").tag("integer"); Text("开关（boolean）").tag("boolean")
                    Text("列表（list）").tag("list"); Text("键值表（map）").tag("map")
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
    var unavailableReason: String?
    var helpDocument: String?
    var translate = true
    @State private var platformPresented = false
    @Environment(\.formHelpDocument) private var context
    var displayTitle: String {
        guard translate else { return title }
        let translated = configFieldTitle(key, document: context.isEmpty ? "general.md" : context)
        return translated + (title.hasSuffix(" *") ? " *" : "")
    }
    var body: some View {
        HStack(spacing: 6) {
            Text(displayTitle).textSelection(.enabled).help(key)
            FieldHelpButton(key: key, description: description, hint: hint, kind: kind)
                .environment(\.formHelpDocument, helpDocument ?? context)
            if let reason = unavailableReason {
                Button { platformPresented.toggle() } label: {
                    Image(systemName: "exclamationmark.circle").font(.system(size: 12)).foregroundStyle(.orange)
                }
                .buttonStyle(.borderless).help("查看平台说明").accessibilityLabel(key + " 平台说明")
                .popover(isPresented: $platformPresented, arrowEdge: .top) {
                    Text(reason).fixedSize(horizontal: false, vertical: true)
                        .padding(14).frame(width: 280, alignment: .leading)
                }
            }
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
        if ["port", "socks-port", "mixed-port", "redir-port", "tproxy-port"].contains(key), context.isEmpty || context == "general.md" {
            return "inbound/port.md"
        }
        if context == "settings", key == "unified-delay" { return "general.md" }
        if !context.isEmpty { return context }
        if key.hasPrefix("dns.") || key == "hosts" { return "dns/index.md" }
        if key.hasPrefix("sniffer.") { return "sniff/index.md" }
        if key.hasPrefix("tun.") { return "inbound/tun.md" }
        return "general.md"
    }
    var explanation: String {
        if context == "subscription" {
            return key == "name" ? "订阅在客户端中显示的名称，用于区分不同订阅来源。" : "提供 Clash YAML 节点配置的 HTTPS 订阅地址。"
        }
        if kind.isEmpty && !description.isEmpty { return description }
        let client: [String: String] = [
            "测试地址": "测速时通过所选节点访问的 HTTP / HTTPS 地址。默认使用返回 HTTP 204 的测试页面；仅用于客户端测速。",
            "超时（毫秒）": "单个节点测速请求的最长等待时间，单位毫秒。默认 5000，允许范围为 1–120000；超过该时间显示失败或超时。",
            "key": "额外配置字段的路径。嵌套字段使用点号分隔，例如 realm-opts.realm-id。",
            "address": "CIDR 规则匹配的 IP 地址。IPv4 使用点分十进制，IPv6 使用冒号分隔的地址。",
            "prefix": "CIDR 网络前缀长度：IPv4 为 0–32，IPv6 为 0–128。",
            "expression-mode": "开启后直接输入逻辑表达式；关闭时通过条件列表组合表达式。",
            "expression": "填写完整的逻辑条件表达式，使用括号组合条件。例如 ((DOMAIN,example.com),(NETWORK,tcp))。",
            "conditions": "添加用于 AND / OR 等逻辑规则的匹配条件。NOT 和 SUB-RULE 使用单个条件。",
            "application": "选择应用程序后，填入其可执行文件路径，用于 PROCESS-PATH 规则。",
            "target": "匹配规则后使用的出口，可选择节点、代理组或 DIRECT / REJECT 等内置策略。",
            "sub-rule": "选择匹配条件满足后继续执行的子规则集。",
            "no-resolve": "匹配目标 IP 的规则不主动触发域名解析。如果连接尚无目标 IP，将跳过需要解析的匹配。",
            "src": "将目标 IP 匹配改为匹配连接的来源 IP。"
        ]
        if let text = client[key] { return text }
        if key.hasPrefix("condition[") { return key.hasSuffix(".type") ? "选择此条件的规则类型。" : "填写此条件的匹配内容，格式取决于所选规则类型。" }
        if key == "type", document.hasPrefix("proxy-groups/") { return "代理组类型：select 手动选择；url-test 根据延迟自动选择；fallback 按顺序故障转移；load-balance 负载均衡。" }
        if key == "type", document.hasPrefix("rule-providers/") { return "规则集来源：http 从网络下载；file 读取本地文件；inline 在配置中直接保存规则内容。" }
        if key == "type", document.hasPrefix("rules/") { return "选择路由规则类型。不同类型会显示对应的匹配条件输入项。" }
        if key == "type", document.hasPrefix("proxies/") { return "选择节点使用的代理协议。协议决定连接参数和表单中需要填写的字段。" }
        if !description.isEmpty { return description }
        if let text = documentedHelp(document: document, key: key) { return text }
        let url = "https://wiki.metacubex.one/config/" + document.replacingOccurrences(of: "index.md", with: "").replacingOccurrences(of: ".md", with: "/")
        return "[查看对应配置文档](" + url + ")"
    }
    var body: some View {
        Button { presented.toggle() } label: {
            Image(systemName: "questionmark.circle").font(.system(size: 12)).foregroundStyle(.secondary)
        }.buttonStyle(.borderless).help("查看说明").accessibilityLabel(key + " 帮助")
            .popover(isPresented: $presented, arrowEdge: .top) {
                VStack(alignment: .leading, spacing: 8) {
                    Text(key).font(.system(.callout, design: .monospaced)).textSelection(.enabled)
                    if explanation.count > 260 {
                        ScrollView { Text(LocalizedStringKey(explanation)).fixedSize(horizontal: false, vertical: true).frame(maxWidth: .infinity, alignment: .leading) }.frame(height: 200)
                    } else { Text(LocalizedStringKey(explanation)).fixedSize(horizontal: false, vertical: true) }
                    if document.hasSuffix(".md"), let url = URL(string: "https://wiki.metacubex.one/config/" + document.replacingOccurrences(of: "index.md", with: "").replacingOccurrences(of: ".md", with: "/")) {
                        Link("查看配置文档", destination: url).font(.caption)
                    }
                }.padding(14).frame(width: 340, alignment: .leading)
            }
    }
}

struct DeleteButton: View {
    var title = "删除"
    var message = "确定删除此项吗？此操作无法撤销。"
    let action: () -> Void
    @State private var confirming = false

    var body: some View {
        Button(role: .destructive) { confirming = true } label: {
            Label(title, systemImage: "trash")
        }
        .labelStyle(.iconOnly)
        .help(title)
        .controlSize(.regular)
        .alert("确认" + title, isPresented: $confirming) {
            Button("取消", role: .cancel) {}
            Button("确认删除", role: .destructive, action: action)
        } message: { Text(message) }
    }
}
