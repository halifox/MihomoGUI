import Foundation
import Security
import MihomoGUICore

private func signingRequirement(_ code: SecStaticCode) throws -> String {
    var information: CFDictionary?
    guard SecCodeCopySigningInformation(code, [], &information) == errSecSuccess,
          let hash = (information as? [String: Any])?[kSecCodeInfoUnique as String] as? Data else {
        throw MihomoGUIError("无法读取代码签名，请使用打包脚本重新构建应用")
    }
    return "cdhash H\"" + hash.map { String(format: "%02x", $0) }.joined() + "\""
}

// One result owns the XPC connection until the reply or a transport failure arrives.
final class PrivilegedRequest {
    let connection: NSXPCConnection
    let lock = NSLock()
    var continuation: CheckedContinuation<Void, Error>?
    private var timeout: DispatchWorkItem?

    init(connection: NSXPCConnection, continuation: CheckedContinuation<Void, Error>) {
        self.connection = connection
        self.continuation = continuation
    }

    func startTimeout(after seconds: TimeInterval = 180) {
        let timeout = DispatchWorkItem { [weak self] in
            self?.finish(MihomoGUIError("特权服务请求超时；操作结果未知，请检查内核状态后重试"))
        }
        lock.lock()
        self.timeout = timeout
        lock.unlock()
        DispatchQueue.global(qos: .utility).asyncAfter(deadline: .now() + seconds, execute: timeout)
    }

    func finish(_ error: Error? = nil) {
        lock.lock()
        let pending = continuation
        continuation = nil
        timeout?.cancel(); timeout = nil
        lock.unlock()
        guard let pending else { return }
        connection.invalidationHandler = nil
        connection.interruptionHandler = nil
        connection.invalidate()
        if let error { pending.resume(throwing: error) } else { pending.resume() }
    }
}

