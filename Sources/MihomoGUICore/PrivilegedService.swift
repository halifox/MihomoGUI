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

// Shared read-only policy before authorization and again under the root install
// lock. A missing/corrupt ownership record must never imply the current user.
public func serviceOwnershipCheckCommand(owner: UInt32,
    helperPlist: String = "/Library/LaunchDaemons/" + privilegedServiceLabel + ".plist",
    installedHelper: String = "/Library/PrivilegedHelperTools/" + privilegedServiceLabel,
    corePlist: String = "/Library/LaunchDaemons/" + coreLabel + ".plist",
    dataDirectory: String = rootDirectory) -> String {
    """
    set -eu
    ownership_unknown() { echo '无法验证现有系统服务归属，请管理员按卸载文档完整清理后重试' >&2; exit 1; }
    if [ -e \(shellQuote(helperPlist)) ] || [ -L \(shellQuote(helperPlist)) ]; then
        /bin/test -f \(shellQuote(helperPlist)) && /bin/test ! -L \(shellQuote(helperPlist)) || ownership_unknown
        file_owner=$(/usr/bin/stat -f %u \(shellQuote(helperPlist))) || ownership_unknown
        file_mode=$(/usr/bin/stat -f %Lp \(shellQuote(helperPlist))) || ownership_unknown
        [ "$file_owner" = 0 ] && [ "$((0$file_mode & 022))" -eq 0 ] || ownership_unknown
        label=$(/usr/libexec/PlistBuddy -c 'Print :Label' \(shellQuote(helperPlist)) 2>/dev/null) || ownership_unknown
        program=$(/usr/libexec/PlistBuddy -c 'Print :ProgramArguments:0' \(shellQuote(helperPlist)) 2>/dev/null) || ownership_unknown
        service_owner=$(/usr/libexec/PlistBuddy -c 'Print :ProgramArguments:1' \(shellQuote(helperPlist)) 2>/dev/null) || ownership_unknown
        /usr/libexec/PlistBuddy -c 'Print :ProgramArguments:3' \(shellQuote(helperPlist)) >/dev/null 2>&1 || ownership_unknown
        if /usr/libexec/PlistBuddy -c 'Print :ProgramArguments:4' \(shellQuote(helperPlist)) >/dev/null 2>&1; then ownership_unknown; fi
        [ "$label" = \(shellQuote(privilegedServiceLabel)) ] && [ "$program" = \(shellQuote(installedHelper)) ] || ownership_unknown
        case "$service_owner" in ''|*[!0-9]*|0) ownership_unknown ;; esac
        if [ "$service_owner" != \(shellQuote(String(owner))) ]; then
            echo '系统服务由其他用户安装，请由原用户停止并完整卸载后再切换安装用户' >&2
            exit 1
        fi
    else
        for path in \(shellQuote(corePlist)) \(shellQuote(installedHelper)) \(shellQuote(dataDirectory)); do
            if [ -e "$path" ] || [ -L "$path" ]; then ownership_unknown; fi
        done
    fi
    """
}

public func shellQuote(_ string: String) -> String { "'" + string.replacingOccurrences(of: "'", with: "'\\''") + "'" }
