import SwiftUI
import MihomoCore

struct CoreLogsView: View {
    @EnvironmentObject var model: MihomoModel
    @State private var entries: [Entry] = []
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
            search.isEmpty || $0.log.payload.localizedCaseInsensitiveContains(search) || $0.log.type.localizedCaseInsensitiveContains(search)
        }
    }

    var body: some View {
        let rows = filtered
        let widths = [
            tableColumnWidth("接收时间", rows.map { $0.date.formatted(date: .omitted, time: .standard) }),
            tableColumnWidth("等级", rows.map { $0.log.type.uppercased() })
        ]
        Table(rows) {
            TableColumn("接收时间") { entry in
                Text(entry.date.formatted(date: .omitted, time: .standard))
            }.width(min: 80, ideal: widths[0], max: nil)
            TableColumn("等级") { entry in
                Text(entry.log.type.uppercased())
            }.width(min: 50, ideal: widths[1], max: nil)
            TableColumn("日志") { entry in
                Text(entry.log.payload)
                    .font(.system(.body, design: .monospaced))
                    .lineLimit(nil)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .textSelection(.enabled)
                    .help(entry.log.payload)
            }.width(min: 200, ideal: 600, max: nil)
        }
        .overlay {
            if rows.isEmpty && !entries.isEmpty {
                Text("没有匹配的日志")
                    .foregroundStyle(.secondary).allowsHitTesting(false)
            }
        }
        .searchable(text: $search, placement: .toolbar, prompt: "搜索日志")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button { entries.removeAll() } label: {
                    Label("清空日志", systemImage: "trash")
                }
                .disabled(entries.isEmpty)
                .help("清空当前页面已接收的日志")
                .accessibilityLabel("清空日志")
                .labelStyle(.iconOnly)
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
