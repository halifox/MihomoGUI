import SwiftUI
import AppKit
import ClashCore

struct SubscriptionsView: View {
    @State private var sortOrder: [TableSort<Subscription>] = []
    @EnvironmentObject var model: DeskModel
    @State private var selection: String?
    @State private var adding = false
    @State private var editing: Subscription?
    var selected: Subscription? { model.settings.subscriptions.first { $0.id == selection } }
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
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("代理订阅").font(.title2.bold())
                Spacer()
                Button { adding = true } label: { Label("添加", systemImage: "plus") }
                    .disabled(model.busy)
                Button { editing = selected } label: { Label("编辑", systemImage: "pencil") }
                    .disabled(model.busy || selected == nil)
                DeleteButton(message: "确定删除订阅“\(selected?.name ?? "")”及其节点吗？此操作无法撤销。") { if let selected { model.deleteSubscription(selected) } }
                    .disabled(model.busy || selected == nil)
                Button { if let selected { model.refreshSubscription(selected) } } label: { Label("更新", systemImage: "arrow.clockwise") }
                    .disabled(model.busy || selected == nil || model.settings.corePath.isEmpty)
                Button { model.refreshSubscriptions() } label: { Label("全部更新", systemImage: "arrow.triangle.2.circlepath") }
                    .disabled(model.busy || model.settings.corePath.isEmpty || model.settings.subscriptions.isEmpty)
            }.pageActions()
            Table(model.settings.subscriptions.sorted(using: currentSort), selection: $selection, sortOrder: $sortOrder) {
                TableColumn("名称", sortUsing: columnSort("名称")) { subscription in
                    Text(columnText(subscription, "名称")).textSelection(.enabled).lineLimit(1).help(subscription.name)
                }.width(min: 40, ideal: contentWidth("名称"), max: nil)
                TableColumn("上传流量", sortUsing: columnSort("上传流量")) { subscription in
                    Text(columnText(subscription, "上传流量")).monospacedDigit()
                }.width(min: 40, ideal: contentWidth("上传流量"), max: nil)
                TableColumn("下载流量", sortUsing: columnSort("下载流量")) { subscription in
                    Text(columnText(subscription, "下载流量")).monospacedDigit()
                }.width(min: 40, ideal: contentWidth("下载流量"), max: nil)
                TableColumn("剩余流量", sortUsing: columnSort("剩余流量")) { subscription in
                    Text(columnText(subscription, "剩余流量")).monospacedDigit()
                }.width(min: 40, ideal: contentWidth("剩余流量"), max: nil)
                TableColumn("总流量", sortUsing: columnSort("总流量")) { subscription in
                    Text(columnText(subscription, "总流量")).monospacedDigit()
                }.width(min: 40, ideal: contentWidth("总流量"), max: nil)
                TableColumn("到期时间", sortUsing: columnSort("到期时间")) { subscription in
                    Text(columnText(subscription, "到期时间")).monospacedDigit()
                }.width(min: 40, ideal: contentWidth("到期时间"), max: nil)
                TableColumn("节点数", sortUsing: columnSort("节点数")) { subscription in
                    Text(columnText(subscription, "节点数")).monospacedDigit()
                }.width(min: 40, ideal: contentWidth("节点数"), max: nil)
                TableColumn("上次更新时间", sortUsing: columnSort("上次更新时间")) { subscription in
                    Text(columnText(subscription, "上次更新时间")).monospacedDigit()
                }.width(min: 40, ideal: contentWidth("上次更新时间"), max: nil)
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
                         numeric: column != "名称")
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
            formRow("name *") { TextField("订阅名称", text: $name) }
            formRow("url *") { TextField("HTTPS Clash YAML 订阅地址", text: $url) }
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
            if model.settings.corePath.isEmpty { Text("请先在设置中选择 mihomo 二进制文件。").foregroundStyle(.orange) }
        }.textFieldStyle(.roundedBorder).padding(16).controlSize(.regular).frame(width: 620)
            .environment(\.formHelpDocument, "subscription")
            .interactiveDismissDisabled(model.busy)
    }
}

