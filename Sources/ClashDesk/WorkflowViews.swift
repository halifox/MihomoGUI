import SwiftUI
import ClashCore

struct SubscriptionChanges: Identifiable {
    let id = UUID()
    var added: [String]
    var removed: [String]
    var changed: [String]
}

extension DeskModel {
    func subscriptionChanges(from old: ClashCore.Settings, to new: ClashCore.Settings) -> SubscriptionChanges {
        func entries(_ value: ClashCore.Settings) -> [String: ConfigValue] {
            var result: [String: ConfigValue] = [:]
            for source in value.subscriptions {
                for entry in value.subscriptionProxies?[source.id] ?? [] {
                    result[source.provider + "/" + (entry.object["name"]?.text ?? "")] = entry
                }
            }
            return result
        }
        let a = entries(old), b = entries(new)
        return SubscriptionChanges(added: b.keys.filter { a[$0] == nil }.sorted(), removed: a.keys.filter { b[$0] == nil }.sorted(), changed: b.keys.filter { a[$0] != nil && a[$0] != b[$0] }.sorted())
    }
    var missingNodeReferences: [String] {
        var references = settings.rules.compactMap { $0.node.map { "node:" + $0.id } }
        if let node = settings.defaultNode { references.append("node:" + node.id) }
        references += (settings.proxyGroups ?? []).flatMap(\.targets).filter { $0.hasPrefix("node:") }
        references += settings.options?["rule-providers"]?.object.values.compactMap { $0.object["proxy"]?.text }.filter { $0.hasPrefix("node:") } ?? []
        let valid = Set(allNodes.map { "node:" + $0.id })
        return Array(Set(references).subtracting(valid)).sorted()
    }
    func referenceLocations(_ target: String) -> [String] {
        var locations: [String] = []
        if settings.defaultNode.map({ "node:" + $0.id }) == target { locations.append("MATCH") }
        for (index, rule) in settings.rules.enumerated() where rule.node.map({ "node:" + $0.id }) == target { locations.append("第 \(index + 1) 条规则：\(rule.kind.rawValue) / \(rule.value)") }
        for group in settings.proxyGroups ?? [] where group.targets.contains(target) { locations.append("代理组：" + group.name) }
        for (name, fields) in settings.options?["rule-providers"]?.object ?? [:] where fields.object["proxy"]?.text == target { locations.append("规则集下载：" + name) }
        return locations
    }
    func replaceMissingReference(_ old: String, with target: String) throws {
        guard !missingNodeReferences.contains(target) else { throw DeskError("请选择有效出口") }
        let candidate = try replacingNodeReferences(settings, old: old, target: target, nodes: allNodes)
        try saveSettings(candidate, to: directory); settings = candidate
        message = "引用已修复，请应用更改。"
    }
}

struct SubscriptionChangesView: View {
    @EnvironmentObject var model: DeskModel
    @Environment(\.dismiss) private var dismiss
    let changes: SubscriptionChanges
    @State private var selected = ""
    @State private var replacement = "builtin:REJECT"
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("订阅更新结果").font(.title2.bold())
            Text("新增 \(changes.added.count) · 移除 \(changes.removed.count) · 参数变化 \(changes.changed.count)")
            Text("节点已保存到草稿，运行配置尚未更新。失效引用在应用后使用 REJECT。").foregroundStyle(.secondary)
            ScrollView {
                VStack(alignment: .leading, spacing: 8) {
                    ForEach([("新增", changes.added), ("移除", changes.removed), ("参数变化", changes.changed)], id: \.0) { section in
                        DisclosureGroup("\(section.0)（\(section.1.count)）") {
                            ForEach(section.1, id: \.self) { key in Text(referencedNode("node:" + key).map(model.nodeLabel) ?? key).textSelection(.enabled) }
                        }
                    }
                    if !model.missingNodeReferences.isEmpty {
                        GroupBox("修复失效引用") {
                            VStack(alignment: .leading) {
                                Picker("失效节点", selection: $selected) {
                                    Text("选择节点").tag("")
                                    ForEach(model.missingNodeReferences, id: \.self) { Text(referencedNode($0).map(model.nodeLabel) ?? $0).tag($0) }
                                }
                                ForEach(model.referenceLocations(selected), id: \.self) { Text($0).foregroundStyle(.secondary) }
                                PolicyPicker(model: model, selection: $replacement)
                                Button("替换全部引用") {
                                    do { try model.replaceMissingReference(selected, with: replacement); selected = "" }
                                    catch { model.error = error.localizedDescription }
                                }.disabled(selected.isEmpty)
                            }
                        }
                    }
                }
            }
            HStack { Spacer(); Button("完成") { dismiss() }.keyboardShortcut(.cancelAction) }
        }.padding(20).frame(width: 720, height: 500)
    }
}

