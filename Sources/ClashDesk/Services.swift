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
    let stage = directory.appendingPathComponent("stats-install-" + UUID().uuidString)
    try FileManager.default.createDirectory(at: stage, withIntermediateDirectories: true, attributes: [.posixPermissions: 0o700])
    defer { try? FileManager.default.removeItem(at: stage) }
    let stagedBinary = stage.appendingPathComponent("clash-stats")
    let stagedPlist = stage.appendingPathComponent("stats.plist")
    try FileManager.default.copyItem(at: source, to: stagedBinary)
    try FileManager.default.setAttributes([.posixPermissions: 0o700], ofItemAtPath: stagedBinary.path)
    try writePlist([
        "Label": statsLabel, "ProgramArguments": [target.path, "--directory", directory.path],
        "RunAtLoad": true, "KeepAlive": true, "ThrottleInterval": 10,
        "StandardOutPath": "/dev/null", "StandardErrorPath": "/dev/null",
        "ProcessType": "Background", "Umask": 0o077
    ], to: stagedPlist)
    let wasRunning = await servicePID(domain: domain, label: statsLabel) != nil
    let disabledOutput = try await runCommand("/bin/launchctl", ["print-disabled", domain])
    let wasDisabled = disabledOutput.contains("\"" + statsLabel + "\" => true")
    let oldBinary = stage.appendingPathComponent("old-binary")
    let oldPlist = stage.appendingPathComponent("old-plist")
    if FileManager.default.fileExists(atPath: target.path) { try FileManager.default.copyItem(at: target, to: oldBinary) }
    if FileManager.default.fileExists(atPath: plist.path) { try FileManager.default.copyItem(at: plist, to: oldPlist) }
    _ = try? await runCommand("/bin/launchctl", ["bootout", domain + "/" + statsLabel])
    do {
        try Data(contentsOf: stagedBinary).write(to: target, options: .atomic)
        try FileManager.default.setAttributes([.posixPermissions: 0o700], ofItemAtPath: target.path)
        try Data(contentsOf: stagedPlist).write(to: plist, options: .atomic)
        try FileManager.default.setAttributes([.posixPermissions: 0o600], ofItemAtPath: plist.path)
        _ = try await runCommand("/bin/launchctl", ["enable", domain + "/" + statsLabel])
        _ = try await runCommand("/bin/launchctl", ["bootstrap", domain, plist.path])
    } catch {
        let original = error
        _ = try? await runCommand("/bin/launchctl", ["bootout", domain + "/" + statsLabel])
        do {
            for (backup, destination) in [(oldBinary, target), (oldPlist, plist)] {
                if FileManager.default.fileExists(atPath: destination.path) { try FileManager.default.removeItem(at: destination) }
                if FileManager.default.fileExists(atPath: backup.path) { try FileManager.default.copyItem(at: backup, to: destination) }
            }
            _ = try await runCommand("/bin/launchctl", [wasDisabled ? "disable" : "enable", domain + "/" + statsLabel])
            if wasRunning { _ = try await runCommand("/bin/launchctl", ["bootstrap", domain, plist.path]) }
        } catch { throw DeskError("统计服务更新失败且恢复失败：\(original.localizedDescription)；\(error.localizedDescription)") }
        throw original
    }
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
    let stagedRules = staging.appendingPathComponent("rules")
    try FileManager.default.createDirectory(at: stagedRules, withIntermediateDirectories: true, attributes: [.posixPermissions: 0o700])
    var ruleFiles: [String] = []
    let resources = settings.options?["rule-providers"]?.object ?? [:]
    for (index, name) in resources.keys.sorted().enumerated() {
        let fields = resources[name]?.object ?? [:]
        guard fields["type"] == .string("file") else { continue }
        let source = URL(fileURLWithPath: fields["path"]?.text ?? "")
        let filename = "set-\(index)." + (fields["format"]?.text ?? "yaml")
        try FileManager.default.copyItem(at: source, to: stagedRules.appendingPathComponent(filename))
        try FileManager.default.setAttributes([.posixPermissions: 0o600], ofItemAtPath: stagedRules.appendingPathComponent(filename).path)
        ruleFiles.append(filename)
    }
    _ = try await runCommand(binary.path, ["-v"])
    _ = try await runCommand(binary.path, ["-t", "-d", staging.path, "-f", configFile.path])
    let logger = staging.appendingPathComponent("logger")
    guard FileManager.default.isExecutableFile(atPath: statisticsExecutable().path) else { throw DeskError("找不到内核日志采集程序，请重新构建应用") }
    try FileManager.default.copyItem(at: statisticsExecutable(), to: logger)
    let installedLogger = installedCore + "-logger"
    let coreCommand = shellQuote(installedCore) + " -d " + shellQuote(rootDirectory) + " -f " + shellQuote(rootDirectory + "/config.yaml")
        + " 2>&1 | " + shellQuote(installedLogger) + " --log-stream " + shellQuote(rootDirectory + "/core.log")
    let plist = staging.appendingPathComponent(coreLabel + ".plist")
    try writePlist([
        "Label": coreLabel,
        "ProgramArguments": ["/bin/sh", "-c", coreCommand],
        "RunAtLoad": true, "KeepAlive": true, "ThrottleInterval": 10,
        "StandardOutPath": "/dev/null", "StandardErrorPath": "/dev/null", "Umask": 0o077
    ], to: plist)
    var seedCommands: [String] = ["/bin/test ! -L \(shellQuote(rootDirectory + "/rules"))", "/bin/mkdir -p \(shellQuote(rootDirectory + "/rules"))", "/bin/chmod 700 \(shellQuote(rootDirectory + "/rules"))"]
    for name in ruleFiles {
        let target = rootDirectory + "/rules/" + name
        seedCommands.append("/bin/test ! -L \(shellQuote(target))")
        seedCommands.append("/usr/bin/install -o root -g wheel -m 600 \(shellQuote(stagedRules.appendingPathComponent(name).path)) \(shellQuote(target))")
    }
    for name in geoNames {
        let target = rootDirectory + "/" + name
        seedCommands.append("/bin/test ! -L \(shellQuote(target))")
        seedCommands.append("/usr/bin/install -o root -g wheel -m 600 \(shellQuote(staging.appendingPathComponent(name).path)) \(shellQuote(target))")
    }
    let runtime = staging.appendingPathComponent("runtime.json")
    try JSONEncoder().encode(settings).write(to: runtime)
    try FileManager.default.setAttributes([.posixPermissions: 0o600], ofItemAtPath: runtime.path)
    let endpoint = try controllerEndpoint(settings)
    let host = endpoint.host.contains(":") && !endpoint.host.hasPrefix("[") ? "[\(endpoint.host)]" : endpoint.host
    func curlEscape(_ value: String) -> String { value.replacingOccurrences(of: "\\", with: "\\\\").replacingOccurrences(of: "\"", with: "\\\"") }
    let health = staging.appendingPathComponent("health.curl")
    let healthText = "url = \"http://\(host):\(endpoint.port)/version\"\nheader = \"Authorization: Bearer \(curlEscape(endpoint.secret))\"\n"
    try healthText.write(to: health, atomically: true, encoding: .utf8)
    try FileManager.default.setAttributes([.posixPermissions: 0o600], ofItemAtPath: health.path)
    let command = coreInstallCommand(staging: staging, directory: directory, seedCommands: seedCommands)
    try await administratorCommand(command)
}

