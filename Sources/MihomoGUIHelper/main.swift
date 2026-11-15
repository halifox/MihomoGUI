import Foundation
import MihomoGUICore

// launchd owns this process; GUI connections may disappear without stopping the core.
final class Service: NSObject, NSXPCListenerDelegate, PrivilegedService {
    let owner: uid_t
    let requirement: String
    let queue = DispatchQueue(label: "local.MihomoGUI.helper.commands")

    init(owner: uid_t, requirement: String) {
        self.owner = owner
        self.requirement = requirement
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

    func execute(_ command: String, reply: @escaping (Int32) -> Void) {
        queue.async {
            let process = Process()
            process.executableURL = URL(fileURLWithPath: "/bin/sh")
            process.arguments = ["-c", command]
            // Commands may contain credentials. Never forward them to system logs.
            process.standardOutput = FileHandle.nullDevice
            process.standardError = FileHandle.nullDevice
            do {
                try process.run()
                process.waitUntilExit()
                reply(process.terminationStatus)
            } catch { reply(-1) }
        }
    }
}

guard getuid() == 0, CommandLine.arguments.count == 3,
      let owner = uid_t(CommandLine.arguments[1]), owner != 0 else { exit(64) }
let service = Service(owner: owner, requirement: CommandLine.arguments[2])
let listener = NSXPCListener(machServiceName: privilegedServiceLabel)
listener.delegate = service
listener.resume()
RunLoop.current.run()
