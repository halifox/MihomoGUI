import SwiftUI
import AppKit
import ClashCore

struct OutboundProxiesView: View {
    @State private var sortOrder: [TableSort<Node>] = []
    @EnvironmentObject var model: DeskModel
    @State private var adding = false
    @State private var editing: ManualProxy?
    @State private var deleting: ManualProxy?
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
    func columnSort(_ column: String) -> TableSort<Node> {
        switch column {
        case "名称": return TableSort(column) { $0.name }
        case "类型": return TableSort(column) { $0.protocolName ?? "—" }
        case "UDP": return TableSort(column) { row in (row.provider == "manual" ? model.manualUDP[row.name] : row.supportsUDP).map { $0 ? 1 : 0 } ?? -1 }
        case "来源": return TableSort(column) { row in row.provider == "manual" ? "手动添加" : model.settings.subscriptions.first { $0.provider == row.provider }?.name ?? "—" }
        default: return TableSort(column, optionalValue: { $0.delayFailed == true ? nil : $0.delayMilliseconds })
        }
    }
    var body: some View {
        let rows = model.allNodes
        Table(rows.sorted(using: sortOrder), selection: $selection, sortOrder: tableSortBinding($sortOrder)) {
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
            }.width(min: 40, ideal: tableColumnWidth("延迟", rows.map { $0.delayMilliseconds.map { "\($0) ms" } ?? "" } + ["测试中…", "超时"], numeric: true, unitSample: "ms"), max: nil)
        }
        .background(TableColumnAutoFit(widths: [
            tableColumnWidth("名称", rows.map(\.name)),
            tableColumnWidth("类型", rows.map { $0.protocolName ?? "—" }),
            tableColumnWidth("UDP", rows.map { node in
                (node.provider == "manual" ? model.manualUDP[node.name] : node.supportsUDP).map { $0 ? "支持" : "不支持" } ?? "未知"
            }),
            tableColumnWidth("来源", rows.map { node in
                node.provider == "manual" ? "手动添加" : model.settings.subscriptions.first { $0.provider == node.provider }?.name ?? "—"
            }),
            tableColumnWidth("延迟", rows.map { $0.delayMilliseconds.map { "\($0) ms" } ?? "" } + ["测试中…", "超时"], numeric: true, unitSample: "ms")
        ]))
        .contextMenu(forSelectionType: String.self) { ids in
            if let id = ids.first, let node = rows.first(where: { $0.id == id }) {
                if let item = model.manualProxy(for: node) {
                    Button("编辑") { editing = item }.disabled(model.busy)
                    Button("删除", role: .destructive) { deleting = item }.disabled(model.busy)
                }
                Button("测延迟") { model.testDelay(node) }
                    .disabled(model.busy || model.settings.corePath.isEmpty)
            }
        }
        .alert("确认删除", isPresented: Binding(get: { deleting != nil }, set: { if !$0 { deleting = nil } })) {
            Button("取消", role: .cancel) { deleting = nil }
            Button("确认删除", role: .destructive) {
                if let item = deleting { model.deleteManualProxy(item) }
                deleting = nil
            }.disabled(model.busy)
        } message: {
            Text("确定删除所选代理吗？此操作无法撤销。")
        }
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    if model.isTestingDelays { model.cancelDelayTests() }
                    else { model.testAllDelays() }
                } label: {
                    Label(model.isTestingDelays ? "取消测延迟" : "全部测延迟",
                          systemImage: model.isTestingDelays ? "stop.circle" : "speedometer")
                }
                .disabled(!model.isTestingDelays && (model.busy || rows.isEmpty || model.settings.corePath.isEmpty))
                .labelStyle(.iconOnly)
                .help(model.isTestingDelays ? "取消测延迟" : "全部测延迟")
            }
            ToolbarItem(placement: .primaryAction) {
                Button { adding = true } label: { Label("新建出站代理", systemImage: "plus") }
                    .disabled(model.busy)
                    .labelStyle(.iconOnly)
                    .help("新建出站代理")
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
            if model.testingNodes.contains(nodeID) { Text("测试中…").frame(maxWidth: .infinity, alignment: .trailing) }
            else if node?.delayFailed == true {
                Text("超时")
                    .foregroundStyle(.red)
                    .frame(maxWidth: .infinity, alignment: .trailing)
            }
            else { TableUnitValue(text: node?.delayMilliseconds.map { "\($0) ms" } ?? "", unitSample: "ms") }
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
    @State private var addingField = false
    @State private var invalidMap = false
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
            formRow("type *", labelWidth: editorLabelWidth) {
                Picker("代理类型", selection: $type) {
                    ForEach(documentSchemas.proxies) { Text(optionLabel($0.key)).tag($0.key) }
                }.labelsHidden()
            }
            ScrollView {
                VStack(alignment: .leading, spacing: 2) {
                    ForEach(schema.fields) { field in
                        VisualField(field: field, value: Binding(get: { fields[field.path] }, set: { fields[field.path] = $0 }), compact: true, labelWidth: editorLabelWidth)
                    }
                    if fields.keys.contains(where: { !knownFields.contains($0) }) {
                        Text("额外字段").font(.headline).padding(.top, 8)
                        ForEach(fields.keys.filter { !knownFields.contains($0) }.sorted(), id: \.self) { path in
                            HStack(alignment: .top) {
                                VisualField(field: customSpec(path), value: Binding(get: { fields[path] }, set: { fields[path] = $0 }), compact: true, labelWidth: editorLabelWidth)
                                Button(role: .destructive) { fields.removeValue(forKey: path) } label: {
                                    Image(systemName: "trash")
                                }
                                .help("删除字段 \(path)")
                                .accessibilityLabel("删除字段 \(path)")
                                .padding(.top, 3)
                            }
                        }
                    }
                }.padding(.trailing, 4)
            }
            HStack {
                Button { addingField = true } label: {
                    Label("添加额外字段", systemImage: "plus")
                }
                .popover(isPresented: $addingField, arrowEdge: .top) {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("添加额外字段").font(.headline)
                        CustomFieldEditor(fields: $fields, reservedPaths: knownFields) { addingField = false }
                        Button("取消") { addingField = false }
                            .frame(maxWidth: .infinity, alignment: .trailing)
                    }.padding(16).frame(width: editorSheetWidth)
                }
                Spacer()
                Button("取消") { dismiss() }.keyboardShortcut(.cancelAction)
                Button("保存代理") {
                    do {
                        var proxy = ManualProxy(type: type, fields: fields)
                        if let original { proxy.id = original.id; proxy.delayMilliseconds = original.delayMilliseconds; proxy.delayFailed = original.delayFailed }
                        try model.saveManualProxy(proxy)
                        dismiss()
                    } catch { self.error = error.localizedDescription }
                }.buttonStyle(.borderedProminent).keyboardShortcut(.defaultAction).disabled(invalidMap)
            }
        }.padding(16).controlSize(.regular).frame(width: editorSheetWidth, height: 360)
        .onPreferenceChange(InvalidMapPreference.self) { invalidMap = $0 }
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

