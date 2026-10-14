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
                                        GroupBox(configFieldTitle(group, document: schema.document)) {
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
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("设置").font(.title2.bold())
                Spacer()
                Button { model.toggleAllServices() } label: {
                    Label(model.servicesActive ? "停止全部" : "启动全部", systemImage: model.servicesActive ? "stop.fill" : "play.fill")
                }.controlSize(.regular).disabled(model.busy)
                Button { model.applyLive() } label: { Label("应用更改", systemImage: "checkmark") }.disabled(model.busy || !model.coreRunning)
            }.pageActions()
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 6) {
                    GroupBox {
                        VStack(alignment: .leading, spacing: 4) {
                            formRow("内核状态", help: "mihomo 控制接口是否可访问。") {
                                statusBadge(model.coreRunning ? "在线" : "离线", active: model.coreRunning)
                            }
                            formRow("采集服务", help: "后台流量采集服务的状态。等待采集表示服务已启动，但尚未收到近期采集数据。") {
                                statusBadge(statsStatus, active: model.statsPID != nil && statsStatus == "采集中")
                            }
                            info("内核版本", model.coreVersion ?? "—", "当前运行的 mihomo 版本。")
                            info("内存占用", model.coreMemory.map(bytes) ?? "—", "mihomo 控制接口报告的内存使用量。")
                            info("内核 PID", model.corePID.map(String.init) ?? "—", "由 launchd 管理的 mihomo 进程编号。")
                            info("采集服务 PID", model.statsPID.map(String.init) ?? "—", "独立流量采集服务的进程编号。")
                            info("上次采集时间", model.lastSample.map { $0.formatted(date: .abbreviated, time: .standard) } ?? "未采集", "后台服务最近一次成功采集流量的时间。")
                            info("控制接口", model.activeController, "已应用配置中的 mihomo 控制接口地址。")
                            info("用户数据目录", model.directory.path, "客户端设置、订阅缓存和统计数据库保存的位置。")
                            info("系统内核目录", rootDirectory, "系统 mihomo 服务的运行配置和数据目录。")
                        }.padding(6)
                    } label: {
                        HStack {
                            Text("运行概览")
                            Spacer()
                            if model.busy { ProgressView().controlSize(.small) }
                            Button { model.perform { await model.refreshDiagnostics() } } label: { Image(systemName: "arrow.clockwise") }
                                .buttonStyle(.borderless).help("刷新运行信息").disabled(model.busy)
                        }
                    }
                    GroupBox("内核文件") {
                        formRow("core-path", help: "选择可执行的 macOS mihomo 二进制文件，用于代理运行、订阅解析和延迟测试。") {
                            HStack {
                                Text(model.settings.corePath.isEmpty ? "尚未配置" : model.settings.corePath)
                                    .font(.system(.body, design: .monospaced)).lineLimit(1).truncationMode(.middle)
                                    .textSelection(.enabled).help(model.settings.corePath)
                                Spacer(minLength: 0)
                                Button("选择文件") { model.chooseCore() }.disabled(model.busy)
                            }
                        }.padding(6)
                    }
                    GroupBox("延迟测试") {
                        VStack(alignment: .leading, spacing: 4) {
                            formRow("unified-delay") {
                                Toggle("", isOn: Binding(get: {
                                    model.option("unified-delay") != .boolean(false)
                                }, set: { model.setOption("unified-delay", value: .boolean($0)) })).disabled(model.busy)
                            }
                            formRow("测试地址") {
                                TextField("HTTP / HTTPS URL", text: Binding(get: {
                                    model.settings.delayTestURL ?? "https://www.gstatic.com/generate_204"
                                }, set: { model.settings.delayTestURL = $0; model.scheduleConfigurationSave() })).disabled(model.busy)
                            }
                            formRow("超时（毫秒）") {
                                TextField("5000", value: Binding(get: {
                                    model.settings.delayTestTimeoutMilliseconds ?? 5000
                                }, set: { model.settings.delayTestTimeoutMilliseconds = $0; model.scheduleConfigurationSave() }), format: .number.grouping(.never))
                                    .frame(width: 150).disabled(model.busy)
                            }
                        }.textFieldStyle(.roundedBorder).padding(6)
                    }
                }.padding(.trailing, 4)
            }
        }.controlSize(.regular).environment(\.formHelpDocument, "settings")
    }
    var statsStatus: String {
        guard model.statsPID != nil else { return "已停止" }
        guard let sample = model.lastSample else { return "等待采集" }
        return Date().timeIntervalSince(sample) < 20 ? "采集中" : "等待采集"
    }
    func statusBadge(_ text: String, active: Bool) -> some View {
        HStack(spacing: 5) {
            Circle().fill(active ? Color.green : Color.secondary).frame(width: 6, height: 6)
            Text(text)
        }.padding(.horizontal, 8).padding(.vertical, 3)
            .background((active ? Color.green : Color.secondary).opacity(0.10), in: Capsule())
    }
    func info(_ title: String, _ value: String, _ help: String) -> some View {
        formRow(title, help: help) { Text(value).lineLimit(1).truncationMode(.middle).textSelection(.enabled).help(value) }
    }
}
