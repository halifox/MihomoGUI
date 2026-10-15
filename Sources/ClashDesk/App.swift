import SwiftUI
import Darwin
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
                      padding: CGFloat = 28) -> CGFloat {
    let font = monospaced ? NSFont.monospacedSystemFont(ofSize: NSFont.systemFontSize, weight: .regular)
        : numeric ? NSFont.monospacedDigitSystemFont(ofSize: NSFont.systemFontSize, weight: .regular)
        : NSFont.systemFont(ofSize: NSFont.systemFontSize)
    let header = (title as NSString).size(withAttributes: [.font: NSFont.systemFont(ofSize: NSFont.systemFontSize, weight: .semibold)]).width
    let content = values.lazy.flatMap { $0.components(separatedBy: .newlines) }
        .map { ($0 as NSString).size(withAttributes: [.font: font]).width }.max() ?? 0
    return ceil(max(header, content)) + padding
}

enum DeskPage: Int, CaseIterable, Identifiable {
    case general, subscriptions, outbound, groups, ruleSets, rules, connections, traffic, settings
    var id: Int { rawValue }
    var title: String { ["全局配置", "代理订阅", "出站代理", "代理分组", "规则集合", "路由规则", "活动连接", "流量统计", "应用设置"][rawValue] }
    var icon: String { ["slider.horizontal.3", "link", "network", "square.stack.3d.up", "folder", "list.bullet.rectangle", "arrow.left.arrow.right", "chart.bar", "gearshape"][rawValue] }
}

private struct TableDataReadyKey: EnvironmentKey {
    static let defaultValue = true
}

extension EnvironmentValues {
    var tableDataReady: Bool {
        get { self[TableDataReadyKey.self] }
        set { self[TableDataReadyKey.self] = newValue }
    }
}

private struct DeferredTableData: ViewModifier {
    @State private var ready = false
    func body(content: Content) -> some View {
        content.environment(\.tableDataReady, ready)
            .task {
                // Give the empty table a frame before constructing its rows and measuring columns.
                do { try await Task.sleep(nanoseconds: 20_000_000) } catch { return }
                guard !Task.isCancelled else { return }
                ready = true
            }
    }
}

struct DeskView: View {
    @EnvironmentObject var model: DeskModel
    @State private var page: DeskPage? = .general
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Circle().fill(model.coreRunning ? Color.green : Color.secondary).frame(width: 7, height: 7)
                Text(model.coreRunning ? "内核在线" : "内核离线")
                Text(model.draftStatus).foregroundStyle(model.hasUnappliedChanges ? Color.orange : Color.secondary)
                Spacer()
                if model.busy { ProgressView().controlSize(.small) }
                Button("查看差异") { model.previewConfig() }.disabled(model.busy)
                Button(model.coreRunning ? "应用更改" : "启动服务") {
                    if model.coreRunning { model.applyLive() } else { model.startAll() }
                }.disabled(model.busy || (model.coreRunning && !model.hasUnappliedChanges))
            }.pageActions().padding(.horizontal, 20).padding(.vertical, 10)
            Divider()
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
                    .modifier(DeferredTableData())
                    .id(page ?? .general)
            }
            Divider()
            Text(model.message).font(.caption).foregroundStyle(.secondary).lineLimit(1).help(model.message)
                .frame(maxWidth: .infinity, alignment: .leading).padding(.horizontal, 20).padding(.vertical, 6)

        }
        .onReceive(NotificationCenter.default.publisher(for: NSApplication.willTerminateNotification)) { _ in model.flushConfigurationSave() }
        .onDisappear { model.flushConfigurationSave() }
        .alert("操作未完成", isPresented: Binding(get: { model.error != nil }, set: { if !$0 { model.error = nil } })) {
            Button("确定") { model.error = nil }
        } message: { Text(model.error ?? "") }
        .sheet(isPresented: Binding(get: { model.serviceLogs != nil }, set: { if !$0 { model.serviceLogs = nil } })) {
            VStack(alignment: .leading) {
                Text("服务日志").font(.title2)
                ScrollView { Text(model.serviceLogs ?? "").font(.system(.body, design: .monospaced)).textSelection(.enabled).frame(maxWidth: .infinity, alignment: .leading) }
                Button("关闭") { model.serviceLogs = nil }.keyboardShortcut(.cancelAction)
            }.padding(20).frame(width: 760, height: 520)
        }
        .sheet(item: $model.rulePrefill) { prefill in
            RuleEditorView(prefill: prefill)
        }
        .sheet(item: $model.configurationImport) { ConfigurationImportView(value: $0) }
        .sheet(item: $model.subscriptionUpdate) { SubscriptionChangesView(changes: $0) }
        .sheet(item: $model.configPreview) { preview in
            ConfigPreviewView(preview: preview)
        }
    }

}