extension DeskModel {
    func manualProxy(for node: Node) -> ManualProxy? {
        guard node.provider == "manual" else { return nil }
        return settings.manualProxies?.first { $0.name == node.name }
    }
    func saveManualProxy(_ proxy: ManualProxy) throws {
        guard !busy else { throw DeskError("正在执行其他操作，请稍后重试") }
        _ = try proxy.configuration()
        var candidate = settings
        var proxies = candidate.manualProxies ?? []
        if let index = proxies.firstIndex(where: { $0.id == proxy.id }) {
            let old = proxies[index].name
            proxies[index] = proxy
            for index in proxies.indices where proxies[index].fields["dialer-proxy"] == .string(old) {
                proxies[index].fields["dialer-proxy"] = .string(proxy.name)
            }
            for index in candidate.rules.indices where candidate.rules[index].node?.provider == "manual" && candidate.rules[index].node?.name == old { candidate.rules[index].node = proxy.node }
            if candidate.defaultNode?.provider == "manual", candidate.defaultNode?.name == old { candidate.defaultNode = proxy.node }
            var providers = candidate.options?["rule-providers"]?.object ?? [:]
            for name in providers.keys {
                var fields = providers[name]?.object ?? [:]
                if fields["proxy"] == .string("node:manual/" + old) || fields["proxy"] == .string(old) { fields["proxy"] = .string("node:" + proxy.node.id) }
                providers[name] = .object(fields)
            }
            if !providers.isEmpty { candidate.options?["rule-providers"] = .object(providers) }

            for index in candidate.proxyGroups?.indices ?? 0..<0 {
                let targets = candidate.proxyGroups?[index].targets ?? []
                candidate.proxyGroups?[index].targets = targets.map { $0 == "node:manual/" + old ? "node:" + proxy.node.id : $0 }
                if candidate.proxyGroups?[index].fields["default-selected"] == .string("node:manual/" + old) { candidate.proxyGroups?[index].fields["default-selected"] = .string("node:" + proxy.node.id) }
            }
        } else { proxies.append(proxy) }
        candidate.manualProxies = proxies
        if candidate.defaultNode == nil, candidate.defaultDirect != true, candidate.defaultPolicy == nil, candidate.defaultProxyGroup == nil { candidate.defaultNode = proxies.first?.node ?? nodes.first }
        _ = try generateConfig(candidate); try saveSettings(candidate, to: directory); settings = candidate
        message = "代理已保存，运行时将自动应用。"
    }
    func deleteManualProxy(_ proxy: ManualProxy) {
        guard !busy else { return }
        if (settings.manualProxies ?? []).contains(where: { $0.id != proxy.id && $0.fields["dialer-proxy"] == .string(proxy.name) }) {
            error = "该代理仍被其他代理用作拨号出口，请先调整引用。"; return
        }
        if (settings.proxyGroups ?? []).contains(where: { $0.targets.contains("node:" + proxy.node.id) }) {
            error = "该代理仍被代理组引用，请先调整组内出口。"; return
        }
        if settings.options?["rule-providers"]?.object.values.contains(where: { $0.object["proxy"] == .string("node:" + proxy.node.id) || $0.object["proxy"] == .string(proxy.name) }) == true {
            error = "该代理仍用于规则集下载，请先修改下载出口。"; return
        }
        do {
            var candidate = settings
            candidate.manualProxies?.removeAll { $0.id == proxy.id }
            rejectUnavailableRouteNodes(&candidate, nodes: nodes)
            _ = try generateConfig(candidate)
            try saveSettings(candidate, to: directory)
            settings = candidate
            message = "代理已删除，运行时将自动应用。"
        } catch { self.error = error.localizedDescription }
    }
}