struct ConfigurationImport: Identifiable {
    let id = UUID()
    let name: String
    let settings: ClashCore.Settings
}

extension DeskModel {
    func exportConfiguration(backup: Bool) {
        let panel = NSSavePanel(); panel.nameFieldStringValue = backup ? "ClashDesk-backup.json" : "config.yaml"
        panel.message = "文件包含节点凭据，请妥善保管。"
        guard panel.runModal() == .OK, let url = panel.url else { return }
        do {
            let data = backup ? try JSONEncoder().encode(settings) : try generateConfig(settings)
            try data.write(to: url, options: .atomic)
            try FileManager.default.setAttributes([.posixPermissions: 0o600], ofItemAtPath: url.path)
            message = backup ? "配置备份已导出。" : "YAML 已导出。"
        } catch { self.error = error.localizedDescription }
    }
    func importConfigurationFile(backup: Bool) {
        let panel = NSOpenPanel(); panel.canChooseDirectories = false; panel.allowsMultipleSelection = false
        panel.message = backup ? "选择 ClashDesk JSON 配置备份" : "选择 mihomo YAML 配置（节点需内联在 proxies 中）"
        guard panel.runModal() == .OK, let url = panel.url else { return }
        perform {
            let path = self.settings.corePath
            let candidate = try await Task.detached {
                if backup {
                    let size = try url.resourceValues(forKeys: [.fileSizeKey]).fileSize ?? 0
                    guard size <= 16 * 1024 * 1024 else { throw DeskError("备份超过 16 MiB") }
                    var restored = try JSONDecoder().decode(ClashCore.Settings.self, from: Data(contentsOf: url))
                    restored.corePath = path; _ = try generateConfig(restored); return restored
                }
                return try importConfiguration(readConfigurationYAML(url), corePath: path)
            }.value
            self.configurationImport = ConfigurationImport(name: url.lastPathComponent, settings: candidate)
        }
    }
    func confirmImport(_ value: ConfigurationImport) {
        do {
            _ = try generateConfig(value.settings)
            let backupFolder = directory.appendingPathComponent("backups")
            try FileManager.default.createDirectory(at: backupFolder, withIntermediateDirectories: true, attributes: [.posixPermissions: 0o700])
            let stamp = ISO8601DateFormatter().string(from: Date()).replacingOccurrences(of: ":", with: "-")
            let backup = backupFolder.appendingPathComponent(stamp + "-" + UUID().uuidString.prefix(8) + ".json")
            try JSONEncoder().encode(settings).write(to: backup, options: .atomic)
            try FileManager.default.setAttributes([.posixPermissions: 0o600], ofItemAtPath: backup.path)
            var imported: [Node] = []
            for source in value.settings.subscriptions {
                for entry in value.settings.subscriptionProxies?[source.id] ?? [] {
                    var node = Node(provider: source.provider, name: entry.object["name"]?.text ?? "")
                    node.protocolName = entry.object["type"]?.text; node.server = entry.object["server"]?.text; node.port = entry.object["port"]?.text
                    imported.append(node)
                }
            }
            try commitFiles([("settings.json", try JSONEncoder().encode(value.settings)), ("nodes.json", try JSONEncoder().encode(imported))], directory: directory)
            settings = value.settings; nodes = imported; configurationImport = nil
            message = "已导入草稿，旧草稿已备份。请检查差异后应用。"
        } catch { self.error = error.localizedDescription }
    }
    var profileFiles: [URL] {
        ((try? FileManager.default.contentsOfDirectory(at: directory.appendingPathComponent("profiles"), includingPropertiesForKeys: nil)) ?? []).filter { $0.pathExtension == "json" }.sorted { $0.lastPathComponent < $1.lastPathComponent }
    }
    func saveProfile(_ name: String) throws {
        let name = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !name.isEmpty, name != ".", name != "..", !name.contains("/"), name.utf8.count <= 120 else { throw DeskError("方案名称不能为空，不能含斜杠，最长 120 字节") }
        let folder = directory.appendingPathComponent("profiles")
        try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true, attributes: [.posixPermissions: 0o700])
        let file = folder.appendingPathComponent(name + ".json")
        guard !FileManager.default.fileExists(atPath: file.path) else { throw DeskError("方案已存在，请使用新的名称") }
        try JSONEncoder().encode(settings).write(to: file, options: .atomic)
        try FileManager.default.setAttributes([.posixPermissions: 0o600], ofItemAtPath: file.path)
        message = "方案已保存。"
    }
    func loadProfile(_ file: URL) {
        do {
            var candidate = try JSONDecoder().decode(ClashCore.Settings.self, from: Data(contentsOf: file)); candidate.corePath = settings.corePath
            _ = try generateConfig(candidate)
            configurationImport = ConfigurationImport(name: file.deletingPathExtension().lastPathComponent, settings: candidate)
        } catch { self.error = error.localizedDescription }
    }
    func runDiagnostics(_ host: String) {
        perform {
            var results: [String] = []
            do { _ = try generateConfig(self.settings); results.append("草稿：生成通过；启动时仍需内核校验。") }
            catch { results.append("草稿：" + error.localizedDescription) }
            do { results.append("控制接口：在线，" + (try await self.api.version())) }
            catch { results.append("控制接口：不可达，请检查内核状态及已应用接口；" + error.localizedDescription) }
            let query = host.trimmingCharacters(in: .whitespacesAndNewlines)
            if !query.isEmpty {
                do {
                    let name = query.addingPercentEncoding(withAllowedCharacters: .alphanumerics) ?? ""
                    let data = try await self.api.request("/dns/query?name=" + name + "&type=A", timeout: 8)
                    let response = try JSONSerialization.jsonObject(with: data) as? [String: Any]
                    let answers = response?["Answer"] as? [Any] ?? []
                    results.append(answers.isEmpty ? "DNS：没有返回 A 记录，请检查域名、DNS 配置及响应。" : "DNS：返回 \(answers.count) 条 A 记录。")
                } catch { results.append("DNS 查询失败：" + error.localizedDescription) }
            }
            results.append("失效节点引用：\(self.missingNodeReferences.count) 个。")
            results.append("节点可达性请在出站代理页执行选中节点测速；实际规则命中请查看活动连接详情。")
            self.diagnosticReport = results.joined(separator: "\n")
        }
    }
}

