import Foundation
import MihomoGUICore

// The timer can reply while a system API is blocked; every later phase still
// checks the same deadline before it may change the live service or files.
private final class PrivilegedReply {
    private let lock = NSLock()
    private let reply: (Int32, String?) -> Void
    private var completed = false
    private var timeout: DispatchWorkItem?
    init(deadline: PrivilegedOperationDeadline, reply: @escaping (Int32, String?) -> Void) {
        self.reply = reply
        let timeout = DispatchWorkItem { [weak self] in self?.finish(-1, "操作超时，结果可能未知，请检查系统服务状态后重试") }
        self.timeout = timeout
        DispatchQueue.global(qos: .utility).asyncAfter(deadline: deadline.end, execute: timeout)
    }
    func finish(_ status: Int32, _ diagnostic: String?) {
        lock.lock()
        guard !completed else { lock.unlock(); return }
        completed = true
        timeout?.cancel(); timeout = nil
        lock.unlock()
        reply(status, diagnostic)
    }
}

// launchd owns this process; GUI connections may disappear without stopping the core.
final class Service: NSObject, NSXPCListenerDelegate, PrivilegedService {
    let owner: uid_t
    let requirement: String
    let coreRequirement: String
    let queue = DispatchQueue(label: "local.MihomoGUI.helper.commands")

    init(owner: uid_t, requirement: String, coreRequirement: String) {
        self.owner = owner
        self.requirement = requirement
        self.coreRequirement = coreRequirement
    }

    func listener(_ listener: NSXPCListener, shouldAcceptNewConnection connection: NSXPCConnection) -> Bool {
        guard connection.effectiveUserIdentifier == owner else { return false }
        // Foundation checks the actual XPC peer for every message, avoiding PID lookup races.
        connection.setCodeSigningRequirement(requirement)
        connection.exportedInterface = NSXPCInterface(with: PrivilegedService.self)
        connection.exportedObject = self
        connection.resume()
        return true
    }

    func execute(_ payload: Data, deadline clientDeadline: UInt64, reply: @escaping (Int32, String?) -> Void) {
        let deadline = PrivilegedOperationDeadline(clientDeadline: clientDeadline)
        let response = PrivilegedReply(deadline: deadline, reply: reply)
        queue.async {
            let reply = response.finish
            do { try deadline.check() }
            catch { reply(-1, "操作超时，结果可能未知，请检查系统服务状态后重试"); return }
            do {
                guard payload.count <= privilegedPayloadMaximumBytes else { reply(64, "特权请求超过大小限制"); return }
                let operation = try JSONDecoder().decode(PrivilegedOperation.self, from: payload)
                try deadline.check()
                reply(try executeOperation(operation, owner: self.owner, coreRequirement: self.coreRequirement, deadline: deadline), nil)
            } catch let error as PrivilegedCommandFailure {
                reply(-1, error.diagnostic)
            } catch let error as MihomoGUIError {
                reply(-1, safePrivilegedDiagnostic(status: -1, output: error.message))
            } catch { reply(-1, "特权操作输入无效或文件读写失败，请检查安装文件和系统权限") }
        }
    }

}

guard getuid() == 0, CommandLine.arguments.count == 4,
      let owner = uid_t(CommandLine.arguments[1]), owner != 0 else { exit(64) }
let service = Service(owner: owner, requirement: CommandLine.arguments[2], coreRequirement: CommandLine.arguments[3])
let listener = NSXPCListener(machServiceName: privilegedServiceLabel)
listener.delegate = service
listener.resume()
RunLoop.current.run()
