import Foundation
import ClashCore

func shellQuote(_ string: String) -> String { "'" + string.replacingOccurrences(of: "'", with: "'\\''") + "'" }

func runCommand(_ executable: String, _ arguments: [String]) async throws -> String {
    try await Task.detached {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: executable); process.arguments = arguments
        let output = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        FileManager.default.createFile(atPath: output.path, contents: nil, attributes: [.posixPermissions: 0o600])
        let handle = try FileHandle(forWritingTo: output)
        defer { try? handle.close(); try? FileManager.default.removeItem(at: output) }
        process.standardOutput = handle; process.standardError = handle
        try process.run(); process.waitUntilExit()
        let data = try Data(contentsOf: output)
        let text = String(decoding: data.prefix(16_384), as: UTF8.self)
        guard process.terminationStatus == 0 else {
            throw DeskError(text.isEmpty ? "操作失败（\(process.terminationStatus)）" : text)
        }
        return text
    }.value
}

func administratorCommand(_ command: String) async throws {
    let script = "on run argv\n do shell script (item 1 of argv) with administrator privileges\nend run"
    _ = try await runCommand("/usr/bin/osascript", ["-e", script, command])
}

func writePlist(_ dictionary: [String: Any], to url: URL) throws {
    let data = try PropertyListSerialization.data(fromPropertyList: dictionary, format: .xml, options: 0)
    try data.write(to: url, options: .atomic)
    try FileManager.default.setAttributes([.posixPermissions: 0o600], ofItemAtPath: url.path)
}

func statisticsExecutable() -> URL {
    let bundled = Bundle.main.bundleURL.appendingPathComponent("Contents/Helpers/clash-stats")
    let adjacent = URL(fileURLWithPath: CommandLine.arguments[0]).deletingLastPathComponent().appendingPathComponent("clash-stats")
    return FileManager.default.isExecutableFile(atPath: bundled.path) ? bundled : adjacent
}

func startStatistics(directory: URL) async throws {
    let source = statisticsExecutable()
    guard FileManager.default.isExecutableFile(atPath: source.path) else { throw DeskError("找不到 clash-stats，请使用打包脚本构建应用") }
    let target = directory.appendingPathComponent("clash-stats")
    let agents = FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent("Library/LaunchAgents")
    try FileManager.default.createDirectory(at: agents, withIntermediateDirectories: true)
    let plist = agents.appendingPathComponent(statsLabel + ".plist")
    let domain = "gui/\(getuid())"
    _ = try? await runCommand("/bin/launchctl", ["bootout", domain + "/" + statsLabel])
    if FileManager.default.fileExists(atPath: target.path) { try FileManager.default.removeItem(at: target) }
    try FileManager.default.copyItem(at: source, to: target)
    try FileManager.default.setAttributes([.posixPermissions: 0o700], ofItemAtPath: target.path)
    try writePlist([
        "Label": statsLabel, "ProgramArguments": [target.path, "--directory", directory.path],
        "RunAtLoad": true, "KeepAlive": true, "ThrottleInterval": 10,
        "StandardOutPath": "/dev/null", "StandardErrorPath": "/dev/null",
        "ProcessType": "Background", "Umask": 0o077
    ], to: plist)
    _ = try await runCommand("/bin/launchctl", ["enable", domain + "/" + statsLabel])
    _ = try await runCommand("/bin/launchctl", ["bootstrap", domain, plist.path])
}

func stopStatistics() async throws {
    let target = "gui/\(getuid())/" + statsLabel
    _ = try await runCommand("/bin/launchctl", ["disable", target])
    _ = try? await runCommand("/bin/launchctl", ["bootout", target])
}