struct ConfigurationTransferView: View {
    @EnvironmentObject var model: DeskModel
    @State private var profileName = ""
    @State private var profiles: [URL] = []
    @State private var host = "example.com"
    var body: some View {
        GroupBox("配置与方案") {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Button("导入 YAML") { model.importConfigurationFile(backup: false) }
                    Button("导出 YAML") { model.exportConfiguration(backup: false) }
                    Button("备份配置") { model.exportConfiguration(backup: true) }
                    Button("恢复备份") { model.importConfigurationFile(backup: true) }
                }.pageActions()
                Text("导入或切换仅修改草稿，确认时自动备份旧草稿；备份包含节点凭据，不包含流量数据库。").font(.caption).foregroundStyle(.secondary)
                HStack {
                    TextField("新方案名称", text: $profileName).textFieldStyle(.roundedBorder)
                    Button("保存当前方案") {
                        do { try model.saveProfile(profileName); profiles = model.profileFiles; profileName = "" }
                        catch { model.error = error.localizedDescription }
                    }
                }
                ForEach(profiles, id: \.path) { file in
                    HStack { Text(file.deletingPathExtension().lastPathComponent); Spacer(); Button("载入方案") { model.loadProfile(file) } }
                }
                HStack {
                    Button("查看自动备份") { NSWorkspace.shared.open(model.directory.appendingPathComponent("backups")) }
                    Spacer()
                    TextField("诊断域名", text: $host).frame(width: 190).textFieldStyle(.roundedBorder)
                    Button("基础诊断") { model.runDiagnostics(host) }
                }
                if let report = model.diagnosticReport { Text(report).textSelection(.enabled).font(.callout) }
            }.padding(6).disabled(model.busy)
        }.task { profiles = model.profileFiles }
    }
}

