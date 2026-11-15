import SwiftUI
import AppKit
import MihomoCore

struct RuleProvidersView: View {
    @State private var sortOrder: [TableSort<ResourceRow>] = []
    @EnvironmentObject var model: MihomoModel
    @State private var selection: String?
    @State private var adding = false
    @State private var editing: ResourceRow?
    @State private var deleting: ResourceRow?
    var rows: [ResourceRow] {
        (model.settings.options?["rule-providers"]?.object ?? [:]).keys.sorted().map { name in
            let fields = model.settings.options?["rule-providers"]?.object[name]?.object ?? [:]
            return ResourceRow(id: name, name: name, type: fields["type"]?.text ?? "", fields: fields)
        }
    }
    func columnSort(_ column: String) -> TableSort<ResourceRow> {
        switch column {
        case "名称": return TableSort(column) { $0.name }
        case "类型": return TableSort(column) { $0.type }
        case "行为": return TableSort(column, value: detail)
        default: return TableSort(column, value: source)
        }
    }
    var body: some View {
        let rows = rows
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
        .contextMenu(forSelectionType: String.self) { ids in
            if let id = ids.first, let item = rows.first(where: { $0.id == id }) {
                Button("编辑") { editing = item }.disabled(model.busy)
                Button("删除", role: .destructive) { deleting = item }.disabled(model.busy)
            }
        }
        .alert("确认删除", isPresented: Binding(get: { deleting != nil }, set: { if !$0 { deleting = nil } })) {
            Button("取消", role: .cancel) { deleting = nil }
            Button("确认删除", role: .destructive) {
                if let item = deleting { model.deleteResource(item, groups: false) }
                deleting = nil
            }.disabled(model.busy)
        } message: {
            Text("确定删除“\(deleting?.name ?? "")”吗？此操作无法撤销。")
        }
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button { adding = true } label: { Label("新建规则集合", systemImage: "plus") }
                    .disabled(model.busy)
                    .labelStyle(.iconOnly)
                    .help("新建规则集合")
            }
        }
        .sheet(isPresented: $adding) { ResourceEditorView(groups: false) }
        .sheet(item: $editing) { ResourceEditorView(groups: false, original: $0) }
    }
    func detail(_ row: ResourceRow) -> String {
        (row.fields["behavior"]?.text ?? "—") + " / " + (row.fields["format"]?.text ?? "yaml")
    }
    func source(_ row: ResourceRow) -> String {
        if row.type == "inline" { return "\(row.fields["payload"]?.array.count ?? 0) 条规则" }
        return row.fields[row.type == "http" ? "url" : "path"]?.text ?? "—"
    }
}
