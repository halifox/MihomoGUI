import SwiftUI
import ClashCore

struct GeneralConfigurationView: View {
    @EnvironmentObject var model: DeskModel
    @State private var search = ""
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("通用配置").font(.title2.bold())
                Spacer()
                TextField("搜索配置项", text: $search).frame(width: 250).textFieldStyle(.roundedBorder)
                Button("保存配置") { model.saveGeneralConfiguration() }.disabled(model.busy)
            }
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 20) {
                    ForEach(documentSchemas.sections.filter { !visibleFields($0).isEmpty }) { schema in
                        GroupBox {
                            VStack(alignment: .leading, spacing: 12) {
                                ForEach(fieldGroups(schema), id: \.self) { group in
                                    if group.isEmpty {
                                        fieldRows(schema, group: group)
                                    } else {
                                        GroupBox(group) {
                                            fieldRows(schema, group: group).padding(8)
                                        }
                                    }
                                }
                            }.padding(10).frame(maxWidth: .infinity, alignment: .leading)
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
            HStack {
                Text("配置先保存在本地；启动与应用前仍需确认完整 YAML。").font(.caption).foregroundStyle(.secondary)
                Spacer()
                Link("配置文档", destination: URL(string: "https://wiki.metacubex.one/config/")!)
            }
        }
    }
    func visibleFields(_ schema: EditorSchema) -> [EditorField] {
        schema.fields.filter {
            search.isEmpty || ($0.path + $0.description + schema.name).localizedCaseInsensitiveContains(search)
        }
    }
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
                            allowUnset: model.baseOption(field.path) == nil, compact: true)
                    .disabled(!fieldEnabled(field.path))
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
                GroupBox("mihomo 二进制") {
                    HStack {
                        Text(model.settings.corePath.isEmpty ? "尚未配置" : model.settings.corePath)
                            .font(.system(.body, design: .monospaced)).textSelection(.enabled)
                        Spacer()
                        Button("选择文件") { model.chooseCore() }.disabled(model.busy)
                    }.padding(8)
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
                Text("内存为 mihomo 控制接口报告的内存值；PID 从对应 launchd 服务读取。退出 GUI 后，独立服务继续运行。")
                    .font(.caption).foregroundStyle(.secondary)
            }
        }
    }
    func info(_ title: String, _ value: String) -> some View {
        GridRow { Text(title).foregroundStyle(.secondary); Text(value).textSelection(.enabled) }
    }
}