func installAndStartCore(settings: Settings, config: Data, directory: URL) async throws {
    guard FileManager.default.isExecutableFile(atPath: settings.corePath) else { throw DeskError("请先选择可执行的 macOS mihomo 二进制文件") }
    // Stage immutable inputs for this operation, never interpolate unquoted user values into a shell.
    let staging = directory.appendingPathComponent("install-" + UUID().uuidString)
    try FileManager.default.createDirectory(at: staging, withIntermediateDirectories: false, attributes: [.posixPermissions: 0o700])
    defer { try? FileManager.default.removeItem(at: staging) }
    let binary = staging.appendingPathComponent("mihomo")
    try FileManager.default.copyItem(at: URL(fileURLWithPath: settings.corePath), to: binary)
    try FileManager.default.setAttributes([.posixPermissions: 0o700], ofItemAtPath: binary.path)
    let configFile = staging.appendingPathComponent("config.yaml")
    try config.write(to: configFile)
    try FileManager.default.setAttributes([.posixPermissions: 0o600], ofItemAtPath: configFile.path)
    // The requested DNS fallback filters require both GeoIP and GeoSite data.
    let geodata = directory.appendingPathComponent("geodata")
    let geoNames = geoAssetsNeeded(settings)
    try await prepareGeoAssets(corePath: settings.corePath, directory: geodata, names: geoNames, urls: geoDownloadURLs(settings))
    for name in geoNames {
        try FileManager.default.copyItem(at: geodata.appendingPathComponent(name), to: staging.appendingPathComponent(name))
    }
    // Seed the system core with nodes already downloaded by the GUI, before any network fetch.
    let stagedProviders = staging.appendingPathComponent("providers")
    try FileManager.default.createDirectory(at: stagedProviders, withIntermediateDirectories: false)
    for subscription in settings.subscriptions {
        let cached = providerFile(subscription, directory: directory)
        if FileManager.default.fileExists(atPath: cached.path) {
            try FileManager.default.copyItem(at: cached, to: stagedProviders.appendingPathComponent(subscription.id + ".yaml"))
        }
    }
    _ = try await runCommand(binary.path, ["-v"])
    _ = try await runCommand(binary.path, ["-t", "-d", staging.path, "-f", configFile.path])
    let plist = staging.appendingPathComponent(coreLabel + ".plist")
    try writePlist([
        "Label": coreLabel,
        "ProgramArguments": [installedCore, "-d", rootDirectory, "-f", rootDirectory + "/config.yaml"],
        "RunAtLoad": true, "KeepAlive": true, "ThrottleInterval": 10,
        "StandardOutPath": "/dev/null", "StandardErrorPath": "/dev/null", "Umask": 0o077
    ], to: plist)
    let destinationPlist = "/Library/LaunchDaemons/" + coreLabel + ".plist"
    var seedCommands: [String] = ["/bin/test ! -L \(shellQuote(rootDirectory + "/providers"))", "/bin/mkdir -p \(shellQuote(rootDirectory + "/providers"))", "/bin/chmod 700 \(shellQuote(rootDirectory + "/providers"))"]
    for name in geoNames {
        let target = rootDirectory + "/" + name
        seedCommands.append("/bin/test ! -L \(shellQuote(target))")
        seedCommands.append("/usr/bin/install -o root -g wheel -m 600 \(shellQuote(staging.appendingPathComponent(name).path)) \(shellQuote(target))")
    }
    for subscription in settings.subscriptions {
        let source = stagedProviders.appendingPathComponent(subscription.id + ".yaml")
        if FileManager.default.fileExists(atPath: source.path) {
            let target = rootDirectory + "/providers/" + subscription.id + ".yaml"
            seedCommands.append("/bin/test ! -L \(shellQuote(target))")
            seedCommands.append("/usr/bin/install -o root -g wheel -m 600 \(shellQuote(source.path)) \(shellQuote(target))")
        }
    }
    let command = """
    set -eu
    /bin/test ! -L \(shellQuote(rootDirectory))
    /bin/test ! -L /Library/PrivilegedHelperTools/ClashDesk
    /bin/mkdir -p \(shellQuote(rootDirectory)) /Library/PrivilegedHelperTools/ClashDesk
    /usr/sbin/chown root:wheel \(shellQuote(rootDirectory)) /Library/PrivilegedHelperTools/ClashDesk
    /bin/chmod 700 \(shellQuote(rootDirectory)) /Library/PrivilegedHelperTools/ClashDesk
    /bin/test ! -L \(shellQuote(installedCore))
    /bin/test ! -L \(shellQuote(rootDirectory + "/config.yaml"))
    /bin/test ! -L \(shellQuote(destinationPlist))
    /bin/launchctl bootout system/\(coreLabel) >/dev/null 2>&1 || true
    /usr/bin/install -o root -g wheel -m 700 \(shellQuote(binary.path)) \(shellQuote(installedCore))
    /usr/bin/install -o root -g wheel -m 600 \(shellQuote(configFile.path)) \(shellQuote(rootDirectory + "/config.yaml"))
    \(seedCommands.joined(separator: "\n"))
    /usr/bin/install -o root -g wheel -m 644 \(shellQuote(plist.path)) \(shellQuote(destinationPlist))
    /bin/launchctl enable system/\(coreLabel)
    /bin/launchctl bootstrap system \(shellQuote(destinationPlist))
    """
    try await administratorCommand(command)
}

func stopCore() async throws {
    try await administratorCommand("set -eu; /bin/launchctl disable system/\(coreLabel); /bin/launchctl bootout system/\(coreLabel) >/dev/null 2>&1 || true")
}

func servicePID(domain: String, label: String) async -> Int? {
    guard let output = try? await runCommand("/bin/launchctl", ["print", domain + "/" + label]),
          let expression = try? NSRegularExpression(pattern: "(?m)^\\s*pid = (\\d+)\\s*$"),
          let match = expression.firstMatch(in: output, range: NSRange(output.startIndex..., in: output)),
          let range = Range(match.range(at: 1), in: output) else { return nil }
    return Int(output[range])
}

func upgradeRunningStatistics(directory: URL) async throws {
    guard await servicePID(domain: "gui/\(getuid())", label: statsLabel) != nil else { return }
    let installed = directory.appendingPathComponent("clash-stats")
    if !FileManager.default.contentsEqual(atPath: statisticsExecutable().path, andPath: installed.path) {
        try await startStatistics(directory: directory)
    }
}
