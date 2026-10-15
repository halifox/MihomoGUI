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
        .windowToolbarStyle(.unified)
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
                      padding: CGFloat = 0) -> CGFloat {
    let font = monospaced ? NSFont.monospacedSystemFont(ofSize: NSFont.systemFontSize, weight: .regular)
        : numeric ? NSFont.monospacedDigitSystemFont(ofSize: NSFont.systemFontSize, weight: .regular)
        : NSFont.systemFont(ofSize: NSFont.systemFontSize)
    let header = (title as NSString).size(withAttributes: [.font: NSFont.systemFont(ofSize: NSFont.systemFontSize, weight: .semibold)]).width
    let content = values.lazy.flatMap { $0.components(separatedBy: .newlines) }
        .map { ($0 as NSString).size(withAttributes: [.font: font]).width }.max() ?? 0
    // Keep room for the header's sort indicator without padding every cell as much.
    return ceil(max(header + 24, content + padding))
}

// Use the same full-data measurements for initial sizing and divider double-clicks.
struct TableColumnAutoFit: NSViewRepresentable {
    var widths: [CGFloat]
    func makeNSView(context: Context) -> TableColumnAutoFitView { TableColumnAutoFitView() }
    func updateNSView(_ view: TableColumnAutoFitView, context: Context) { view.widths = widths }
    static func dismantleNSView(_ view: TableColumnAutoFitView, coordinator: ()) { view.stopMonitoring() }
}

final class TableColumnAutoFitView: NSView {
    var widths: [CGFloat] = []
    private var monitor: Any?
    override func hitTest(_ point: NSPoint) -> NSView? { nil }
    override func viewDidMoveToWindow() {
        super.viewDidMoveToWindow()
        stopMonitoring()
        guard window != nil else { return }
        monitor = NSEvent.addLocalMonitorForEvents(matching: .leftMouseDown) { [weak self] event in
            guard let self else { return event }
            return self.handleMouseDown(event)
        }
    }
    // Header decorations can receive hit tests instead of NSTableHeaderView itself.
    // Resolve the actual table from our shared SwiftUI container instead.
    func tableView(in view: NSView) -> NSTableView? {
        if let table = view as? NSTableView { return table }
        for child in view.subviews {
            if let table = tableView(in: child) { return table }
        }
        return nil
    }
    func handleMouseDown(_ event: NSEvent) -> NSEvent? {
        guard event.clickCount == 2, let window, event.window === window else { return event }
        return fitColumn(at: event.locationInWindow) ? nil : event
    }
    func fitColumn(at location: NSPoint) -> Bool {
        var ancestor = superview
        while let container = ancestor {
            if let table = tableView(in: container), let header = table.headerView,
               table.tableColumns.count == widths.count {
                let point = header.convert(location, from: nil)
                guard header.visibleRect.contains(point) else { return false }
                for index in table.tableColumns.indices {
                    let rect = header.headerRect(ofColumn: index)
                    let edge = table.userInterfaceLayoutDirection == .rightToLeft ? rect.minX : rect.maxX
                    guard abs(point.x - edge) <= 4 else { continue }
                    let column = table.tableColumns[index]
                    column.width = min(column.maxWidth, max(column.minWidth, widths[index]))
                    return true
                }
                return false
            }
            ancestor = container.superview
        }
        return false
    }
    func stopMonitoring() {
        if let monitor { NSEvent.removeMonitor(monitor) }
        monitor = nil
    }
    deinit { stopMonitoring() }
}

// Compare underlying values so byte counts, dates and delays sort numerically.
struct TableSort<Row>: SortComparator {
    var order: SortOrder = .forward
    let column: String
    private let comparison: (Row, Row) -> ComparisonResult
    init<Value: Comparable>(_ column: String, value: @escaping (Row) -> Value) {
        self.column = column
        comparison = { lhs, rhs in
            let a = value(lhs), b = value(rhs)
            return a < b ? .orderedAscending : a > b ? .orderedDescending : .orderedSame
        }
    }
    func compare(_ lhs: Row, _ rhs: Row) -> ComparisonResult {
        let result = comparison(lhs, rhs)
        return order == .forward ? result : result == .orderedAscending ? .orderedDescending : result == .orderedDescending ? .orderedAscending : .orderedSame
    }
    static func == (lhs: Self, rhs: Self) -> Bool { lhs.column == rhs.column && lhs.order == rhs.order }
    func hash(into hasher: inout Hasher) { hasher.combine(column); hasher.combine(order) }
}

