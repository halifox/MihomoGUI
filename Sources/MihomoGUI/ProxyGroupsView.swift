import SwiftUI
import AppKit
import MihomoGUICore

struct ProxyGroupsView: View {
    @State private var activeSelections: [String: String] = [:]
    @State private var selectionsError: String?
    @State private var sortOrder: [TableSort<ResourceRow>] = []
    @EnvironmentObject var model: MihomoGUIModel
    @State private var selection: String?
    @State private var adding = false
    @State private var editing: ResourceRow?
    @State private var deleting: ResourceRow?
    private var endpoint: String {
        guard let api = try? model.api else { return "" }
        return "\(api.host):\(api.port)/\(api.secret)/\(model.coreActive)"
    }
    var rows: [ResourceRow] {
        (model.settings.proxyGroups ?? []).map { ResourceRow(id: $0.id, name: $0.name, type: $0.type, fields: $0.fields, group: $0) }
    }
    func columnSort(_ column: String) -> TableSort<ResourceRow> {
        switch column {
        case "名称": return TableSort(column) { $0.name }
        case "类型": return TableSort(column) { optionLabel($0.type) }
        default: return TableSort(column, value: selectedMemberText)
        }
    }
    var body: some View {
        let rows = rows
        Table(rows.sorted(using: sortOrder), selection: $selection, sortOrder: tableSortBinding($sortOrder)) {
            TableColumn("名称", sortUsing: columnSort("名称")) { row in Text(row.name).textSelection(.enabled) }.width(min: 40, ideal: tableColumnWidth("名称", rows.map(\.name)), max: nil)
            TableColumn("类型", sortUsing: columnSort("类型")) { row in Text(optionLabel(row.type)) }.width(min: 40, ideal: tableColumnWidth("类型", rows.map { optionLabel($0.type) }), max: nil)
            TableColumn("选择节点", sortUsing: columnSort("选择节点")) { row in
                memberPicker(row)
            }.width(min: 40, ideal: tableColumnWidth("选择节点", rows.map(selectedMemberText), padding: 48), max: nil)
        }
        .background(TableColumnAutoFit(widths: [
            tableColumnWidth("名称", rows.map(\.name)),
            tableColumnWidth("类型", rows.map { optionLabel($0.type) }),
            tableColumnWidth("选择节点", rows.map(selectedMemberText), padding: 48)
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
                if let item = deleting { model.deleteResource(item, groups: true) }
                deleting = nil
            }.disabled(model.busy)
        } message: {
            Text("确定删除“\(deleting?.name ?? "")”吗？此操作无法撤销。")
        }
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button { adding = true } label: { Label("新建代理组", systemImage: "plus") }
                    .disabled(model.busy)
                    .labelStyle(.iconOnly)
                    .help("新建代理组")
            }
        }
        .safeAreaInset(edge: .top, spacing: 0) {
            if let selectionsError {
                Text(selectionsError).font(.caption).foregroundStyle(.orange)
                    .padding(8).frame(maxWidth: .infinity, alignment: .leading).background(.bar)
            }
        }
        .task(id: endpoint) {
            let source = endpoint
            activeSelections = [:]; selectionsError = nil
            guard model.coreActive else { return }
            while !Task.isCancelled {
                do {
                    let selections = try await model.api.proxyGroupSelections()
                    guard !Task.isCancelled, source == endpoint else { return }
                    activeSelections = selections; selectionsError = nil
                } catch {
                    guard !Task.isCancelled, source == endpoint else { return }
                    activeSelections = [:]
                    selectionsError = "代理组实际选择读取失败，将自动重试：" + error.localizedDescription
                }
                do { try await Task.sleep(nanoseconds: 3_000_000_000) }
                catch { return }
            }
        }
        .sheet(isPresented: $adding) { ResourceEditorView(groups: true) }
        .sheet(item: $editing) { ResourceEditorView(groups: true, original: $0) }
    }
    @ViewBuilder func memberPicker(_ row: ResourceRow) -> some View {
        if let group = row.group, group.type == "select" {
            let targets = proxyGroupTargets(group, settings: model.settings)
            Picker("选择节点", selection: Binding(get: {
                selectedTarget(group) ?? ""
            }, set: { target in
                do { try model.selectProxyGroup(group, target: target) }
                catch { model.error = error.localizedDescription }
            })) {
                if selectedTarget(group) == nil { Text(model.coreActive ? "运行选择尚未确认" : "空（Empty）").tag("") }
                ForEach(targets, id: \.self) { target in
                    Text(memberLabel(target)).tag(target)
                }
            }
            .labelsHidden()
            .disabled(model.busy || targets.isEmpty)
        } else {
            Text(selectedMemberText(row))
        }
    }
    func selectedMemberText(_ row: ResourceRow) -> String {
        guard let group = row.group, group.type == "select" else { return "—" }
        guard let target = selectedTarget(group) else { return model.coreActive ? "运行选择尚未确认" : "空（Empty）" }
        return memberLabel(target)
    }
    private func selectedTarget(_ group: ProxyGroup) -> String? {
        let targets = proxyGroupTargets(group, settings: model.settings)
        if model.coreActive {
            guard let actual = activeSelections[group.name] else { return nil }
            return targets.first { (try? proxyTargetName($0, settings: model.runtimeSettings)) == actual }
        }
        let selected = group.fields["default-selected"]?.text ?? ""
        return selected.isEmpty ? targets.first : selected
    }
    func memberLabel(_ target: String) -> String {
        if let node = model.allNodes.first(where: { "node:" + $0.id == target }) {
            return model.nodeLabelWithDelay(node)
        }
        if target.hasPrefix("group:") { return "代理组 / " + target.dropFirst(6) }
        if target.hasPrefix("builtin:") { return optionLabel(String(target.dropFirst(8))) }
        return "已失效：" + target
    }
}
