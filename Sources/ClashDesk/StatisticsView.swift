import SwiftUI
import ClashCore

struct StatisticsView: View {
    @State private var sortOrder: [TableSort<DomainTrafficRow>] = []
    @EnvironmentObject var model: DeskModel
    @State private var selection: Set<String> = []
    func trafficShare(_ row: DomainTrafficRow) -> String {
        guard row.totalTraffic > 0 else { return "0.00%" }
        let share = Double(row.upload + row.download) / Double(row.totalTraffic) * 100
        return String(format: "%.2f%%", share)
    }
    func columnSort(_ column: String) -> TableSort<DomainTrafficRow> {
        switch column {
        case "程序数": return TableSort(column) { $0.processCount }
        case "域名数": return TableSort(column) { $0.domainCount }
        case "目标 IP 数": return TableSort(column) { $0.ipCount }
        case "出口数": return TableSort(column) { $0.outboundCount }
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
        Table(rows.sorted(using: currentSort), selection: $selection, sortOrder: tableSortBinding($sortOrder)) {
            TableColumn(model.trafficGrouping.title, sortUsing: columnSort(model.trafficGrouping.title)) { row in Text(row.domain).monospacedDigit() }.width(min: 40, ideal: tableColumnWidth(model.trafficGrouping.title, rows.map { row in row.domain }, numeric: false), max: nil)
            TableColumn("下载量", sortUsing: columnSort("下载量")) { row in Text(bytes(row.download)).monospacedDigit() }.width(min: 40, ideal: tableColumnWidth("下载量", rows.map { row in bytes(row.download) }, numeric: true), max: nil)
            TableColumn("上传量", sortUsing: columnSort("上传量")) { row in Text(bytes(row.upload)).monospacedDigit() }.width(min: 40, ideal: tableColumnWidth("上传量", rows.map { row in bytes(row.upload) }, numeric: true), max: nil)
            TableColumn("总流量", sortUsing: columnSort("总流量")) { row in Text(bytes(row.upload + row.download)).monospacedDigit() }.width(min: 40, ideal: tableColumnWidth("总流量", rows.map { row in bytes(row.upload + row.download) }, numeric: true), max: nil)
            TableColumn("流量占比", sortUsing: columnSort("流量占比")) { row in Text(trafficShare(row)).monospacedDigit() }.width(min: 40, ideal: tableColumnWidth("流量占比", rows.map { row in trafficShare(row) }, numeric: true), max: nil)
            TableColumn(model.trafficGrouping == .process ? "域名数" : "程序数", sortUsing: columnSort(model.trafficGrouping == .process ? "域名数" : "程序数")) { row in Text(String(model.trafficGrouping == .process ? row.domainCount : row.processCount)).monospacedDigit() }.width(min: 40, ideal: tableColumnWidth(model.trafficGrouping == .process ? "域名数" : "程序数", rows.map { row in String(model.trafficGrouping == .process ? row.domainCount : row.processCount) }, numeric: true), max: nil)
            TableColumn("目标 IP 数", sortUsing: columnSort("目标 IP 数")) { row in Text(String(row.ipCount)).monospacedDigit() }.width(min: 40, ideal: tableColumnWidth("目标 IP 数", rows.map { row in String(row.ipCount) }, numeric: true), max: nil)
            TableColumn("出口数", sortUsing: columnSort("出口数")) { row in Text(String(row.outboundCount)).monospacedDigit() }.width(min: 40, ideal: tableColumnWidth("出口数", rows.map { row in String(row.outboundCount) }, numeric: true), max: nil)
        }
        .overlay {
            if rows.isEmpty {
                Text(model.statisticsError.map { "统计不可用：" + $0 } ?? "暂无统计。启动服务后访问网站，数据会自动显示。")
                    .foregroundStyle(.secondary).allowsHitTesting(false)
            }
        }
        .toolbar {
            ToolbarItemGroup(placement: .primaryAction) {
                Picker("统计方式", selection: $model.trafficGrouping) {
                    Text("域名统计").tag(TrafficGrouping.domain)
                    Text("进程统计").tag(TrafficGrouping.process)
                }
                .pickerStyle(.menu)
                .labelsHidden()
                .fixedSize()
                .help("统计方式")

                Picker("时间范围", selection: $model.hours) {
                    Text("最近 24 小时").tag(24)
                    Text("最近 7 天").tag(168)
                    Text("最近 30 天").tag(720)
                }
                .pickerStyle(.menu)
                .labelsHidden()
                .fixedSize()
                .help("时间范围")

                Menu {
                    if let row = rows.first(where: { selection.contains($0.id) }) { trafficRoutes(row) }
                } label: { toolbarIcon("添加路由规则", systemImage: "plus") }
                .menuStyle(.borderedButton)
                .menuIndicator(.hidden)
                .disabled(selection.count != 1 || model.busy)
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
