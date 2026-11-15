import SwiftUI
import AppKit
import ClashCore

struct StatisticsView: View {
    @State private var sortOrder: [TableSort<DomainTrafficRow>] = []
    @EnvironmentObject var model: DeskModel
    @State private var selection: Set<String> = []
    @State private var search = ""
    @State private var pausedRows: [DomainTrafficRow]?
    @State private var detail: TrafficDetailSelection?
    @State private var batchAdding = false
    @State private var batchRules: [RouteRule] = []
    @State private var skippedCount = 0
    var displayedRows: [DomainTrafficRow] { pausedRows ?? model.traffic }
    var filteredRows: [DomainTrafficRow] { displayedRows.filter { search.isEmpty || $0.domain.localizedCaseInsensitiveContains(search) } }
    var selectedRows: [DomainTrafficRow] { filteredRows.filter { selection.contains($0.id) } }
    var ruleKind: RuleKind {
        switch model.trafficGrouping {
        case .domain: return .domain
        case .process: return .processName
        case .ip: return .ipCIDR
        case .port: return .destinationPort
        }
    }
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
        let rows = filteredRows
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
            let selected = rows.filter { ids.contains($0.id) }
            if selected.count == 1, let row = selected.first {
                Button("查看关联明细") { showDetail(row) }
                trafficRoutes(row).disabled(model.busy)
            } else if !selected.isEmpty {
                Button("批量添加路由规则…") { prepareBatch(selected) }.disabled(model.busy)
            }
            if !selected.isEmpty {
                Button("复制所选名称") { copyNames(selected) }
            }
        } primaryAction: { ids in
            if ids.count == 1, let row = rows.first(where: { ids.contains($0.id) }) { showDetail(row) }
        }
        .sheet(item: $detail) { selection in TrafficDetailView(selection: selection) }
        .sheet(isPresented: $batchAdding) { BatchRouteEditor(rules: batchRules, skippedCount: skippedCount) }
        .safeAreaInset(edge: .top, spacing: 0) { filters }
        .safeAreaInset(edge: .bottom, spacing: 0) { status }
        .overlay {
            if rows.isEmpty {
                if !model.statisticsLoaded && pausedRows == nil {
                    ProgressView("正在读取统计…")
                } else {
                    Text(model.statisticsError != nil ? "统计读取失败，请查看下方提示。" : displayedRows.isEmpty ? "所选时间范围暂无流量记录" : "没有符合搜索条件的统计记录")
                        .foregroundStyle(.secondary).allowsHitTesting(false)
                }
            }
        }
        .toolbar {
            ToolbarItemGroup(placement: .primaryAction) {
                Picker("统计方式", selection: $model.trafficGrouping) {
                    Text("域名统计").tag(TrafficGrouping.domain)
                    Text("进程统计").tag(TrafficGrouping.process)
                    Text("目标 IP 统计").tag(TrafficGrouping.ip)
                    Text("目标端口统计").tag(TrafficGrouping.port)
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
        .task(id: "\(model.trafficGrouping.rawValue)-\(model.hours)") {
            selection = []; pausedRows = nil
            model.traffic = []; model.statisticsError = nil; model.statisticsLoaded = false
            await model.refreshStatistics()
        }
    }
    @ViewBuilder func trafficRoutes(_ row: DomainTrafficRow) -> some View {
        switch model.trafficGrouping {
        case .domain: RouteMenu(kind: .domain, value: row.domain)
        case .process: RouteMenu(kind: row.domain.hasPrefix("/") ? .processPath : .processName, value: row.domain)
        case .ip: RouteMenu(kind: .ipCIDR, value: row.domain)
        case .port: RouteMenu(kind: .destinationPort, value: row.domain)
        }
    }

    var filters: some View {
        HStack {
            TextField("搜索" + model.trafficGrouping.title, text: $search)
                .textFieldStyle(.roundedBorder).accessibilityLabel("搜索统计记录")
            Menu {
                if selectedRows.count == 1, let row = selectedRows.first { trafficRoutes(row) }
                Button("批量添加路由规则…") { prepareBatch(selectedRows) }
            } label: { Label("添加规则", systemImage: "plus") }
                .disabled(selectedRows.isEmpty || model.busy)
            Button {
                if let row = selectedRows.first { showDetail(row) }
            } label: { Label("关联明细", systemImage: "list.bullet.rectangle") }
                .disabled(selectedRows.count != 1)
            Button {
                pausedRows = pausedRows == nil ? model.traffic : nil
            } label: { Label(pausedRows == nil ? "暂停" : "继续", systemImage: pausedRows == nil ? "pause" : "play") }
        }.labelStyle(.titleAndIcon).padding(8)
    }
    @ViewBuilder var status: some View {
        if let error = model.statisticsError {
            Text("统计不可用：" + error + (displayedRows.isEmpty ? "" : "；当前显示上次成功读取的数据。"))
                .foregroundStyle(.orange).textSelection(.enabled)
                .font(.caption).padding(8).frame(maxWidth: .infinity, alignment: .leading).background(.bar)
        }
    }
    func showDetail(_ row: DomainTrafficRow) {
        detail = TrafficDetailSelection(grouping: model.trafficGrouping, value: row.domain, hours: model.hours)
    }
    func prepareBatch(_ rows: [DomainTrafficRow]) {
        batchRules = rows.compactMap { row in
            let kind = model.trafficGrouping == .process && row.domain.hasPrefix("/") ? RuleKind.processPath : ruleKind
            return quickRouteRule(kind: kind, value: row.domain)
        }
        skippedCount = rows.count - batchRules.count
        batchAdding = true
    }
    func copyNames(_ rows: [DomainTrafficRow]) {
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(rows.map(\.domain).joined(separator: "\n"), forType: .string)
    }

}

private struct TrafficDetailSelection: Identifiable {
    let id = UUID()
    let grouping: TrafficGrouping
    let value: String
    let hours: Int
}

private struct TrafficDetailView: View {
    @EnvironmentObject var model: DeskModel
    @Environment(\.dismiss) private var dismiss
    let selection: TrafficDetailSelection
    @State private var rows: [TrafficRow] = []
    @State private var selectedID: String?
    @State private var search = ""
    @State private var loading = true
    @State private var error: String?
    @State private var ruleDraft: RouteRule?
    var filteredRows: [TrafficRow] {
        rows.filter { row in
            search.isEmpty || [row.domain, row.process, row.ip, row.port, row.outbound].contains { $0.localizedCaseInsensitiveContains(search) }
        }
    }
    var selectedRow: TrafficRow? { filteredRows.first { $0.id == selectedID } }
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("关联流量明细").font(.title2.bold())
            Text("\(selection.grouping.title)：\(selection.value) · 最近 \(selection.hours) 小时")
                .textSelection(.enabled)
            TextField("搜索域名、进程、IP、端口或出口", text: $search).textFieldStyle(.roundedBorder)
            Table(filteredRows, selection: $selectedID) {
                TableColumn("域名 / IP") { row in Text(row.domain).help(row.domain) }
                TableColumn("进程") { row in Text(row.process).help(row.process) }
                TableColumn("目标 IP") { row in Text(row.ip).help(row.ip) }
                TableColumn("端口", value: \.port).width(55)
                TableColumn("出口") { row in Text(model.connectionProxyNames[row.outbound] ?? row.outbound) }
                TableColumn("下载量") { row in TableUnitValue(text: bytes(row.download)) }
                TableColumn("上传量") { row in TableUnitValue(text: bytes(row.upload)) }
            }
            .contextMenu(forSelectionType: String.self) { ids in
                if let row = filteredRows.first(where: { ids.contains($0.id) }) {
                    detailRoutes(row).disabled(model.busy)
                    Button("复制明细") { copy(row) }
                }
            }
            .overlay {
                if loading { ProgressView("正在读取关联记录…") }
                else if rows.isEmpty, error == nil { Text("所选范围暂无关联记录").foregroundStyle(.secondary) }
                else if !rows.isEmpty, filteredRows.isEmpty { Text("没有符合搜索条件的关联记录").foregroundStyle(.secondary) }
            }
            if let error { Text("明细读取失败：" + error).foregroundStyle(.red).textSelection(.enabled) }
            Text("按域名、进程、目标 IP、端口和出口汇总，最多显示流量排名前 500 项。打开时读取一次，时间按小时统计。")
                .font(.caption).foregroundStyle(.secondary)
            HStack {
                Menu {
                    if let row = selectedRow { detailRoutes(row) }
                } label: { Label("添加规则", systemImage: "plus") }
                    .disabled(selectedRow == nil || model.busy)
                Button("复制明细") { if let row = selectedRow { copy(row) } }.disabled(selectedRow == nil)
                Spacer()
                Button("完成") { dismiss() }.keyboardShortcut(.cancelAction)
            }
        }.padding(16).frame(width: 900, height: 520)
        .sheet(item: $ruleDraft) { RuleEditorView(prefill: $0) }
        .task(id: selection.id) { await load() }
    }
    @ViewBuilder func detailRoutes(_ row: TrafficRow) -> some View {
        Menu { RouteMenu(kind: .domain, value: row.domain, onOpen: { ruleDraft = $0 }) } label: { Label("按域名 / IP", systemImage: "globe") }
        Menu { RouteMenu(kind: row.process.hasPrefix("/") ? .processPath : .processName, value: row.process, onOpen: { ruleDraft = $0 }) } label: { Label("按进程", systemImage: "app") }
        Menu { RouteMenu(kind: .ipCIDR, value: row.ip, onOpen: { ruleDraft = $0 }) } label: { Label("按目标 IP", systemImage: "network") }
        Menu { RouteMenu(kind: .destinationPort, value: row.port, onOpen: { ruleDraft = $0 }) } label: { Label("按目标端口", systemImage: "number") }
    }
    func load() async {
        let url = model.directory.appendingPathComponent("traffic.sqlite")
        let grouping = selection.grouping; let value = selection.value
        let since = Date().addingTimeInterval(-Double(selection.hours) * 3600)
        do {
            let result = try await Task.detached {
                try TrafficDatabase(url: url, readOnly: true).rows(since: since, matching: grouping, value: value)
            }.value
            try Task.checkCancellation()
            rows = result; error = nil; loading = false
        } catch {
            guard !Task.isCancelled else { return }
            self.error = error.localizedDescription; loading = false
        }
    }
    func copy(_ row: TrafficRow) {
        let text = "域名 / IP：\(row.domain)\n进程：\(row.process)\n目标 IP：\(row.ip)\n端口：\(row.port)\n出口：\(model.connectionProxyNames[row.outbound] ?? row.outbound)\n下载量：\(bytes(row.download))\n上传量：\(bytes(row.upload))"
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(text, forType: .string)
    }
}
