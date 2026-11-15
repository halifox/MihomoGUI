import Foundation

public let privilegedServiceLabel = "local.MihomoGUI.helper"

// Shared wire contract for the authenticated GUI and its root LaunchDaemon.
@objc public protocol PrivilegedService {
    func execute(_ payload: Data, reply: @escaping (Int32) -> Void)
}

// Only these operations cross the privileged boundary; shell text is never accepted.
public enum PrivilegedOperation: Codable {
    case install(staging: String, settings: Settings)
    case stop
    case persist(Data)
    case prepareRules(staging: String, id: UUID, filenames: [String])
    case finishRules(id: UUID, filenames: [String], restore: Bool)
}

public func shellQuote(_ string: String) -> String { "'" + string.replacingOccurrences(of: "'", with: "'\\''") + "'" }