struct OutboundProxiesView: View {
    @State private var sortOrder: [TableSort<Node>] = []
    @EnvironmentObject var model: DeskModel
    @State private var adding = false
    @State private var editing: ManualProxy?
    @State private var selection: String?
    var udpKey: Data {
        let encoder = JSONEncoder(); encoder.outputFormatting = [.sortedKeys]
        var data = Data(model.settings.corePath.utf8)
        data.append((try? encoder.encode(model.settings.subscriptions)) ?? Data())
        for proxy in model.settings.manualProxies ?? [] {
            data.append(Data(proxy.type.utf8))
            data.append((try? encoder.encode(proxy.fields)) ?? Data())
        }
        return data
    }
    var selectedManual: ManualProxy? {
        guard let node = model.allNodes.first(where: { $0.id == selection }) else { return nil }
        return model.manualProxy(for: node)
    }
    func columnSort(_ column: String) -> TableSort<Node> {
        switch column {
        case "名称": return TableSort(column) { $0.name }
        case "类型": return TableSort(column) { $0.protocolName ?? "—" }
        case "UDP": return TableSort(column) { row in (row.provider == "manual" ? model.manualUDP[row.name] : row.supportsUDP).map { $0 ? 1 : 0 } ?? -1 }
        case "来源": return TableSort(column) { row in row.provider == "manual" ? "手动添加" : model.settings.subscriptions.first { $0.provider == row.provider }?.name ?? "—" }
        default: return TableSort(column) { $0.delayMilliseconds ?? -1 }
        }
    }
    var body: some View {
        let rows = model.allNodes
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("出站代理").font(.title2.bold())
                Spacer()
                Button { adding = true } label: { Label("添加", systemImage: "plus") }.disabled(model.busy)
                Button { editing = selectedManual } label: { Label("编辑", systemImage: "pencil") }.disabled(model.busy || selectedManual == nil)
                DeleteButton(message: "确定删除所选代理吗？此操作无法撤销。") { if let proxy = selectedManual { model.deleteManualProxy(proxy) } }.disabled(model.busy || selectedManual == nil)
                Button {
                    if let node = model.allNodes.first(where: { $0.id == selection }) { model.testDelay(node) }
                } label: { Label("延迟", systemImage: "speedometer") }
                    .disabled(model.busy || !model.allNodes.contains(where: { $0.id == selection }) || model.settings.corePath.isEmpty)
                Button {
                    if model.isTestingDelays { model.cancelDelayTests() }
                    else { model.testAllDelays() }
                } label: {
                    Label(model.isTestingDelays ? "取消测延迟" : "全部延迟",
                          systemImage: model.isTestingDelays ? "stop.circle" : "gauge.with.dots.needle.50percent")
                }.disabled(!model.isTestingDelays && (model.busy || model.allNodes.isEmpty || model.settings.corePath.isEmpty))
            }.pageActions()
            Table(rows.sorted(using: sortOrder), selection: $selection, sortOrder: $sortOrder) {
                TableColumn("名称", sortUsing: columnSort("名称")) { node in Text(node.name).textSelection(.enabled) }.width(min: 40, ideal: tableColumnWidth("名称", rows.map(\.name)), max: nil)
                TableColumn("类型", sortUsing: columnSort("类型")) { node in Text(node.protocolName ?? "—") }.width(min: 40, ideal: tableColumnWidth("类型", rows.map { $0.protocolName ?? "—" }), max: nil)
                TableColumn("UDP", sortUsing: columnSort("UDP")) { node in
                    let supported = node.provider == "manual" ? model.manualUDP[node.name] : node.supportsUDP
                    Text(supported.map { $0 ? "支持" : "不支持" } ?? "未知")
                }.width(min: 40, ideal: tableColumnWidth("UDP", rows.map { node in
                    (node.provider == "manual" ? model.manualUDP[node.name] : node.supportsUDP).map { $0 ? "支持" : "不支持" } ?? "未知"
                }), max: nil)
                TableColumn("来源", sortUsing: columnSort("来源")) { node in
                    Text(node.provider == "manual" ? "手动添加" : model.settings.subscriptions.first { $0.provider == node.provider }?.name ?? "—")
                }.width(min: 40, ideal: tableColumnWidth("来源", rows.map { node in
                    node.provider == "manual" ? "手动添加" : model.settings.subscriptions.first { $0.provider == node.provider }?.name ?? "—"
                }), max: nil)
                TableColumn("延迟", sortUsing: columnSort("延迟")) { node in
                    NodeDelayCell(model: model, nodeID: node.id)
                }.width(min: 40, ideal: tableColumnWidth("延迟", rows.map { $0.delayMilliseconds.map { "\($0) ms" } ?? "" } + ["测试中…", "失败 / 超时"]), max: nil)
            }

        }
        .task(id: udpKey) { await model.refreshManualUDP() }
        .sheet(isPresented: $adding) { ProxyEditorView() }
        .sheet(item: $editing) { ProxyEditorView(proxy: $0) }
    }
}

