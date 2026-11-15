import SwiftUI
import ClashCore

struct DashboardView: View {
    @EnvironmentObject var model: DeskModel
    @State private var configurationText: String?
    @State private var traffic: CoreTraffic?
    @State private var trafficError: String?

    private var endpoint: String {
        guard let api = try? model.api else { return "" }
        return "\(api.host):\(api.port)/\(api.secret)/\(model.coreRunning)"
    }

    private var status: String {
        if model.coreRunning { return model.connectionsError == nil ? "已连接" : "控制接口异常" }
        return model.coreActive ? "内核服务已加载，等待连接" : "未连接"
    }

    var body: some View {
        Form {
            Section("内核运行信息") {
                information("连接状态", status)
                information("内核版本", model.coreVersion ?? "暂不可用")
                information("内存占用", model.coreMemory.map { bytes($0) } ?? "暂不可用")
                information("控制接口", model.activeController)
                if let pid = model.corePID { information("内核进程 PID", String(pid)) }
                Text("关闭窗口或退出 GUI 后，Clash 内核继续运行。")
                    .font(.caption).foregroundStyle(.secondary)
                if let error = model.connectionsError {
                    Text(error).font(.caption).foregroundStyle(.red)
                }
            }
            Section("实时流量与连接") {
                information("上传速率", traffic.map { bytes($0.up) + "/s" } ?? "—")
                information("下载速率", traffic.map { bytes($0.down) + "/s" } ?? "—")
                information("累计上传", model.uploadTotal.map { bytes($0) } ?? "—")
                information("累计下载", model.downloadTotal.map { bytes($0) } ?? "—")
                information("活动连接", model.coreRunning && model.connectionsError == nil ? String(model.connections.count) : "—")
                Text("累计流量由内核提供，内核重启后重置；不保存历史统计。")
                    .font(.caption).foregroundStyle(.secondary)
                if let error = trafficError {
                    Text(error).font(.caption).foregroundStyle(.red)
                }
            }
        }
        .formStyle(.grouped)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    do { configurationText = String(decoding: try generateConfig(model.settings), as: UTF8.self) }
                    catch { model.error = error.localizedDescription }
                } label: {
                    Label("查看配置文件", systemImage: "doc.text")
                }
                .disabled(model.busy)
                .help("查看当前设置生成的完整配置文件")
                .labelStyle(.iconOnly)
            }
            ToolbarItem(placement: .primaryAction) {
                Button { model.toggleCore() } label: {
                    Label {
                        Text(serviceButtonTitle)
                    } icon: {
                        if model.serviceOperation != nil {
                            ProgressView().controlSize(.small)
                        } else {
                            Image(systemName: model.coreActive ? "stop.fill" : "play.fill")
                        }
                    }
                }
                .disabled(model.busy)
                .help(serviceButtonTitle)
                .accessibilityLabel(serviceButtonTitle)
                .labelStyle(.iconOnly)
            }
        }
        .task(id: endpoint) {
            let source = endpoint
            traffic = nil; trafficError = nil
            guard model.coreRunning else { return }
            while !Task.isCancelled {
                do {
                    try await model.api.traffic { sample in
                        guard !Task.isCancelled, source == endpoint else { return }
                        traffic = sample; trafficError = nil
                    }
                } catch {
                    guard !Task.isCancelled, source == endpoint else { return }
                    traffic = nil
                    trafficError = "实时流量读取失败，将自动重试：" + error.localizedDescription
                }
                do { try await Task.sleep(nanoseconds: 3_000_000_000) }
                catch { return }
            }
        }
        .sheet(isPresented: Binding(get: { configurationText != nil }, set: { if !$0 { configurationText = nil } })) {
            VStack(alignment: .leading, spacing: 12) {
                Text("完整配置 · config.yaml").font(.title2)
                Text("根据当前设置生成").font(.caption).foregroundStyle(.secondary)
                ScrollView([.horizontal, .vertical]) {
                    Text(configurationText ?? "")
                        .font(.system(.body, design: .monospaced))
                        .textSelection(.enabled)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                Button("关闭") { configurationText = nil }.keyboardShortcut(.cancelAction)
                    .frame(maxWidth: .infinity, alignment: .trailing)
            }.padding(20).frame(minWidth: 520, idealWidth: 760, minHeight: 360, idealHeight: 520)
        }
    }

    private var serviceButtonTitle: String {
        switch model.serviceOperation {
        case .starting: return "正在启动…"
        case .stopping: return "正在停止…"
        case nil: return model.coreActive ? "停止 Clash 内核" : "启动 Clash 内核"
        }
    }

    private func information(_ title: String, _ value: String) -> some View {
        HStack {
            Text(title)
            Spacer()
            Text(value).foregroundStyle(.secondary).monospacedDigit().textSelection(.enabled)
        }
    }
}
