import SwiftUI
import ClashCore

struct ApplicationSettingsView: View {
    @EnvironmentObject var model: DeskModel
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
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
                            info("内核服务 PID", model.corePID.map(String.init) ?? "—", "由 launchd 管理的内核服务进程编号，包含内核与日志采集子进程。")
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
                    GroupBox("延迟测试") {
                        VStack(alignment: .leading, spacing: 4) {
                            formRow("unified-delay") {
                                Toggle("", isOn: Binding(get: {
                                    model.option("unified-delay") != .boolean(false)
                                }, set: { model.setOption("unified-delay", value: .boolean($0)) })).disabled(model.busy || model.configurationLocked)
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
        }
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                HStack(spacing: 4) {
                    Button { model.perform { model.serviceLogs = try await readCoreLog(directory: model.directory) } } label: {
                        toolbarIcon("查看日志", systemImage: "doc.text")
                    }.frame(width: 28, height: 28).disabled(model.busy).help("读取用户日志目录中的 core.log")
                    Button { model.toggleAllServices() } label: {
                        toolbarIcon(model.servicesActive ? "停止全部" : "启动全部", systemImage: model.servicesActive ? "stop.fill" : "play.fill")
                    }.frame(width: 28, height: 28).disabled(model.busy)
                }
                .buttonStyle(.bordered)
                .controlSize(.regular)
                .padding(.horizontal, 4)
                .padding(.vertical, 2)
            }
        }
        .padding(20).controlSize(.regular).environment(\.formHelpDocument, "settings")
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
