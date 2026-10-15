import SwiftUI
import ClashCore
import AppKit

private let matchID = "default-match"
struct RuleTableItem: Identifiable { let id: String; let number: Int; let rule: RouteRule? }

struct PolicyPicker: View {
    @ObservedObject var model: DeskModel
    @Binding var selection: String
    var body: some View {
        Picker("出口", selection: $selection) {
            Label(optionLabel("DIRECT"), systemImage: "arrow.up.right").tag("builtin:DIRECT")
            Label(optionLabel("REJECT"), systemImage: "hand.raised").tag("builtin:REJECT")
            Label(optionLabel("REJECT-DROP"), systemImage: "hand.raised.slash").tag("builtin:REJECT-DROP")
            if selection.hasPrefix("node:"), !model.allNodes.contains(where: { "node:" + $0.id == selection }) {
                Label("已失效：" + selection.dropFirst(5), systemImage: "exclamationmark.triangle").tag(selection)
            }
            ForEach(model.settings.proxyGroups ?? []) { Label("代理组 / " + $0.name, systemImage: "square.stack.3d.up").tag("group:" + $0.name) }
            ForEach(model.allNodes) { node in Label(model.nodeLabel(node), systemImage: "network").tag("node:" + node.id) }
        }.labelsHidden()
    }
}

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
    func columnSort(_ column: String) -> TableSort<RuleTableItem> {
        switch column {
        case "序号": return TableSort(column) { $0.number }
        case "类型": return TableSort(column) { $0.rule?.kind.rawValue ?? "MATCH" }
        case "匹配条件": return TableSort(column) { $0.rule?.value ?? "所有未匹配的连接" }
        case "附加选项": return TableSort(column) { [$0.rule?.noResolve == true ? "no-resolve" : nil, $0.rule?.sourceIP == true ? "src" : nil].compactMap { $0 }.joined(separator: ", ") }
        default: return TableSort(column, value: targetText)
        }
    }
    var body: some View {
        let rows = rows
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
                DeleteButton(message: "确定删除所选路由规则吗？此操作无法撤销。") {
                    if let selection { model.deleteRule(selection); self.selection = nil }
                }.disabled(selectedIndex == nil || model.busy)
                Menu {
                    if let row = rows.first(where: { $0.id == selection }) { targetActions(row) }
                } label: { Label("选择出口", systemImage: "arrow.triangle.branch") }.disabled(model.busy || selection == nil)
            }.pageActions()
            RuleTable(rows: rows, selection: $selection, sortOrder: $sortOrder, busy: model.busy,
                      targetText: targetText, columnSort: columnSort) { id, targetID in
                guard model.moveRule(id, before: targetID) else { return false }
                selection = id
                sortOrder = []
                return true
            }
            Text("长按并拖动行可调整匹配顺序；序号为实际匹配优先级，MATCH 固定在最后。")
                .font(.caption).foregroundStyle(.secondary)
        }
        .sheet(isPresented: $adding) { RuleEditorView() }
        .sheet(item: $editing) { RuleEditorView(rule: $0) }
    }
    @ViewBuilder func targetActions(_ row: RuleTableItem) -> some View {
        if let rule = row.rule {
            if rule.kind == .subRule {
                Button { editing = rule } label: { Label("编辑子规则", systemImage: "pencil") }
            } else {
                PolicyPicker(model: model, selection: Binding(get: { model.targetID(node: rule.node, builtin: rule.builtin, group: rule.proxyGroup) }, set: { model.setRuleTarget(rule, target: $0) }))
            }
        } else {
            PolicyPicker(model: model, selection: Binding(get: { model.targetID(node: model.settings.defaultNode, builtin: model.settings.defaultPolicy ?? (model.settings.defaultDirect == true ? "DIRECT" : "REJECT"), group: model.settings.defaultProxyGroup) }, set: { model.setDefaultTarget($0) }))
        }
    }

}

// AppKit owns the whole-row drag, insertion indicator and drop acceptance.
private struct RuleTable: NSViewRepresentable {
    let rows: [RuleTableItem]
    @Binding var selection: String?
    @Binding var sortOrder: [TableSort<RuleTableItem>]
    let busy: Bool
    let targetText: (RuleTableItem) -> String
    let columnSort: (String) -> TableSort<RuleTableItem>
    let move: (String, String?) -> Bool
    static let columns = ["序号", "类型", "匹配条件", "附加选项", "出口"]
    static let dragType = NSPasteboard.PasteboardType("local.clashdesk.route-rule")

