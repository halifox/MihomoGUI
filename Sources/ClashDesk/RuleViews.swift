import SwiftUI
import ClashCore

private let matchID = "default-match"
struct RuleTableItem: Identifiable { let id: String; let rule: RouteRule? }

struct PolicyPicker: View {
    @ObservedObject var model: DeskModel
    @Binding var selection: String
    var body: some View {
        Picker("出口", selection: $selection) {
            Text(optionLabel("DIRECT")).tag("builtin:DIRECT")
            Text(optionLabel("REJECT")).tag("builtin:REJECT")
            Text(optionLabel("REJECT-DROP")).tag("builtin:REJECT-DROP")
            if selection.hasPrefix("node:"), !model.allNodes.contains(where: { "node:" + $0.id == selection }) {
                Text("已失效：" + selection.dropFirst(5)).tag(selection)
            }
            ForEach(model.settings.proxyGroups ?? []) { Text("代理组 / " + $0.name).tag("group:" + $0.name) }
            ForEach(model.allNodes) { node in Text(model.nodeLabel(node)).tag("node:" + node.id) }
        }.labelsHidden()
    }
}

struct RulesView: View {
    @EnvironmentObject var model: DeskModel
    @State private var selection: String?
    @State private var adding = false
    @State private var editing: RouteRule?
    private var selectedIndex: Int? {
        model.settings.rules.firstIndex { $0.id == selection }
    }
    var rows: [RuleTableItem] {
        model.settings.rules.map { RuleTableItem(id: $0.id, rule: $0) } + [RuleTableItem(id: matchID, rule: nil)]
    }
    func targetText(_ row: RuleTableItem) -> String {
        if let rule = row.rule, rule.kind == .subRule { return "子规则：" + (rule.subRuleTarget ?? "未选择") }
        if let group = row.rule == nil ? model.settings.defaultProxyGroup : row.rule?.proxyGroup { return "代理组 / " + group }
        let node = row.rule == nil ? model.settings.defaultNode : row.rule?.node
        if let node {
            return model.allNodes.contains(node) ? model.nodeLabel(node) : "已失效：" + node.id
        }
        let builtin = row.rule == nil ? model.settings.defaultPolicy ?? (model.settings.defaultDirect == true ? "DIRECT" : "REJECT") : row.rule?.builtin ?? "DIRECT"
        return builtin == "DIRECT" ? "DIRECT · 直连" : builtin == "REJECT-DROP" ? "REJECT-DROP · 丢弃" : "REJECT · 拒绝"
    }
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("路由规则").font(.title2.bold())
                Spacer()
                Button { adding = true } label: { Label("添加规则", systemImage: "plus") }.disabled(model.busy)
                Button {
                    if let selectedIndex { editing = model.settings.rules[selectedIndex] }
                } label: { Label("编辑", systemImage: "pencil") }.disabled(selectedIndex == nil || model.busy)
                Button {
                    if let selection { model.moveRule(selection, offset: -1) }
                } label: { Label("上移", systemImage: "arrow.up") }.disabled(selectedIndex == nil || selectedIndex == 0 || model.busy)
                Button {
                    if let selection { model.moveRule(selection, offset: 1) }
                } label: { Label("下移", systemImage: "arrow.down") }.disabled(selectedIndex == nil || selectedIndex == model.settings.rules.count - 1 || model.busy)
                Button {
                    if let selection { model.deleteRule(selection); self.selection = nil }
                } label: { Label("删除", systemImage: "minus") }.disabled(selectedIndex == nil || model.busy)
            }.pageActions()
            Table(rows, selection: $selection) {
                TableColumn("类型") { row in Text(row.rule?.kind.rawValue ?? "MATCH").font(.system(.body, design: .monospaced)) }.width(tableColumnWidth("类型", rows.map { $0.rule?.kind.rawValue ?? "MATCH" }, monospaced: true))
                TableColumn("匹配条件") { row in Text(row.rule?.value ?? "所有未匹配的连接").textSelection(.enabled) }.width(tableColumnWidth("匹配条件", rows.map { $0.rule?.value ?? "所有未匹配的连接" }))
                TableColumn("附加选项") { row in
                    Text([row.rule?.noResolve == true ? "no-resolve" : nil, row.rule?.sourceIP == true ? "src" : nil].compactMap { $0 }.joined(separator: ", "))
                }.width(tableColumnWidth("附加选项", rows.map { [ $0.rule?.noResolve == true ? "no-resolve" : nil, $0.rule?.sourceIP == true ? "src" : nil ].compactMap { $0 }.joined(separator: ", ") }))
                TableColumn("出口") { row in
                    if let rule = row.rule {
                        if rule.kind == .subRule { Text("子规则：" + (rule.subRuleTarget ?? "未选择")) }
                        else {
                            PolicyPicker(model: model, selection: Binding(get: { model.targetID(node: rule.node, builtin: rule.builtin, group: rule.proxyGroup) }, set: { model.setRuleTarget(rule, target: $0) }))
                                .disabled(model.busy)
                        }
                    } else {
                        PolicyPicker(model: model, selection: Binding(get: { model.targetID(node: model.settings.defaultNode, builtin: model.settings.defaultPolicy ?? (model.settings.defaultDirect == true ? "DIRECT" : "REJECT"), group: model.settings.defaultProxyGroup) }, set: { model.setDefaultTarget($0) }))
                            .disabled(model.busy)
                    }
                }.width(tableColumnWidth("出口", rows.map(targetText), padding: 48))
            }
        }
        .sheet(isPresented: $adding) { RuleEditorView() }
        .sheet(item: $editing) { RuleEditorView(rule: $0) }
    }
}