struct ConfigurationImportView: View {
    @EnvironmentObject var model: DeskModel
    let value: ConfigurationImport
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("确认载入：" + value.name).font(.title2.bold())
            Text("将替换当前草稿并自动备份旧草稿；正在运行的配置在应用更改前保持当前状态。YAML 未指定的字段使用应用默认值，请检查差异。")
            Text("手动节点 \(value.settings.manualProxies?.count ?? 0) · 订阅 \(value.settings.subscriptions.count) · 分组 \(value.settings.proxyGroups?.count ?? 0) · 规则 \(value.settings.rules.count)")
            ScrollView { Text(model.configurationChanges(value.settings)).textSelection(.enabled).frame(maxWidth: .infinity, alignment: .leading) }
            HStack {
                Button("取消") { model.configurationImport = nil }.keyboardShortcut(.cancelAction)
                Spacer(); Button("备份并载入草稿") { model.confirmImport(value) }.buttonStyle(.borderedProminent)
            }
        }.padding(20).frame(width: 720, height: 460)
    }
}

struct NodeLinksView: View {
    @EnvironmentObject var model: DeskModel
    @Environment(\.dismiss) private var dismiss
    @State private var text = ""
    @State private var error: String?
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("导入节点链接").font(.title2.bold())
            Text("每行一个 URI，或粘贴 Base64 编码的链接列表。支持 SS、VMess、VLESS、Trojan、Hysteria2、TUIC、HTTP、SOCKS5；复杂参数请使用 YAML。")
            TextEditor(text: $text).font(.system(.body, design: .monospaced)).border(Color.secondary.opacity(0.3))
            if let error { Text(error).foregroundStyle(.red) }
            HStack {
                Button("取消") { dismiss() }.keyboardShortcut(.cancelAction)
                Spacer()
                Button("解析并预览") {
                    do {
                        var candidate = model.settings
                        candidate.manualProxies = (candidate.manualProxies ?? []) + (try importNodeLinks(text))
                        _ = try generateConfig(candidate)
                        dismiss()
                        Task { @MainActor in
                            await Task.yield()
                            model.configurationImport = ConfigurationImport(name: "节点链接（追加到当前草稿）", settings: candidate)
                        }
                    } catch { self.error = error.localizedDescription }
                }.buttonStyle(.borderedProminent).disabled(text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
        }.padding(20).frame(width: 720, height: 500)
    }
}

struct ConnectionDetailView: View {
    @EnvironmentObject var model: DeskModel
    @Environment(\.dismiss) private var dismiss
    let connection: Connection
    @State private var editing: RouteRule?
    var matchedRule: RouteRule? { model.matchedDraftRule(connection) }
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("连接详情").font(.title2.bold())
            Text(connection.domain).textSelection(.enabled)
            Text("目标：" + (connection.metadata.destinationIP ?? "—") + ":" + (connection.metadata.destinationPort ?? "—"))
            Text("程序：" + connection.process).textSelection(.enabled)
            Text("协议：" + (connection.metadata.network ?? "—"))
            GroupBox("实际命中") {
                VStack(alignment: .leading, spacing: 8) {
                    Text((connection.rule ?? "未知规则") + " / " + (connection.rulePayload ?? "—")).textSelection(.enabled)
                    Text("策略链：" + (connection.chains ?? []).reversed().map(model.runtimeMemberLabel).joined(separator: " → ")).textSelection(.enabled)
                    if let rule = matchedRule {
                        Button("查看 / 编辑命中规则") { editing = rule }
                    } else { Text("草稿中没有对应规则，可能来自 MATCH、规则集或已变更的运行配置。").foregroundStyle(.secondary) }
                    Menu("添加路由规则") { RouteMenu(kind: .domain, value: connection.domain) }
                }.frame(maxWidth: .infinity, alignment: .leading).padding(6)
            }
            Spacer(); HStack { Spacer(); Button("关闭") { dismiss() }.keyboardShortcut(.cancelAction) }
        }.padding(20).frame(width: 720, height: 420)
        .sheet(item: $editing) { RuleEditorView(rule: $0) }
    }
}
