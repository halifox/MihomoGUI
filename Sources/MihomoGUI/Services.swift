import Foundation
import MihomoGUICore

func runCommand(_ executable: String, _ arguments: [String], timeout: TimeInterval = 45) async throws -> String {
    try await Task.detached {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: executable); process.arguments = arguments
        let output = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        FileManager.default.createFile(atPath: output.path, contents: nil, attributes: [.posixPermissions: 0o600])
        let handle = try FileHandle(forWritingTo: output)
        defer { try? handle.close(); try? FileManager.default.removeItem(at: output) }
        process.standardOutput = handle; process.standardError = handle
        try process.run()
        let deadline = ProcessDeadline(process: process, timeout: timeout)
        defer { deadline.invalidate() }
        process.waitUntilExit()
        try deadline.check()
        let data = try Data(contentsOf: output)
        let text = String(decoding: data.prefix(16_384), as: UTF8.self)
        guard process.terminationStatus == 0 else {
            throw MihomoGUIError(text.isEmpty ? "操作失败（\(process.terminationStatus)）" : text)
        }
        return text
    }.value
}

func administratorCommand(_ command: String) async throws {
    let script = "on run argv\n do shell script (item 1 of argv) with administrator privileges\nend run"
    _ = try await runCommand("/usr/bin/osascript", ["-e", script, command], timeout: 180)
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

func installAndStartCore(settings: Settings, config: Data, directory: URL) async throws {
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
    let pending = directory.appendingPathComponent("runtime-update-pending")
    try Data().write(to: pending, options: .atomic)
    try FileManager.default.setAttributes([.posixPermissions: 0o600], ofItemAtPath: pending.path)
    try await privilegedOperation(.install(staging: staging.path, settings: settings))
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

struct RuleFileUpdate {
    let id: UUID
    let filenames: [String]

    func finish(restore: Bool) async throws {
        try await privilegedOperation(.finishRules(id: id, filenames: filenames, restore: restore))
    }
}

func prepareRuleFileUpdate(_ settings: Settings) async throws -> RuleFileUpdate? {
    let resources = settings.options?["rule-providers"]?.object ?? [:]
    guard resources.values.contains(where: { $0.object["type"] == .string("file") }) else { return nil }
    let staging = FileManager.default.temporaryDirectory.appendingPathComponent("MihomoGUI-rules-" + UUID().uuidString)
    defer { try? FileManager.default.removeItem(at: staging) }
    let filenames = try await Task.detached { try stageRuleProviderFiles(settings, directory: staging) }.value
    let update = RuleFileUpdate(id: UUID(), filenames: filenames)
    try await privilegedOperation(.prepareRules(staging: staging.path, id: update.id, filenames: filenames))
    return update
}