struct RuleCondition: Identifiable {
    let id = UUID()
    var kind: RuleKind = .domain
    var value = ""
}

struct RuleEditorView: View {
    @EnvironmentObject var model: DeskModel
    @Environment(\.dismiss) private var dismiss
    let original: RouteRule?
    @State private var kind: RuleKind
    @State private var value: String
    @State private var address: String
    @State private var prefix: String
    @State private var target: String
    @State private var noResolve: Bool
    @State private var sourceIP: Bool
    @State private var subTarget: String
    @State private var advancedLogic: Bool
    @State private var conditions = [RuleCondition(), RuleCondition(kind: .network, value: "tcp")]
    @State private var error: String?
    init(rule: RouteRule? = nil) {
        original = rule
        _kind = State(initialValue: rule?.kind ?? .domain)
        _value = State(initialValue: rule?.value ?? "")
        let cidr = (rule?.value ?? "").split(separator: "/").map(String.init)
        _address = State(initialValue: cidr.first ?? "")
        _prefix = State(initialValue: cidr.count == 2 ? cidr[1] : "24")
        _target = State(initialValue: rule?.proxyGroup.map { "group:" + $0 } ?? rule?.node.map { "node:" + $0.id } ?? "builtin:" + (rule?.builtin ?? "DIRECT"))
        _noResolve = State(initialValue: rule?.noResolve ?? false)
        _sourceIP = State(initialValue: rule?.sourceIP ?? false)
        _subTarget = State(initialValue: rule?.subRuleTarget ?? "")
        _advancedLogic = State(initialValue: rule?.kind.isLogic == true)
    }
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(original == nil ? "添加路由规则" : "编辑路由规则").font(.title2.bold())
            ScrollView {
                VStack(alignment: .leading, spacing: 6) {
                    formRow("type *") {
                        Picker("规则类型", selection: $kind) { ForEach(RuleKind.allCases, id: \.self) { Text(optionLabel($0.rawValue)).tag($0) } }.labelsHidden()
                    }
                    if kind.isCIDR {
                        formRow("address *") { TextField("192.168.1.0 或 2001:db8::", text: $address) }
                        formRow("prefix *") { TextField("掩码位数", text: $prefix).frame(width: 90) }
                    } else if kind == .network {
                        formRow("network *") {
                            Picker("网络协议", selection: $value) { Text(optionLabel("tcp")).tag("tcp"); Text(optionLabel("udp")).tag("udp") }.labelsHidden()
                        }
                    } else if kind == .ruleSet {
                        formRow("rule-set *") {
                            Picker("集合名称", selection: $value) {
                                Text("空（Empty）").tag("")
                                ForEach((model.settings.options?["rule-providers"]?.object.keys.sorted() ?? []), id: \.self) { Text($0).tag($0) }
                            }.labelsHidden()
                        }
                    } else if kind.isLogic {
                        formRow("expression-mode") { Toggle("直接编辑逻辑表达式", isOn: $advancedLogic) }
                        if advancedLogic { formRow("expression *") { TextField("", text: $value) } }
                        else {
                            ForEach(conditions.indices, id: \.self) { index in
                                formRow("condition[\(index + 1)].type") {
                                    HStack {
                                        Picker("条件", selection: $conditions[index].kind) {
                                            ForEach(RuleKind.allCases.filter { !$0.isLogic }, id: \.self) { Text(optionLabel($0.rawValue)).tag($0) }
                                        }.labelsHidden()
                                        if conditions.count > 1 && kind != .not && kind != .subRule {
                                            Button { conditions.remove(at: index) } label: { formActionIcon("minus") }.buttonStyle(.bordered).controlSize(.regular).help("删除条件")
                                        }
                                    }
                                }
                                formRow("condition[\(index + 1)].value", help: "填写条件的匹配内容。\n\n示例：" + conditions[index].kind.hint) { TextField("", text: $conditions[index].value) }
                            }
                            if kind != .not && kind != .subRule {
                                formRow("conditions") { Button("添加条件") { conditions.append(RuleCondition()) } }
                            }
                        }
                    } else {
                        formRow("value *", help: "填写当前规则类型的匹配内容。\n\n示例：" + kind.hint) { TextField("", text: $value).help(kind.hint) }
                        if kind == .processPath {
                            formRow("application") { Button("选择应用可执行文件") { if let path = model.chooseApplicationPath() { value = path } } }
                        }
                    }
                    if kind.supportsIPOptions {
                        formRow("no-resolve") { Toggle("不触发域名解析", isOn: $noResolve) }
                        formRow("src") { Toggle("匹配来源 IP", isOn: $sourceIP) }
                    }
                    if kind == .subRule {
                        formRow("sub-rule *") {
                            Picker("子规则", selection: $subTarget) {
                                Text("空（Empty）").tag("")
                                ForEach(model.settings.options?["sub-rules"]?.object.keys.sorted() ?? [], id: \.self) { Text($0).tag($0) }
                            }.labelsHidden()
                        }
                    } else { formRow("target *") { PolicyPicker(model: model, selection: $target) } }
                }.textFieldStyle(.roundedBorder)
            }
            HStack {
                Spacer()
                Button("取消") { dismiss() }.keyboardShortcut(.cancelAction)
                Button("保存规则") { save() }.buttonStyle(.borderedProminent)
            }
        }.padding(16).controlSize(.regular).frame(width: 720, height: 540)
        .environment(\.formHelpDocument, "rules/index.md")
        .onChange(of: kind) { changed in
            if changed == .network { value = "tcp" }
            if changed == .ipCIDR6 { prefix = "64"; address = "" }
            if changed == .not || changed == .subRule { conditions = [RuleCondition()] }
            if !changed.supportsIPOptions { noResolve = false; sourceIP = false }
        }
        .alert("规则参数无效", isPresented: Binding(get: { error != nil }, set: { if !$0 { error = nil } })) {
            Button("确定") { error = nil }
        } message: { Text(error ?? "") }
    }
    func save() {
        do {
            var payload = kind.isCIDR ? address.trimmingCharacters(in: .whitespaces) + "/" + prefix : value.trimmingCharacters(in: .whitespacesAndNewlines)
            if kind.isLogic && !advancedLogic {
                for condition in conditions { try validateRule(RouteRule(kind: condition.kind, value: condition.value, node: nil), settings: model.settings) }
                let clauses = conditions.map { "(\($0.kind.rawValue),\($0.value))" }
                payload = kind == .subRule ? clauses[0] : "(" + clauses.joined(separator: ",") + ")"
            }
            let node = model.allNodes.first { "node:" + $0.id == target }
                ?? (original?.node.map { "node:" + $0.id == target } == true ? original?.node : nil)
            if target.hasPrefix("node:"), node == nil { throw DeskError("所选代理已失效，请重新选择出口") }
            var rule = RouteRule(kind: kind, value: payload, node: node)
            if let original { rule.id = original.id }
            rule.proxyGroup = target.hasPrefix("group:") ? String(target.dropFirst(6)) : nil
            rule.builtin = target.hasPrefix("builtin:") ? optionLabel(String(target.dropFirst(8))) : nil
            rule.noResolve = noResolve; rule.sourceIP = sourceIP; rule.subRuleTarget = subTarget
            try model.saveRule(rule); dismiss()
        } catch { self.error = error.localizedDescription }
    }
}
