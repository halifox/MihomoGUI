import SwiftUI
import AppKit
import MihomoCore

import Darwin

struct RouteMenu: View {
    @EnvironmentObject var model: MihomoModel
    let kind: RuleKind
    let value: String
    var onOpen: ((RouteRule) -> Void)? = nil
    var isIPv4: Bool { !kind.isProcess && !value.contains(":") && validCIDR(value + "/32") }
    var isIPv6: Bool { !kind.isProcess && value.contains(":") && validCIDR(value + "/128") }
    var body: some View {
        if !value.isEmpty && !["未知目标", "未知 IP", "未知端口", "未知程序"].contains(value) {
            Section("添加路由规则") {
                if kind == .sourceCIDR, isIPv4 || isIPv6 {
                    Button { open(.sourceCIDR, value + (isIPv4 ? "/32" : "/128")) } label: { Label("来源设备（SRC-IP-CIDR）", systemImage: "desktopcomputer") }
                } else if kind.isProcess {
                    Button {
                        open(.processName, (value as NSString).lastPathComponent)
                    } label: { Label("进程名称（PROCESS-NAME）", systemImage: "app") }
                    if value.hasPrefix("/") {
                        Button { open(.processPath, value) } label: { Label("进程路径（PROCESS-PATH）", systemImage: "folder") }
                    }
                } else if isIPv4 || isIPv6 {
                    Button {
                        open(isIPv4 ? .ipCIDR : .ipCIDR6, value + (isIPv4 ? "/32" : "/128"))
                    } label: { Label("目标 IP（\(isIPv4 ? "IP-CIDR /32" : "IP-CIDR6 /128")）", systemImage: "network") }
                    Button {
                        open(isIPv4 ? .ipCIDR : .ipCIDR6, subnet)
                    } label: { Label("目标网段（\(isIPv4 ? "IP-CIDR /24" : "IP-CIDR6 /64")）", systemImage: "network") }
                } else if kind == .destinationPort {
                    Button { open(.destinationPort, value) } label: { Label("目标端口（DST-PORT）", systemImage: "number") }
                } else if kind == .domain {
                    Button { open(.domain, value) } label: { Label("完整域名（DOMAIN）", systemImage: "globe") }
                    Button { open(.suffix, value) } label: { Label("域名后缀（DOMAIN-SUFFIX）", systemImage: "text.end") }
                    Button { open(.keyword, value) } label: { Label("域名关键词（DOMAIN-KEYWORD）", systemImage: "text.magnifyingglass") }
                }
            }
        }
    }
    var subnet: String {
        if isIPv4 {
            return value.split(separator: ".").prefix(3).joined(separator: ".") + ".0/24"
        }
        var address = [UInt8](repeating: 0, count: 16)
        let parsed = address.withUnsafeMutableBytes { inet_pton(AF_INET6, value, $0.baseAddress) }
        guard parsed == 1 else { return value + "/64" }
        for index in 8..<16 { address[index] = 0 }
        var buffer = [CChar](repeating: 0, count: Int(INET6_ADDRSTRLEN))
        let converted = address.withUnsafeBytes { inet_ntop(AF_INET6, $0.baseAddress, &buffer, socklen_t(buffer.count)) }
        return (converted == nil ? value : String(cString: buffer)) + "/64"
    }
    func open(_ kind: RuleKind, _ value: String) {
        let rule = RouteRule(kind: kind, value: value, node: nil)
        if let onOpen { onOpen(rule) } else { model.rulePrefill = rule }
    }
}

// Used by the rule editor to explain overlapping rule priority.
func quickRouteRule(kind: RuleKind, value: String) -> RouteRule? {
    guard !value.isEmpty, !["未知目标", "未知 IP", "未知端口", "未知程序"].contains(value) else { return nil }
    if kind == .domain || kind == .ipCIDR {
        if !value.contains(":"), validCIDR(value + "/32") { return RouteRule(kind: .ipCIDR, value: value + "/32", node: nil) }
        if value.contains(":"), validCIDR(value + "/128") { return RouteRule(kind: .ipCIDR6, value: value + "/128", node: nil) }
        if kind == .ipCIDR { return nil }
    }
    return RouteRule(kind: kind, value: value, node: nil)
}

func sameRuleMatch(_ lhs: RouteRule, _ rhs: RouteRule) -> Bool {
    lhs.kind == rhs.kind && lhs.value == rhs.value
        && (lhs.noResolve == true) == (rhs.noResolve == true)
        && (lhs.sourceIP == true) == (rhs.sourceIP == true)
        && (lhs.kind != .subRule || lhs.subRuleTarget == rhs.subRuleTarget)
}

