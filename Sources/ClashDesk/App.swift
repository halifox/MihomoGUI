import SwiftUI
import ClashCore

@main
struct ClashDeskApp: App {
    @StateObject private var model = DeskModel()
    var body: some Scene {
        WindowGroup("ClashDesk") {
            DeskView().environmentObject(model).frame(minWidth: 800, minHeight: 600)
                .background(InitialWindowSize())
                .task { model.startMonitor() }
        }
        .defaultSize(width: 800, height: 600)
        .commands {
            CommandGroup(after: .appInfo) {
                Button("安装 / 启动全部服务") { model.startAll() }.disabled(model.busy)
            }
        }
    }
}

// Apply once per new window so a restored frame cannot override the requested launch size.
struct InitialWindowSize: NSViewRepresentable {
    func makeNSView(context: Context) -> NSView { LaunchSizeView() }
    func updateNSView(_ nsView: NSView, context: Context) {}
}

final class LaunchSizeView: NSView {
    private var sized = false
    override func viewDidMoveToWindow() {
        super.viewDidMoveToWindow()
        guard !sized, let window else { return }
        sized = true
        DispatchQueue.main.async { [weak window] in
            window?.setContentSize(NSSize(width: 800, height: 600))
        }
    }
}

func bytes(_ value: Int64) -> String {
    ByteCountFormatter.string(fromByteCount: value, countStyle: .binary)
}

func tableColumnWidth(_ title: String, _ values: [String], numeric: Bool = false, monospaced: Bool = false,
                      padding: CGFloat = 28, maximum: CGFloat = 420) -> CGFloat {
    let font = monospaced ? NSFont.monospacedSystemFont(ofSize: NSFont.systemFontSize, weight: .regular)
        : numeric ? NSFont.monospacedDigitSystemFont(ofSize: NSFont.systemFontSize, weight: .regular)
        : NSFont.systemFont(ofSize: NSFont.systemFontSize)
    let header = (title as NSString).size(withAttributes: [.font: NSFont.systemFont(ofSize: NSFont.systemFontSize, weight: .semibold)]).width
    let content = values.map { ($0 as NSString).size(withAttributes: [.font: font]).width }.max() ?? 0
    return min(maximum, ceil(max(header, content)) + padding)
}

enum DeskPage: Int, CaseIterable, Identifiable {
    case general, subscriptions, outbound, groups, rules, ruleSets, connections, traffic, settings
    var id: Int { rawValue }
    var title: String { ["通用配置", "订阅管理", "代理", "代理组", "路由规则", "规则集合", "当前连接", "流量统计", "设置"][rawValue] }
    var icon: String { ["slider.horizontal.3", "link", "network", "square.stack.3d.up", "list.bullet.rectangle", "folder", "arrow.left.arrow.right", "chart.bar", "gearshape"][rawValue] }
}

struct DeskView: View {
    @EnvironmentObject var model: DeskModel
    @State private var page: DeskPage? = .general
    var body: some View {
        VStack(spacing: 0) {
            NavigationSplitView {
                List(DeskPage.allCases, selection: $page) { page in
                    Label(page.title, systemImage: page.icon).tag(page)
                }.navigationSplitViewColumnWidth(min: 170, ideal: 190, max: 230)
            } detail: {
                Group {
                    switch page ?? .general {
                    case .general: GeneralConfigurationView()
                    case .subscriptions: SubscriptionsView()
                    case .outbound: OutboundProxiesView()
                    case .groups: ResourcesView(groups: true)
                    case .ruleSets: ResourcesView(groups: false)
                    case .rules: RulesView()
                    case .connections: ConnectionsView()
                    case .traffic: StatisticsView()
                    case .settings: ApplicationSettingsView()
                    }
                }.padding(20)
            }

        }
        .onReceive(NotificationCenter.default.publisher(for: NSApplication.willTerminateNotification)) { _ in model.flushConfigurationSave() }
        .onDisappear { model.flushConfigurationSave() }
        .alert("操作未完成", isPresented: Binding(get: { model.error != nil }, set: { if !$0 { model.error = nil } })) {
            Button("确定") { model.error = nil }
        } message: { Text(model.error ?? "") }
        .sheet(item: $model.configPreview) { preview in
            ConfigPreviewView(preview: preview)
        }
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
                Table(model.traffic) {
                    TableColumn("域名 / IP") { row in
                        Text(row.domain).textSelection(.enabled).contextMenu { RouteMenu(kind: .domain, value: row.domain) }
                    }.width(tableColumnWidth("域名 / IP", model.traffic.map(\.domain)))
                    TableColumn("程序数") { row in Text(String(row.processCount)) }.width(tableColumnWidth("程序数", model.traffic.map { String($0.processCount) }, numeric: true))
                    TableColumn("出口数") { row in Text(String(row.outboundCount)) }.width(tableColumnWidth("出口数", model.traffic.map { String($0.outboundCount) }, numeric: true))
                    TableColumn("当前连接数") { row in Text(String(counts[row.domain] ?? 0)) }.width(tableColumnWidth("当前连接数", model.traffic.map { String(counts[$0.domain] ?? 0) }, numeric: true))
                    TableColumn("上传") { row in Text(bytes(row.upload)).monospacedDigit() }.width(tableColumnWidth("上传", model.traffic.map { bytes($0.upload) }, numeric: true))
                    TableColumn("下载") { row in Text(bytes(row.download)).monospacedDigit() }.width(tableColumnWidth("下载", model.traffic.map { bytes($0.download) }, numeric: true))
                    TableColumn("总流量") { row in Text(bytes(row.upload + row.download)).monospacedDigit() }.width(tableColumnWidth("总流量", model.traffic.map { bytes($0.upload + $0.download) }, numeric: true))
                }
                .overlay {
                    if model.traffic.isEmpty {
                        Text("暂无统计。启动服务后访问网站，数据会自动显示。").foregroundStyle(.secondary).allowsHitTesting(false)
                    }
                }

        }
    }
}

struct ConnectionsView: View {
    @EnvironmentObject var model: DeskModel
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("当前连接").font(.title3.bold())
            Table(model.connections) {
                TableColumn("域名 / IP") { connection in
                    Text(connection.domain).textSelection(.enabled).contextMenu { RouteMenu(kind: .domain, value: connection.domain) }
                }.width(tableColumnWidth("域名 / IP", model.connections.map(\.domain)))
                TableColumn("程序") { connection in
                    Text(connection.process).help(connection.process).contextMenu {
                        if connection.process != "未知程序" {
                            RouteMenu(kind: connection.process.hasPrefix("/") ? .processPath : .processName, value: connection.process)
                        }
                    }
                }.width(tableColumnWidth("程序", model.connections.map(\.process)))
                TableColumn("协议") { connection in Text(connection.metadata.network ?? "—") }.width(tableColumnWidth("协议", model.connections.map { $0.metadata.network ?? "—" }))
                TableColumn("出口") { connection in Text(connection.outbound) }.width(tableColumnWidth("出口", model.connections.map(\.outbound)))
                TableColumn("上传") { connection in Text(bytes(connection.upload)) }.width(tableColumnWidth("上传", model.connections.map { bytes($0.upload) }, numeric: true))
                TableColumn("下载") { connection in Text(bytes(connection.download)) }.width(tableColumnWidth("下载", model.connections.map { bytes($0.download) }, numeric: true))
                TableColumn("操作") { connection in
                    Button("断开") { model.perform { try await model.api.closeConnection(connection.id) } }
                        .disabled(model.busy)
                }.width(tableColumnWidth("操作", model.connections.isEmpty ? [] : ["断开"], padding: 42))
            }
        }
    }
}
