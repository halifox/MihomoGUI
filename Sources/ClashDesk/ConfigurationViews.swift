import SwiftUI
import ClashCore

struct GeneralConfigurationView: View {
    @EnvironmentObject var model: DeskModel
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("通用配置").font(.title2.bold())
                Spacer()
            }
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 6) {
                    ForEach(documentSchemas.sections.filter { !visibleFields($0).isEmpty }) { schema in
                        GroupBox {
                            VStack(alignment: .leading, spacing: 6) {
                                ForEach(fieldGroups(schema), id: \.self) { group in
                                    if group.isEmpty {
                                        fieldRows(schema, group: group)
                                    } else {
                                        GroupBox(group) {
                                            fieldRows(schema, group: group).padding(4)
                                        }
                                    }
                                }
                            }.padding(6).frame(maxWidth: .infinity, alignment: .leading)
                                .environment(\.formHelpDocument, schema.document)
                        } label: {
                            HStack {
                                Text(schema.name).font(.headline)
                                Spacer()
                                Link("配置文档", destination: URL(string: "https://wiki.metacubex.one/config/" + (schema.key == "general" ? "general/" : schema.key == "sniffer" ? "sniff/" : schema.key == "tun" ? "inbound/tun/" : "dns/"))!)
                                    .font(.caption)
                            }
                        }
                    }
                }.padding(.trailing, 4)
            }.disabled(model.busy)

        }
    }
    func visibleFields(_ schema: EditorSchema) -> [EditorField] { schema.fields }
    func localPath(_ field: EditorField, schema: EditorSchema) -> String {
        let prefix = schema.key + "."
        return field.path.hasPrefix(prefix) ? String(field.path.dropFirst(prefix.count)) : field.path
    }
    func groupName(_ field: EditorField, schema: EditorSchema) -> String {
        let path = localPath(field, schema: schema)
        return path.split(separator: ".").dropLast().joined(separator: ".")
    }
    func fieldGroups(_ schema: EditorSchema) -> [String] {
        var groups: [String] = []
        for field in visibleFields(schema) {
            let group = groupName(field, schema: schema)
            if !groups.contains(group) { groups.append(group) }
        }
        return groups
    }
    func fieldRows(_ schema: EditorSchema, group: String) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            ForEach(visibleFields(schema).filter { groupName($0, schema: schema) == group }) { field in
                VisualField(field: displayField(field, schema: schema), value: Binding(get: {
                    model.option(field.path)
                }, set: { model.setOption(field.path, value: $0) }),
                            allowUnset: model.baseOption(field.path) == nil, compact: true, inputEnabled: fieldEnabled(field.path))
                Divider()
            }
        }
    }
    func displayField(_ field: EditorField, schema: EditorSchema) -> EditorField {
        var result = field
        result.title = localPath(field, schema: schema).split(separator: ".").last.map(String.init) ?? field.title
        return result
    }
    func fieldEnabled(_ path: String) -> Bool {
        for parent in ["dns", "sniffer", "tun"] {
            if path.hasPrefix(parent + "."), path != parent + ".enable" {
                return model.option(parent + ".enable") == .boolean(true)
            }
        }
        if path.hasPrefix("external-controller-cors.") {
            return !(model.option("external-controller")?.text.isEmpty ?? true)
        }
        return true
    }

}

