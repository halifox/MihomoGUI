import SwiftUI
import AppKit
import ClashCore

struct ConnectionsView: View {
    @State private var selection: String?
    @State private var search = ""
    @State private var details: Connection?
    @State private var confirmingCloseAll = false
    @State private var closing = false
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
        case "下载速度": return model.connectionSpeedsAvailable ? bytes(row.downloadSpeed) + "/s" : "—"
        case "上传速度": return model.connectionSpeedsAvailable ? bytes(row.uploadSpeed) + "/s" : "—"
        case "链路": return connectionChain(row, proxyNames: model.connectionProxyNames)
        case "规则": return connectionRule(row)
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
    var filteredRows: [Connection] {
        model.connections.filter { row in
            guard !search.isEmpty else { return true }
            let fields = [row.domain, row.process, row.metadata.sourceIP ?? "", row.metadata.destinationIP ?? "", value(row, "规则"), value(row, "链路"), row.metadata.destinationPort ?? ""]
            return fields.contains { $0.localizedCaseInsensitiveContains(search) }
        }
    }
    var body: some View {
        let rows = filteredRows
        Table(rows.sorted(using: sortOrder), selection: $selection, sortOrder: tableSortBinding($sortOrder)) {
            TableColumnBuilder<Connection, TableSort<Connection>>.buildBlock(
            TableColumn("主机", sortUsing: columnSort("主机")) { row in Text(value(row, "主机")).help(value(row, "主机")) }.width(min: 40, ideal: tableColumnWidth("主机", rows.map { value($0, "主机") }), max: nil),
            TableColumn("下载量", sortUsing: columnSort("下载量")) { row in TableUnitValue(text: value(row, "下载量")).help(value(row, "下载量")) }.width(min: 40, ideal: tableColumnWidth("下载量", rows.map { value($0, "下载量") }, numeric: true, unitSample: "MB"), max: nil),
            TableColumn("上传量", sortUsing: columnSort("上传量")) { row in TableUnitValue(text: value(row, "上传量")).help(value(row, "上传量")) }.width(min: 40, ideal: tableColumnWidth("上传量", rows.map { value($0, "上传量") }, numeric: true, unitSample: "MB"), max: nil),
            TableColumn("下载速度", sortUsing: columnSort("下载速度")) { row in TableUnitValue(text: value(row, "下载速度"), unitSample: "MB/s").help(value(row, "下载速度")) }.width(min: 40, ideal: tableColumnWidth("下载速度", rows.map { value($0, "下载速度") }, numeric: true, unitSample: "MB/s"), max: nil),
            TableColumn("上传速度", sortUsing: columnSort("上传速度")) { row in TableUnitValue(text: value(row, "上传速度"), unitSample: "MB/s").help(value(row, "上传速度")) }.width(min: 40, ideal: tableColumnWidth("上传速度", rows.map { value($0, "上传速度") }, numeric: true, unitSample: "MB/s"), max: nil),
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
        .contextMenu(forSelectionType: String.self) { ids in
            if let id = ids.first, let row = rows.first(where: { $0.id == id }) {
                Button("查看详情") { details = row }
                Button("复制连接详情") { copyDetails(row) }
                Button("关闭连接") { closeConnection(row.id) }
                    .disabled(!canClose(row.id))
                connectionRoutes(row).disabled(model.busy)
            }
        } primaryAction: { ids in
            if let id = ids.first, let row = rows.first(where: { $0.id == id }) { details = row }
        }
        .sheet(item: $details) { row in connectionDetail(row) }
        .alert("关闭所有连接？", isPresented: $confirmingCloseAll) {
            Button("取消", role: .cancel) {}
            Button("关闭所有连接", role: .destructive) { closeAllConnections() }
        } message: {
            Text("将关闭执行时的全部活动连接（当前 \(model.connections.count) 条），包括未显示的连接。应用可能自动重新建立连接。")
        }
        .safeAreaInset(edge: .top, spacing: 0) {
            if let error = model.connectionsError, !model.connections.isEmpty {
                Text(error + "；当前显示上次成功读取的数据。")
                    .font(.caption).foregroundStyle(.orange).textSelection(.enabled)
                    .padding(8).frame(maxWidth: .infinity, alignment: .leading).background(.bar)
            }
        }
        .overlay {
            if rows.isEmpty {
                if !model.connectionsLoaded {
                    ProgressView("正在读取连接…")
                } else if model.connectionsError != nil || !model.connections.isEmpty {
                    Text(model.connectionsError ?? "没有符合筛选条件的连接")
                        .foregroundStyle(.secondary).allowsHitTesting(false)
                }
            }
        }
        .background(TableColumnAutoFit(widths: ["主机", "下载量", "上传量", "下载速度", "上传速度", "链路", "规则", "进程", "连接时间", "源地址", "目标地址", "类型"].map { column in
            tableColumnWidth(column, rows.map { value($0, column) },
                             numeric: ["下载量", "上传量", "下载速度", "上传速度"].contains(column),
                             unitSample: ["下载速度", "上传速度"].contains(column) ? "MB/s"
                                : ["下载量", "上传量"].contains(column) ? "MB" : nil)
        }))
        .searchable(text: $search, placement: .toolbar, prompt: "搜索连接")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    confirmingCloseAll = true
                } label: {
                    Label {
                        Text("关闭所有连接")
                    } icon: {
                        if closing { ProgressView().controlSize(.small) }
                        else { Image(systemName: "xmark.circle.fill") }
                    }
                }
                .accessibilityLabel("关闭所有连接")
                .help("关闭全部活动连接，包括未显示的连接")
                .disabled(model.busy || model.connections.isEmpty || model.connectionsError != nil)
                .labelStyle(.iconOnly)
            }
        }
    }
    @ViewBuilder func connectionRoutes(_ row: Connection) -> some View {
        Menu { RouteMenu(kind: .domain, value: row.domain) } label: { Label("按域名 / IP 添加规则", systemImage: "globe") }
        if let ip = row.metadata.destinationIP, ip != row.domain, quickRouteRule(kind: .ipCIDR, value: ip) != nil {
            Menu { RouteMenu(kind: .ipCIDR, value: ip) } label: { Label("按实际目标 IP 添加规则", systemImage: "network") }
        }
        if let port = row.metadata.destinationPort, !port.isEmpty {
            Menu { RouteMenu(kind: .destinationPort, value: port) } label: { Label("按目标端口添加规则", systemImage: "number") }
        }
        if let source = row.metadata.sourceIP, validCIDR(source + "/32") || validCIDR(source + "/128") {
            Menu { RouteMenu(kind: .sourceCIDR, value: source) } label: { Label("按来源设备添加规则", systemImage: "desktopcomputer") }
        }
        if !row.process.isEmpty, row.process != "未知程序" {
            Menu { RouteMenu(kind: row.process.hasPrefix("/") ? .processPath : .processName, value: row.process) } label: { Label("按程序添加规则", systemImage: "app") }
            if let rule = combinedRule(row, withPort: false) {
                Button("按进程＋域名添加规则") { model.rulePrefill = rule }
            }
            if let rule = combinedRule(row, withPort: true) {
                Button("按进程＋目标端口添加规则") { model.rulePrefill = rule }
            }
        }
    }
    func canClose(_ id: String?) -> Bool {
        !model.busy && model.connectionsError == nil && model.connections.contains { $0.id == id }
    }
    func closeConnection(_ id: String) {
        guard canClose(id) else { return }
        closing = true
        model.perform {
            defer { closing = false }
            try await model.api.closeConnection(id)
        }
    }
    func closeAllConnections() {
        guard !model.busy, model.connectionsError == nil else { return }
        closing = true
        model.perform {
            defer { closing = false }
            try await model.api.closeAllConnections()
        }
    }
    func combinedRule(_ row: Connection, withPort: Bool) -> RouteRule? {
        let processKind: RuleKind = row.process.hasPrefix("/") ? .processPath : .processName
        let other = withPort ? row.metadata.destinationPort : row.metadata.host
        guard !row.process.isEmpty, row.process != "未知程序", let other, !other.isEmpty,
              ![row.process, other].contains(where: { $0.contains(",") || $0.unicodeScalars.contains(where: CharacterSet.controlCharacters.contains) }) else { return nil }
        for text in [row.process, other] {
            var depth = 0
            for character in text {
                if character == "(" { depth += 1 }
                if character == ")" { depth -= 1 }
                if depth < 0 { return nil }
            }
            if depth != 0 { return nil }
        }
        let kind: RuleKind = withPort ? .destinationPort : .domain
        guard (try? validateRule(RouteRule(kind: processKind, value: row.process, node: nil), settings: model.settings)) != nil,
              (try? validateRule(RouteRule(kind: kind, value: other, node: nil), settings: model.settings)) != nil else { return nil }
        return RouteRule(kind: .and, value: "((\(processKind.rawValue),\(row.process)),(\(kind.rawValue),\(other)))", node: nil)
    }
    func detailText(_ row: Connection) -> String {
        (["主机", "下载量", "上传量", "下载速度", "上传速度", "链路", "规则", "进程", "源地址", "目标地址", "类型"].map {
            $0 + "：" + value(row, $0)
        } + ["连接时间：" + (row.start ?? "—"), "连接 ID：" + row.id]).joined(separator: "\n")
    }
    func copyDetails(_ row: Connection) {
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(detailText(row), forType: .string)
    }
    func connectionDetail(_ row: Connection) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("连接详情").font(.title2.bold())
            Text("打开时的连接快照；可选中文本复制。").font(.caption).foregroundStyle(.secondary)
            ScrollView {
                Text(detailText(row)).textSelection(.enabled).frame(maxWidth: .infinity, alignment: .leading)
            }
            HStack {
                Button("复制全部") { copyDetails(row) }
                Spacer()
                Button("完成") { details = nil }.keyboardShortcut(.cancelAction)
            }
        }.padding(16).frame(minWidth: 520, idealWidth: 640, minHeight: 360, idealHeight: 460)
    }

}