struct NodeDelayCell: View {
    @ObservedObject var model: DeskModel
    let nodeID: String
    var node: Node? { model.allNodes.first { $0.id == nodeID } }
    var body: some View {
        Group {
            if model.testingNodes.contains(nodeID) { Text("测试中…") }
            else if node?.delayFailed == true { Text("失败 / 超时").foregroundStyle(.red) }
            else { Text(node?.delayMilliseconds.map { "\($0) ms" } ?? "") }
        }
    }
}

struct ProxyEditorView: View {
    @EnvironmentObject var model: DeskModel
    @Environment(\.dismiss) private var dismiss
    let original: ManualProxy?
    @State private var type: String
    @State private var fields: [String: ConfigValue]
    @State private var error: String?
    init(proxy: ManualProxy? = nil) {
        original = proxy
        let type = proxy?.type ?? "hysteria2"
        _type = State(initialValue: type)
        var fields = proxy?.fields ?? [:]
        for field in documentSchemas.proxies.first(where: { $0.key == type })?.fields ?? [] where field.required && fields[field.path] == nil {
            fields[field.path] = emptyValue(field)
        }
        _fields = State(initialValue: fields)
    }
    var schema: EditorSchema { documentSchemas.proxies.first { $0.key == type }! }
    var knownFields: Set<String> { Set(schema.fields.map(\.path)) }
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(original == nil ? "添加代理" : "编辑代理").font(.title2.bold())
            formRow("type *") {
                Picker("代理类型", selection: $type) {
                    ForEach(documentSchemas.proxies) { Text(optionLabel($0.key)).tag($0.key) }
                }.labelsHidden()
            }
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 2) {
                    ForEach(schema.fields) { field in
                        VisualField(field: field, value: Binding(get: { fields[field.path] }, set: { fields[field.path] = $0 }), compact: true)
                    }
                    DisclosureGroup("额外字段") {
                        ForEach(fields.keys.filter { !knownFields.contains($0) }.sorted(), id: \.self) { path in
                            VisualField(field: customSpec(path), value: Binding(get: { fields[path] }, set: { fields[path] = $0 }), compact: true)
                        }
                        CustomFieldEditor(fields: $fields)
                    }
                }.padding(.trailing, 4)
            }
            HStack {
                Spacer()
                Button("取消") { dismiss() }.keyboardShortcut(.cancelAction)
                Button("保存代理") {
                    do {
                        var proxy = ManualProxy(type: type, fields: fields)
                        if let original { proxy.id = original.id; proxy.delayMilliseconds = original.delayMilliseconds; proxy.delayFailed = original.delayFailed }
                        try model.saveManualProxy(proxy)
                        dismiss()
                    } catch { self.error = error.localizedDescription }
                }.buttonStyle(.borderedProminent)
            }
        }.padding(16).controlSize(.regular).frame(width: 720, height: 560)
        .environment(\.formHelpDocument, schema.document)
        .onChange(of: type) { _ in
            let common = fields.filter { ["name", "server", "port"].contains($0.key) }
            fields = common
            for field in schema.fields where field.required && fields[field.path] == nil { fields[field.path] = emptyValue(field) }
        }
        .alert("代理参数无效", isPresented: Binding(get: { error != nil }, set: { if !$0 { error = nil } })) {
            Button("确定") { error = nil }
        } message: { Text(error ?? "") }
    }
    func customSpec(_ path: String) -> EditorField {
        let kind: String
        switch fields[path] {
        case .boolean: kind = "boolean"
        case .integer: kind = "integer"
        case .number: kind = "number"
        case .array: kind = "list"
        case .object: kind = "map"
        default: kind = "string"
        }
        return EditorField(path, kind: kind, elementKind: "string")
    }
}
