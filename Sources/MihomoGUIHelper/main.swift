import Foundation
import MihomoGUICore

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

    func execute(_ payload: Data, reply: @escaping (Int32) -> Void) {
        queue.async {
            do {
                guard payload.count <= 32 * 1024 * 1024 else { reply(64); return }
                let operation = try JSONDecoder().decode(PrivilegedOperation.self, from: payload)
                reply(try executeOperation(operation, owner: self.owner, coreRequirement: self.coreRequirement))
            } catch { reply(-1) }
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