struct ConfigPreviewView: View {
    @EnvironmentObject var model: DeskModel
    let preview: ConfigPreview
    @State private var showYAML = false
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text(preview.action == .preview ? "预览 mihomo 配置" : "确认 mihomo 配置").font(.title2.bold())
            if preview.action != .preview {
                Text(preview.action == .start ? "确认后将通过 macOS 管理员授权保存配置并重启系统代理服务，已有连接会中断。" : "确认后才会将下列配置应用到运行中的 mihomo。")
                    .foregroundStyle(.secondary)
            }
            HStack {
                Text("config.yaml").font(.headline)
                Spacer()
                Text(preview.action == .preview ? "YAML · 当前设置生成的配置" : "YAML · 只读预览 · 实际使用此份配置").font(.caption).foregroundStyle(.secondary)
            }
            ScrollView { Text(model.configurationChanges(preview.settings)).font(.body).textSelection(.enabled).frame(maxWidth: .infinity, alignment: .leading) }.frame(maxHeight: showYAML ? 130 : .infinity)
            Toggle("显示完整 YAML（包含节点凭据）", isOn: $showYAML)
            if showYAML {
            GeometryReader { geometry in
                ScrollView([.vertical, .horizontal]) {
                    Text(String(decoding: preview.config, as: UTF8.self))
                        .font(.system(size: 12, design: .monospaced))
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: true, vertical: true)
                        .textSelection(.enabled)
                        .padding(12)
                        .frame(minWidth: geometry.size.width, alignment: .topLeading)
                }
            }.background(Color(nsColor: .textBackgroundColor)).border(Color.secondary.opacity(0.3))
            } else { Spacer() }
            HStack {
                Button(preview.action == .preview ? "关闭" : "取消") { model.configPreview = nil }.keyboardShortcut(.cancelAction)
                Spacer()
                if preview.action != .preview {
                    Button(preview.action == .start ? "确认并启动" : "确认并应用") { model.confirmConfig(preview) }
                        .buttonStyle(.borderedProminent).disabled(model.busy)
                }
            }
        }.padding(20).frame(width: 760, height: 520)
    }
}

struct RouteMenu: View {
    @EnvironmentObject var model: DeskModel
    let kind: RuleKind
    let value: String
    var isIPv4: Bool { !kind.isProcess && validCIDR(value + "/32") }
    var isIPv6: Bool { !kind.isProcess && validCIDR(value + "/128") }
    var body: some View {
        if !value.isEmpty && !["未知目标", "未知 IP", "未知端口", "未知程序"].contains(value) {
            Section("添加路由规则") {
                if kind.isProcess {
                    Button("进程名称（PROCESS-NAME）") {
                        open(.processName, (value as NSString).lastPathComponent)
                    }
                    if value.hasPrefix("/") {
                        Button("进程路径（PROCESS-PATH）") { open(.processPath, value) }
                    }
                } else if isIPv4 || isIPv6 {
                    Button("目标 IP（\(isIPv4 ? "IP-CIDR /32" : "IP-CIDR6 /128")）") {
                        open(isIPv4 ? .ipCIDR : .ipCIDR6, value + (isIPv4 ? "/32" : "/128"))
                    }
                    Button("目标网段（\(isIPv4 ? "IP-CIDR /24" : "IP-CIDR6 /64")）") {
                        open(isIPv4 ? .ipCIDR : .ipCIDR6, subnet)
                    }
                } else if kind == .destinationPort {
                    Button("目标端口（DST-PORT）") { open(.destinationPort, value) }
                } else if kind == .domain {
                    Button("完整域名（DOMAIN）") { open(.domain, value) }
                    Button("域名后缀（DOMAIN-SUFFIX）") { open(.suffix, value) }
                    Button("域名关键词（DOMAIN-KEYWORD）") { open(.keyword, value) }
                }
            }
        }
    }
    var subnet: String {
        if isIPv4 {
            return value.split(separator: ".").prefix(3).joined(separator: ".") + ".0/24"
        }
        var address = [UInt8](repeating: 0, count: 16)
        let parsed = address.withUnsafeMutableBytes { inet_pton(AF_INET6, value, $0.baseAddress) }
        guard parsed == 1 else { return value + "/64" }
        for index in 8..<16 { address[index] = 0 }
        var buffer = [CChar](repeating: 0, count: Int(INET6_ADDRSTRLEN))
        let converted = address.withUnsafeBytes { inet_ntop(AF_INET6, $0.baseAddress, &buffer, socklen_t(buffer.count)) }
        return (converted == nil ? value : String(cString: buffer)) + "/64"
    }
    func open(_ kind: RuleKind, _ value: String) {
        model.rulePrefill = RouteRule(kind: kind, value: value, node: nil)
    }
}

