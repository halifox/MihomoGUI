import Foundation
import Darwin
import MihomoGUICore

func runCommand(_ executable: String, _ arguments: [String], timeout: TimeInterval = 45, expiresAt: DispatchTime? = nil) async throws -> String {
    try await Task.detached {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: executable); process.arguments = arguments
        let pipe = Pipe()
        process.standardOutput = pipe; process.standardError = pipe
        defer { try? pipe.fileHandleForReading.close(); try? pipe.fileHandleForWriting.close() }
        try process.run()
        let deadline = ProcessDeadline(process: process, timeout: timeout, expiresAt: expiresAt)
        defer {
            if process.isRunning {
                let pid = process.processIdentifier
                kill(getpgid(pid) == pid ? -pid : pid, SIGKILL)
                process.waitUntilExit()
            }
            deadline.invalidate()
        }
        try pipe.fileHandleForWriting.close()
        let descriptor = pipe.fileHandleForReading.fileDescriptor
        let flags = fcntl(descriptor, F_GETFL)
        guard flags >= 0, fcntl(descriptor, F_SETFL, flags | O_NONBLOCK) == 0 else { throw MihomoGUIError("无法读取子进程输出") }
        var output = Data()
        var buffer = [UInt8](repeating: 0, count: 4096)
        while true {
            var event = pollfd(fd: descriptor, events: Int16(POLLIN), revents: 0)
            let ready = poll(&event, 1, 100)
            if ready < 0 {
                if errno == EINTR { continue }
                throw MihomoGUIError("读取子进程输出失败")
            }
            if ready > 0 {
                let count = Darwin.read(descriptor, &buffer, buffer.count)
                if count == 0 { break }
                if count > 0 {
                    output.append(contentsOf: buffer.prefix(min(count, 16_384 - output.count)))
                } else if errno != EAGAIN && errno != EINTR { throw MihomoGUIError("读取子进程输出失败") }
            }
            // A completed command may leave a descendant holding the pipe open.
            // Retain the prefix already available, without waiting for that descendant.
            if !process.isRunning && (ready == 0 || output.count == 16_384) { break }
            try deadline.check()
        }
        process.waitUntilExit()
        try deadline.check()
        let text = String(decoding: output, as: UTF8.self)
        guard process.terminationStatus == 0 else {
            throw MihomoGUIError(text.isEmpty ? "操作失败（\(process.terminationStatus)）" : text)
        }
        return text
    }.value
}

func administratorCommand(_ command: String, timeout: TimeInterval = 180, expiresAt: DispatchTime? = nil) async throws {
    let script = "on run argv\n do shell script (item 1 of argv) with administrator privileges\nend run"
    _ = try await runCommand("/usr/bin/osascript", ["-e", script, command], timeout: timeout, expiresAt: expiresAt)
}

// Shared by initial installation and live reloads; keep generated file paths in sync.
func stageRuleProviderFiles(_ settings: Settings, directory: URL) throws -> [String] {
    try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true, attributes: [.posixPermissions: 0o700])
    var ruleFiles: [String] = []
    let resources = settings.options?["rule-providers"]?.object ?? [:]
    for (index, name) in resources.keys.sorted().enumerated() {
        let fields = resources[name]?.object ?? [:]
        guard fields["type"] == .string("file") else { continue }
        let source = URL(fileURLWithPath: fields["path"]?.text ?? "")
        let filename = "set-\(index)." + (fields["format"]?.text ?? "yaml")
        try FileManager.default.copyItem(at: source, to: directory.appendingPathComponent(filename))
        try FileManager.default.setAttributes([.posixPermissions: 0o600], ofItemAtPath: directory.appendingPathComponent(filename).path)
        ruleFiles.append(filename)
    }
    return ruleFiles
}

