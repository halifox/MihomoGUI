import Foundation
import Darwin
import Security
import MihomoGUICore

// Read through one descriptor so a user-controlled symlink cannot redirect a root read.
private func readInput(_ path: String, owner: uid_t) throws -> Data {
    let descriptor = open(path, O_RDONLY | O_NOFOLLOW | O_NONBLOCK)
    guard descriptor >= 0 else { throw MihomoGUIError("无法读取操作输入") }
    let file = FileHandle(fileDescriptor: descriptor, closeOnDealloc: true)
    defer { try? file.close() }
    var info = stat()
    guard fstat(descriptor, &info) == 0, info.st_mode & S_IFMT == S_IFREG,
          info.st_uid == owner, info.st_size >= 0, info.st_size <= 128 * 1024 * 1024 else {
        throw MihomoGUIError("操作输入必须是安装用户拥有的普通文件")
    }
    return try file.readToEnd() ?? Data()
}

private func checkRuleNames(_ names: [String]) throws {
    guard Set(names).count == names.count, names.count <= 10000,
          names.allSatisfy({ $0.range(of: "^set-[0-9]+\\.(yaml|text|mrs)$", options: .regularExpression) != nil }) else {
        throw MihomoGUIError("规则文件标识无效")
    }
}

private func checkDirectory(_ path: String) throws {
    var info = stat()
    guard lstat(path, &info) == 0, info.st_mode & S_IFMT == S_IFDIR, info.st_uid == 0,
          info.st_mode & 0o022 == 0 else { throw MihomoGUIError("系统操作目录权限无效") }
}