// Keep a single active column and cycle ascending → descending → original row order.
func tableSortBinding<Row>(_ state: Binding<[TableSort<Row>]>) -> Binding<[TableSort<Row>]> {
    Binding(get: { state.wrappedValue }, set: { proposed in
        guard var next = proposed.first else {
            state.wrappedValue = []
            return
        }
        if let current = state.wrappedValue.first, current.column == next.column {
            if current.order == .reverse {
                state.wrappedValue = []
                return
            }
            next.order = .reverse
        } else {
            next.order = .forward
        }
        state.wrappedValue = [next]
    })
}

enum DeskPage: Int, CaseIterable, Identifiable {
    case general, subscriptions, outbound, groups, ruleSets, rules, connections, traffic, settings
    var id: Int { rawValue }
    var title: String { ["全局配置", "代理订阅", "出站代理", "代理分组", "规则集合", "路由规则", "活动连接", "流量统计", "应用设置"][rawValue] }
    var icon: String { ["slider.horizontal.3", "link", "network", "square.stack.3d.up", "folder", "list.bullet.rectangle", "arrow.left.arrow.right", "chart.bar", "gearshape"][rawValue] }
}

struct DeskView: View {
    @EnvironmentObject var model: DeskModel
    @State private var page: DeskPage? = .general
    var body: some View {
        VStack(spacing: 0) {
            NavigationSplitView {
                List(DeskPage.allCases, selection: $page) { page in
                    Label(page.title, systemImage: page.icon).tag(page)
                }.listStyle(.sidebar)
                    .navigationSplitViewColumnWidth(min: 170, ideal: 190, max: 230)
            } detail: {
                Group {
                    switch page ?? .general {
                    case .general: GeneralConfigurationView()
                    case .subscriptions: SubscriptionsView()
                    case .outbound: OutboundProxiesView()
                    case .groups: ResourcesView(groups: true)
                    case .ruleSets: ResourcesView(groups: false).disabled(model.busy || model.configurationLocked)
                    case .rules: RulesView()
                    case .connections: ConnectionsView()
                    case .traffic: StatisticsView()
                    case .settings: ApplicationSettingsView()
                    }
                }.navigationTitle((page ?? .general).title)
                    .tableStyle(.inset(alternatesRowBackgrounds: true))
                    .id(page ?? .general)
            }

        }
        .onReceive(NotificationCenter.default.publisher(for: NSApplication.willTerminateNotification)) { _ in model.flushConfigurationSave() }
        .onDisappear { model.flushConfigurationSave() }
        .alert("操作未完成", isPresented: Binding(get: { model.error != nil }, set: { if !$0 { model.error = nil } })) {
            Button("确定") { model.error = nil }
        } message: { Text(model.error ?? "") }
        .sheet(isPresented: Binding(get: { model.serviceLogs != nil }, set: { if !$0 { model.serviceLogs = nil } })) {
            VStack(alignment: .leading) {
                Text("内核日志 · core.log").font(.title2)
                ScrollView { Text(model.serviceLogs ?? "").font(.system(.body, design: .monospaced)).textSelection(.enabled).frame(maxWidth: .infinity, alignment: .leading) }
                Button("关闭") { model.serviceLogs = nil }.keyboardShortcut(.cancelAction)
            }.padding(20).frame(width: 760, height: 520)
        }
        .sheet(item: $model.rulePrefill) { prefill in
            RuleEditorView(prefill: prefill)
        }

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
                    Button {
                        open(.processName, (value as NSString).lastPathComponent)
                    } label: { Label("进程名称（PROCESS-NAME）", systemImage: "app") }
                    if value.hasPrefix("/") {
                        Button { open(.processPath, value) } label: { Label("进程路径（PROCESS-PATH）", systemImage: "folder") }
                    }
                } else if isIPv4 || isIPv6 {
                    Button {
                        open(isIPv4 ? .ipCIDR : .ipCIDR6, value + (isIPv4 ? "/32" : "/128"))
                    } label: { Label("目标 IP（\(isIPv4 ? "IP-CIDR /32" : "IP-CIDR6 /128")）", systemImage: "network") }
                    Button {
                        open(isIPv4 ? .ipCIDR : .ipCIDR6, subnet)
                    } label: { Label("目标网段（\(isIPv4 ? "IP-CIDR /24" : "IP-CIDR6 /64")）", systemImage: "network") }
                } else if kind == .destinationPort {
                    Button { open(.destinationPort, value) } label: { Label("目标端口（DST-PORT）", systemImage: "number") }
                } else if kind == .domain {
                    Button { open(.domain, value) } label: { Label("完整域名（DOMAIN）", systemImage: "globe") }
                    Button { open(.suffix, value) } label: { Label("域名后缀（DOMAIN-SUFFIX）", systemImage: "text.end") }
                    Button { open(.keyword, value) } label: { Label("域名关键词（DOMAIN-KEYWORD）", systemImage: "text.magnifyingglass") }
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
    @State private var sortOrder: [TableSort<DomainTrafficRow>] = []
    @EnvironmentObject var model: DeskModel
    @State private var selection: Set<String> = []
    var activeCounts: [String: Int] { Dictionary(model.connections.map { (model.trafficGrouping.key(for: $0), 1) }, uniquingKeysWith: +) }
    func trafficShare(_ row: DomainTrafficRow) -> String {
        guard row.totalTraffic > 0 else { return "0.00%" }
        let share = Double(row.upload + row.download) / Double(row.totalTraffic) * 100
        return String(format: "%.2f%%", share)
    }
    var liveSpeeds: [String: (download: Int64, upload: Int64)] {
        var result: [String: (download: Int64, upload: Int64)] = [:]
        for connection in model.connections {
            let key = model.trafficGrouping.key(for: connection)
            let previous = result[key] ?? (0, 0)
            result[key] = (previous.download + connection.downloadSpeed, previous.upload + connection.uploadSpeed)
        }
        return result
    }
    func columnSort(_ column: String) -> TableSort<DomainTrafficRow> {
        let counts = activeCounts
        let speeds = liveSpeeds
        switch column {
        case "程序数": return TableSort(column) { $0.processCount }
        case "域名数": return TableSort(column) { $0.domainCount }
        case "目标 IP 数": return TableSort(column) { $0.ipCount }
        case "出口数": return TableSort(column) { $0.outboundCount }
        case "当前连接数": return TableSort(column) { counts[$0.domain] ?? 0 }
        case "当前下载速度": return TableSort(column) { speeds[$0.domain]?.download ?? 0 }
        case "当前上传速度": return TableSort(column) { speeds[$0.domain]?.upload ?? 0 }
        case "上传量": return TableSort(column) { $0.upload }
        case "下载量": return TableSort(column) { $0.download }
        case "总流量", "流量占比": return TableSort(column) { $0.upload + $0.download }
        default: return TableSort(column) { $0.domain }
        }
    }
    var body: some View {
        let currentSort = sortOrder.map { descriptor in
            var comparator = columnSort(descriptor.column)
            comparator.order = descriptor.order
            return comparator
        }
        let rows = model.traffic
        let counts = activeCounts
        let speeds = liveSpeeds
        VStack(alignment: .leading, spacing: 0) {
            if let sampled = model.lastSample, Date().timeIntervalSince(sampled) > 15 {
                Text("采集已暂停，以下为历史数据。最后采集：" + sampled.formatted(date: .abbreviated, time: .standard))
                    .font(.caption).foregroundStyle(.secondary).padding(8)
            }
            Group {
                if model.trafficGrouping == .ip {
                Table(rows.sorted(using: currentSort), selection: $selection, sortOrder: tableSortBinding($sortOrder)) {
                    TableColumnBuilder<DomainTrafficRow, TableSort<DomainTrafficRow>>.buildBlock(
                        TableColumn(model.trafficGrouping.title, sortUsing: columnSort(model.trafficGrouping.title)) { row in Text(row.domain).monospacedDigit() }.width(min: 40, ideal: tableColumnWidth(model.trafficGrouping.title, rows.map { row in row.domain }, numeric: false), max: nil),
                        TableColumn("下载量", sortUsing: columnSort("下载量")) { row in Text(bytes(row.download)).monospacedDigit() }.width(min: 40, ideal: tableColumnWidth("下载量", rows.map { row in bytes(row.download) }, numeric: true), max: nil),
                        TableColumn("上传量", sortUsing: columnSort("上传量")) { row in Text(bytes(row.upload)).monospacedDigit() }.width(min: 40, ideal: tableColumnWidth("上传量", rows.map { row in bytes(row.upload) }, numeric: true), max: nil),
                        TableColumn("总流量", sortUsing: columnSort("总流量")) { row in Text(bytes(row.upload + row.download)).monospacedDigit() }.width(min: 40, ideal: tableColumnWidth("总流量", rows.map { row in bytes(row.upload + row.download) }, numeric: true), max: nil),
                        TableColumn("流量占比", sortUsing: columnSort("流量占比")) { row in Text(trafficShare(row)).monospacedDigit() }.width(min: 40, ideal: tableColumnWidth("流量占比", rows.map { row in trafficShare(row) }, numeric: true), max: nil),
                        TableColumn("当前下载速度", sortUsing: columnSort("当前下载速度")) { row in Text(model.connectionSpeedsAvailable ? bytes(speeds[row.domain]?.download ?? 0) + "/s" : "—").monospacedDigit() }.width(min: 40, ideal: tableColumnWidth("当前下载速度", rows.map { row in model.connectionSpeedsAvailable ? bytes(speeds[row.domain]?.download ?? 0) + "/s" : "—" }, numeric: true), max: nil)
                    )
                    TableColumnBuilder<DomainTrafficRow, TableSort<DomainTrafficRow>>.buildBlock(
                        TableColumn("当前上传速度", sortUsing: columnSort("当前上传速度")) { row in Text(model.connectionSpeedsAvailable ? bytes(speeds[row.domain]?.upload ?? 0) + "/s" : "—").monospacedDigit() }.width(min: 40, ideal: tableColumnWidth("当前上传速度", rows.map { row in model.connectionSpeedsAvailable ? bytes(speeds[row.domain]?.upload ?? 0) + "/s" : "—" }, numeric: true), max: nil),
                        TableColumn("当前连接数", sortUsing: columnSort("当前连接数")) { row in Text(model.coreRunning ? String(counts[row.domain] ?? 0) : "—").monospacedDigit() }.width(min: 40, ideal: tableColumnWidth("当前连接数", rows.map { row in model.coreRunning ? String(counts[row.domain] ?? 0) : "—" }, numeric: true), max: nil),
                        TableColumn(model.trafficGrouping == .process ? "域名数" : "程序数", sortUsing: columnSort(model.trafficGrouping == .process ? "域名数" : "程序数")) { row in Text(String(model.trafficGrouping == .process ? row.domainCount : row.processCount)).monospacedDigit() }.width(min: 40, ideal: tableColumnWidth(model.trafficGrouping == .process ? "域名数" : "程序数", rows.map { row in String(model.trafficGrouping == .process ? row.domainCount : row.processCount) }, numeric: true), max: nil)
                    )

                        TableColumn("出口数", sortUsing: columnSort("出口数")) { row in Text(String(row.outboundCount)).monospacedDigit() }.width(min: 40, ideal: tableColumnWidth("出口数", rows.map { row in String(row.outboundCount) }, numeric: true), max: nil)
                }
                } else {
                Table(rows.sorted(using: currentSort), selection: $selection, sortOrder: tableSortBinding($sortOrder)) {
                    TableColumnBuilder<DomainTrafficRow, TableSort<DomainTrafficRow>>.buildBlock(
                        TableColumn(model.trafficGrouping.title, sortUsing: columnSort(model.trafficGrouping.title)) { row in Text(row.domain).monospacedDigit() }.width(min: 40, ideal: tableColumnWidth(model.trafficGrouping.title, rows.map { row in row.domain }, numeric: false), max: nil),
                        TableColumn("下载量", sortUsing: columnSort("下载量")) { row in Text(bytes(row.download)).monospacedDigit() }.width(min: 40, ideal: tableColumnWidth("下载量", rows.map { row in bytes(row.download) }, numeric: true), max: nil),
                        TableColumn("上传量", sortUsing: columnSort("上传量")) { row in Text(bytes(row.upload)).monospacedDigit() }.width(min: 40, ideal: tableColumnWidth("上传量", rows.map { row in bytes(row.upload) }, numeric: true), max: nil),
                        TableColumn("总流量", sortUsing: columnSort("总流量")) { row in Text(bytes(row.upload + row.download)).monospacedDigit() }.width(min: 40, ideal: tableColumnWidth("总流量", rows.map { row in bytes(row.upload + row.download) }, numeric: true), max: nil),
                        TableColumn("流量占比", sortUsing: columnSort("流量占比")) { row in Text(trafficShare(row)).monospacedDigit() }.width(min: 40, ideal: tableColumnWidth("流量占比", rows.map { row in trafficShare(row) }, numeric: true), max: nil),
                        TableColumn("当前下载速度", sortUsing: columnSort("当前下载速度")) { row in Text(model.connectionSpeedsAvailable ? bytes(speeds[row.domain]?.download ?? 0) + "/s" : "—").monospacedDigit() }.width(min: 40, ideal: tableColumnWidth("当前下载速度", rows.map { row in model.connectionSpeedsAvailable ? bytes(speeds[row.domain]?.download ?? 0) + "/s" : "—" }, numeric: true), max: nil)
                    )
                    TableColumnBuilder<DomainTrafficRow, TableSort<DomainTrafficRow>>.buildBlock(
                        TableColumn("当前上传速度", sortUsing: columnSort("当前上传速度")) { row in Text(model.connectionSpeedsAvailable ? bytes(speeds[row.domain]?.upload ?? 0) + "/s" : "—").monospacedDigit() }.width(min: 40, ideal: tableColumnWidth("当前上传速度", rows.map { row in model.connectionSpeedsAvailable ? bytes(speeds[row.domain]?.upload ?? 0) + "/s" : "—" }, numeric: true), max: nil),
                        TableColumn("当前连接数", sortUsing: columnSort("当前连接数")) { row in Text(model.coreRunning ? String(counts[row.domain] ?? 0) : "—").monospacedDigit() }.width(min: 40, ideal: tableColumnWidth("当前连接数", rows.map { row in model.coreRunning ? String(counts[row.domain] ?? 0) : "—" }, numeric: true), max: nil),
                        TableColumn(model.trafficGrouping == .process ? "域名数" : "程序数", sortUsing: columnSort(model.trafficGrouping == .process ? "域名数" : "程序数")) { row in Text(String(model.trafficGrouping == .process ? row.domainCount : row.processCount)).monospacedDigit() }.width(min: 40, ideal: tableColumnWidth(model.trafficGrouping == .process ? "域名数" : "程序数", rows.map { row in String(model.trafficGrouping == .process ? row.domainCount : row.processCount) }, numeric: true), max: nil)
                    )
                        TableColumn("目标 IP 数", sortUsing: columnSort("目标 IP 数")) { row in Text(String(row.ipCount)).monospacedDigit() }.width(min: 40, ideal: tableColumnWidth("目标 IP 数", rows.map { row in String(row.ipCount) }, numeric: true), max: nil)

                        TableColumn("出口数", sortUsing: columnSort("出口数")) { row in Text(String(row.outboundCount)).monospacedDigit() }.width(min: 40, ideal: tableColumnWidth("出口数", rows.map { row in String(row.outboundCount) }, numeric: true), max: nil)
                }
                }
            }
                .overlay {
                    if rows.isEmpty {
                        Text(model.statisticsError.map { "统计不可用：" + $0 } ?? "暂无统计。启动服务后访问网站，数据会自动显示。").foregroundStyle(.secondary).allowsHitTesting(false)
                    }
                }

        }
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                HStack(spacing: 4) {
                    Menu {
                        if let row = rows.first(where: { selection.contains($0.id) }) { trafficRoutes(row) }
                    } label: { toolbarIcon("添加路由规则", systemImage: "plus.circle") }
                    .menuStyle(.borderedButton)
                    .menuIndicator(.hidden)
                    .frame(width: 28, height: 28).disabled(selection.count != 1 || model.busy)
                    Picker("统计方式", selection: $model.trafficGrouping) {
                        ForEach(TrafficGrouping.allCases) { grouping in Text(grouping.title).tag(grouping) }
                    }.labelsHidden().frame(width: 110).help("统计方式")
                    Picker("时间范围", selection: $model.hours) {
                        Text("最近 24 小时").tag(24); Text("最近 7 天").tag(168); Text("最近 30 天").tag(720)
                    }.labelsHidden().frame(width: 125).help("时间范围")
                }
                .buttonStyle(.bordered)
                .controlSize(.regular)
                .padding(.horizontal, 4)
                .padding(.vertical, 2)
            }
        }
        .task(id: "\(model.trafficGrouping.rawValue)-\(model.hours)") { await model.refresh() }
    }
    @ViewBuilder func trafficRoutes(_ row: DomainTrafficRow) -> some View {
        switch model.trafficGrouping {
        case .domain: RouteMenu(kind: .domain, value: row.domain)
        case .process: RouteMenu(kind: row.domain.hasPrefix("/") ? .processPath : .processName, value: row.domain)
        case .ip: RouteMenu(kind: .ipCIDR, value: row.domain)
        case .port: RouteMenu(kind: .destinationPort, value: row.domain)
        }
    }

}

