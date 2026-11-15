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
private final class PrivilegedRequest {
    let connection: NSXPCConnection
    let lock = NSLock()
    var continuation: CheckedContinuation<Void, Error>?

    init(connection: NSXPCConnection, continuation: CheckedContinuation<Void, Error>) {
        self.connection = connection
        self.continuation = continuation
    }

    func finish(_ error: Error? = nil) {
        lock.lock()
        let pending = continuation
        continuation = nil
        lock.unlock()
        guard let pending else { return }
        connection.invalidationHandler = nil
        connection.interruptionHandler = nil
        connection.invalidate()
        if let error { pending.resume(throwing: error) } else { pending.resume() }
    }
}

func privilegedOperation(_ operation: PrivilegedOperation) async throws {
    let payload = try JSONEncoder().encode(operation)
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
    let clientRequirement = try signingRequirement(applicationStaticCode)
    let helperRequirement = try signingRequirement(helperCode)
    let coreRequirement = try signingRequirement(coreCode)
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
    let registered = (try? await runCommand("/bin/launchctl", ["print", "system/" + privilegedServiceLabel])) != nil
    if (try? Data(contentsOf: URL(fileURLWithPath: installed))) != sourceData
        || installedProperties != plist as NSDictionary || !registered {
        // Only installation/update asks macOS for authorization. Never retry a submitted command.
        try await administratorCommand("""
        set -eu
        /bin/test ! -L /Library/PrivilegedHelperTools
        /bin/test ! -L /Library/LaunchDaemons
        /bin/test ! -L \(shellQuote(installed))
        /bin/test ! -L \(shellQuote(plistPath))
        /bin/mkdir -p /Library/PrivilegedHelperTools
        stage=$(/usr/bin/mktemp -d /private/tmp/MihomoGUIHelper.XXXXXX)
        trap '/bin/rm -rf "$stage"' EXIT
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
            exit "$status"
        }
        trap rollback EXIT
        /bin/launchctl bootout system/\(privilegedServiceLabel) >/dev/null 2>&1 || true
        /usr/bin/install -o root -g wheel -m 755 "$stage/helper" \(shellQuote(installed))
        /usr/bin/install -o root -g wheel -m 644 "$stage/helper.plist" \(shellQuote(plistPath))
        /bin/launchctl enable system/\(privilegedServiceLabel)
        /bin/launchctl bootstrap system \(shellQuote(plistPath))
        """)
    }
    let connection = NSXPCConnection(machServiceName: privilegedServiceLabel, options: .privileged)
    connection.setCodeSigningRequirement(helperRequirement)
    connection.remoteObjectInterface = NSXPCInterface(with: PrivilegedService.self)
    try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
        let request = PrivilegedRequest(connection: connection, continuation: continuation)
        let failed = { request.finish(MihomoGUIError("特权辅助服务连接中断；操作结果未知，请检查内核状态后重试。若持续失败，请重新安装应用。")) }
        connection.invalidationHandler = failed
        connection.interruptionHandler = failed
        connection.resume()
        guard let proxy = connection.remoteObjectProxyWithErrorHandler({ _ in failed() }) as? PrivilegedService else {
            failed()
            return
        }
        proxy.execute(payload) { status, diagnostic in
            request.finish(status == 0 ? nil : MihomoGUIError(diagnostic ?? "特权操作失败（\(status)），请检查内核状态和日志"))
        }
    }
}
