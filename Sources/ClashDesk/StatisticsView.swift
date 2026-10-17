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
        let widths = [
            tableColumnWidth(model.trafficGrouping.title, rows.map { row in row.domain }, numeric: true),
            tableColumnWidth("下载量", rows.map { row in bytes(row.download) }, numeric: true, unitSample: "MB"),
            tableColumnWidth("上传量", rows.map { row in bytes(row.upload) }, numeric: true, unitSample: "MB"),
            tableColumnWidth("总流量", rows.map { row in bytes(row.upload + row.download) }, numeric: true, unitSample: "MB"),
            tableColumnWidth("流量占比", rows.map { row in trafficShare(row) }, numeric: true, unitSample: "%"),
            tableColumnWidth(model.trafficGrouping == .process ? "域名数" : "程序数", rows.map { row in String(model.trafficGrouping == .process ? row.domainCount : row.processCount) }, numeric: true),
            tableColumnWidth("目标 IP 数", rows.map { row in String(row.ipCount) }, numeric: true),
            tableColumnWidth("出口数", rows.map { row in String(row.outboundCount) }, numeric: true)
        ]
        Table(rows.sorted(using: currentSort), selection: $selection, sortOrder: tableSortBinding($sortOrder)) {
            TableColumn(model.trafficGrouping.title, sortUsing: columnSort(model.trafficGrouping.title)) { row in Text(row.domain).monospacedDigit() }.width(min: 40, ideal: widths[0], max: nil)
            TableColumn("下载量", sortUsing: columnSort("下载量")) { row in TableUnitValue(text: bytes(row.download)) }.width(min: 40, ideal: widths[1], max: nil)
            TableColumn("上传量", sortUsing: columnSort("上传量")) { row in TableUnitValue(text: bytes(row.upload)) }.width(min: 40, ideal: widths[2], max: nil)
            TableColumn("总流量", sortUsing: columnSort("总流量")) { row in TableUnitValue(text: bytes(row.upload + row.download)) }.width(min: 40, ideal: widths[3], max: nil)
            TableColumn("流量占比", sortUsing: columnSort("流量占比")) { row in TableUnitValue(text: trafficShare(row), unitSample: "%") }.width(min: 40, ideal: widths[4], max: nil)
            TableColumn(model.trafficGrouping == .process ? "域名数" : "程序数", sortUsing: columnSort(model.trafficGrouping == .process ? "域名数" : "程序数")) { row in Text(String(model.trafficGrouping == .process ? row.domainCount : row.processCount)).monospacedDigit().frame(maxWidth: .infinity, alignment: .trailing) }.width(min: 40, ideal: widths[5], max: nil)
            TableColumn("目标 IP 数", sortUsing: columnSort("目标 IP 数")) { row in Text(String(row.ipCount)).monospacedDigit().frame(maxWidth: .infinity, alignment: .trailing) }.width(min: 40, ideal: widths[6], max: nil)
            TableColumn("出口数", sortUsing: columnSort("出口数")) { row in Text(String(row.outboundCount)).monospacedDigit().frame(maxWidth: .infinity, alignment: .trailing) }.width(min: 40, ideal: widths[7], max: nil)
        }
        .background(TableColumnAutoFit(widths: widths))
        .contextMenu(forSelectionType: String.self) { ids in
            if ids.count == 1, let row = rows.first(where: { ids.contains($0.id) }) {
                trafficRoutes(row).disabled(model.busy)
            }
        }
        .overlay {
            if rows.isEmpty, let error = model.statisticsError {
                Text("统计不可用：" + error)
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