struct StatisticsView: View {
    @EnvironmentObject var model: DeskModel
    @Environment(\.tableDataReady) private var tableDataReady
    @State private var selection: Set<String> = []
    var activeCounts: [String: Int] { Dictionary(model.connections.map { (model.trafficGrouping.key(for: $0), 1) }, uniquingKeysWith: +) }
    var body: some View {
        let rows = tableDataReady ? model.traffic : []
        let counts = tableDataReady ? activeCounts : [:]
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("流量统计").font(.title2.bold())
                Spacer()
                Picker("统计方式", selection: $model.trafficGrouping) {
                    ForEach(TrafficGrouping.allCases) { grouping in Text(grouping.title).tag(grouping) }
                }.frame(width: 180)
                Picker("时间范围", selection: $model.hours) {
                    Text("最近 24 小时（Last 24 hours）").tag(24); Text("最近 7 天（Last 7 days）").tag(168); Text("最近 30 天（Last 30 days）").tag(720)
                }.frame(width: 220)
            }.pageActions()
            if let sampled = model.lastSample, Date().timeIntervalSince(sampled) > 15 {
                Text("采集已暂停，以下为历史数据。最后采集：" + sampled.formatted(date: .abbreviated, time: .standard))
                    .font(.caption).foregroundStyle(.secondary)
            }
                Table(rows, selection: $selection) {
                    TableColumn(model.trafficGrouping.title) { row in
                        Text(row.domain)
                    }.width(tableColumnWidth(model.trafficGrouping.title, rows.map(\.domain)))
                    TableColumn("程序数") { row in Text(String(row.processCount)) }.width(tableColumnWidth("程序数", rows.map { String($0.processCount) }, numeric: true))
                    TableColumn("出口数") { row in Text(String(row.outboundCount)) }.width(tableColumnWidth("出口数", rows.map { String($0.outboundCount) }, numeric: true))
                    TableColumn("当前连接数") { row in Text(String(counts[row.domain] ?? 0)) }.width(tableColumnWidth("当前连接数", rows.map { String(counts[$0.domain] ?? 0) }, numeric: true))
                    TableColumn("上传") { row in Text(bytes(row.upload)).monospacedDigit() }.width(tableColumnWidth("上传", rows.map { bytes($0.upload) }, numeric: true))
                    TableColumn("下载") { row in Text(bytes(row.download)).monospacedDigit() }.width(tableColumnWidth("下载", rows.map { bytes($0.download) }, numeric: true))
                    TableColumn("总流量") { row in Text(bytes(row.upload + row.download)).monospacedDigit() }.width(tableColumnWidth("总流量", rows.map { bytes($0.upload + $0.download) }, numeric: true))
                }
                .contextMenu(forSelectionType: String.self) { ids in
                    if ids.count == 1, let id = ids.first, let row = model.traffic.first(where: { $0.id == id }) {
                        switch model.trafficGrouping {
                        case .domain: RouteMenu(kind: .domain, value: row.domain)
                        case .process: RouteMenu(kind: row.domain.hasPrefix("/") ? .processPath : .processName, value: row.domain)
                        case .ip: RouteMenu(kind: .ipCIDR, value: row.domain)
                        case .port: RouteMenu(kind: .destinationPort, value: row.domain)
                        }
                    }
                }
                .overlay {
                    if tableDataReady && rows.isEmpty {
                        Text(model.statisticsError.map { "统计不可用：" + $0 } ?? "暂无统计。启动服务后访问网站，数据会自动显示。").foregroundStyle(.secondary).allowsHitTesting(false)
                    }
                }

        }
        .task(id: "\(model.trafficGrouping.rawValue)-\(model.hours)") { await model.refresh() }
    }
}

struct ConnectionsView: View {
    @EnvironmentObject var model: DeskModel
    @Environment(\.tableDataReady) private var tableDataReady
    @State private var detail: Connection?
    var body: some View {
        let rows = tableDataReady ? model.connections : []
        VStack(alignment: .leading, spacing: 12) {
            Text("活动连接").font(.title2.bold())
            Table(rows) {
                TableColumn("域名 / IP") { connection in
                    Text(connection.domain).textSelection(.enabled).contextMenu { RouteMenu(kind: .domain, value: connection.domain) }
                }.width(tableColumnWidth("域名 / IP", rows.map(\.domain)))
                TableColumn("程序") { connection in
                    Text(connection.process).help(connection.process).contextMenu {
                        if connection.process != "未知程序" {
                            RouteMenu(kind: connection.process.hasPrefix("/") ? .processPath : .processName, value: connection.process)
                        }
                    }
                }.width(tableColumnWidth("程序", rows.map(\.process)))
                TableColumn("协议") { connection in Text(connection.metadata.network ?? "—") }.width(tableColumnWidth("协议", rows.map { $0.metadata.network ?? "—" }))
                TableColumn("出口") { connection in Text(connection.outbound) }.width(tableColumnWidth("出口", rows.map(\.outbound)))
                TableColumn("上传") { connection in Text(bytes(connection.upload)) }.width(tableColumnWidth("上传", rows.map { bytes($0.upload) }, numeric: true))
                TableColumn("下载") { connection in Text(bytes(connection.download)) }.width(tableColumnWidth("下载", rows.map { bytes($0.download) }, numeric: true))
                TableColumn("操作") { connection in
                    HStack {
                        Button("详情") { detail = connection }
                        Button("断开") { model.perform { try await model.api.closeConnection(connection.id) } }
                    }
                        .disabled(model.busy)
                }.width(tableColumnWidth("操作", rows.isEmpty ? [] : ["断开"], padding: 42))
            }
        }.sheet(item: $detail) { ConnectionDetailView(connection: $0) }
    }
}