func executeOperation(_ operation: PrivilegedOperation, owner: uid_t, coreRequirement: String) throws -> Int32 {
    let stage = URL(fileURLWithPath: "/private/tmp").appendingPathComponent("MihomoGUI-operation-" + UUID().uuidString)
    try FileManager.default.createDirectory(at: stage, withIntermediateDirectories: false, attributes: [.posixPermissions: 0o700])
    defer { try? FileManager.default.removeItem(at: stage) }
    func write(_ data: Data, _ name: String) throws {
        let target = stage.appendingPathComponent(name)
        try FileManager.default.createDirectory(at: target.deletingLastPathComponent(), withIntermediateDirectories: true, attributes: [.posixPermissions: 0o700])
        try data.write(to: target, options: .atomic)
        try FileManager.default.setAttributes([.posixPermissions: 0o600], ofItemAtPath: target.path)
    }
    let command: String
    switch operation {
    case .stop:
        command = stopCoreCommand
    case .persist(let data):
        try checkDirectory(rootDirectory)
        try write(data, "config.yaml")
        let target = rootDirectory + "/config.yaml"
        let pending = target + "." + UUID().uuidString
        command = "set -eu\n/usr/bin/install -o root -g wheel -m 600 " + shellQuote(stage.appendingPathComponent("config.yaml").path) + " " + shellQuote(pending)
            + "\n/bin/mv -f " + shellQuote(pending) + " " + shellQuote(target)
    case .install(let source, let settings):
        try write(readInput(URL(fileURLWithPath: source).appendingPathComponent("mihomo").path, owner: owner), "mihomo")
        try FileManager.default.setAttributes([.posixPermissions: 0o700], ofItemAtPath: stage.appendingPathComponent("mihomo").path)
        try verifyCore(at: stage.appendingPathComponent("mihomo"), requirement: coreRequirement)

        try write(generateConfig(settings), "config.yaml")
        let plist: [String: Any] = ["Label": coreLabel,
            "ProgramArguments": [installedCore, "-d", rootDirectory, "-f", rootDirectory + "/config.yaml"],
            "RunAtLoad": true, "KeepAlive": true, "ThrottleInterval": 10,
            "StandardOutPath": "/dev/null", "StandardErrorPath": "/dev/null", "Umask": 0o077]
        try write(PropertyListSerialization.data(fromPropertyList: plist, format: .xml, options: 0), coreLabel + ".plist")
        let endpoint = try controllerEndpoint(settings)
        let host = endpoint.host.contains(":") && !endpoint.host.hasPrefix("[") ? "[\(endpoint.host)]" : endpoint.host
        func escape(_ value: String) -> String { value.replacingOccurrences(of: "\\", with: "\\\\").replacingOccurrences(of: "\"", with: "\\\"") }
        try write(Data(("url = \"" + escape("http://\(host):\(endpoint.port)/version") + "\"\nheader = \"Authorization: Bearer " + escape(endpoint.secret) + "\"\n").utf8), "health.curl")
        var seeds = ["/bin/test ! -L " + shellQuote(rootDirectory + "/rules"), "/bin/mkdir -p " + shellQuote(rootDirectory + "/rules"), "/bin/chmod 700 " + shellQuote(rootDirectory + "/rules")]
        let providers = settings.options?["rule-providers"]?.object ?? [:]
        var names = geoAssetsNeeded(settings)
        for (index, name) in providers.keys.sorted().enumerated() where providers[name]?.object["type"] == .string("file") {
            names.append("rules/set-\(index)." + (providers[name]?.object["format"]?.text ?? "yaml"))
        }
        for name in names {
            try write(readInput(URL(fileURLWithPath: source).appendingPathComponent(name).path, owner: owner), name)
            let target = rootDirectory + "/" + name
            seeds.append("/bin/test ! -L " + shellQuote(target))
            seeds.append("/usr/bin/install -o root -g wheel -m 600 " + shellQuote(stage.appendingPathComponent(name).path) + " " + shellQuote(target))
        }
        command = coreInstallCommand(staging: stage, seedCommands: seeds)
    case .prepareRules(let source, let id, let filenames):
        try checkRuleNames(filenames)
        try checkDirectory(rootDirectory)
        let rules = rootDirectory + "/rules"
        let backup = rootDirectory + "/rules-backup-" + id.uuidString
        var commands = ["set -eu", "/bin/test ! -L " + shellQuote(rules), "/bin/mkdir -p " + shellQuote(rules), "/bin/chmod 700 " + shellQuote(rules), "/bin/mkdir -m 700 " + shellQuote(backup)]
        var rollback: [String] = []
        for name in filenames {
            try write(readInput(URL(fileURLWithPath: source).appendingPathComponent(name).path, owner: owner), name)
            let target = rules + "/" + name
            let saved = backup + "/" + name
            commands.append("/bin/test ! -L " + shellQuote(target))
            commands.append("if [ -e " + shellQuote(target) + " ]; then /bin/cp -p " + shellQuote(target) + " " + shellQuote(saved) + "; fi")
            rollback.append("if [ -f " + shellQuote(saved) + " ]; then /bin/cp -p " + shellQuote(saved) + " " + shellQuote(target) + "; else /bin/rm -f " + shellQuote(target) + "; fi")
        }
        commands.append("trap " + shellQuote(rollback.joined(separator: "\n")) + " EXIT")
        for name in filenames { commands.append("/usr/bin/install -o root -g wheel -m 600 " + shellQuote(stage.appendingPathComponent(name).path) + " " + shellQuote(rules + "/" + name)) }
        commands.append("trap - EXIT")
        command = commands.joined(separator: "\n")
    case .finishRules(let id, let filenames, let restore):
        try checkRuleNames(filenames)
        try checkDirectory(rootDirectory)
        let backup = rootDirectory + "/rules-backup-" + id.uuidString
        try checkDirectory(backup)
        var commands = ["set -eu", "/bin/test ! -L " + shellQuote(rootDirectory + "/rules")]
        if restore {
            for name in filenames {
                let target = rootDirectory + "/rules/" + name
                let saved = backup + "/" + name
                commands.append("/bin/test ! -L " + shellQuote(target))
                commands.append("if [ -f " + shellQuote(saved) + " ]; then /bin/cp -p " + shellQuote(saved) + " " + shellQuote(target) + "; else /bin/rm -f " + shellQuote(target) + "; fi")
            }
        }
        commands.append("/bin/rm -rf " + shellQuote(backup))
        command = commands.joined(separator: "\n")
    }
    let result = try runPrivilegedScript(command)
    guard result.status == 0 else { throw PrivilegedCommandFailure(diagnostic: result.diagnostic) }
    return result.status
}

