import SwiftUI
import AppKit
import ClashCore

struct ResourceRow: Identifiable {
    var id: String
    var name: String
    var type: String
    var fields: [String: ConfigValue]
    var group: ProxyGroup?
}

struct ResourcesView: View {
    @State private var sortOrder: [TableSort<ResourceRow>] = []
    @EnvironmentObject var model: DeskModel
    let groups: Bool
    @State private var selection: String?
    @State private var adding = false
    @State private var editing: ResourceRow?
    var title: String { groups ? "代理分组" : "规则集合" }
    var rows: [ResourceRow] {
        if groups { return (model.settings.proxyGroups ?? []).map { ResourceRow(id: $0.id, name: $0.name, type: $0.type, fields: $0.fields, group: $0) } }
        return (model.settings.options?["rule-providers"]?.object ?? [:]).keys.sorted().map { name in
            let fields = model.settings.options?["rule-providers"]?.object[name]?.object ?? [:]
            return ResourceRow(id: name, name: name, type: fields["type"]?.text ?? "", fields: fields)
        }
    }
    var selected: ResourceRow? { rows.first { $0.id == selection } }
    func columnSort(_ column: String) -> TableSort<ResourceRow> {
        switch column {
        case "名称": return TableSort(column) { $0.name }
        case "类型": return TableSort(column) { $0.type }
        case "选择节点": return TableSort(column, value: selectedMemberText)
        case "行为": return TableSort(column, value: detail)
        default: return TableSort(column, value: source)
        }
    }
    var body: some View {
        let rows = rows
        VStack(alignment: .leading, spacing: 0) {
            if groups {
                Table(rows.sorted(using: sortOrder), selection: $selection, sortOrder: tableSortBinding($sortOrder)) {
                    TableColumn("名称", sortUsing: columnSort("名称")) { row in Text(row.name).textSelection(.enabled) }.width(min: 40, ideal: tableColumnWidth("名称", rows.map(\.name)), max: nil)
                    TableColumn("类型", sortUsing: columnSort("类型")) { row in Text(row.type) }.width(min: 40, ideal: tableColumnWidth("类型", rows.map(\.type)), max: nil)
                    TableColumn("选择节点", sortUsing: columnSort("选择节点")) { row in
                        memberPicker(row)
                    }.width(min: 40, ideal: tableColumnWidth("选择节点", rows.map(selectedMemberText), padding: 48), max: nil)
                }
                .background(TableColumnAutoFit(widths: [
                    tableColumnWidth("名称", rows.map(\.name)),
                    tableColumnWidth("类型", rows.map(\.type)),
                    tableColumnWidth("选择节点", rows.map(selectedMemberText), padding: 48)
                ]))
            } else {
                Table(rows.sorted(using: sortOrder), selection: $selection, sortOrder: tableSortBinding($sortOrder)) {
                    TableColumn("名称", sortUsing: columnSort("名称")) { row in Text(row.name).textSelection(.enabled) }.width(min: 40, ideal: tableColumnWidth("名称", rows.map(\.name)), max: nil)
                    TableColumn("类型", sortUsing: columnSort("类型")) { row in Text(row.type) }.width(min: 40, ideal: tableColumnWidth("类型", rows.map(\.type)), max: nil)
                    TableColumn("行为", sortUsing: columnSort("行为")) { row in Text(detail(row)) }.width(min: 40, ideal: tableColumnWidth("行为", rows.map(detail)), max: nil)
                    TableColumn("来源 / 内容", sortUsing: columnSort("来源 / 内容")) { row in Text(source(row)).textSelection(.enabled).help(source(row)) }
                        .width(min: 40, ideal: tableColumnWidth("来源 / 内容", rows.map(source)), max: nil)
                }
                .background(TableColumnAutoFit(widths: [
                    tableColumnWidth("名称", rows.map(\.name)),
                    tableColumnWidth("类型", rows.map(\.type)),
                    tableColumnWidth("行为", rows.map(detail)),
                    tableColumnWidth("来源 / 内容", rows.map(source))
                ]))
            }

        }
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                HStack(spacing: -4) {
                    Button { adding = true } label: { toolbarIcon("添加", systemImage: "plus") }.frame(width: 28, height: 28).disabled(model.busy)
                    Button { editing = selected } label: { toolbarIcon("编辑", systemImage: "pencil") }.frame(width: 28, height: 28).disabled(model.busy || selected == nil)
                    DeleteButton(toolbar: true, message: "确定删除“\(selected?.name ?? "")”吗？此操作无法撤销。") {
                        if let selected { model.deleteResource(selected, groups: groups) }
                    }.disabled(model.busy || selected == nil)
                }
                .buttonStyle(.bordered)
                .controlSize(.regular)
                .padding(.horizontal, 4)
                .padding(.vertical, 2)
            }
        }
        .sheet(isPresented: $adding) { ResourceEditorView(groups: groups) }
        .sheet(item: $editing) { ResourceEditorView(groups: groups, original: $0) }
    }
    @ViewBuilder func memberPicker(_ row: ResourceRow) -> some View {
        if let group = row.group, group.type == "select" {
            Picker("选择节点", selection: Binding(get: {
                let current = group.fields["default-selected"]?.text ?? ""
                return current.isEmpty ? group.targets.first ?? "" : current
            }, set: { target in
                var updated = group
                updated.fields["default-selected"] = .string(target)
                do { try model.saveProxyGroup(updated) }
                catch { model.error = error.localizedDescription }
            })) {
                if group.targets.isEmpty { Text("空（Empty）").tag("") }
                ForEach(group.targets.reduce(into: [String]()) { if !$0.contains($1) { $0.append($1) } }, id: \.self) { target in
                    Text(memberLabel(target)).tag(target)
                }
            }
            .labelsHidden()
            .disabled(model.busy || group.targets.isEmpty)
        } else {
            Text(selectedMemberText(row))
        }
    }
    func detail(_ row: ResourceRow) -> String {
        if let group = row.group { return "\(group.targets.count)" + (group.fields["include-all-proxies"] == .boolean(true) ? " + 全部节点" : "") }
        return (row.fields["behavior"]?.text ?? "—") + " / " + (row.fields["format"]?.text ?? "yaml")
    }
    func selectedMemberText(_ row: ResourceRow) -> String {
        guard let group = row.group, group.type == "select" else { return "—" }
        let selected = group.fields["default-selected"]?.text ?? ""
        guard let target = selected.isEmpty ? group.targets.first : selected else { return "空（Empty）" }
        return memberLabel(target)
    }
    func memberLabel(_ target: String) -> String {
        if let node = model.allNodes.first(where: { "node:" + $0.id == target }) { return model.nodeLabel(node) }
        if target.hasPrefix("group:") { return "代理组 / " + target.dropFirst(6) }
        if target.hasPrefix("builtin:") { return optionLabel(String(target.dropFirst(8))) }
        return "已失效：" + target
    }
    func source(_ row: ResourceRow) -> String {
        if groups { return row.fields["url"]?.text ?? "—" }
        if row.type == "inline" { return "\(row.fields["payload"]?.array.count ?? 0) 条规则" }
        return row.fields[row.type == "http" ? "url" : "path"]?.text ?? "—"
    }
}

