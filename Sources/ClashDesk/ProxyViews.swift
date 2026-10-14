import SwiftUI
import ClashCore

struct SubscriptionsView: View {
    @EnvironmentObject var model: DeskModel
    @State private var selection: String?
    @State private var adding = false
    @State private var editing: Subscription?
    var selected: Subscription? { model.settings.subscriptions.first { $0.id == selection } }
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("订阅管理").font(.title2.bold())
                Text("\(model.settings.subscriptions.count) 个订阅").foregroundStyle(.secondary)
                Spacer()
                Button { adding = true } label: { Label("添加", systemImage: "plus") }
                    .disabled(model.busy)
                Button { editing = selected } label: { Label("编辑", systemImage: "pencil") }
                    .disabled(model.busy || selected == nil)
                Button { if let selected { model.refreshSubscription(selected) } } label: { Label("更新", systemImage: "arrow.clockwise") }
                    .disabled(model.busy || selected == nil || model.settings.corePath.isEmpty)
                Button { if let selected { model.deleteSubscription(selected) } } label: { Label("删除", systemImage: "trash") }
                    .disabled(model.busy || selected == nil)
                Button { model.refreshSubscriptions() } label: { Label("全部更新", systemImage: "arrow.triangle.2.circlepath") }
                    .disabled(model.busy || model.settings.corePath.isEmpty || model.settings.subscriptions.isEmpty)
            }
            Table(model.settings.subscriptions, selection: $selection) {
                TableColumn("名称") { subscription in Text(subscription.name).textSelection(.enabled) }.width(min: 80, ideal: 110, max: 150)
                TableColumn("已用流量") { subscription in
                    Text(subscription.usage?.used.map(bytes) ?? "—").monospacedDigit()
                }.width(min: 100, ideal: 130)
                TableColumn("剩余 / 总流量") { subscription in
                    Text((subscription.usage?.remaining.map(bytes) ?? "—") + " / " + (subscription.usage?.total.map(bytes) ?? "—")).monospacedDigit()
                }.width(min: 170, ideal: 210)
                TableColumn("到期时间") { subscription in
                    Text(subscription.usage?.expiresAt.map {
                        $0.formatted(.dateTime.year().month(.twoDigits).day(.twoDigits).hour().minute())
                    } ?? "—").monospacedDigit()
                }.width(175)
                TableColumn("节点数") { subscription in
                    Text(String(model.nodes.filter { $0.provider == subscription.provider }.count))
                }.width(80)
                TableColumn("上次更新时间") { subscription in
                    Text(subscription.lastUpdatedAt.map {
                        $0.formatted(.dateTime.year().month(.twoDigits).day(.twoDigits).hour().minute().second())
                    } ?? "未记录").monospacedDigit()
                }.width(190)
            }

        }
        .sheet(isPresented: $adding) { SubscriptionEditorView() }
        .sheet(item: $editing) { SubscriptionEditorView(subscription: $0) }

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
        VStack(alignment: .leading, spacing: 20) {
            Text(original == nil ? "添加订阅" : "编辑订阅").font(.title2.bold())
            TextField("订阅名称", text: $name)
            TextField("HTTPS Clash YAML 订阅地址", text: $url)
            Text("成功拉取并解析节点后才保存订阅；失败时保留当前内容供修改重试。")
                .font(.caption).foregroundStyle(.secondary)
            if let error { Text(error).foregroundStyle(.red).textSelection(.enabled) }
            HStack {
                Button("取消") { dismiss() }.keyboardShortcut(.cancelAction).disabled(model.busy)
                Spacer()
                if model.busy { ProgressView().controlSize(.small) }
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
        }.textFieldStyle(.roundedBorder).padding(24).frame(width: 620)
            .interactiveDismissDisabled(model.busy)
    }
}

struct OutboundProxiesView: View {
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
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("出站代理").font(.title2.bold())
                Text("\(model.allNodes.count) 个代理").foregroundStyle(.secondary)
                Spacer()
                Button { adding = true } label: { Label("添加代理", systemImage: "plus") }.disabled(model.busy)
                Button("编辑") { editing = selectedManual }.disabled(model.busy || selectedManual == nil)
                Button("删除") { if let proxy = selectedManual { model.deleteManualProxy(proxy) } }.disabled(model.busy || selectedManual == nil)

            }
            Table(model.allNodes, selection: $selection) {
                TableColumn("名称") { node in Text(node.name).textSelection(.enabled) }
                TableColumn("类型") { node in Text(node.protocolName ?? "—") }.width(105)
                TableColumn("UDP") { node in
                    let supported = node.provider == "manual" ? model.manualUDP[node.name] : node.supportsUDP
                    Text(supported.map { $0 ? "支持" : "不支持" } ?? "未知")
                }.width(85)
                TableColumn("来源") { node in
                    Text(node.provider == "manual" ? "手动添加" : model.settings.subscriptions.first { $0.provider == node.provider }?.name ?? "—")
                }.width(100)
                TableColumn("延迟") { node in
                    NodeDelayCell(model: model, nodeID: node.id)
                }.width(110)
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
        Button {
            if let node { model.testDelay(node) }
        } label: {
            if model.testingNode == nodeID { Text("测试中…") }
            else if node?.delayFailed == true { Text("失败 / 超时").foregroundStyle(.red) }
            else { Text(node?.delayMilliseconds.map { "\($0) ms" } ?? "未测试") }
        }.buttonStyle(.borderless).disabled(model.busy || node == nil).help("点击测试延迟")
    }
}

struct ProxyEditorView: View {
    @EnvironmentObject var model: DeskModel
    @Environment(\.dismiss) private var dismiss
    let original: ManualProxy?
    @State private var type: String
    @State private var fields: [String: ConfigValue]
    @State private var search = ""
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
        VStack(alignment: .leading, spacing: 16) {
            Text(original == nil ? "添加出站代理" : "编辑出站代理").font(.title2.bold())
            HStack {
                Picker("代理类型", selection: $type) {
                    ForEach(documentSchemas.proxies) { Text($0.name).tag($0.key) }
                }.frame(width: 270)
                Spacer()
                TextField("搜索协议字段", text: $search).frame(width: 250)
            }
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 12) {
                    ForEach(schema.fields.filter { search.isEmpty || ($0.path + $0.description).localizedCaseInsensitiveContains(search) }) { field in
                        GroupBox { VisualField(field: field, value: Binding(get: { fields[field.path] }, set: { fields[field.path] = $0 })) }
                    }
                    DisclosureGroup("额外字段") {
                        ForEach(fields.keys.filter { !knownFields.contains($0) }.sorted(), id: \.self) { path in
                            VisualField(field: customSpec(path), value: Binding(get: { fields[path] }, set: { fields[path] = $0 }))
                        }
                        CustomFieldEditor(fields: $fields)
                    }
                }.padding(.trailing, 4)
            }
            HStack {
                Link("\(type) 配置文档", destination: URL(string: "https://wiki.metacubex.one/config/" + schema.document.replacingOccurrences(of: ".md", with: "/"))!)
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
        }.padding(24).frame(width: 760, height: 740)
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