    func values(_ row: RuleTableItem) -> [String] {
        [String(row.number), row.rule?.kind.rawValue ?? "MATCH", row.rule?.value ?? "所有未匹配的连接",
         [row.rule?.noResolve == true ? "no-resolve" : nil, row.rule?.sourceIP == true ? "src" : nil].compactMap { $0 }.joined(separator: ", "),
         targetText(row)]
    }
    func makeCoordinator() -> Coordinator { Coordinator(self) }
    func makeNSView(context: Context) -> NSScrollView {
        let table = NSTableView()
        table.delegate = context.coordinator
        table.dataSource = context.coordinator
        table.rowHeight = 24
        table.allowsMultipleSelection = false
        table.allowsEmptySelection = true
        table.columnAutoresizingStyle = .noColumnAutoresizing
        table.usesAlternatingRowBackgroundColors = true
        table.registerForDraggedTypes([Self.dragType])
        table.setDraggingSourceOperationMask(.move, forLocal: true)
        for title in Self.columns {
            let column = NSTableColumn(identifier: NSUserInterfaceItemIdentifier(title))
            column.title = title
            column.minWidth = 40
            column.resizingMask = .userResizingMask
            column.sortDescriptorPrototype = NSSortDescriptor(key: title, ascending: true)
            table.addTableColumn(column)
        }
        let scroll = NSScrollView()
        scroll.hasVerticalScroller = true
        scroll.hasHorizontalScroller = true
        scroll.autohidesScrollers = true
        scroll.borderType = .bezelBorder
        scroll.documentView = table
        return scroll
    }
    func updateNSView(_ scroll: NSScrollView, context: Context) {
        guard let table = scroll.documentView as? NSTableView else { return }
        let coordinator = context.coordinator
        coordinator.parent = self
        let displayed = rows.sorted(using: sortOrder)
        let values = displayed.map(self.values)
        coordinator.updating = true
        defer { coordinator.updating = false }
        if displayed.map(\.id) != coordinator.rows.map(\.id) || values != coordinator.cells {
            coordinator.rows = displayed
            coordinator.cells = values
            table.reloadData()
        }
        for (index, column) in table.tableColumns.enumerated() where !coordinator.resizedColumns.contains(column.identifier) {
            column.width = tableColumnWidth(column.title, values.map { $0[index] }, numeric: index == 0, monospaced: index == 1)
        }
        let descriptors = sortOrder.map { NSSortDescriptor(key: $0.column, ascending: $0.order == .forward) }
        if table.sortDescriptors != descriptors { table.sortDescriptors = descriptors }
        let selectedRow = displayed.firstIndex { $0.id == selection }
        let indexes = selectedRow.map { IndexSet(integer: $0) } ?? IndexSet()
        if table.selectedRowIndexes != indexes { table.selectRowIndexes(indexes, byExtendingSelection: false) }
    }