// Kept separate so rollback can be exercised against temporary files without administrator access.
func coreInstallCommand(staging: URL, directory: URL, seedCommands: [String],
                        rootDirectory: String = ClashCore.rootDirectory, installedCore: String = ClashCore.installedCore,
                        coreLabel: String = ClashCore.coreLabel, destinationPlist: String? = nil) -> String {
    let helperDirectory = URL(fileURLWithPath: installedCore).deletingLastPathComponent().path
    let installedLogger = installedCore + "-logger"
    let destinationPlist = destinationPlist ?? "/Library/LaunchDaemons/" + coreLabel + ".plist"
    let runtimeTarget = directory.appendingPathComponent("runtime.json").path
    let binary = staging.appendingPathComponent("mihomo")
    let logger = staging.appendingPathComponent("logger")
    let configFile = staging.appendingPathComponent("config.yaml")
    let plist = staging.appendingPathComponent(coreLabel + ".plist")
    let runtime = staging.appendingPathComponent("runtime.json")
    let health = staging.appendingPathComponent("health.curl")
    return """
    set -eu
    /bin/test ! -L \(shellQuote(rootDirectory))
    /bin/test ! -L \(shellQuote(helperDirectory))
    /bin/mkdir -p \(shellQuote(rootDirectory)) \(shellQuote(helperDirectory))
    /usr/sbin/chown root:wheel \(shellQuote(rootDirectory)) \(shellQuote(helperDirectory))
    /bin/chmod 700 \(shellQuote(rootDirectory)) \(shellQuote(helperDirectory))
    /bin/test ! -L \(shellQuote(installedLogger))
    /bin/test ! -L \(shellQuote(installedCore))
    /bin/test ! -L \(shellQuote(rootDirectory + "/config.yaml"))
    /bin/test ! -L \(shellQuote(destinationPlist))
    backup=$(/usr/bin/mktemp -d /private/tmp/clashdesk-rollback.XXXXXXXX)
    /bin/chmod 700 "$backup"
    trap '/bin/rm -rf "$backup"' EXIT
    disabled=0
    if /bin/launchctl print-disabled system | /usr/bin/grep -F \(shellQuote("\"" + coreLabel + "\" => true")) >/dev/null; then disabled=1; fi
    loaded=0
    /bin/launchctl print system/\(coreLabel) >/dev/null 2>&1 && loaded=1
    [ ! -e \(shellQuote(rootDirectory)) ] || /bin/cp -pR \(shellQuote(rootDirectory)) "$backup/core"
    [ ! -e \(shellQuote(installedCore)) ] || /bin/cp -p \(shellQuote(installedCore)) "$backup/binary"
    [ ! -e \(shellQuote(installedLogger)) ] || /bin/cp -p \(shellQuote(installedLogger)) "$backup/logger"
    [ ! -e \(shellQuote(destinationPlist)) ] || /bin/cp -p \(shellQuote(destinationPlist)) "$backup/plist"
    /bin/test ! -L \(shellQuote(runtimeTarget))
    [ ! -e \(shellQuote(runtimeTarget)) ] || /bin/cp -p \(shellQuote(runtimeTarget)) "$backup/runtime"
    rollback() {
        status=$?
        trap - EXIT HUP INT TERM
        if [ "$status" -ne 0 ]; then
            set +e
            /bin/launchctl bootout system/\(coreLabel) >/dev/null 2>&1
            if [ -f \(shellQuote(rootDirectory + "/core.log")) ]; then /bin/cp -p \(shellQuote(rootDirectory + "/core.log")) "$backup/failure.log"; fi
            /bin/rm -rf \(shellQuote(rootDirectory))
            /bin/rm -f \(shellQuote(installedCore)) \(shellQuote(installedLogger)) \(shellQuote(destinationPlist)) \(shellQuote(runtimeTarget))
            restored=1
            if [ -e "$backup/core" ]; then /bin/cp -pR "$backup/core" \(shellQuote(rootDirectory)) || restored=0; fi
            if [ -e "$backup/failure.log" ]; then
                /bin/mkdir -p \(shellQuote(rootDirectory))
                /bin/chmod 700 \(shellQuote(rootDirectory))
                /bin/cp -p "$backup/failure.log" \(shellQuote(rootDirectory + "/core-failure.log")) || restored=0
            fi
            if [ -e "$backup/logger" ]; then /bin/cp -p "$backup/logger" \(shellQuote(installedLogger)) || restored=0; fi
            if [ -e "$backup/binary" ]; then /bin/cp -p "$backup/binary" \(shellQuote(installedCore)) || restored=0; fi
            if [ -e "$backup/plist" ]; then /bin/cp -p "$backup/plist" \(shellQuote(destinationPlist)) || restored=0; fi
            if [ -e "$backup/runtime" ]; then /bin/cp -p "$backup/runtime" \(shellQuote(runtimeTarget)) || restored=0; fi
            if [ "$disabled" -eq 1 ]; then
                /bin/launchctl disable system/\(coreLabel) || restored=0
            else
                /bin/launchctl enable system/\(coreLabel) || restored=0
            fi
            if [ "$loaded" -eq 1 ]; then /bin/launchctl bootstrap system \(shellQuote(destinationPlist)) || restored=0; fi
            if [ "$restored" -eq 0 ]; then
                echo "恢复失败，备份保留于 $backup" >&2
                exit "$status"
            fi
            echo "安装失败，已恢复旧配置和服务" >&2
        fi
        /bin/rm -rf "$backup"
        exit "$status"
    }
    trap rollback EXIT
    trap 'exit 1' HUP INT TERM
    /bin/launchctl bootout system/\(coreLabel) >/dev/null 2>&1 || true
    /usr/bin/install -o root -g wheel -m 700 \(shellQuote(logger.path)) \(shellQuote(installedLogger))
    /usr/bin/install -o root -g wheel -m 700 \(shellQuote(binary.path)) \(shellQuote(installedCore))
    /usr/bin/install -o root -g wheel -m 600 \(shellQuote(configFile.path)) \(shellQuote(rootDirectory + "/config.yaml"))
    \(seedCommands.joined(separator: "\n"))
    /usr/bin/install -o root -g wheel -m 644 \(shellQuote(plist.path)) \(shellQuote(destinationPlist))
    /usr/bin/install -o \(getuid()) -g \(getgid()) -m 600 \(shellQuote(runtime.path)) \(shellQuote(runtimeTarget))
    /bin/launchctl enable system/\(coreLabel)
    /bin/launchctl bootstrap system \(shellQuote(destinationPlist))
    ready=0
    for attempt in 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15; do
        if /usr/bin/curl --noproxy '*' --fail --silent --output /dev/null --max-time 1 --config \(shellQuote(health.path)); then ready=1; break; fi
        /bin/sleep 1
    done
    [ "$ready" -eq 1 ] || { echo "内核启动后控制接口未就绪" >&2; exit 1; }
    """
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

func readCoreLog() async throws -> String {
    let path = shellQuote(rootDirectory + "/core.log")
    let command = "if [ -f " + path + " ]; then /usr/bin/tail -n 500 " + path + "; else echo '暂无内核日志'; fi"
    let script = "on run argv\n do shell script (item 1 of argv) with administrator privileges\nend run"
    return try await runCommand("/usr/bin/osascript", ["-e", script, command])
}

func persistCoreConfiguration(_ config: Data) async throws {
    let file = FileManager.default.temporaryDirectory.appendingPathComponent("clashdesk-config-" + UUID().uuidString)
    try config.write(to: file, options: .atomic)
    try FileManager.default.setAttributes([.posixPermissions: 0o600], ofItemAtPath: file.path)
    defer { try? FileManager.default.removeItem(at: file) }
    let target = rootDirectory + "/config.yaml"
    let staged = target + "." + UUID().uuidString
    let command = "set -e; /usr/bin/install -o root -g wheel -m 600 " + shellQuote(file.path) + " " + shellQuote(staged)
        + "; /bin/mv -f " + shellQuote(staged) + " " + shellQuote(target)
    let script = "on run argv\n do shell script (item 1 of argv) with administrator privileges\nend run"
    _ = try await runCommand("/usr/bin/osascript", ["-e", script, command])
}
