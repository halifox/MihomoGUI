import SwiftUI
import AppKit
import MihomoGUICore

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
            return key == "name" ? "订阅在客户端中显示的名称，用于区分不同订阅来源。" : "提供 mihomo YAML 节点配置的 HTTPS 订阅地址。"
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
                }.padding(14).frame(width: 340, alignment: .leading)
            }
    }
}
