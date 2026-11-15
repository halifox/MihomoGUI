import SwiftUI
import AppKit
import ClashCore

struct SubscriptionsView: View {
    @State private var sortOrder: [TableSort<Subscription>] = []
    @EnvironmentObject var model: DeskModel
    @State private var selection: String?
    @State private var adding = false
    @State private var editing: Subscription?
    @State private var deleting: Subscription?
    func columnSort(_ column: String) -> TableSort<Subscription> {
        let counts = Dictionary(model.nodes.map { ($0.provider, 1) }, uniquingKeysWith: +)
        switch column {
        case "上传流量": return TableSort(column) { $0.usage?.upload ?? -1 }
        case "下载流量": return TableSort(column) { $0.usage?.download ?? -1 }
        case "剩余流量": return TableSort(column) { $0.usage?.remaining ?? -1 }
        case "总流量": return TableSort(column) { $0.usage?.total ?? -1 }
        case "到期时间": return TableSort(column) { $0.usage?.expiresAt ?? .distantPast }
        case "节点数": return TableSort(column) { counts[$0.provider] ?? 0 }
        case "上次更新时间": return TableSort(column) { $0.lastUpdatedAt ?? .distantPast }
        default: return TableSort(column) { $0.name }
        }
    }
    var body: some View {
        let currentSort = sortOrder.map { descriptor in
            var comparator = columnSort(descriptor.column)
            comparator.order = descriptor.order
            return comparator
        }
        Table(model.settings.subscriptions.sorted(using: currentSort), selection: $selection, sortOrder: tableSortBinding($sortOrder)) {
            TableColumn("名称", sortUsing: columnSort("名称")) { subscription in
                Text(columnText(subscription, "名称")).textSelection(.enabled).lineLimit(1).help(subscription.name)
            }.width(min: 40, ideal: contentWidth("名称"), max: nil)
            TableColumn("上传流量", sortUsing: columnSort("上传流量")) { subscription in
                TableUnitValue(text: columnText(subscription, "上传流量"))
            }.width(min: 40, ideal: contentWidth("上传流量"), max: nil)
            TableColumn("下载流量", sortUsing: columnSort("下载流量")) { subscription in
                TableUnitValue(text: columnText(subscription, "下载流量"))
            }.width(min: 40, ideal: contentWidth("下载流量"), max: nil)
            TableColumn("剩余流量", sortUsing: columnSort("剩余流量")) { subscription in
                TableUnitValue(text: columnText(subscription, "剩余流量"))
            }.width(min: 40, ideal: contentWidth("剩余流量"), max: nil)
            TableColumn("总流量", sortUsing: columnSort("总流量")) { subscription in
                TableUnitValue(text: columnText(subscription, "总流量"))
            }.width(min: 40, ideal: contentWidth("总流量"), max: nil)
            TableColumn("到期时间", sortUsing: columnSort("到期时间")) { subscription in
                Text(columnText(subscription, "到期时间")).monospacedDigit()
            }.width(min: 40, ideal: contentWidth("到期时间"), max: nil)
            TableColumn("节点数", sortUsing: columnSort("节点数")) { subscription in
                Text(columnText(subscription, "节点数")).monospacedDigit().frame(maxWidth: .infinity, alignment: .trailing)
            }.width(min: 40, ideal: contentWidth("节点数"), max: nil)
            TableColumn("上次更新时间", sortUsing: columnSort("上次更新时间")) { subscription in
                Text(columnText(subscription, "上次更新时间")).monospacedDigit()
            }.width(min: 40, ideal: contentWidth("上次更新时间"), max: nil)
        }
        .background(TableColumnAutoFit(widths: [
            contentWidth("名称"),
            contentWidth("上传流量"),
            contentWidth("下载流量"),
            contentWidth("剩余流量"),
            contentWidth("总流量"),
            contentWidth("到期时间"),
            contentWidth("节点数"),
            contentWidth("上次更新时间")
        ]))
        .contextMenu(forSelectionType: String.self) { ids in
            if let id = ids.first, let item = model.settings.subscriptions.first(where: { $0.id == id }) {
                Button("编辑") { editing = item }.disabled(model.busy)
                Button("删除", role: .destructive) { deleting = item }.disabled(model.busy)
                Button("更新") { model.refreshSubscription(item) }
                    .disabled(model.busy || model.settings.corePath.isEmpty)
            }
            Button("全部更新") { model.refreshSubscriptions() }
                .disabled(model.busy || model.settings.corePath.isEmpty || model.settings.subscriptions.isEmpty)
        }
        .alert("确认删除", isPresented: Binding(get: { deleting != nil }, set: { if !$0 { deleting = nil } })) {
            Button("取消", role: .cancel) { deleting = nil }
            Button("确认删除", role: .destructive) {
                if let item = deleting { model.deleteSubscription(item) }
                deleting = nil
            }.disabled(model.busy)
        } message: {
            Text("确定删除订阅“\(deleting?.name ?? "")”及其节点吗？此操作无法撤销。")
        }
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button { adding = true } label: { Label("新建代理订阅", systemImage: "plus") }
                    .disabled(model.busy)
                    .labelStyle(.iconOnly)
                    .help("新建代理订阅")
            }
        }
        .sheet(isPresented: $adding) { SubscriptionEditorView() }
        .sheet(item: $editing) { SubscriptionEditorView(subscription: $0) }

    }
    func columnText(_ subscription: Subscription, _ column: String) -> String {
        switch column {
        case "名称": return subscription.name
        case "上传流量": return subscription.usage?.upload.map(bytes) ?? "—"
        case "下载流量": return subscription.usage?.download.map(bytes) ?? "—"
        case "剩余流量": return subscription.usage?.remaining.map(bytes) ?? "—"
        case "总流量": return subscription.usage?.total.map(bytes) ?? "—"
        case "到期时间": return subscription.usage?.expiresAt.map {
            $0.formatted(.dateTime.year().month(.twoDigits).day(.twoDigits).hour().minute())
        } ?? "—"
        case "节点数": return String(model.nodes.filter { $0.provider == subscription.provider }.count)
        default: return subscription.lastUpdatedAt.map {
            $0.formatted(.dateTime.year().month(.twoDigits).day(.twoDigits).hour().minute().second())
        } ?? "未记录"
        }
    }
    func contentWidth(_ column: String) -> CGFloat {
        tableColumnWidth(column, (model.settings.subscriptions).map { columnText($0, column) },
                         numeric: column != "名称",
                         unitSample: ["上传流量", "下载流量", "剩余流量", "总流量"].contains(column) ? "MB" : nil)
    }

}