struct ApplicationSettingsView: View {
    @EnvironmentObject var model: DeskModel
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("设置与调试").font(.title2.bold())
                GroupBox("服务控制") {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack(spacing: 10) {
                            Image(systemName: "network").font(.title2).foregroundStyle(.blue)
                            VStack(alignment: .leading, spacing: 4) {
                                Text("ClashDesk · 0.5").font(.headline)
                                Text("内核 \(model.coreRunning ? "在线" : "离线") · 统计 \(statsStatus)")
                                    .font(.caption).foregroundStyle(.secondary)
                            }
                            Spacer()
                            if model.busy { ProgressView().controlSize(.small) }
                        }
                        HStack {
                            Button("安装 / 启动全部") { model.startAll() }.disabled(model.busy)
                            Button("应用运行配置") { model.applyLive() }.disabled(model.busy || !model.coreRunning)
                            Menu("停止") {
                                Button("停止代理") { model.perform { try await stopCore() } }
                                Button("停止统计") { model.perform { try await stopStatistics() } }
                                Button("停止全部服务") {
                                    model.perform { try await stopCore(); try await stopStatistics() }
                                }
                            }.disabled(model.busy)
                        }
                    }.padding(8)
                }
                GroupBox("mihomo 二进制") {
                    HStack {
                        Text(model.settings.corePath.isEmpty ? "尚未配置" : model.settings.corePath)
                            .font(.system(.body, design: .monospaced)).textSelection(.enabled)
                        Spacer()
                        Button("选择文件") { model.chooseCore() }.disabled(model.busy)
                    }.padding(8)
                }
                GroupBox("延迟测试") {
                    VStack(alignment: .leading, spacing: 6) {
                        Grid(alignment: .leading, horizontalSpacing: 24, verticalSpacing: 14) {
                            GridRow {
                                FieldKeyLabel(title: "unified-delay", key: "unified-delay")
                                Toggle("统一延迟", isOn: Binding(get: {
                                    model.option("unified-delay") != .boolean(false)
                                }, set: { model.setOption("unified-delay", value: .boolean($0)) }))
                            }
                            GridRow {
                                FieldKeyLabel(title: "测试地址", key: "测试地址")
                                TextField("HTTP / HTTPS URL", text: Binding(get: {
                                    model.settings.delayTestURL ?? "https://www.gstatic.com/generate_204"
                                }, set: { model.settings.delayTestURL = $0; model.scheduleConfigurationSave() }))
                            }
                            GridRow {
                                FieldKeyLabel(title: "超时（毫秒）", key: "超时（毫秒）")
                                TextField("5000", value: Binding(get: {
                                    model.settings.delayTestTimeoutMilliseconds ?? 5000
                                }, set: { model.settings.delayTestTimeoutMilliseconds = $0; model.scheduleConfigurationSave() }), format: .number.grouping(.never))
                                    .frame(width: 150)
                            }
                        }.textFieldStyle(.roundedBorder)

                    }.padding(12).disabled(model.busy)
                }
                GroupBox("运行信息") {
                    Grid(alignment: .leading, horizontalSpacing: 36, verticalSpacing: 16) {
                        info("内核状态", model.coreRunning ? "运行中" : "离线")
                        info("mihomo 版本", model.coreVersion ?? "—")
                        info("Clash 内存占用", model.coreMemory.map(bytes) ?? "—")
                        info("Clash 进程 PID", model.corePID.map(String.init) ?? "—")
                        info("后台采集服务 PID", model.statsPID.map(String.init) ?? "—")
                        info("采集时间", model.lastSample.map { $0.formatted(date: .abbreviated, time: .standard) } ?? "未采集")
                        info("控制接口", model.activeController)
                        info("用户数据目录", model.directory.path)
                        info("系统内核目录", rootDirectory)
                    }.padding(12)
                }
                HStack {
                    Button("刷新调试信息") { model.perform { await model.refreshDiagnostics() } }.disabled(model.busy)
                    Button("启动统计后台") { model.perform { try await startStatistics(directory: model.directory) } }.disabled(model.busy)
                }

            }
        }
    }
    var statsStatus: String {
        guard let sample = model.lastSample else { return "未采集" }
        return Date().timeIntervalSince(sample) < 20 ? "采集中" : "采集已暂停"
    }
    func info(_ title: String, _ value: String) -> some View {
        GridRow { Text(title).foregroundStyle(.secondary); Text(value).textSelection(.enabled) }
    }
}