func ruleScopeDescription(_ rule: RouteRule) -> String {
    switch rule.kind {
    case .domain: return "仅匹配完整域名，不包含子域名。"
    case .suffix: return "匹配此域名及其所有子域名，请确认覆盖范围。"
    case .keyword: return "匹配包含此关键词的所有域名，请确认覆盖范围。"
    case .ipCIDR, .ipCIDR6:
        return rule.sourceIP == true ? "匹配该来源 IP / 网段发起的连接，与目标无关。" : "匹配该目标 IP / 网段中的地址，与进程无关。"
    case .sourceCIDR: return "匹配该来源设备 / 网段发起的连接，与目标无关。"
    case .destinationPort: return "匹配使用该目标端口的连接，与域名和进程无关。"
    case .processName: return "匹配所有同名进程；可使用进程路径进一步限定。"
    case .processPath: return "匹配该完整可执行文件路径。"
    case .and: return "仅当表达式中的所有条件都满足时匹配。"
    default: return "请确认匹配条件和目标出口。"
    }
}

func rulePriorityNotice(_ rule: RouteRule, preceding: [RouteRule]) -> String? {
    let overlaps = preceding.enumerated().filter { _, prior in
        if sameRuleMatch(prior, rule) { return true }
        guard rule.kind == .domain else { return false }
        switch prior.kind {
        case .suffix: return rule.value == prior.value || rule.value.hasSuffix("." + prior.value)
        case .keyword: return rule.value.contains(prior.value)
        default: return false
        }
    }
    guard !overlaps.isEmpty else { return nil }
    return "前置规则第 " + overlaps.map { String($0.offset + 1) }.joined(separator: "、") + " 条包含相同或覆盖此域名的条件，可能优先命中。"
}

struct BatchRouteEditor: View {
    @EnvironmentObject var model: MihomoModel
    @Environment(\.dismiss) private var dismiss
    let rules: [RouteRule]
    let skippedCount: Int
    @State private var target = "builtin:DIRECT"
    @State private var atTop = false
    @State private var error: String?
    var uniqueRules: [RouteRule] {
        var result: [RouteRule] = []
        for rule in rules where !result.contains(where: { sameRuleMatch($0, rule) }) { result.append(rule) }
        return result
    }
    var additions: [RouteRule] {
        uniqueRules.filter { rule in !model.settings.rules.contains { sameRuleMatch($0, rule) } }
    }
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("批量添加路由规则").font(.title2.bold())
            Text("待添加 \(additions.count) 条；已有相同条件 \(uniqueRules.count - additions.count) 条；不可用记录 \(skippedCount) 条。")
                .foregroundStyle(.secondary)
            formRow("目标出口", labelWidth: editorLabelWidth) { PolicyPicker(model: model, selection: $target) }
            Toggle("插入列表顶部（优先匹配）", isOn: $atTop)
            Text(atTop ? "将先于现有规则匹配。" : "追加到现有规则之后、MATCH 之前；前置规则可能优先命中。")
                .font(.caption).foregroundStyle(.secondary)
            List(uniqueRules) { rule in
                VStack(alignment: .leading, spacing: 4) {
                    Text("\(rule.kind.rawValue),\(rule.value)").font(.system(.body, design: .monospaced)).textSelection(.enabled)
                    Text(ruleScopeDescription(rule)).font(.caption).foregroundStyle(.secondary)
                    if model.settings.rules.contains(where: { sameRuleMatch($0, rule) }) {
                        Text("已存在相同匹配条件，将跳过。可到路由规则页面修改出口。")
                            .font(.caption).foregroundStyle(.orange)
                    } else if !atTop, let notice = rulePriorityNotice(rule, preceding: model.settings.rules) {
                        Text(notice).font(.caption).foregroundStyle(.orange)
                    }
                }
            }
            if let error { Text(error).foregroundStyle(.red).textSelection(.enabled) }
            HStack {
                Spacer()
                Button("取消") { dismiss() }.keyboardShortcut(.cancelAction)
                Button("添加 \(additions.count) 条规则") { save() }
                    .buttonStyle(.borderedProminent).keyboardShortcut(.defaultAction).disabled(model.busy || additions.isEmpty)
            }
        }.padding(16).frame(width: editorSheetWidth, height: 360)
    }
    func save() {
        do {
            let node = model.allNodes.first { "node:" + $0.id == target }
            if target.hasPrefix("node:"), node == nil { throw MihomoError("所选代理已失效，请重新选择出口") }
            let selected = additions.map { initial in
                var rule = initial
                rule.node = node
                rule.proxyGroup = target.hasPrefix("group:") ? String(target.dropFirst(6)) : nil
                rule.builtin = target.hasPrefix("builtin:") ? String(target.dropFirst(8)) : nil
                return rule
            }
            try model.addRules(selected, atTop: atTop)
            dismiss()
        } catch { self.error = error.localizedDescription }
    }
}
