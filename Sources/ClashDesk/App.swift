import SwiftUI
import ClashCore

@main
struct ClashDeskApp: App {
    @StateObject private var model = DeskModel()
    var body: some Scene {
        WindowGroup("ClashDesk") {
            DeskView().environmentObject(model).frame(minWidth: 1240, minHeight: 760)
                .task { model.startMonitor() }
        }
        .commands {
            CommandGroup(after: .appInfo) {
                Button("安装 / 启动全部服务") { model.startAll() }.disabled(model.busy)
            }
        }
    }
}

func bytes(_ value: Int64) -> String {
    ByteCountFormatter.string(fromByteCount: value, countStyle: .binary)
}

enum DeskPage: Int, CaseIterable, Identifiable {
    case general, outbound, rules, connections, traffic, settings
    var id: Int { rawValue }
    var title: String { ["通用配置", "出站代理", "路由规则", "当前连接", "流量统计", "设置"][rawValue] }
    var icon: String { ["slider.horizontal.3", "network", "list.bullet.rectangle", "arrow.left.arrow.right", "chart.bar", "gearshape"][rawValue] }
}

struct DeskView: View {
    @EnvironmentObject var model: DeskModel
    @State private var page: DeskPage? = .general
    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 12) {
                Image(systemName: "network").font(.title2).foregroundStyle(.blue)
                VStack(alignment: .leading) {
                    Text("ClashDesk · 0.5").font(.title2.bold())
                    Text("内核 \(model.coreRunning ? "在线" : "离线") · 统计 \(statsStatus)").font(.caption).foregroundStyle(.secondary)
                }
                Spacer()
                if model.busy { ProgressView().controlSize(.small) }
                Button("安装 / 启动全部") { model.startAll() }.disabled(model.busy)
                Button("应用运行配置") { model.applyLive() }.disabled(model.busy || !model.coreRunning)
                Menu("停止") {
                    Button("停止代理") { model.perform { try await stopCore() } }
                    Button("停止统计") { model.perform { try await stopStatistics() } }
                    Button("停止全部服务") {
                        model.perform { try await stopCore(); try await stopStatistics() }
                    }
                }.disabled(model.busy)
            }.padding(20)
            Divider()
            NavigationSplitView {
                List(DeskPage.allCases, selection: $page) { page in
                    Label(page.title, systemImage: page.icon).tag(page)
                }.navigationSplitViewColumnWidth(min: 170, ideal: 190, max: 230)
            } detail: {
                Group {
                    switch page ?? .general {
                    case .general: GeneralConfigurationView()
                    case .outbound: OutboundProxiesView()
                    case .rules: RulesView()
                    case .connections: ConnectionsView()
                    case .traffic: StatisticsView()
                    case .settings: ApplicationSettingsView()
                    }
                }.padding(20)
            }
            Divider()
            HStack {
                Text(model.message).font(.caption).foregroundStyle(.secondary).textSelection(.enabled)
                Spacer()
            }.padding(12)
        }
        .alert("操作未完成", isPresented: Binding(get: { model.error != nil }, set: { if !$0 { model.error = nil } })) {
            Button("确定") { model.error = nil }
        } message: { Text(model.error ?? "") }
        .sheet(item: $model.configPreview) { preview in
            ConfigPreviewView(preview: preview)
        }
    }
    var statsStatus: String {
        guard let sample = model.lastSample else { return "未采集" }
        return Date().timeIntervalSince(sample) < 20 ? "采集中" : "采集已暂停"
    }
}

struct ConfigPreviewView: View {
    @EnvironmentObject var model: DeskModel
    let preview: ConfigPreview
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("确认 mihomo 配置").font(.title2.bold())
            Text(preview.action == .start ? "确认后才会安装并启动系统代理服务，随后弹出 macOS 管理员授权。" : "确认后才会将下列配置应用到运行中的 mihomo。")
                .foregroundStyle(.secondary)
            HStack {
                Text("config.yaml").font(.headline)
                Spacer()
                Text("YAML · 只读预览 · 实际使用此份配置").font(.caption).foregroundStyle(.secondary)
            }
            ScrollView([.vertical, .horizontal]) {
                Text(String(decoding: preview.config, as: UTF8.self))
                    .font(.system(size: 12, design: .monospaced))
                    .textSelection(.enabled)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(12)
            }.background(Color(nsColor: .textBackgroundColor)).border(Color.secondary.opacity(0.3))
            HStack {
                Button("取消") { model.configPreview = nil }.keyboardShortcut(.cancelAction)
                Spacer()
                Button(preview.action == .start ? "确认并启动" : "确认并应用") { model.confirmConfig(preview) }
                    .buttonStyle(.borderedProminent).disabled(model.busy)
            }
        }.padding(24).frame(width: 900, height: 650)
    }
}