func privilegedOperation(_ operation: PrivilegedOperation) async throws {
    let deadline = PrivilegedOperationDeadline()
    let payload = try encodePrivilegedOperation(operation)
    try deadline.check()
    _ = try await runCommand("/bin/sh", ["-c", serviceOwnershipCheckCommand(owner: getuid())], timeout: min(45, deadline.remaining), expiresAt: deadline.end)
    let source = Bundle.main.bundleURL.appendingPathComponent("Contents/Helpers/MihomoGUIHelper")
    var applicationCode: SecCode?
    var applicationStaticCode: SecStaticCode?
    var helperCode: SecStaticCode?
    var coreCode: SecStaticCode?
    let core = Bundle.main.bundleURL.appendingPathComponent("Contents/Helpers/mihomo")
    guard SecCodeCopySelf([], &applicationCode) == errSecSuccess, let applicationCode,
          SecCodeCopyStaticCode(applicationCode, [], &applicationStaticCode) == errSecSuccess,
          let applicationStaticCode,
          SecStaticCodeCreateWithPath(source as CFURL, [], &helperCode) == errSecSuccess,
          let helperCode,
          SecStaticCodeCreateWithPath(core as CFURL, [], &coreCode) == errSecSuccess, let coreCode else { throw MihomoGUIError("特权辅助服务或应用签名缺失，请使用打包后的应用") }
    try deadline.check()
    let clientRequirement = try signingRequirement(applicationStaticCode)
    let helperRequirement = try signingRequirement(helperCode)
    let coreRequirement = try signingRequirement(coreCode)
    try deadline.check()
    let installed = "/Library/PrivilegedHelperTools/" + privilegedServiceLabel
    let plistPath = "/Library/LaunchDaemons/" + privilegedServiceLabel + ".plist"
    let plist: [String: Any] = [
        "Label": privilegedServiceLabel,
        "ProgramArguments": [installed, String(getuid()), clientRequirement, coreRequirement],
        "MachServices": [privilegedServiceLabel: true],
        "RunAtLoad": true, "ProcessType": "Background", "Umask": 0o077
    ]
    let expected = try PropertyListSerialization.data(fromPropertyList: plist, format: .xml, options: 0)
    let sourceData = try Data(contentsOf: source)
    let installedPlist = try? Data(contentsOf: URL(fileURLWithPath: plistPath))
    let installedProperties = installedPlist.flatMap { try? PropertyListSerialization.propertyList(from: $0, format: nil) as? NSDictionary }
    try deadline.check()
    let registered = (try? await runCommand("/bin/launchctl", ["print", "system/" + privilegedServiceLabel], timeout: min(45, deadline.remaining), expiresAt: deadline.end)) != nil
    try deadline.check()
    if (try? Data(contentsOf: URL(fileURLWithPath: installed))) != sourceData
        || installedProperties != plist as NSDictionary || !registered {
        // Only installation/update asks macOS for authorization. Never retry a submitted command.
        let authorizationBudget = try deadline.remaining
        try await administratorCommand("""
        set -eu
        /bin/test ! -L /Library/PrivilegedHelperTools
        /bin/test ! -L /Library/LaunchDaemons
        /bin/test ! -L \(shellQuote(installed))
        /bin/test ! -L \(shellQuote(plistPath))
        /bin/mkdir -p /Library/PrivilegedHelperTools
        lock=\(shellQuote(installed + ".install-lock"))
        if ! /bin/mkdir -m 700 "$lock"; then
            echo '辅助服务安装锁已占用，请等待安装结束；若上次安装中断，请管理员检查后清理安装锁' >&2
            exit 1
        fi
        trap '/bin/rmdir "$lock"' EXIT
        \(serviceOwnershipCheckCommand(owner: getuid()))
        stage=$(/usr/bin/mktemp -d /private/tmp/MihomoGUIHelper.XXXXXX)
        trap '/bin/rm -rf "$stage"; /bin/rmdir "$lock"' EXIT
        /usr/bin/install -o root -g wheel -m 755 \(shellQuote(source.path)) "$stage/helper"
        /usr/bin/codesign --verify --strict -R \(shellQuote("=" + helperRequirement)) "$stage/helper"
        /usr/bin/printf '%s' \(shellQuote(String(decoding: expected, as: UTF8.self))) > "$stage/helper.plist"
        if [ -f \(shellQuote(installed)) ]; then /bin/cp -p \(shellQuote(installed)) "$stage/old-helper"; fi
        if [ -f \(shellQuote(plistPath)) ]; then /bin/cp -p \(shellQuote(plistPath)) "$stage/old.plist"; fi
        loaded=0
        /bin/launchctl print system/\(privilegedServiceLabel) >/dev/null 2>&1 && loaded=1
        disabled=0
        if /bin/launchctl print-disabled system | /usr/bin/grep -F '\"\(privilegedServiceLabel)\" => true' >/dev/null; then disabled=1; fi
        rollback() {
            status=$?
            trap - EXIT
            if [ "$status" -ne 0 ]; then
                set +e
                restored=1
                /bin/launchctl bootout system/\(privilegedServiceLabel) >/dev/null 2>&1
                /bin/rm -f \(shellQuote(installed)) \(shellQuote(plistPath)) || restored=0
                if [ -f "$stage/old-helper" ]; then /bin/cp -p "$stage/old-helper" \(shellQuote(installed)) || restored=0; fi
                if [ -f "$stage/old.plist" ]; then /bin/cp -p "$stage/old.plist" \(shellQuote(plistPath)) || restored=0; fi
                if [ "$disabled" -eq 1 ]; then
                    /bin/launchctl disable system/\(privilegedServiceLabel) || restored=0
                else
                    /bin/launchctl enable system/\(privilegedServiceLabel) || restored=0
                fi
                if [ "$loaded" -eq 1 ]; then /bin/launchctl bootstrap system \(shellQuote(plistPath)) || restored=0; fi
                if [ "$restored" -ne 1 ]; then echo '辅助服务安装失败，恢复旧服务也失败' >&2; fi
            fi
            /bin/rm -rf "$stage"
            /bin/rmdir "$lock"
            exit "$status"
        }
        trap rollback EXIT
        /bin/launchctl bootout system/\(privilegedServiceLabel) >/dev/null 2>&1 || true
        /usr/bin/install -o root -g wheel -m 755 "$stage/helper" \(shellQuote(installed))
        /usr/bin/install -o root -g wheel -m 644 "$stage/helper.plist" \(shellQuote(plistPath))
        /bin/launchctl enable system/\(privilegedServiceLabel)
        /bin/launchctl bootstrap system \(shellQuote(plistPath))
        """, timeout: authorizationBudget, expiresAt: deadline.end)
    }
    try deadline.check()
    let connection = NSXPCConnection(machServiceName: privilegedServiceLabel, options: .privileged)
    connection.setCodeSigningRequirement(helperRequirement)
    connection.remoteObjectInterface = NSXPCInterface(with: PrivilegedService.self)
    let remaining = try deadline.remaining
    try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
        let request = PrivilegedRequest(connection: connection, continuation: continuation)
        let failed = { request.finish(MihomoGUIError("特权辅助服务连接中断；操作结果未知，请检查内核状态后重试。若持续失败，请重新安装应用。")) }
        connection.invalidationHandler = failed
        connection.interruptionHandler = failed
        request.startTimeout(after: remaining)
        connection.resume()
        guard let proxy = connection.remoteObjectProxyWithErrorHandler({ _ in failed() }) as? PrivilegedService else {
            failed()
            return
        }
        proxy.execute(payload, deadline: deadline.end.uptimeNanoseconds) { status, diagnostic in
            request.finish(status == 0 ? nil : MihomoGUIError(diagnostic ?? "特权操作失败（\(status)），请检查内核状态和日志"))
        }
    }
}
