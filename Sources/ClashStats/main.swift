import Foundation
import ClashCore
import Darwin

// Single writer per log. Cap both each record and the two retained files.
func appendLog(_ text: String, to logURL: URL) {
    do {
        let data = Data(("\(Date()) \(String(text.prefix(8192)))\n").utf8)
        let size = ((try? FileManager.default.attributesOfItem(atPath: logURL.path)[.size]) as? NSNumber)?.intValue ?? 0
        if size + data.count > 1024 * 1024 {
            let previous = URL(fileURLWithPath: logURL.path + ".1")
            if FileManager.default.fileExists(atPath: previous.path) { try FileManager.default.removeItem(at: previous) }
            try FileManager.default.moveItem(at: logURL, to: previous)
        }
        if !FileManager.default.fileExists(atPath: logURL.path) {
            FileManager.default.createFile(atPath: logURL.path, contents: nil, attributes: [.posixPermissions: 0o600])
        }
        let handle = try FileHandle(forWritingTo: logURL)
        defer { try? handle.close() }
        try handle.seekToEnd(); try handle.write(contentsOf: data)
    } catch { fputs("日志写入失败：\(error.localizedDescription)\n", stderr) }
}

@main
struct StatsMain {
    static func main() async {
        var failureLog: URL?
        do {
            let args = CommandLine.arguments
            if let index = args.firstIndex(of: "--log-stream"), args.indices.contains(index + 1) {
                let logURL = URL(fileURLWithPath: args[index + 1])
                while let data = try FileHandle.standardInput.read(upToCount: 8192), !data.isEmpty {
                    appendLog(String(decoding: data, as: UTF8.self), to: logURL)
                }
                return
            }
            let port: Int
            if let index = args.firstIndex(of: "--port"), args.indices.contains(index + 1), let value = Int(args[index + 1]), (1...65535).contains(value) {
                port = value
            } else { port = 19090 }
            let directory: URL
            if let index = args.firstIndex(of: "--directory"), args.indices.contains(index + 1) {
                directory = URL(fileURLWithPath: args[index + 1], isDirectory: true)
            } else { directory = try dataDirectory() }
            let logURL = directory.appendingPathComponent("services.log")
            func log(_ text: String) {
                appendLog(text, to: logURL)
            }
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
            failureLog = logURL
            let database = try TrafficDatabase(url: directory.appendingPathComponent("traffic.sqlite"))
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
                    if failed { log("统计采集已恢复"); failed = false }
                } catch {
                    if !failed { log("统计暂不可用：\(error.localizedDescription)"); failed = true }
                    if args.contains("--once") { throw error }
                }
                if args.contains("--once") { break }
                try await Task.sleep(nanoseconds: failed ? 5_000_000_000 : 2_000_000_000)
            }
        } catch {
            if let failureLog { appendLog(error.localizedDescription, to: failureLog) }
            fputs("\(error.localizedDescription)\n", stderr); exit(1)
        }
    }
}