    final class Coordinator: NSObject, NSTableViewDataSource, NSTableViewDelegate {
        var parent: RuleTable
        var rows: [RuleTableItem] = []
        var cells: [[String]] = []
        var updating = false
        var resizedColumns: Set<NSUserInterfaceItemIdentifier> = []
        init(_ parent: RuleTable) { self.parent = parent }
        func numberOfRows(in tableView: NSTableView) -> Int { rows.count }
        func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
            guard let column = tableColumn, let index = RuleTable.columns.firstIndex(of: column.title), cells.indices.contains(row) else { return nil }
            let identifier = column.identifier
            let cell = (tableView.makeView(withIdentifier: identifier, owner: nil) as? NSTextField) ?? NSTextField(labelWithString: "")
            cell.identifier = identifier
            cell.stringValue = cells[row][index]
            cell.toolTip = cell.stringValue
            cell.lineBreakMode = .byTruncatingTail
            cell.font = index == 0 ? .monospacedDigitSystemFont(ofSize: NSFont.systemFontSize, weight: .regular)
                : index == 1 ? .monospacedSystemFont(ofSize: NSFont.systemFontSize, weight: .regular) : .systemFont(ofSize: NSFont.systemFontSize)
            return cell
        }
        func tableViewSelectionDidChange(_ notification: Notification) {
            guard !updating, let table = notification.object as? NSTableView else { return }
            parent.selection = rows.indices.contains(table.selectedRow) ? rows[table.selectedRow].id : nil
        }
        func tableView(_ tableView: NSTableView, sortDescriptorsDidChange oldDescriptors: [NSSortDescriptor]) {
            guard !updating else { return }
            parent.sortOrder = tableView.sortDescriptors.compactMap { descriptor in
                guard let key = descriptor.key else { return nil }
                var sort = parent.columnSort(key)
                sort.order = descriptor.ascending ? .forward : .reverse
                return sort
            }
        }
        func tableViewColumnDidResize(_ notification: Notification) {
            guard !updating, let column = notification.userInfo?["NSTableColumn"] as? NSTableColumn else { return }
            resizedColumns.insert(column.identifier)
        }
        func tableView(_ tableView: NSTableView, pasteboardWriterForRow row: Int) -> NSPasteboardWriting? {
            guard !parent.busy, rows.indices.contains(row), rows[row].rule != nil else { return nil }
            let item = NSPasteboardItem()
            item.setString(rows[row].id, forType: RuleTable.dragType)
            return item
        }
        func tableView(_ tableView: NSTableView, validateDrop info: NSDraggingInfo, proposedRow row: Int, proposedDropOperation operation: NSTableView.DropOperation) -> NSDragOperation {
            guard !parent.busy, let source = info.draggingSource as? NSTableView, source === tableView,
                  let id = info.draggingPasteboard.string(forType: RuleTable.dragType),
                  rows.contains(where: { $0.id == id && $0.rule != nil }) else { return [] }
            tableView.setDropRow(max(0, min(row, rows.count)), dropOperation: .above)
            return .move
        }
        func tableView(_ tableView: NSTableView, acceptDrop info: NSDraggingInfo, row: Int, dropOperation: NSTableView.DropOperation) -> Bool {
            guard !parent.busy, let source = info.draggingSource as? NSTableView, source === tableView,
                  let id = info.draggingPasteboard.string(forType: RuleTable.dragType) else { return false }
            let target = rows.indices.contains(row) ? rows[row].rule?.id : nil
            return parent.move(id, target)
        }
        func tableView(_ tableView: NSTableView, draggingSession session: NSDraggingSession, willBeginAt screenPoint: NSPoint, forRowIndexes rowIndexes: IndexSet) {
            session.draggingFormation = .none
            session.enumerateDraggingItems(options: [], for: tableView, classes: [NSPasteboardItem.self], searchOptions: [:]) { item, _, _ in
                guard let row = rowIndexes.first else { return }
                let rect = tableView.rect(ofRow: row)
                guard let bitmap = tableView.bitmapImageRepForCachingDisplay(in: rect) else { return }
                tableView.cacheDisplay(in: rect, to: bitmap)
                let image = NSImage(size: rect.size)
                image.addRepresentation(bitmap)
                // Keep AppKit's original drag frame and mouse anchor. Row coordinates
                // must not replace the session's frame when the table is flipped/scrolled.
                item.imageComponentsProvider = {
                    let component = NSDraggingImageComponent(key: .icon)
                    component.contents = image
                    component.frame = NSRect(origin: .zero, size: image.size)
                    return [component]
                }
            }
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
                                formRow("condition[\(index + 1)].value", help: (documentedHelp(document: "rules/index.md", key: conditions[index].kind.rawValue) ?? "填写条件的匹配内容。") + "\n\n示例：" + conditions[index].kind.hint) { TextField("", text: $conditions[index].value) }
                            }
                            if kind != .not && kind != .subRule {
                                formRow("conditions") { Button("添加条件") { conditions.append(RuleCondition()) } }
                            }
                        }
                    } else {
                        formRow("value *", help: (documentedHelp(document: "rules/index.md", key: kind.rawValue) ?? "填写当前规则类型的匹配内容。") + "\n\n示例：" + kind.hint) { TextField("", text: $value).help(kind.hint) }
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
