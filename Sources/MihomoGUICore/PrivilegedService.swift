import Foundation

public let privilegedServiceLabel = "local.MihomoGUI.helper"
public let privilegedPayloadMaximumBytes = 32 * 1024 * 1024

// Shared wire contract for the authenticated GUI and its root LaunchDaemon.
@objc public protocol PrivilegedService {
    func execute(_ payload: Data, deadline: UInt64, reply: @escaping (Int32, String?) -> Void)
}

// Same-host monotonic budget, carried across authorization, XPC queuing and execution.
public struct PrivilegedOperationDeadline {
    public let end: DispatchTime
    public init(timeout: TimeInterval = 180) { end = .now() + timeout }
    public init(clientDeadline: UInt64, maximumSeconds: TimeInterval = 120) {
        end = DispatchTime(uptimeNanoseconds: min(clientDeadline, (DispatchTime.now() + maximumSeconds).uptimeNanoseconds))
    }
    public var remaining: TimeInterval {
        get throws {
            let now = DispatchTime.now().uptimeNanoseconds
            guard end.uptimeNanoseconds > now else { throw MihomoGUIError("操作超时，结果可能未知，请检查系统服务状态后重试") }
            return Double(end.uptimeNanoseconds - now) / 1_000_000_000
        }
    }
    public func check() throws { _ = try remaining }
}

// Only these operations cross the privileged boundary; shell text is never accepted.
public enum PrivilegedOperation: Codable {
    case install(staging: String, settings: Settings)
    case stop
    case persist(Data)
    case prepareRules(staging: String, id: UUID, filenames: [String])
    case finishRules(id: UUID, filenames: [String], restore: Bool)
}

public func encodePrivilegedOperation(_ operation: PrivilegedOperation) throws -> Data {
    let payload = try JSONEncoder().encode(operation)
    guard payload.count <= privilegedPayloadMaximumBytes else {
        throw MihomoGUIError("特权请求超过32MiB限制，请减少订阅节点或配置内容；本次操作未提交")
    }
    return payload
}

// Validate both wire forms before committing fetched subscriptions. Raw download
// sizes cannot predict JSON escaping or the base64 expansion of persisted YAML.
public func validatePrivilegedConfiguration(_ settings: Settings, config: Data, directory: URL) throws {
    let staging = directory.appendingPathComponent("install-00000000-0000-0000-0000-000000000000")
    _ = try encodePrivilegedOperation(.install(staging: staging.path, settings: settings))
    _ = try encodePrivilegedOperation(.persist(config))
}

public func shellQuote(_ string: String) -> String { "'" + string.replacingOccurrences(of: "'", with: "'\\''") + "'" }
