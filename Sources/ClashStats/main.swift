import Foundation
import ClashCore
import Darwin

@main
struct StatsMain {
    static func main() async {
        do {
            let args = CommandLine.arguments
            let port: Int
            if let index = args.firstIndex(of: "--port"), args.indices.contains(index + 1), let value = Int(args[index + 1]), (1...65535).contains(value) {
                port = value
            } else { port = 19090 }
            let directory: URL
            if let index = args.firstIndex(of: "--directory"), args.indices.contains(index + 1) {
                directory = URL(fileURLWithPath: args[index + 1], isDirectory: true)
            } else { directory = try dataDirectory() }
            let database = try TrafficDatabase(url: directory.appendingPathComponent("traffic.sqlite"))
            var tracker = TrafficTracker()
            var lastPrune = Date.distantPast
            var failed = false
            var initialized = false
            // The lock prevents a second collector (manual launch + launchd) from double counting.
            let lockPath = directory.appendingPathComponent("collector.lock").path
            let lockFD = open(lockPath, O_CREAT | O_RDWR, 0o600)
            guard lockFD >= 0, flock(lockFD, LOCK_EX | LOCK_NB) == 0 else {
                throw DeskError("统计后台已运行，或无法取得锁")
            }
            defer { close(lockFD) }
            while !Task.isCancelled {
                do {
                    let settings = try loadRuntimeSettings(from: directory)
                    let api: CoreAPI
                    if args.contains("--port") {
                        let endpoint = try controllerEndpoint(settings)
                        api = CoreAPI(secret: endpoint.secret, port: port, host: endpoint.host)
                    }
                    else { api = try CoreAPI(settings: settings) }
                    let connections = try await api.connections()
                    // Commit the baseline only after SQLite succeeds, so a busy database can be retried.
                    var next = tracker
                    let changes = next.consume(connections)
                    let deltas = initialized ? changes : []
                    try database.record(deltas)
                    tracker = next
                    initialized = true
                    if Date().timeIntervalSince(lastPrune) > 3600 {
                        try database.prune(before: Date().addingTimeInterval(-90 * 86400))
                        lastPrune = Date()
                    }
                    if failed { fputs("统计采集已恢复\n", stderr); failed = false }
                } catch {
                    if !failed { fputs("统计暂不可用：\(error.localizedDescription)\n", stderr); failed = true }
                    if args.contains("--once") { throw error }
                }
                if args.contains("--once") { break }
                try await Task.sleep(nanoseconds: failed ? 5_000_000_000 : 2_000_000_000)
            }
        } catch { fputs("\(error.localizedDescription)\n", stderr); exit(1) }
    }
}
