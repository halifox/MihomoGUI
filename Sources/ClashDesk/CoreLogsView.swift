import SwiftUI
import ClashCore

struct CoreLogsView: View {
    @EnvironmentObject var model: DeskModel
    @State private var entries: [Entry] = []
    @State private var level = "all"
    @State private var search = ""
    @State private var streamError: String?
    @State private var connected = false

    private struct Entry: Identifiable {
        let id = UUID()
        let date = Date()
        let log: CoreLog
    }

    private var endpoint: String {
        guard let api = try? model.api else { return "" }
        return "\(api.host):\(api.port)/\(api.secret)/\(model.coreRunning)"
    }

    private var filtered: [Entry] {
        entries.filter {
            (level == "all" || $0.log.type == level) &&
            (search.isEmpty || $0.log.payload.localizedCaseInsensitiveContains(search) || $0.log.type.localizedCaseInsensitiveContains(search))
        }
    }

    var body: some View {
        let rows = filtered
        let widths = [
            tableColumnWidth("接收时间", rows.map { $0.date.formatted(date: .omitted, time: .standard) }),
            tableColumnWidth("等级", rows.map { $0.log.type.uppercased() }),
            tableColumnWidth("日志", rows.map { $0.log.payload }, monospaced: true)
        ]
        Table(rows) {
            TableColumn("接收时间") { entry in Text(entry.date.formatted(date: .omitted, time: .standard)) }.width(min: 40, ideal: widths[0], max: nil)
            TableColumn("等级") { entry in Text(entry.log.type.uppercased()) }.width(min: 40, ideal: widths[1], max: nil)
            TableColumn("日志") { entry in
                Text(entry.log.payload).font(.system(.body, design: .monospaced))
                    .textSelection(.enabled).help(entry.log.payload)
            }.width(min: 40, ideal: widths[2], max: nil)
        }
        .background(TableColumnAutoFit(widths: widths))
        .overlay {
            if rows.isEmpty && !entries.isEmpty {
                Text("没有匹配的日志")
                    .foregroundStyle(.secondary).allowsHitTesting(false)
            }
        }
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                HStack {
                    Picker("日志等级", selection: $level) {
                        Text("全部等级").tag("all")
                        Text("Debug").tag("debug")
                        Text("Info").tag("info")
                        Text("Warning").tag("warning")
                        Text("Error").tag("error")
                    }.frame(width: 140)
                    TextField("搜索日志", text: $search).textFieldStyle(.roundedBorder).frame(width: 180)
                    Button { entries.removeAll() } label: {
                        toolbarIcon("清空日志", systemImage: "trash")
                    }.disabled(entries.isEmpty).help("清空当前页面已接收的日志")
                }
            }
        }
        .task(id: endpoint) {
            let source = endpoint
            connected = false
            streamError = nil
            while !Task.isCancelled {
                do {
                    let api = try model.api
                    try await api.logs { log in
                        guard !Task.isCancelled, endpoint == source else { return }
                        connected = true
                        streamError = nil
                        entries.append(Entry(log: log))
                        if entries.count > 5_000 { entries.removeFirst(entries.count - 5_000) }
                    }
                } catch {
                    guard !Task.isCancelled, endpoint == source else { return }
                    connected = false
                    streamError = "日志连接失败，将自动重试：\(error.localizedDescription)"
                }
                do { try await Task.sleep(nanoseconds: 3_000_000_000) }
                catch { return }
            }
        }
    }
}
