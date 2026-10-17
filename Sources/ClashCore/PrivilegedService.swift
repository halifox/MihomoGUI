import Foundation

public let privilegedServiceLabel = "local.clashdesk.helper"

// Shared wire contract for the authenticated GUI and its root LaunchDaemon.
@objc public protocol PrivilegedService {
    func execute(_ command: String, reply: @escaping (Int32) -> Void)
}
