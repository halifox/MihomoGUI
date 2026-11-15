import SwiftUI
import AppKit
import ClashCore

private let matchID = "default-match"
struct RuleTableItem: Identifiable { let id: String; let number: Int; let rule: RouteRule? }

struct RulesView: View {
    @State private var sortOrder: [TableSort<RuleTableItem>] = []
    @EnvironmentObject var model: DeskModel
    @State private var selection: String?
    @State private var adding = false
    @State private var editing: RouteRule?
    private var selectedIndex: Int? {
        model.settings.rules.firstIndex { $0.id == selection }
    }
    var rows: [RuleTableItem] {
        return model.settings.rules.enumerated().map { RuleTableItem(id: $0.element.id, number: $0.offset + 1, rule: $0.element) }
            + [RuleTableItem(id: matchID, number: model.settings.rules.count + 1, rule: nil)]
    }
    func targetText(_ row: RuleTableItem) -> String {
        if let rule = row.rule, rule.kind == .subRule { return "子规则：" + (rule.subRuleTarget ?? "未选择") }
        if let group = row.rule == nil ? model.settings.defaultProxyGroup : row.rule?.proxyGroup { return "代理组 / " + group }
        let node = row.rule == nil ? model.settings.defaultNode : row.rule?.node
        if let node {
            return model.allNodes.first(where: { $0.id == node.id }).map { model.nodeLabel($0) } ?? "已失效：" + node.id
        }
        let builtin = row.rule == nil ? model.settings.defaultPolicy ?? (model.settings.defaultDirect == true ? "DIRECT" : "REJECT") : row.rule?.builtin ?? "DIRECT"
        return optionLabel(builtin)
    }
    func optionsText(_ row: RuleTableItem) -> String {
        [row.rule?.noResolve == true ? "no-resolve" : nil, row.rule?.sourceIP == true ? "src" : nil].compactMap { $0 }.joined(separator: ", ")
    }
    func columnSort(_ column: String) -> TableSort<RuleTableItem> {
        switch column {
        case "序号": return TableSort(column) { $0.number }
        case "类型": return TableSort(column) { $0.rule?.kind.rawValue ?? "MATCH" }
        case "匹配条件": return TableSort(column) { $0.rule?.value ?? "所有未匹配的连接" }
        case "附加选项": return TableSort(column, value: optionsText)
        default: return TableSort(column, value: targetText)
        }
    }
    var body: some View {
        let rows = rows
        Table(rows.sorted(using: sortOrder), selection: $selection, sortOrder: tableSortBinding($sortOrder)) {
            TableColumn("序号", sortUsing: columnSort("序号")) { row in
                Text(String(row.number)).monospacedDigit().frame(maxWidth: .infinity, alignment: .trailing)
            }.width(min: 40, ideal: tableColumnWidth("序号", rows.map { String($0.number) }, numeric: true), max: nil)
            TableColumn("类型", sortUsing: columnSort("类型")) { row in
                Text(row.rule?.kind.rawValue ?? "MATCH").monospaced()
            }.width(min: 40, ideal: tableColumnWidth("类型", rows.map { $0.rule?.kind.rawValue ?? "MATCH" }, monospaced: true), max: nil)
            TableColumn("匹配条件", sortUsing: columnSort("匹配条件")) { row in
                Text(row.rule?.value ?? "所有未匹配的连接").textSelection(.enabled)
            }.width(min: 40, ideal: tableColumnWidth("匹配条件", rows.map { $0.rule?.value ?? "所有未匹配的连接" }), max: nil)
            TableColumn("附加选项", sortUsing: columnSort("附加选项")) { row in
                Text(optionsText(row))
            }.width(min: 40, ideal: tableColumnWidth("附加选项", rows.map(optionsText)), max: nil)
            TableColumn("出口", sortUsing: columnSort("出口")) { row in
                targetPicker(row)
                    .disabled(model.busy)
            }.width(min: 40, ideal: tableColumnWidth("出口", rows.map(targetText), padding: 48), max: nil)
        }
        .background(TableColumnAutoFit(widths: [
            tableColumnWidth("序号", rows.map { String($0.number) }, numeric: true),
            tableColumnWidth("类型", rows.map { $0.rule?.kind.rawValue ?? "MATCH" }, monospaced: true),
            tableColumnWidth("匹配条件", rows.map { $0.rule?.value ?? "所有未匹配的连接" }),
            tableColumnWidth("附加选项", rows.map(optionsText)),
            tableColumnWidth("出口", rows.map(targetText), padding: 48)
        ]))
        .help("使用上移、下移调整匹配顺序；序号为实际匹配优先级，MATCH 固定在最后。")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                HStack(spacing: 4) {
                    Button { adding = true } label: { toolbarIcon("添加规则", systemImage: "plus") }.frame(width: 28, height: 28).disabled(model.busy)
                    Button {
                        if let selectedIndex { editing = model.settings.rules[selectedIndex] }
                    } label: { toolbarIcon("编辑", systemImage: "pencil") }.frame(width: 28, height: 28).disabled(selectedIndex == nil || model.busy)
                    Button {
                        if let selection { model.moveRule(selection, offset: -1) }
                    } label: { toolbarIcon("上移", systemImage: "arrow.up") }.frame(width: 28, height: 28).disabled(selectedIndex == nil || selectedIndex == 0 || model.busy)
                    Button {
                        if let selection { model.moveRule(selection, offset: 1) }
                    } label: { toolbarIcon("下移", systemImage: "arrow.down") }.frame(width: 28, height: 28).disabled(selectedIndex == nil || selectedIndex == model.settings.rules.count - 1 || model.busy)
                    DeleteButton(toolbar: true, message: "确定删除所选路由规则吗？此操作无法撤销。") {
                        if let selection { model.deleteRule(selection); self.selection = nil }
                    }.disabled(selectedIndex == nil || model.busy)
                }
                .buttonStyle(.bordered)
                .controlSize(.regular)
                .padding(.horizontal, 4)
                .padding(.vertical, 2)
            }
        }
        .sheet(isPresented: $adding) { RuleEditorView() }
        .sheet(item: $editing) { RuleEditorView(rule: $0) }
    }
    @ViewBuilder func targetPicker(_ row: RuleTableItem) -> some View {
        if let rule = row.rule {
            if rule.kind == .subRule {
                Picker("子规则", selection: Binding(get: { rule.subRuleTarget ?? "" }, set: { target in
                    var updated = rule
                    updated.subRuleTarget = target
                    do { try model.saveRule(updated) }
                    catch { model.error = error.localizedDescription }
                })) {
                    Text("未选择").tag("")
                    ForEach(model.settings.options?["sub-rules"]?.object.keys.sorted() ?? [], id: \.self) { Text("子规则：" + $0).tag($0) }
                }.labelsHidden()
            } else {
                PolicyPicker(model: model, selection: Binding(get: { model.targetID(node: rule.node, builtin: rule.builtin, group: rule.proxyGroup) }, set: { model.setRuleTarget(rule, target: $0) }))
            }
        } else {
            PolicyPicker(model: model, selection: Binding(get: { model.targetID(node: model.settings.defaultNode, builtin: model.settings.defaultPolicy ?? (model.settings.defaultDirect == true ? "DIRECT" : "REJECT"), group: model.settings.defaultProxyGroup) }, set: { model.setDefaultTarget($0) }))
        }
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
    @State private var atTop = false
    @State private var advancedLogic: Bool
    @State private var conditions = [RuleCondition(), RuleCondition(kind: .network, value: "tcp")]
    @State private var error: String?
    init(rule: RouteRule? = nil, prefill: RouteRule? = nil) {
        original = rule
        let initial = rule ?? prefill
        _kind = State(initialValue: initial?.kind ?? .domain)
        _value = State(initialValue: initial?.value ?? "")
        let cidr = (initial?.value ?? "").split(separator: "/").map(String.init)
        _address = State(initialValue: cidr.first ?? "")
        _prefix = State(initialValue: cidr.count == 2 ? cidr[1] : "24")
        _target = State(initialValue: initial?.proxyGroup.map { "group:" + $0 } ?? initial?.node.map { "node:" + $0.id } ?? "builtin:" + (initial?.builtin ?? "DIRECT"))
        _noResolve = State(initialValue: initial?.noResolve ?? false)
        _sourceIP = State(initialValue: initial?.sourceIP ?? false)
        _subTarget = State(initialValue: initial?.subRuleTarget ?? "")
        _advancedLogic = State(initialValue: initial?.kind.isLogic == true)
    }
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(original == nil ? "添加路由规则" : "编辑路由规则").font(.title2.bold())
            ScrollView {
                VStack(alignment: .leading, spacing: 6) {
                    formRow("type *", help: documentedHelp(document: "rules/index.md", key: kind.rawValue) ?? "选择路由规则类型。") {
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
                        if advancedLogic {
                            formRow("expression *", help: (documentedHelp(document: "rules/index.md", key: kind.rawValue) ?? "填写逻辑表达式。") + "\n\n示例：" + kind.hint) { TextField("", text: $value) }
                        }
                        else {
                            ForEach(conditions.indices, id: \.self) { index in
                                formRow("condition[\(index + 1)].type", help: documentedHelp(document: "rules/index.md", key: conditions[index].kind.rawValue) ?? "选择条件的规则类型。") {
                                    HStack {
                                        Picker("条件", selection: $conditions[index].kind) {
                                            ForEach(RuleKind.allCases.filter { !$0.isLogic }, id: \.self) { Text(optionLabel($0.rawValue)).tag($0) }
                                        }.labelsHidden()
                                        if conditions.count > 1 && kind != .not && kind != .subRule {
                                            DeleteButton(title: "删除条件", message: "确定删除第 \(index + 1) 个条件吗？此操作无法撤销。") {
                                                guard conditions.indices.contains(index) else { return }
                                                conditions.remove(at: index)
                                            }
                                        }
                                    }
                                }
                                formRow("condition[\(index + 1)].value", help: (documentedHelp(document: "rules/index.md", key: conditions[index].kind.rawValue) ?? "填写条件的匹配内容。") + "\n\n示例：" + conditions[index].kind.hint) { matchValueField(kind: conditions[index].kind, value: $conditions[index].value) }
                            }
                            if kind != .not && kind != .subRule {
                                formRow("conditions") { Button("添加条件") { conditions.append(RuleCondition()) } }
                            }
                        }
                    } else {
                        formRow("value *", help: (documentedHelp(document: "rules/index.md", key: kind.rawValue) ?? "填写当前规则类型的匹配内容。") + "\n\n示例：" + kind.hint) { matchValueField(kind: kind, value: $value).help(kind.hint) }
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
                    if original == nil {
                        Toggle("插入列表顶部（优先匹配）", isOn: $atTop)
                        Text(atTop ? "插入第 1 条，优先于现有规则。" : "追加至第 \(model.settings.rules.count + 1) 条、MATCH 之前。前置规则可能优先命中。")
                            .font(.caption).foregroundStyle(.secondary)
                    }
                    if let preview = try? makeRule() {
                        GroupBox("规则预览") {
                            VStack(alignment: .leading, spacing: 6) {
                                Text("\(preview.kind.rawValue),\(preview.value)").font(.system(.body, design: .monospaced)).textSelection(.enabled)
                                let destination = preview.proxyGroup ?? preview.node.map { model.nodeLabelWithDelay($0) } ?? preview.builtin ?? "DIRECT"
                                Text(preview.kind == .subRule ? "子规则：" + subTarget : "目标出口：" + destination)
                                Text(ruleScopeDescription(preview))
                                if model.settings.rules.contains(where: { $0.id != original?.id && sameRuleMatch($0, preview) }) {
                                    Text("已有相同匹配条件，请确认是否需要重复添加，或修改已有规则的出口。")
                                        .foregroundStyle(.orange)
                                }
                                let index = original.flatMap { original in model.settings.rules.firstIndex { $0.id == original.id } }
                                    ?? (atTop ? 0 : model.settings.rules.count)
                                if let notice = rulePriorityNotice(preview, preceding: Array(model.settings.rules.prefix(index))) {
                                    Text(notice).foregroundStyle(.orange)
                                }
                            }.font(.caption).frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                }.textFieldStyle(.roundedBorder)
            }
            HStack {
                Spacer()
                Button("取消") { dismiss() }.keyboardShortcut(.cancelAction)
                Button("保存规则") { save() }.buttonStyle(.borderedProminent).disabled(model.busy)
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
    @ViewBuilder func matchValueField(kind: RuleKind, value: Binding<String>) -> some View {
        if kind == .geosite || kind == .geoIP || kind == .sourceGeoIP {
            GeoMatchInput(value: value, options: kind == .geosite ? geoSiteOptions : geoIPOptions, isGeoIP: kind != .geosite)
                .frame(height: 24)
        } else {
            TextField("", text: value)
        }
    }
    func makeRule() throws -> RouteRule {
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
        rule.builtin = target.hasPrefix("builtin:") ? String(target.dropFirst(8)) : nil
        rule.noResolve = noResolve; rule.sourceIP = sourceIP; rule.subRuleTarget = subTarget
        try validateRule(rule, settings: model.settings)
        return rule
    }
    func save() {
        do {
            try model.saveRule(makeRule(), atTop: atTop); dismiss()
        } catch { self.error = error.localizedDescription }
    }
}

extension DeskModel {
    func deleteRule(_ id: String) {
        guard !busy else { return }
        do {
            var candidate = settings
            candidate.rules.removeAll { $0.id == id }
            try saveSettings(candidate, to: directory)
            settings = candidate
            message = "规则已删除，运行时将自动应用。"
        } catch { self.error = error.localizedDescription }
    }
    func chooseApplicationPath() -> String? {
        let panel = NSOpenPanel(); panel.canChooseDirectories = false; panel.allowedContentTypes = [.application]
        if panel.runModal() == .OK, let url = panel.url,
           let bundle = Bundle(url: url), let executable = bundle.executableURL {
            return executable.path
        }
        return nil
    }
    func targetID(node: Node?, builtin: String?, group: String? = nil) -> String { group.map { "group:" + $0 } ?? node.map { "node:" + $0.id } ?? "builtin:" + (builtin ?? "DIRECT") }
    func setDefaultTarget(_ target: String) {
        do {
            var candidate = settings
            let selected = allNodes.first { "node:" + $0.id == target }
                ?? (candidate.defaultNode.map { "node:" + $0.id == target } == true ? candidate.defaultNode : nil)
            if target.hasPrefix("node:"), selected == nil { throw DeskError("所选代理已失效，请重新选择出口") }
            candidate.defaultProxyGroup = target.hasPrefix("group:") ? String(target.dropFirst(6)) : nil
            candidate.defaultNode = selected
            candidate.defaultPolicy = target.hasPrefix("builtin:") ? String(target.dropFirst(8)) : nil
            candidate.defaultDirect = candidate.defaultPolicy == "DIRECT"
            _ = try generateConfig(candidate); try saveSettings(candidate, to: directory); settings = candidate
        } catch { self.error = error.localizedDescription }
    }
    func saveRule(_ rule: RouteRule, atTop: Bool = false) throws {
        guard !busy else { throw DeskError("正在执行其他操作，请稍后重试") }
        var candidate = settings
        if let index = candidate.rules.firstIndex(where: { $0.id == rule.id }) { candidate.rules[index] = rule }
        else {
            candidate.rules.insert(rule, at: atTop ? 0 : candidate.rules.count)
        }
        _ = try generateConfig(candidate); try saveSettings(candidate, to: directory); settings = candidate
        message = "路由规则已保存，运行时将自动应用。"
    }
    func addRules(_ rules: [RouteRule], atTop: Bool) throws {
        guard !busy else { throw DeskError("正在执行其他操作，请稍后重试") }
        guard !rules.isEmpty else { throw DeskError("没有可添加的规则") }
        var candidate = settings
        var additions: [RouteRule] = []
        for rule in rules {
            guard !candidate.rules.contains(where: { sameRuleMatch($0, rule) }),
                  !additions.contains(where: { sameRuleMatch($0, rule) }) else { throw DeskError("规则已存在，请重新检查批量预览") }
            additions.append(rule)
        }
        candidate.rules.insert(contentsOf: additions, at: atTop ? 0 : candidate.rules.count)
        _ = try generateConfig(candidate)
        try saveSettings(candidate, to: directory)
        settings = candidate
        message = "已保存 \(additions.count) 条路由规则，运行时将自动应用。"
    }
    func setRuleTarget(_ rule: RouteRule, target: String) {
        do {
            var changed = rule
            changed.node = allNodes.first { "node:" + $0.id == target }
                ?? (rule.node.map { "node:" + $0.id == target } == true ? rule.node : nil)
            if target.hasPrefix("node:"), changed.node == nil { throw DeskError("所选代理已失效，请重新选择出口") }
            changed.proxyGroup = target.hasPrefix("group:") ? String(target.dropFirst(6)) : nil
            changed.builtin = target.hasPrefix("builtin:") ? String(target.dropFirst(8)) : nil
            try saveRule(changed)
        } catch { self.error = error.localizedDescription }
    }
    @discardableResult
    func moveRule(_ id: String, before targetID: String?) -> Bool {
        guard !busy, let source = settings.rules.firstIndex(where: { $0.id == id }) else { return false }
        if targetID == id { return true }
        if let targetID, !settings.rules.contains(where: { $0.id == targetID }) { return false }
        var candidate = settings
        let rule = candidate.rules.remove(at: source)
        let destination = targetID.flatMap { target in candidate.rules.firstIndex { $0.id == target } } ?? candidate.rules.count
        candidate.rules.insert(rule, at: destination)
        do {
            try saveSettings(candidate, to: directory)
            settings = candidate
            message = "路由规则顺序已保存，运行时将自动应用。"
            return true
        } catch {
            self.error = error.localizedDescription
            return false
        }
    }
    func moveRule(_ id: String, offset: Int) {
        guard !busy, let index = settings.rules.firstIndex(where: { $0.id == id }), settings.rules.indices.contains(index + offset) else { return }
        do {
            var candidate = settings
            candidate.rules.swapAt(index, index + offset)
            try saveSettings(candidate, to: directory)
            settings = candidate
        } catch { self.error = error.localizedDescription }
    }
}

// Read collection names from the bundled protobuf files once, without decoding domain/IP entries.
private let geoSiteOptions = geoCollectionNames("geosite.dat")
private let geoIPOptions = geoCollectionNames("geoip.dat")

private func geoCollectionNames(_ name: String) -> [String] {
    let url = Bundle.main.bundleURL.appendingPathComponent("Contents/Resources/geodata/" + name)
    guard let data = try? Data(contentsOf: url, options: .mappedIfSafe) else { return [] }
    func varint(_ index: inout Int, end: Int) -> Int? {
        var result: UInt64 = 0
        for shift in stride(from: 0, through: 63, by: 7) {
            guard index < end else { return nil }
            let byte = data[index]; index += 1
            if shift == 63 && byte > 1 { return nil }
            result |= UInt64(byte & 127) << shift
            if byte < 128 { return Int(exactly: result) }
        }
        return nil
    }
    func field(_ index: inout Int, end: Int) -> (Int, Range<Int>?)? {
        guard let key = varint(&index, end: end), key >> 3 > 0 else { return nil }
        switch key & 7 {
        case 0:
            guard varint(&index, end: end) != nil else { return nil }
        case 1, 5:
            let count = key & 7 == 1 ? 8 : 4
            guard end - index >= count else { return nil }
            index += count
        case 2:
            guard let count = varint(&index, end: end), count <= end - index else { return nil }
            let range = index..<(index + count); index += count
            return (key >> 3, range)
        default: return nil
        }
        return (key >> 3, nil)
    }
    var names = Set<String>()
    var index = 0
    while index < data.count {
        guard let (number, entry) = field(&index, end: data.count) else { break }
        guard number == 1, let entry else { continue }
        var nested = entry.lowerBound
        while nested < entry.upperBound {
            guard let (number, bytes) = field(&nested, end: entry.upperBound) else { break }
            if number == 1, let bytes, let name = String(data: data.subdata(in: bytes), encoding: .utf8) {
                names.insert(name.lowercased()); break
            }
        }
    }
    return names.sorted()
}

private struct GeoMatchInput: NSViewRepresentable {
    @Binding var value: String
    let options: [String]
    let isGeoIP: Bool

    private static let geoIPTranslations = [
        "cn": "中国大陆", "private": "私有网络", "google": "谷歌", "telegram": "电报",
        "netflix": "奈飞", "facebook": "脸书", "twitter": "推特", "tor": "洋葱网络",
        "cloudflare": "Cloudflare 云服务", "cloudfront": "亚马逊内容分发网络",
        "fastly": "Fastly 内容分发网络"
    ]

    func label(_ name: String) -> String {
        guard isGeoIP else { return name }
        if let translated = Self.geoIPTranslations[name] { return translated + "（" + name + "）" }
        if name.count == 2, let region = Locale(identifier: "zh_Hans").localizedString(forRegionCode: name.uppercased()) {
            return region + "（" + name + "）"
        }
        return "IP 集合（" + name + "）"
    }

    func makeCoordinator() -> Coordinator { Coordinator(self) }
    func makeNSView(context: Context) -> NSComboBox {
        let view = NSComboBox()
        view.isEditable = true
        view.completes = false
        view.numberOfVisibleItems = 12
        view.placeholderString = "输入或选择集合名称"
        view.delegate = context.coordinator
        view.setAccessibilityLabel("GEO 匹配集合")
        return view
    }
    func updateNSView(_ view: NSComboBox, context: Context) {
        context.coordinator.parent = self
        context.coordinator.updating = true
        defer { context.coordinator.updating = false }
        if view.stringValue != value { view.stringValue = value }
        let choices = value.isEmpty ? options : options.filter { label($0).localizedCaseInsensitiveContains(value) }
        let labels = choices.map(label)
        if context.coordinator.choices != choices || context.coordinator.labels != labels {
            context.coordinator.labels = labels
            context.coordinator.choices = choices
            let text = view.stringValue
            view.removeAllItems()
            view.addItems(withObjectValues: labels)
            view.stringValue = text
        }
    }
    final class Coordinator: NSObject, NSComboBoxDelegate {
        var parent: GeoMatchInput
        var choices: [String] = []
        var labels: [String] = []
        var updating = false
        init(_ parent: GeoMatchInput) { self.parent = parent }
        func controlTextDidChange(_ notification: Notification) {
            guard !updating, let view = notification.object as? NSComboBox else { return }
            if let index = labels.firstIndex(of: view.stringValue), choices.indices.contains(index) {
                parent.value = choices[index]
            } else {
                parent.value = view.stringValue
            }
        }
        func comboBoxSelectionDidChange(_ notification: Notification) {
            guard !updating, let view = notification.object as? NSComboBox,
                  choices.indices.contains(view.indexOfSelectedItem) else { return }
            parent.value = choices[view.indexOfSelectedItem]
        }
    }
}