// Kept separate so rollback can be exercised against temporary files without administrator access.
func coreInstallCommand(staging: URL, seedCommands: [String],
                        rootDirectory: String = MihomoGUICore.rootDirectory, installedCore: String = MihomoGUICore.installedCore,
                        coreLabel: String = MihomoGUICore.coreLabel, destinationPlist: String? = nil) -> String {
    let helperDirectory = URL(fileURLWithPath: installedCore).deletingLastPathComponent().path
    let destinationPlist = destinationPlist ?? "/Library/LaunchDaemons/" + coreLabel + ".plist"
    let binary = staging.appendingPathComponent("mihomo")
    let configFile = staging.appendingPathComponent("config.yaml")
    let plist = staging.appendingPathComponent(coreLabel + ".plist")
    let health = staging.appendingPathComponent("health.curl")
    return """
    set -eu
    /bin/test ! -L \(shellQuote(rootDirectory))
    /bin/test ! -L \(shellQuote(helperDirectory))
    /bin/mkdir -p \(shellQuote(rootDirectory)) \(shellQuote(helperDirectory))
    /usr/sbin/chown root:wheel \(shellQuote(rootDirectory)) \(shellQuote(helperDirectory))
    /bin/chmod 700 \(shellQuote(rootDirectory)) \(shellQuote(helperDirectory))
    /bin/test ! -L \(shellQuote(installedCore))
    /bin/test ! -L \(shellQuote(rootDirectory + "/config.yaml"))
    /bin/test ! -L \(shellQuote(destinationPlist))
    backup=$(/usr/bin/mktemp -d /private/tmp/MihomoGUI-rollback.XXXXXXXX)
    /bin/chmod 700 "$backup"
    trap '/bin/rm -rf "$backup"' EXIT
    disabled=0
    if /bin/launchctl print-disabled system | /usr/bin/grep -F \(shellQuote("\"" + coreLabel + "\" => true")) >/dev/null; then disabled=1; fi
    loaded=0
    /bin/launchctl print system/\(coreLabel) >/dev/null 2>&1 && loaded=1
    [ ! -e \(shellQuote(rootDirectory)) ] || /bin/cp -pR \(shellQuote(rootDirectory)) "$backup/core"
    [ ! -e \(shellQuote(installedCore)) ] || /bin/cp -p \(shellQuote(installedCore)) "$backup/binary"
    [ ! -e \(shellQuote(destinationPlist)) ] || /bin/cp -p \(shellQuote(destinationPlist)) "$backup/plist"
    rollback() {
        status=$?
        trap - EXIT HUP INT TERM
        if [ "$status" -ne 0 ]; then
            set +e
            /bin/launchctl bootout system/\(coreLabel) >/dev/null 2>&1
            if [ -f \(shellQuote(rootDirectory + "/core.log")) ]; then /bin/cp -p \(shellQuote(rootDirectory + "/core.log")) "$backup/failure.log"; fi
            /bin/rm -rf \(shellQuote(rootDirectory))
            /bin/rm -f \(shellQuote(installedCore)) \(shellQuote(destinationPlist))
            restored=1
            if [ -e "$backup/core" ]; then /bin/cp -pR "$backup/core" \(shellQuote(rootDirectory)) || restored=0; fi
            if [ -e "$backup/failure.log" ]; then
                /bin/mkdir -p \(shellQuote(rootDirectory))
                /bin/chmod 700 \(shellQuote(rootDirectory))
                /bin/cp -p "$backup/failure.log" \(shellQuote(rootDirectory + "/core-failure.log")) || restored=0
            fi
            if [ -e "$backup/binary" ]; then /bin/cp -p "$backup/binary" \(shellQuote(installedCore)) || restored=0; fi
            if [ -e "$backup/plist" ]; then /bin/cp -p "$backup/plist" \(shellQuote(destinationPlist)) || restored=0; fi
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
    /usr/bin/install -o root -g wheel -m 700 \(shellQuote(binary.path)) \(shellQuote(installedCore))
    /usr/bin/install -o root -g wheel -m 600 \(shellQuote(configFile.path)) \(shellQuote(rootDirectory + "/config.yaml"))
    \(seedCommands.joined(separator: "\n"))
    /usr/bin/install -o root -g wheel -m 644 \(shellQuote(plist.path)) \(shellQuote(destinationPlist))
    /bin/launchctl enable system/\(coreLabel)
    /bin/launchctl bootstrap system \(shellQuote(destinationPlist))
    ready=0
    for attempt in 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15; do
        if /usr/bin/curl --noproxy '*' --fail --silent --output /dev/null --max-time 1 --config \(shellQuote(health.path)); then ready=1; break; fi
        /bin/sleep 1
    done
    if [ "$ready" -ne 1 ]; then
        echo "内核启动后控制接口未就绪" >&2
        /bin/launchctl print system/\(coreLabel) 2>/dev/null | /usr/bin/awk '/^[[:space:]]*(state|runs|pid|last exit code|last terminating signal) = / {print}' >&2 || true
        exit 1
    fi
    """
}