struct SubscriptionEditorView: View {
    @EnvironmentObject var model: DeskModel
    @Environment(\.dismiss) private var dismiss
    let original: Subscription?
    @State private var name: String
    @State private var url: String
    @State private var error: String?
    init(subscription: Subscription? = nil) {
        original = subscription
        _name = State(initialValue: subscription?.name ?? "")
        _url = State(initialValue: subscription?.url ?? "")
    }
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(original == nil ? "添加订阅" : "编辑订阅").font(.title2.bold())
            formRow("name *", labelWidth: 100) { TextField("订阅名称", text: $name) }
            formRow("url *", labelWidth: 100) { TextField("HTTPS Clash YAML 订阅地址", text: $url) }
            if let error { Text(error).foregroundStyle(.red).textSelection(.enabled) }
            HStack {
                Spacer()
                if model.busy { ProgressView().controlSize(.small) }
                Button("取消") { dismiss() }.keyboardShortcut(.cancelAction).disabled(model.busy)
                Button(model.busy ? "正在拉取…" : "拉取并保存") {
                    var subscription = Subscription(name: name, url: url)
                    if let original { subscription.id = original.id }
                    model.busy = true; error = nil
                    Task {
                        defer { model.busy = false }
                        do { try await model.saveSubscription(subscription); dismiss() }
                        catch { self.error = error.localizedDescription }
                    }
                }.buttonStyle(.borderedProminent)
                    .disabled(model.busy || model.settings.corePath.isEmpty || name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || url.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
            if model.settings.corePath.isEmpty { Text("应用内置 mihomo 内核不可用，请重新安装应用。").foregroundStyle(.orange) }
        }.textFieldStyle(.roundedBorder).padding(16).controlSize(.regular).frame(width: 620)
            .environment(\.formHelpDocument, "subscription")
            .interactiveDismissDisabled(model.busy)
    }
}

extension DeskModel {
    func deleteSubscription(_ subscription: Subscription) {
        guard !busy else { return }
        if (settings.proxyGroups ?? []).contains(where: { $0.targets.contains(where: { referencedNode($0)?.provider == subscription.provider }) }) {
            error = "该订阅仍被代理组引用，请先调整组内出口。"; return
        }
        if settings.options?["rule-providers"]?.object.values.contains(where: { referencedNode($0.object["proxy"]?.text ?? "")?.provider == subscription.provider }) == true {
            error = "该订阅节点仍用于规则集下载，请先修改下载出口。"; return
        }
        do {
            var candidate = settings
            candidate.subscriptions.removeAll { $0.id == subscription.id }
            candidate.subscriptionProxies?.removeValue(forKey: subscription.id)
            let remaining = nodes.filter { $0.provider != subscription.provider }
            rejectUnavailableRouteNodes(&candidate, nodes: remaining)
            _ = try generateConfig(candidate)
            try commitFiles([
                ("settings.json", try JSONEncoder().encode(candidate)),
                ("nodes.json", try JSONEncoder().encode(remaining))
            ], directory: directory)
            settings = candidate; nodes = remaining
        } catch { self.error = error.localizedDescription }
    }
}
