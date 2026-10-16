import SwiftUI
import AppKit
import ClashCore

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
            .overlay {
                if rows.isEmpty {
                    Text(model.connectionsError ?? "暂无活动连接")
                        .foregroundStyle(.secondary).allowsHitTesting(false)
                }
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