struct RouteMenu: View {
    @EnvironmentObject var model: DeskModel
    let kind: RuleKind
    let value: String
    var effectiveKind: RuleKind {
        if !kind.isProcess, validCIDR(value + "/32") { return .ipCIDR }
        if !kind.isProcess, validCIDR(value + "/128") { return .ipCIDR6 }
        return kind
    }
    var effectiveValue: String { effectiveKind == .ipCIDR ? value + "/32" : effectiveKind == .ipCIDR6 ? value + "/128" : value }
    var body: some View {
        Menu("添加\(effectiveKind.isProcess ? "程序" : effectiveKind.isCIDR ? "IP" : "域名")规则") {
            Button("直连") { add(nil) }
            ForEach(model.allNodes) { node in Button(model.nodeLabel(node)) { add(node) } }
        }
    }
    func add(_ node: Node?) {
        do { try model.addRule(kind: effectiveKind, value: effectiveValue, node: node); model.message = "规则已保存，请点击“应用运行配置”。" }
        catch { model.error = error.localizedDescription }
    }
}

struct StatisticsView: View {
    @EnvironmentObject var model: DeskModel
    var activeCounts: [String: Int] { Dictionary(model.connections.map { ($0.domain, 1) }, uniquingKeysWith: +) }
    var body: some View {
        let counts = activeCounts
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("域名流量").font(.title3.bold())
                Spacer()
                Picker("时间范围", selection: $model.hours) {
                    Text("最近 24 小时").tag(24); Text("最近 7 天").tag(168); Text("最近 30 天").tag(720)
                }.frame(width: 220)
            }
            Text("按域名汇总上传与下载 · 显示流量最大的 500 个域名 · 时间精度为小时")
                .font(.caption).foregroundStyle(.secondary)
                Table(model.traffic) {
                    TableColumn("域名 / IP") { row in
                        Text(row.domain).textSelection(.enabled).contextMenu { RouteMenu(kind: .domain, value: row.domain) }
                    }
                    TableColumn("程序数") { row in Text(String(row.processCount)) }.width(80)
                    TableColumn("出口数") { row in Text(String(row.outboundCount)) }.width(80)
                    TableColumn("当前连接数") { row in Text(String(counts[row.domain] ?? 0)) }.width(100)
                    TableColumn("上传") { row in Text(bytes(row.upload)).monospacedDigit() }.width(100)
                    TableColumn("下载") { row in Text(bytes(row.download)).monospacedDigit() }.width(100)
                    TableColumn("总流量") { row in Text(bytes(row.upload + row.download)).monospacedDigit() }.width(100)
                }
                .overlay {
                    if model.traffic.isEmpty {
                        Text("暂无统计。启动服务后访问网站，数据会自动显示。").foregroundStyle(.secondary).allowsHitTesting(false)
                    }
                }
            Text("识别不到域名的连接按 IP 显示。短连接和采集暂停期间可能遗漏；统计后台重启会重新建立基线，避免重复累计。")
                .font(.caption).foregroundStyle(.secondary)
        }
    }
}

struct ConnectionsView: View {
    @EnvironmentObject var model: DeskModel
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("当前连接（\(model.connections.count)）").font(.title3.bold())
            Text("右键域名或程序可添加规则；新规则应用后可断开旧连接，让应用重新建立连接。")
                .font(.caption).foregroundStyle(.secondary)
            Table(model.connections) {
                TableColumn("域名 / IP") { connection in
                    Text(connection.domain).textSelection(.enabled).contextMenu { RouteMenu(kind: .domain, value: connection.domain) }
                }
                TableColumn("程序") { connection in
                    Text(connection.process).help(connection.process).contextMenu {
                        if connection.process != "未知程序" {
                            RouteMenu(kind: connection.process.hasPrefix("/") ? .processPath : .processName, value: connection.process)
                        }
                    }
                }
                TableColumn("协议") { connection in Text(connection.metadata.network ?? "—") }.width(65)
                TableColumn("出口") { connection in Text(connection.outbound) }
                TableColumn("上传") { connection in Text(bytes(connection.upload)) }.width(90)
                TableColumn("下载") { connection in Text(bytes(connection.download)) }.width(100)
                TableColumn("操作") { connection in
                    Button("断开") { model.perform { try await model.api.closeConnection(connection.id) } }
                        .disabled(model.busy)
                }.width(70)
            }
        }
    }
}