struct ConnectionsView: View {
    @State private var selection: String?
    @State private var sortOrder: [TableSort<Connection>] = []
    @EnvironmentObject var model: DeskModel
    func address(_ ip: String?, _ port: String?) -> String {
        guard let ip, !ip.isEmpty else { return "—" }
        let host = ip.contains(":") ? "[\(ip)]" : ip
        return port.flatMap { $0.isEmpty ? nil : "\(host):\($0)" } ?? host
    }
    func startDate(_ row: Connection) -> Date? {
        guard let start = row.start else { return nil }
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter.date(from: start) ?? ISO8601DateFormatter().date(from: start)
    }
    func value(_ row: Connection, _ column: String) -> String {
        switch column {
        case "主机": return address(row.domain, row.metadata.destinationPort)
        case "下载量": return bytes(row.download)
        case "上传量": return bytes(row.upload)
        case "下载速度": return bytes(row.downloadSpeed) + "/s"
        case "上传速度": return bytes(row.uploadSpeed) + "/s"
        case "链路": return row.chains?.reversed().joined(separator: " / ") ?? "—"
        case "规则": return row.rule ?? "—"
        case "进程": return row.process
        case "连接时间":
            guard let date = startDate(row) else { return "—" }
            let formatter = RelativeDateTimeFormatter()
            formatter.locale = Locale(identifier: "zh_CN")
            return formatter.localizedString(for: date, relativeTo: Date())
        case "源地址": return address(row.metadata.sourceIP, row.metadata.sourcePort)
        case "目标地址": return address(row.metadata.destinationIP, row.metadata.destinationPort)
        default: return "\(row.metadata.type ?? "—")(\(row.metadata.network ?? "—"))"
        }
    }
    func columnSort(_ column: String) -> TableSort<Connection> {
        switch column {
        case "下载量": return TableSort(column) { $0.download }
        case "上传量": return TableSort(column) { $0.upload }
        case "下载速度": return TableSort(column) { $0.downloadSpeed }
        case "上传速度": return TableSort(column) { $0.uploadSpeed }
        case "连接时间": return TableSort(column) { startDate($0) ?? .distantPast }
        default: return TableSort(column) { value($0, column) }
        }
    }
    var body: some View {
        let rows = model.connections
        VStack(alignment: .leading, spacing: 0) {
            Table(rows.sorted(using: sortOrder), selection: $selection, sortOrder: tableSortBinding($sortOrder)) {
                TableColumnBuilder<Connection, TableSort<Connection>>.buildBlock(
                TableColumn("主机", sortUsing: columnSort("主机")) { row in Text(value(row, "主机")).help(value(row, "主机")) }.width(min: 40, ideal: tableColumnWidth("主机", rows.map { value($0, "主机") }), max: nil),
                TableColumn("下载量", sortUsing: columnSort("下载量")) { row in Text(value(row, "下载量")).help(value(row, "下载量")) }.width(min: 40, ideal: tableColumnWidth("下载量", rows.map { value($0, "下载量") }), max: nil),
                TableColumn("上传量", sortUsing: columnSort("上传量")) { row in Text(value(row, "上传量")).help(value(row, "上传量")) }.width(min: 40, ideal: tableColumnWidth("上传量", rows.map { value($0, "上传量") }), max: nil),
                TableColumn("下载速度", sortUsing: columnSort("下载速度")) { row in Text(value(row, "下载速度")).help(value(row, "下载速度")) }.width(min: 40, ideal: tableColumnWidth("下载速度", rows.map { value($0, "下载速度") }), max: nil),
                TableColumn("上传速度", sortUsing: columnSort("上传速度")) { row in Text(value(row, "上传速度")).help(value(row, "上传速度")) }.width(min: 40, ideal: tableColumnWidth("上传速度", rows.map { value($0, "上传速度") }), max: nil),
                TableColumn("链路", sortUsing: columnSort("链路")) { row in Text(value(row, "链路")).help(value(row, "链路")) }.width(min: 40, ideal: tableColumnWidth("链路", rows.map { value($0, "链路") }), max: nil)
                )
                TableColumnBuilder<Connection, TableSort<Connection>>.buildBlock(
                TableColumn("规则", sortUsing: columnSort("规则")) { row in Text(value(row, "规则")).help(value(row, "规则")) }.width(min: 40, ideal: tableColumnWidth("规则", rows.map { value($0, "规则") }), max: nil),
                TableColumn("进程", sortUsing: columnSort("进程")) { row in Text(value(row, "进程")).help(value(row, "进程")) }.width(min: 40, ideal: tableColumnWidth("进程", rows.map { value($0, "进程") }), max: nil),
                TableColumn("连接时间", sortUsing: columnSort("连接时间")) { row in Text(value(row, "连接时间")).help(value(row, "连接时间")) }.width(min: 40, ideal: tableColumnWidth("连接时间", rows.map { value($0, "连接时间") }), max: nil),
                TableColumn("源地址", sortUsing: columnSort("源地址")) { row in Text(value(row, "源地址")).help(value(row, "源地址")) }.width(min: 40, ideal: tableColumnWidth("源地址", rows.map { value($0, "源地址") }), max: nil),
                TableColumn("目标地址", sortUsing: columnSort("目标地址")) { row in Text(value(row, "目标地址")).help(value(row, "目标地址")) }.width(min: 40, ideal: tableColumnWidth("目标地址", rows.map { value($0, "目标地址") }), max: nil),
                TableColumn("类型", sortUsing: columnSort("类型")) { row in Text(value(row, "类型")).help(value(row, "类型")) }.width(min: 40, ideal: tableColumnWidth("类型", rows.map { value($0, "类型") }), max: nil)
                )
            }
            .background(TableColumnAutoFit(widths: ["主机", "下载量", "上传量", "下载速度", "上传速度", "链路", "规则", "进程", "连接时间", "源地址", "目标地址", "类型"].map { column in
                tableColumnWidth(column, rows.map { value($0, column) })
            }))
        }
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                HStack(spacing: 4) {
                    Button(role: .destructive) {
                        if let selection { model.perform { try await model.api.closeConnection(selection) } }
                    } label: { toolbarIcon("断开", systemImage: "xmark.circle").foregroundStyle(.red) }.frame(width: 28, height: 28).tint(.red).disabled(model.busy || !rows.contains { $0.id == selection })
                    Menu {
                        if let row = rows.first(where: { $0.id == selection }) { connectionRoutes(row) }
                    } label: { toolbarIcon("添加路由规则", systemImage: "plus.circle") }
                    .menuStyle(.borderedButton)
                    .menuIndicator(.hidden)
                    .frame(width: 28, height: 28).disabled(model.busy || !rows.contains { $0.id == selection })
                }
                .buttonStyle(.bordered)
                .controlSize(.regular)
                .padding(.horizontal, 4)
                .padding(.vertical, 2)
            }
        }
    }
    @ViewBuilder func connectionRoutes(_ row: Connection) -> some View {
        Menu { RouteMenu(kind: .domain, value: row.domain) } label: { Label("按域名 / IP 添加规则", systemImage: "globe") }
        if row.process != "未知程序" {
            Menu { RouteMenu(kind: row.process.hasPrefix("/") ? .processPath : .processName, value: row.process) } label: { Label("按程序添加规则", systemImage: "app") }
        }
    }
}
