import Foundation
import CSQLite

public enum TrafficGrouping: String, CaseIterable, Identifiable {
    case domain, process, ip, port
    public var id: String { rawValue }
    public var title: String {
        switch self { case .domain: return "域名 / IP"; case .process: return "进程"; case .ip: return "目标 IP"; case .port: return "目标端口" }
    }
    public func key(for connection: Connection) -> String {
        switch self {
        case .domain: return connection.domain
        case .process: return connection.process
        case .ip: return connection.metadata.destinationIP.flatMap { $0.isEmpty ? nil : $0 } ?? "未知 IP"
        case .port: return connection.metadata.destinationPort.flatMap { $0.isEmpty ? nil : $0 } ?? "未知端口"
        }
    }
}

public struct TrafficDelta {
    public var domain: String
    public var process: String
    public var outbound: String
    public var upload: Int64
    public var download: Int64
    public var ip: String = "未知 IP"
    public var port: String = "未知端口"
}

public struct TrafficTracker {
    private var previous: [String: (Int64, Int64)] = [:]
    public init() {}
    public var activeCount: Int { previous.count }
    public mutating func consume(_ connections: [Connection]) -> [TrafficDelta] {
        var next: [String: (Int64, Int64)] = [:]
        next.reserveCapacity(connections.count)
        var deltas: [TrafficDelta] = []
        for connection in connections {
            let last = previous[connection.id] ?? (0, 0)
            // A reset counter is a new counter epoch, never a negative traffic delta.
            let up = connection.upload >= last.0 ? connection.upload - last.0 : connection.upload
            let down = connection.download >= last.1 ? connection.download - last.1 : connection.download
            next[connection.id] = (connection.upload, connection.download)
            if up > 0 || down > 0 {
                deltas.append(TrafficDelta(domain: connection.domain, process: connection.process,
                                          outbound: connection.outbound, upload: up, download: down,
                                          ip: TrafficGrouping.ip.key(for: connection), port: TrafficGrouping.port.key(for: connection)))
            }
        }
        previous = next
        return deltas
    }
}

public struct TrafficRow: Identifiable {
    public var id: String { domain + "\u{0}" + process + "\u{0}" + outbound }
    public var domain: String
    public var process: String
    public var outbound: String
    public var upload: Int64
    public var download: Int64
}

public struct DomainTrafficRow: Identifiable, Equatable {
    public var id: String { domain }
    public var domain: String
    public var upload: Int64
    public var download: Int64
    public var processCount: Int
    public var outboundCount: Int
    public var domainCount: Int
    public var ipCount: Int
    public var totalTraffic: Int64
}