func installAndStartCore(settings: Settings, config: Data, directory: URL, groupSelections: [String: String] = [:]) async throws {
    guard FileManager.default.isExecutableFile(atPath: settings.corePath) else { throw MihomoGUIError("应用内置 mihomo 内核缺失或不可执行，请重新安装应用") }
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
    _ = try await Task.detached { try stageRuleProviderFiles(settings, directory: stagedRules) }.value
    let versionOutput = try await runCommand(binary.path, ["-v"])
    let versionParts = versionOutput.split(whereSeparator: \.isWhitespace)
    guard versionParts.count >= 3, versionParts[0] == "Mihomo", versionParts[1] == "Meta" else {
        throw MihomoGUIError("无法识别内置 mihomo 版本，请重新安装应用")
    }
    try validateConfigurationCoreVersion(String(versionParts[2]))
    _ = try await runCommand(binary.path, ["-t", "-d", staging.path, "-f", configFile.path])
    // Installation may succeed even if its reply or the local runtime save fails.
    // Persist recovery intent before the first system-service side effect.
    var selections = try applicableProxyGroupSelections(groupSelections, settings: settings)
    for group in settings.proxyGroups ?? [] where group.type == "select" && selections[group.name] == nil {
        if let selected = group.fields["default-selected"]?.text, !selected.isEmpty {
            selections[group.name] = try proxyTargetName(selected, settings: settings)
        }
    }
    try saveRuntimeUpdateSelections(selections, directory: directory)
    try await privilegedOperation(.install(staging: staging.path, settings: settings))
    let controller = try CoreAPI(settings: settings)
    for name in selections.keys.sorted() {
        if let target = selections[name] { try await controller.selectProxyGroup(name, target: target) }
    }
    try saveRuntimeSettings(settings, to: directory)
}

func stopCore() async throws {
    try await privilegedOperation(.stop)
}

func servicePID(domain: String, label: String) async -> Int? {
    guard let output = try? await runCommand("/bin/launchctl", ["print", domain + "/" + label]),
          let expression = try? NSRegularExpression(pattern: "(?m)^\\s*pid = (\\d+)\\s*$"),
          let match = expression.firstMatch(in: output, range: NSRange(output.startIndex..., in: output)),
          let range = Range(match.range(at: 1), in: output) else { return nil }
    return Int(output[range])
}

func persistCoreConfiguration(_ config: Data) async throws {
    try await privilegedOperation(.persist(config))
}

// Saved before the helper can replace any rule file; retained until full recovery succeeds.
struct RuleFileUpdate: Codable {
    let schemaVersion: Int
    let id: UUID
    let filenames: [String]
    let previousSettings: Settings
    var committed: Bool

    static func load(directory: URL) throws -> RuleFileUpdate? {
        let url = directory.appendingPathComponent("rule-update-pending.json")
        guard FileManager.default.fileExists(atPath: url.path) else { return nil }
        let update = try JSONDecoder().decode(Self.self, from: Data(contentsOf: url))
        guard update.schemaVersion == 1 else { throw MihomoGUIError("规则恢复记录版本不受支持，原文件未修改") }
        return update
    }
    func save(directory: URL) throws {
        let url = directory.appendingPathComponent("rule-update-pending.json")
        try JSONEncoder().encode(self).write(to: url, options: .atomic)
        try FileManager.default.setAttributes([.posixPermissions: 0o600], ofItemAtPath: url.path)
    }
    func clear(directory: URL) throws {
        let url = directory.appendingPathComponent("rule-update-pending.json")
        if FileManager.default.fileExists(atPath: url.path) { try FileManager.default.removeItem(at: url) }
    }
    func finish(restore: Bool) async throws {
        try await privilegedOperation(.finishRules(id: id, filenames: filenames, restore: restore))
    }
}

func prepareRuleFileUpdate(_ settings: Settings, previousSettings: Settings, directory: URL) async throws -> RuleFileUpdate? {
    let resources = settings.options?["rule-providers"]?.object ?? [:]
    guard resources.values.contains(where: { $0.object["type"] == .string("file") }) else { return nil }
    guard try RuleFileUpdate.load(directory: directory) == nil else { throw MihomoGUIError("请先完成上一次规则文件事务恢复") }
    let staging = FileManager.default.temporaryDirectory.appendingPathComponent("MihomoGUI-rules-" + UUID().uuidString)
    defer { try? FileManager.default.removeItem(at: staging) }
    let filenames = try await Task.detached { try stageRuleProviderFiles(settings, directory: staging) }.value
    let update = RuleFileUpdate(schemaVersion: 1, id: UUID(), filenames: filenames, previousSettings: previousSettings, committed: false)
    try update.save(directory: directory)
    try await privilegedOperation(.prepareRules(staging: staging.path, id: update.id, filenames: filenames))
    return update
}
