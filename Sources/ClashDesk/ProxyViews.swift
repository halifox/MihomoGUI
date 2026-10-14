import SwiftUI
import ClashCore

struct SubscriptionsView: View {
    @EnvironmentObject var model: DeskModel
    @State private var selection: String?
    @State private var name = ""
    @State private var url = ""
    var selected: Subscription? { model.settings.subscriptions.first { $0.id == selection } }
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("订阅管理").font(.title2.bold())
                Text("\(model.settings.subscriptions.count) 个订阅").foregroundStyle(.secondary)
                Spacer()
                Button { if let selected { model.deleteSubscription(selected) } } label: {
                    Label("删除订阅", systemImage: "minus")
                }.disabled(model.busy || selected == nil)
                Button("更新全部订阅") { model.refreshSubscriptions() }
                    .disabled(model.busy || model.settings.corePath.isEmpty || model.settings.subscriptions.isEmpty)
            }
            Table(model.settings.subscriptions, selection: $selection) {
                TableColumn("名称") { subscription in Text(subscription.name).textSelection(.enabled) }.width(min: 130, ideal: 180)
                TableColumn("订阅链接") { subscription in Text(subscription.url).lineLimit(1).textSelection(.enabled) }
                TableColumn("节点数") { subscription in
                    Text(String(model.nodes.filter { $0.provider == subscription.provider }.count))
                }.width(80)
                TableColumn("操作") { subscription in
                    Button("删除") { model.deleteSubscription(subscription) }.disabled(model.busy)
                }.width(80)
            }
            GroupBox("添加订阅") {
                HStack {
                    TextField("订阅名称", text: $name).frame(width: 180)
                    TextField("HTTPS Clash YAML 订阅地址", text: $url)
                    Button { model.addSubscription(name: name, url: url) } label: {
                        Label("添加并拉取", systemImage: "plus")
                    }.disabled(model.busy || model.settings.corePath.isEmpty || name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || url.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }.textFieldStyle(.roundedBorder).padding(8)
            }
            Text(model.settings.corePath.isEmpty ? "请先在设置中选择 mihomo 二进制文件，再拉取订阅。" : "订阅节点保存在本地，并在出站代理页面显示。被规则引用的订阅需先调整出口才能删除。")
                .font(.caption).foregroundStyle(.secondary)
        }
    }
}

struct OutboundProxiesView: View {
    @EnvironmentObject var model: DeskModel
    @State private var adding = false
    @State private var editing: ManualProxy?
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("出站代理").font(.title2.bold())
                Text("\(model.allNodes.count) 个代理").foregroundStyle(.secondary)
                Spacer()
                Button { adding = true } label: { Label("添加代理", systemImage: "plus") }.disabled(model.busy)
            }
            Table(model.allNodes) {
                TableColumn("名称") { node in Text(node.name).textSelection(.enabled) }
                TableColumn("类型") { node in Text(node.protocolName ?? "—") }.width(105)
                TableColumn("服务器") { node in
                    Text(model.manualProxy(for: node)?.fields["server"]?.text ?? "由订阅管理").textSelection(.enabled)
                }
                TableColumn("端口") { node in Text(model.manualProxy(for: node)?.fields["port"]?.text ?? "—") }.width(65)
                TableColumn("来源") { node in
                    Text(node.provider == "manual" ? "手动添加" : model.settings.subscriptions.first { $0.provider == node.provider }?.name ?? "—")
                }.width(100)
                TableColumn("管理") { node in
                    if let proxy = model.manualProxy(for: node) {
                        HStack {
                            Button("编辑") { editing = proxy }
                            Button("删除") { model.deleteManualProxy(proxy) }
                        }.disabled(model.busy)
                    } else { Text("订阅节点").foregroundStyle(.secondary) }
                }.width(110)
                TableColumn("延迟") { node in
                    if model.testingNode == node.id { Text("测试中…") }
                    else if node.delayFailed == true { Text("失败 / 超时").foregroundStyle(.red) }
                    else { Text(node.delayMilliseconds.map { "\($0) ms" } ?? "未测试") }
                }.width(90)
                TableColumn("测试延迟") { node in Button("测试") { model.testDelay(node) }.disabled(model.busy) }.width(85)
            }
            Text("手动代理按协议生成表单；订阅节点由订阅更新。首次添加代理后，MATCH 指向第一个代理。")
                .font(.caption).foregroundStyle(.secondary)
        }
        .sheet(isPresented: $adding) { ProxyEditorView() }
        .sheet(item: $editing) { ProxyEditorView(proxy: $0) }
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
