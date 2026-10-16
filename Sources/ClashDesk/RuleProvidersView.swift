import SwiftUI
import AppKit
import ClashCore

struct RuleProvidersView: View {
    @State private var sortOrder: [TableSort<ResourceRow>] = []
    @EnvironmentObject var model: DeskModel
    @State private var selection: String?
    @State private var adding = false
    @State private var editing: ResourceRow?
    var rows: [ResourceRow] {
        (model.settings.options?["rule-providers"]?.object ?? [:]).keys.sorted().map { name in
            let fields = model.settings.options?["rule-providers"]?.object[name]?.object ?? [:]
            return ResourceRow(id: name, name: name, type: fields["type"]?.text ?? "", fields: fields)
        }
    }
    var selected: ResourceRow? { rows.first { $0.id == selection } }
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
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                HStack(spacing: 4) {
                    Button { adding = true } label: { toolbarIcon("添加", systemImage: "plus") }.frame(width: 28, height: 28).disabled(model.busy)
                    Button { editing = selected } label: { toolbarIcon("编辑", systemImage: "pencil") }.frame(width: 28, height: 28).disabled(model.busy || selected == nil)
                    DeleteButton(toolbar: true, message: "确定删除“\(selected?.name ?? "")”吗？此操作无法撤销。") {
                        if let selected { model.deleteResource(selected, groups: false) }
                    }.disabled(model.busy || selected == nil)
                }
                .buttonStyle(.bordered)
                .controlSize(.regular)
                .padding(.horizontal, 4)
                .padding(.vertical, 2)
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