let stopCoreCommand = """
    set -eu
    /bin/launchctl disable system/\(coreLabel)
    if /bin/launchctl print system/\(coreLabel) >/dev/null 2>&1; then
        /bin/launchctl bootout system/\(coreLabel)
    fi
    if /bin/launchctl print system/\(coreLabel) >/dev/null 2>&1; then
        echo "内核服务未能停止" >&2
        exit 1
    fi
    """

// The requirement is fixed by the administrator-authorized launchd installation.
func verifyCore(at url: URL, requirement: String) throws {
    var code: SecStaticCode?
    var expected: SecRequirement?
    guard SecStaticCodeCreateWithPath(url as CFURL, [], &code) == errSecSuccess, let code,
          SecRequirementCreateWithString(requirement as CFString, [], &expected) == errSecSuccess, let expected,
          SecStaticCodeCheckValidity(code, SecCSFlags(rawValue: kSecCSStrictValidate), expected) == errSecSuccess else {
        throw MihomoGUIError("暂存内核签名与授权版本不匹配，请重新安装应用")
    }
}

struct PrivilegedCommandFailure: Error {
    let diagnostic: String
}

// Commands are generated locally. Retain a bounded tail and expose only known diagnostic categories.
func runPrivilegedScript(_ command: String, timeout: TimeInterval = 120) throws -> (status: Int32, diagnostic: String) {
    let process = Process()
    process.executableURL = URL(fileURLWithPath: "/bin/sh")
    process.arguments = ["-c", command]
    let pipe = Pipe()
    process.standardOutput = pipe
    process.standardError = pipe
    try process.run()
    let deadline = ProcessDeadline(process: process, timeout: timeout)
    defer { deadline.invalidate() }
    try pipe.fileHandleForWriting.close()
    defer { try? pipe.fileHandleForReading.close() }
    var output = Data()
    while let chunk = try pipe.fileHandleForReading.read(upToCount: 4096), !chunk.isEmpty {
        output.append(chunk)
        if output.count > 16384 { output.removeFirst(output.count - 16384) }
    }
    process.waitUntilExit()
    try deadline.check()
    return (process.terminationStatus, safePrivilegedDiagnostic(status: process.terminationStatus, output: String(decoding: output, as: UTF8.self)))
}

func safePrivilegedDiagnostic(status: Int32, output: String) -> String {
    let categories: [(String, String)] = [
        ("操作超时", "操作超时，结果可能未知，请检查系统服务状态后重试"),
        ("无法读取操作输入", "无法读取安装输入文件，请重新安装应用"),
        ("操作输入必须是安装用户拥有的普通文件", "安装输入文件的所有者或文件类型无效"),
        ("系统操作目录权限无效", "系统服务目录所有者或权限无效"),
        ("签名与授权版本不匹配", "内核签名与管理员授权版本不匹配，请重新安装应用"),
        ("Bootstrap failed", "launchd 加载失败，请检查服务文件和系统权限"),
        ("Boot-out failed", "launchd 卸载失败"),
        ("Permission denied", "文件或服务访问被拒绝，请检查系统权限"),
        ("Operation not permitted", "系统拒绝操作，请检查管理员授权"),
        ("No space left on device", "磁盘空间不足"),
        ("Read-only file system", "目标文件系统只读"),
        ("内核启动后控制接口未就绪", "内核控制接口未就绪，请检查端口占用、监听地址和内核退出状态"),
        ("恢复失败", "恢复旧服务失败，请检查系统服务状态"),
        ("已恢复旧配置和服务", "已恢复旧配置和服务")
    ]
    var messages = ["特权操作失败（\(status)）"]
    for (marker, description) in categories where output.contains(marker) { messages.append(description) }
    for line in output.components(separatedBy: .newlines) {
        let field = line.trimmingCharacters(in: .whitespaces)
        if field.range(of: "^(runs|pid|last exit code|last terminating signal) = -?[0-9]+$", options: .regularExpression) != nil {
            messages.append(field)
        }
    }
    return messages.joined(separator: "；")
}