struct ResourceEditorView: View {
    @EnvironmentObject var model: DeskModel
    @Environment(\.dismiss) private var dismiss
    let groups: Bool
    let original: ResourceRow?
    @State private var name: String
    @State private var type: String
    @State private var fields: [String: ConfigValue]
    @State private var targets: [String]
    @State private var error: String?
    init(groups: Bool, original: ResourceRow? = nil) {
        self.groups = groups; self.original = original
        _name = State(initialValue: original?.name ?? "")
        _type = State(initialValue: original?.type ?? (groups ? "select" : "http"))
        _fields = State(initialValue: original?.fields ?? (groups ? [:] : ["behavior": .string("domain"), "format": .string("yaml"), "interval": .integer(600)]))
        _targets = State(initialValue: original?.group?.targets ?? [])
    }
    var schema: [EditorField] { groups ? groupEditorFields(type) : ruleProviderEditorFields(type) }
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text((original == nil ? "添加" : "编辑") + (groups ? "代理组" : "规则集")).font(.title2.bold())
            if !groups {
                formRow("name *") { TextField("规则集名称", text: $name).textFieldStyle(.roundedBorder) }
                formRow("type *") {
                    Picker("类型", selection: $type) {
                        ForEach(["http", "file", "inline"], id: \.self) { Text(optionLabel($0)).tag($0) }
                    }.labelsHidden()
                }
            }
            ScrollView {
                VStack(alignment: .leading, spacing: 6) {
                    if groups {
                        HStack(spacing: 12) {
                            FieldKeyLabel(title: "name *", key: "name").frame(width: 200, alignment: .leading)
                            TextField("代理组名称", text: $name).textFieldStyle(.roundedBorder)
                        }.padding(.vertical, 3)
                        HStack(spacing: 12) {
                            FieldKeyLabel(title: "type *", key: "type").frame(width: 200, alignment: .leading)
                            Picker("类型", selection: $type) {
                                ForEach(["select", "url-test", "fallback", "load-balance"], id: \.self) { Text(optionLabel($0)).tag($0) }
                            }.labelsHidden()
                            Spacer(minLength: 0)
                        }.padding(.vertical, 3)
                        HStack(alignment: .top, spacing: 12) {
                            FieldKeyLabel(title: "proxies", key: "proxies", description: "引入节点或其他代理组作为成员。成员顺序可通过上下移按钮调整；fallback 会按顺序选择可用成员。").frame(width: 200, alignment: .leading)
                            VStack(alignment: .leading, spacing: 4) {
                                ForEach(targets.indices, id: \.self) { index in
                                    HStack {
                                        memberPicker(index)
                                        Button { targets.swapAt(index, index - 1) } label: { formActionIcon("arrow.up") }.buttonStyle(.bordered).controlSize(.regular).help("上移").disabled(index == 0)
                                        Button { targets.swapAt(index, index + 1) } label: { formActionIcon("arrow.down") }.buttonStyle(.bordered).controlSize(.regular).help("下移").disabled(index + 1 == targets.count)
                                        DeleteButton(title: "删除成员", message: "确定删除第 \(index + 1) 个成员吗？此操作无法撤销。") {
                                            guard targets.indices.contains(index) else { return }
                                            targets.remove(at: index)
                                        }
                                    }
                                }
                                Button { targets.append(model.allNodes.first.map { "node:" + $0.id } ?? "builtin:REJECT") } label: { Label("添加成员", systemImage: "plus") }
                            }
                        }.padding(.vertical, 3)
                    }
                    ForEach(schema) { field in
                        if groups && field.path == "default-selected" {
                            HStack {
                                FieldKeyLabel(title: "default-selected", key: "default-selected").frame(width: 200, alignment: .leading)
                                Picker("默认成员", selection: Binding(get: {
                                    let selected = fields["default-selected"]?.text ?? ""
                                    return selected.isEmpty ? targets.first ?? "" : selected
                                }, set: { fields["default-selected"] = .string($0) })) {
                                    if targets.isEmpty { Text("空（Empty）").tag("") }
                                    ForEach(Array(Set(targets)).sorted(), id: \.self) { target in Text(memberLabel(target)).tag(target) }
                                }.labelsHidden()
                            }
                        } else {
                            VisualField(field: field, value: Binding(get: {
                                fields[field.path] ?? (field.path == "lazy" ? .boolean(true) : nil)
                            }, set: { fields[field.path] = $0 }), compact: true)
                        }
                        if field.path == "path", type == "file" {
                            Button("选择规则文件") {
                                let panel = NSOpenPanel(); panel.canChooseDirectories = false
                                if panel.runModal() == .OK, let url = panel.url { fields["path"] = .string(url.path) }
                            }
                        }
                    }
                    if !groups && type == "http" {
                        HStack {
                            FieldKeyLabel(title: "proxy", key: "proxy").frame(width: 200, alignment: .leading)
                            PolicyPicker(model: model, selection: Binding(get: { fields["proxy"]?.text ?? "builtin:DIRECT" }, set: { fields["proxy"] = .string($0) }))
                        }
                    }
                }
            }
            if let error { Text(error).foregroundStyle(.red).textSelection(.enabled) }
            HStack {
                Spacer()
                Button("取消") { dismiss() }.keyboardShortcut(.cancelAction)
                Button("保存") { save() }.buttonStyle(.borderedProminent)
            }
        }.padding(16).controlSize(.regular).frame(width: 720, height: 560)
        .environment(\.formHelpDocument, groups ? "proxy-groups/" + type + ".md" : "rule-providers/index.md")
        .onChange(of: type) { _ in
            let allowed = Set(schema.map(\.path) + (groups ? [] : ["proxy"]))
            fields = fields.filter { allowed.contains($0.key) }
            if groups && type != "select" {
                if fields["url"] == nil { fields["url"] = .string("https://www.gstatic.com/generate_204") }
                if fields["interval"] == nil { fields["interval"] = .integer(300) }
                if fields["timeout"] == nil { fields["timeout"] = .integer(5000) }
                if fields["lazy"] == nil { fields["lazy"] = .boolean(true) }
            }
            if !groups && type == "inline" { fields["payload"] = fields["payload"] ?? .array([]) }
        }
    }
    func memberLabel(_ target: String) -> String {
        if let node = model.allNodes.first(where: { "node:" + $0.id == target }) { return model.nodeLabel(node) }
        return target.hasPrefix("group:") ? "代理组 / " + target.dropFirst(6) : target.hasPrefix("builtin:") ? optionLabel(String(target.dropFirst(8))) : "已失效：" + target
    }
    func memberPicker(_ index: Int) -> some View {
        Picker("成员", selection: Binding(get: { targets.indices.contains(index) ? targets[index] : "" }, set: {
            if targets.indices.contains(index) { targets[index] = $0 }
        })) {
            Text(optionLabel("DIRECT")).tag("builtin:DIRECT")
            Text(optionLabel("REJECT")).tag("builtin:REJECT")
            Text(optionLabel("REJECT-DROP")).tag("builtin:REJECT-DROP")
            if targets.indices.contains(index), !["builtin:DIRECT", "builtin:REJECT", "builtin:REJECT-DROP"].contains(targets[index]),
               !model.allNodes.contains(where: { "node:" + $0.id == targets[index] }),
               !(model.settings.proxyGroups ?? []).contains(where: { "group:" + $0.name == targets[index] }) {
                Text(memberLabel(targets[index])).tag(targets[index])
            }
            ForEach(model.allNodes) { Text(model.nodeLabel($0)).tag("node:" + $0.id) }
            ForEach((model.settings.proxyGroups ?? []).filter { $0.id != original?.group?.id }) { Text("代理组 / " + $0.name).tag("group:" + $0.name) }
        }.labelsHidden()
    }
    func save() {
        do {
            let name = name.trimmingCharacters(in: .whitespacesAndNewlines)
            let fields = fields.filter { $0.value != .string("") }
            if groups {
                var group = ProxyGroup(name: name, type: type, targets: targets, fields: fields)
                if let existing = original?.group { group.id = existing.id }
                try model.saveProxyGroup(group)
            } else { try model.saveRuleProvider(name: name, type: type, fields: fields, oldName: original?.name) }
            dismiss()
        } catch { self.error = error.localizedDescription }
    }
}