public final class TrafficDatabase {
    private var db: OpaquePointer?
    private let transient = unsafeBitCast(-1, to: sqlite3_destructor_type.self)
    public init(url: URL, readOnly: Bool = false) throws {
        let flags = readOnly ? SQLITE_OPEN_READONLY : SQLITE_OPEN_READWRITE | SQLITE_OPEN_CREATE
        guard sqlite3_open_v2(url.path, &db, flags | SQLITE_OPEN_NOMUTEX, nil) == SQLITE_OK else {
            let message = db.map { String(cString: sqlite3_errmsg($0)) } ?? "无法打开数据库"
            sqlite3_close(db); db = nil
            throw DeskError(message)
        }
        sqlite3_busy_timeout(db, 2000)
        do {
            try execute("PRAGMA cache_size=-1024; PRAGMA mmap_size=0;")
            if !readOnly {
                try execute("""
                PRAGMA journal_mode=WAL;
                PRAGMA synchronous=NORMAL;
                PRAGMA wal_autocheckpoint=256;
                CREATE TABLE IF NOT EXISTS traffic (
                    bucket INTEGER NOT NULL, domain TEXT NOT NULL, process TEXT NOT NULL,
                    outbound TEXT NOT NULL, upload INTEGER NOT NULL, download INTEGER NOT NULL,
                    PRIMARY KEY (bucket, domain, process, outbound)
                ) WITHOUT ROWID;
                CREATE TABLE IF NOT EXISTS collector (id INTEGER PRIMARY KEY CHECK(id=1), sampled_at INTEGER NOT NULL);
                """)
                let columns = try prepare("PRAGMA table_info(traffic)")
                var hasIP = false
                while sqlite3_step(columns) == SQLITE_ROW {
                    if String(cString: sqlite3_column_text(columns, 1)) == "ip" { hasIP = true }
                }
                sqlite3_finalize(columns)
                if !hasIP {
                    try execute("""
                    BEGIN IMMEDIATE;
                    ALTER TABLE traffic RENAME TO traffic_old;
                    CREATE TABLE traffic (
                        bucket INTEGER NOT NULL, domain TEXT NOT NULL, process TEXT NOT NULL,
                        outbound TEXT NOT NULL, upload INTEGER NOT NULL, download INTEGER NOT NULL,
                        ip TEXT NOT NULL, port TEXT NOT NULL,
                        PRIMARY KEY (bucket,domain,process,outbound,ip,port)
                    ) WITHOUT ROWID;
                    INSERT INTO traffic SELECT *, '未知 IP', '未知端口' FROM traffic_old;
                    DROP TABLE traffic_old;
                    COMMIT;
                    """)
                }
            }
        } catch { sqlite3_close(db); db = nil; throw error }
    }
    deinit { sqlite3_close(db) }
    private func execute(_ sql: String) throws {
        guard sqlite3_exec(db, sql, nil, nil, nil) == SQLITE_OK else { throw failure() }
    }
    private func failure() -> DeskError { DeskError(String(cString: sqlite3_errmsg(db))) }
    private func prepare(_ sql: String) throws -> OpaquePointer {
        var statement: OpaquePointer?
        guard sqlite3_prepare_v2(db, sql, -1, &statement, nil) == SQLITE_OK, let statement else { throw failure() }
        return statement
    }
    public func record(_ deltas: [TrafficDelta], at date: Date = Date()) throws {
        let timestamp = Int64(date.timeIntervalSince1970)
        let bucket = timestamp / 3600 * 3600
        let statement = try prepare("""
        INSERT INTO traffic VALUES(?,?,?,?,?,?,?,?) ON CONFLICT(bucket,domain,process,outbound,ip,port)
        DO UPDATE SET upload=upload+excluded.upload, download=download+excluded.download
        """)
        defer { sqlite3_finalize(statement) }
        try execute("BEGIN IMMEDIATE")
        do {
            for delta in deltas {
                sqlite3_bind_int64(statement, 1, bucket)
                sqlite3_bind_text(statement, 2, delta.domain, -1, transient)
                sqlite3_bind_text(statement, 3, delta.process, -1, transient)
                sqlite3_bind_text(statement, 4, delta.outbound, -1, transient)
                sqlite3_bind_int64(statement, 5, delta.upload)
                sqlite3_bind_int64(statement, 6, delta.download)
                sqlite3_bind_text(statement, 7, delta.ip, -1, transient)
                sqlite3_bind_text(statement, 8, delta.port, -1, transient)
                guard sqlite3_step(statement) == SQLITE_DONE else { throw failure() }
                sqlite3_reset(statement); sqlite3_clear_bindings(statement)
            }
            try execute("INSERT INTO collector VALUES(1,\(timestamp)) ON CONFLICT(id) DO UPDATE SET sampled_at=excluded.sampled_at")
            try execute("COMMIT")
        } catch { try? execute("ROLLBACK"); throw error }
    }
    public func rows(since date: Date, limit: Int = 500) throws -> [TrafficRow] {
        let statement = try prepare("""
        SELECT domain,process,outbound,SUM(upload),SUM(download) FROM traffic WHERE bucket>=?
        GROUP BY domain,process,outbound ORDER BY SUM(upload)+SUM(download) DESC LIMIT ?
        """)
        defer { sqlite3_finalize(statement) }
        sqlite3_bind_int64(statement, 1, Int64(date.timeIntervalSince1970) / 3600 * 3600)
        sqlite3_bind_int(statement, 2, Int32(max(1, min(limit, 5000))))
        var result: [TrafficRow] = []
        while true {
            let code = sqlite3_step(statement)
            if code == SQLITE_DONE { break }
            guard code == SQLITE_ROW else { throw failure() }
            func string(_ index: Int32) -> String { String(cString: sqlite3_column_text(statement, index)) }
            result.append(TrafficRow(domain: string(0), process: string(1), outbound: string(2),
                                     upload: sqlite3_column_int64(statement, 3), download: sqlite3_column_int64(statement, 4)))
        }
        return result
    }
    public func lastSample() throws -> Date? {
        let statement = try prepare("SELECT sampled_at FROM collector WHERE id=1")
        defer { sqlite3_finalize(statement) }
        let code = sqlite3_step(statement)
        if code == SQLITE_DONE { return nil }
        guard code == SQLITE_ROW else { throw failure() }
        return Date(timeIntervalSince1970: Double(sqlite3_column_int64(statement, 0)))
    }
    public func domainRows(since date: Date, limit: Int = 500) throws -> [DomainTrafficRow] {
        try groupedRows(since: date, by: .domain, limit: limit)
    }
    public func groupedRows(since date: Date, by grouping: TrafficGrouping, limit: Int = 500) throws -> [DomainTrafficRow] {
        var column = grouping.rawValue
        var hasIP = false
        do {
            let schema = try prepare("PRAGMA table_info(traffic)")
            var exists = false
            while sqlite3_step(schema) == SQLITE_ROW {
                let name = String(cString: sqlite3_column_text(schema, 1))
                if name == column { exists = true }
                if name == "ip" { hasIP = true }
            }
            sqlite3_finalize(schema)
            if !exists && (grouping == .ip || grouping == .port) { column = grouping == .ip ? "'未知 IP'" : "'未知端口'" }
        }
        let statement = try prepare("""
        SELECT \(column),SUM(upload),SUM(download),COUNT(DISTINCT process),COUNT(DISTINCT outbound),
        COUNT(DISTINCT domain),
        \(hasIP ? "COUNT(DISTINCT CASE WHEN ip NOT IN ('', '未知 IP') THEN ip END)" : "0"),
        SUM(SUM(upload)+SUM(download)) OVER ()
        FROM traffic WHERE bucket>=? GROUP BY \(column) ORDER BY SUM(upload)+SUM(download) DESC LIMIT ?
        """)
        defer { sqlite3_finalize(statement) }
        sqlite3_bind_int64(statement, 1, Int64(date.timeIntervalSince1970) / 3600 * 3600)
        sqlite3_bind_int(statement, 2, Int32(max(1, min(limit, 5000))))
        var rows: [DomainTrafficRow] = []
        while true {
            let code = sqlite3_step(statement)
            if code == SQLITE_DONE { break }
            guard code == SQLITE_ROW else { throw failure() }
            rows.append(DomainTrafficRow(domain: String(cString: sqlite3_column_text(statement, 0)),
                                         upload: sqlite3_column_int64(statement, 1), download: sqlite3_column_int64(statement, 2),
                                         processCount: Int(sqlite3_column_int(statement, 3)), outboundCount: Int(sqlite3_column_int(statement, 4)),
                                         domainCount: Int(sqlite3_column_int(statement, 5)), ipCount: Int(sqlite3_column_int(statement, 6)),
                                         totalTraffic: sqlite3_column_int64(statement, 7)))
        }
        return rows
    }
    public func prune(before date: Date) throws {
        let statement = try prepare("DELETE FROM traffic WHERE bucket<?")
        defer { sqlite3_finalize(statement) }
        sqlite3_bind_int64(statement, 1, Int64(date.timeIntervalSince1970))
        guard sqlite3_step(statement) == SQLITE_DONE else { throw failure() }
        try execute("PRAGMA wal_checkpoint(PASSIVE)")
    }
}
