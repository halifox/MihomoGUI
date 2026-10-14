import Foundation
import ClashCore

@main
struct ServiceTests {
    static func main() async throws {
        let folder = FileManager.default.temporaryDirectory.appendingPathComponent("clash-services-test-" + UUID().uuidString)
        try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: folder) }
        for mode in ["success", "bootstrap-failure", "health-failure", "write-failure"] {
            let base = folder.appendingPathComponent(mode)
            let stage = base.appendingPathComponent("stage")
            let user = base.appendingPathComponent("user")
            let root = base.appendingPathComponent("core")
            let helper = base.appendingPathComponent("helper")
            for path in [stage, user, root, helper] { try FileManager.default.createDirectory(at: path, withIntermediateDirectories: true) }
            let binary = helper.appendingPathComponent("mihomo")
            let logger = URL(fileURLWithPath: binary.path + "-logger")
            let daemon = base.appendingPathComponent("daemon.plist")
            let runtime = user.appendingPathComponent("runtime.json")
            let config = root.appendingPathComponent("config.yaml")
            let old = Data("old".utf8), new = Data("new".utf8)
            for file in [binary, logger, daemon, runtime, config] { try old.write(to: file) }
            for name in ["mihomo", "logger", "config.yaml", "test.core.plist", "runtime.json", "health.curl"] { try new.write(to: stage.appendingPathComponent(name)) }
            let marker = base.appendingPathComponent("failed-once")
            let launch = base.appendingPathComponent("launchctl")
            let launchScript = """
            #!/bin/sh
            if [ "$1" = bootstrap ] && [ \(shellQuote(mode)) = bootstrap-failure ] && [ ! -e \(shellQuote(marker.path)) ]; then
                touch \(shellQuote(marker.path))
                exit 1
            fi
            exit 0
            """
            try launchScript.write(to: launch, atomically: true, encoding: .utf8)
            try FileManager.default.setAttributes([.posixPermissions: 0o700], ofItemAtPath: launch.path)
            let seeds = mode == "write-failure" ? ["/usr/bin/false"] : []
            var command = coreInstallCommand(staging: stage, directory: user, seedCommands: seeds,
                rootDirectory: root.path, installedCore: binary.path, coreLabel: "test.core", destinationPlist: daemon.path)
            command = command.replacingOccurrences(of: "/bin/launchctl", with: shellQuote(launch.path))
                .replacingOccurrences(of: " -o root -g wheel", with: "")
                .replacingOccurrences(of: "/usr/sbin/chown root:wheel", with: "/usr/bin/true")
                .replacingOccurrences(of: "/usr/bin/curl", with: mode == "health-failure" ? "/usr/bin/false" : "/usr/bin/true")
                .replacingOccurrences(of: "/bin/sleep 1", with: "/usr/bin/true")
            var failed = false
            do { _ = try await runCommand("/bin/sh", ["-c", command]) } catch { failed = true }
            guard failed == (mode != "success") else { throw DeskError("Unexpected result: " + mode) }
            for file in [binary, logger, daemon, runtime, config] {
                guard try Data(contentsOf: file) == (mode == "success" ? new : old) else {
                    throw DeskError("File was not restored: " + file.path)
                }
            }
            print("PASS: install " + mode + " preserves coherent core, logger, plist, configuration and runtime")
        }
    }
}
