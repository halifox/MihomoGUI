import SwiftUI
import AppKit
import ClashCore

enum ConfigAction {
    case preview, start, reload
}

struct ConfigPreview: Identifiable {
    let id = UUID()
    let settings: ClashCore.Settings
    let config: Data
    let action: ConfigAction
}

@MainActor
final class DeskModel: ObservableObject {
    @Published var settings = Settings()
    @Published var nodes: [Node] = []
    @Published var connections: [Connection] = []
    @Published var traffic: [DomainTrafficRow] = []
    @Published var testingNodes: Set<String> = []
    @Published var isTestingDelays = false
    private var delayTask: Task<Void, Never>?
    @Published var configPreview: ConfigPreview?
    @Published var coreRunning = false
    @Published var lastSample: Date?
    @Published var busy = false
    @Published var error: String?
    @Published var message = "退出界面后，已启动的服务继续运行。"
    @Published var hours = 24
    @Published var coreMemory: Int64?
    @Published var coreVersion: String?
    @Published var corePID: Int?
    @Published var statsPID: Int?
    private var runtimeSettings = ClashCore.Settings()
    private var diagnosticsDate = Date.distantPast
    let directory: URL
    private var monitor: Task<Void, Never>?
    private var configurationSaveTask: Task<Void, Never>?
    private var configurationSavePending = false

    init() {
        directory = (try? dataDirectory()) ?? FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent("Library/Application Support/ClashDesk")
        do {
            settings = try loadSettings(from: directory)
            runtimeSettings = try loadRuntimeSettings(from: directory)
            if settings.ruleOrderMigrated == nil {
                settings.rules = settings.rules.filter { $0.kind.isProcess } + settings.rules.filter { !$0.kind.isProcess }
                settings.ruleOrderMigrated = true
            }
            if settings.subscriptionProxies == nil { try cacheSubscriptionProxies(&settings, directory: directory) }
            nodes = try loadNodeCache(directory: directory)
            if settings.defaultNode == nil, settings.defaultDirect != true, settings.defaultPolicy == nil, settings.defaultProxyGroup == nil { settings.defaultNode = allNodes.first }
            // Persist the API secret before starting any service.
            try saveSettings(settings, to: directory)
            if !FileManager.default.fileExists(atPath: directory.appendingPathComponent("runtime.json").path) { try saveRuntimeSettings(runtimeSettings, to: directory) }
        } catch {
            self.error = error.localizedDescription
        }
    }
    func startMonitor() {
        guard monitor == nil else { return }
        if nodes.isEmpty, !settings.subscriptions.isEmpty, !settings.corePath.isEmpty { refreshSubscriptions() }
        monitor = Task { [weak self] in
            while !Task.isCancelled {
                guard let self else { return }
                await self.refresh()
                try? await Task.sleep(nanoseconds: 3_000_000_000)
            }
        }
    }
    var api: CoreAPI { (try? CoreAPI(settings: runtimeSettings)) ?? CoreAPI(secret: runtimeSettings.secret) }
    var allNodes: [Node] { (settings.manualProxies ?? []).map(\.node) + nodes }
    var servicesActive: Bool { coreRunning || corePID != nil || statsPID != nil }
    var hasUnappliedChanges: Bool { runtimeConfigurationChanged(settings, applied: runtimeSettings) }
    func toggleAllServices() {
        if !servicesActive { startAll(); return }
        perform {
            var failures: [String] = []
            do { try await stopCore() } catch { failures.append(error.localizedDescription) }
            do { try await stopStatistics() } catch { failures.append(error.localizedDescription) }
            await self.refreshDiagnostics()
            if !failures.isEmpty { throw DeskError(failures.joined(separator: "\n")) }
        }
    }
    var activeController: String { runtimeSettings.options?["external-controller"]?.text ?? "127.0.0.1:19090" }
    func refresh() async {
        do {
            let live = try await api.connections()
            connections = live; coreRunning = true
        } catch { coreRunning = false; connections = [] }
        do {
            let database = try TrafficDatabase(url: directory.appendingPathComponent("traffic.sqlite"), readOnly: true)
            traffic = try database.domainRows(since: Date().addingTimeInterval(-Double(hours) * 3600))
            lastSample = try database.lastSample()
        } catch { lastSample = nil }
        if Date().timeIntervalSince(diagnosticsDate) > 10 { await refreshDiagnostics() }
    }
    func refreshDiagnostics() async {
        diagnosticsDate = Date()
        async let core = servicePID(domain: "system", label: coreLabel)
        async let stats = servicePID(domain: "gui/\(getuid())", label: statsLabel)
        async let memory = try? api.memory()
        async let version = try? api.version()
        corePID = await core; statsPID = await stats
        coreMemory = await memory; coreVersion = await version
    }
    func baseOption(_ path: String) -> ConfigValue? {
        var baseline = ClashCore.Settings(); baseline.secret = settings.secret; baseline.tun = settings.tun
        guard let object = try? configurationObject(baseline), let value = configPath(path, in: object) else { return nil }
        return ConfigValue(native: value)
    }
    func option(_ path: String) -> ConfigValue? { settings.options?[path] ?? baseOption(path) }
    func setOption(_ path: String, value: ConfigValue?) {
        var options = settings.options ?? [:]; options[path] = value; settings.options = options
        scheduleConfigurationSave()
    }
    func saveGeneralConfiguration() {
        do {
            try validateFieldValues(settings.options ?? [:], schema: documentSchemas.sections.flatMap(\.fields))
            _ = try generateConfig(settings)
            try save()
        } catch { self.error = error.localizedDescription }
    }
    func scheduleConfigurationSave() {
        configurationSavePending = true
        configurationSaveTask?.cancel()
        configurationSaveTask = Task { [weak self] in
            do { try await Task.sleep(nanoseconds: 350_000_000) } catch { return }
            self?.flushConfigurationSave()
        }
    }
    func flushConfigurationSave() {
        guard configurationSavePending else { return }
        configurationSaveTask?.cancel(); configurationSaveTask = nil
        do {
            // Persist editable drafts; validate the full configuration before applying to mihomo.
            try save(); configurationSavePending = false
        } catch { self.error = error.localizedDescription }
    }
    func perform(_ operation: @escaping () async throws -> Void) {
        guard !busy else { return }
        busy = true
        Task {
            defer { busy = false }
            do { try await operation(); await refresh() }
            catch { self.error = error.localizedDescription }
        }
    }
    func save() throws { try saveSettings(settings, to: directory) }
    func importSubscriptions(_ candidate: ClashCore.Settings) async throws {
        let fetched = try await fetchSubscriptionData(candidate.subscriptions, corePath: candidate.corePath, directory: directory)
        let imported = fetched.nodes
        var updated = candidate
        updated.subscriptions = fetched.subscriptions
        try cacheSubscriptionProxies(&updated, directory: directory)
        let updatedAt = Date()
        for index in updated.subscriptions.indices { updated.subscriptions[index].lastUpdatedAt = updatedAt }
        if updated.defaultNode == nil, updated.defaultDirect != true, updated.defaultPolicy == nil, updated.defaultProxyGroup == nil { updated.defaultNode = updated.manualProxies?.first?.node ?? imported.first }
        var merged = imported
        let previous = Dictionary(uniqueKeysWithValues: nodes.map { ($0.id, $0) })
        for index in merged.indices {
            merged[index].delayMilliseconds = previous[merged[index].id]?.delayMilliseconds
            merged[index].delayFailed = previous[merged[index].id]?.delayFailed
        }
        try saveNodeCache(merged, directory: directory)
        try saveSettings(updated, to: directory)
        settings = updated; nodes = merged
        message = "已拉取并保存 \(nodes.count) 个节点。可在规则表修改 MATCH 的出口。"
    }
    func saveSubscription(_ subscription: Subscription) async throws {
        var subscription = subscription
        subscription.name = subscription.name.trimmingCharacters(in: .whitespacesAndNewlines)
        subscription.url = subscription.url.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !subscription.name.isEmpty else { throw DeskError("请输入订阅名称") }
        guard !settings.subscriptions.contains(where: { $0.id != subscription.id && $0.url == subscription.url }) else {
            throw DeskError("该订阅地址已存在")
        }
        let staging = FileManager.default.temporaryDirectory.appendingPathComponent("clashdesk-subscription-" + UUID().uuidString)
        try FileManager.default.createDirectory(at: staging, withIntermediateDirectories: true, attributes: [.posixPermissions: 0o700])
        defer { try? FileManager.default.removeItem(at: staging) }
        let fetched = try await fetchSubscriptionData([subscription], corePath: settings.corePath, directory: staging)
        var imported = fetched.nodes
        subscription.usage = fetched.subscriptions.first?.usage
        guard !imported.isEmpty else { throw DeskError("订阅没有可用节点，未保存") }
        let previous = Dictionary(uniqueKeysWithValues: nodes.map { ($0.id, $0) })
        for index in imported.indices {
            imported[index].delayMilliseconds = previous[imported[index].id]?.delayMilliseconds
            imported[index].delayFailed = previous[imported[index].id]?.delayFailed
        }
        subscription.lastUpdatedAt = Date()
        var updated = settings
        if let index = updated.subscriptions.firstIndex(where: { $0.id == subscription.id }) {
            updated.subscriptions[index] = subscription
        } else { updated.subscriptions.append(subscription) }
        if updated.defaultNode == nil, updated.defaultDirect != true, updated.defaultPolicy == nil, updated.defaultProxyGroup == nil {
            updated.defaultNode = updated.manualProxies?.first?.node ?? imported.first
        }
        let merged = updated.subscriptions.flatMap { source in
            source.id == subscription.id ? imported : nodes.filter { $0.provider == source.provider }
        }
        let target = providerFile(subscription, directory: directory)
        try FileManager.default.createDirectory(at: target.deletingLastPathComponent(), withIntermediateDirectories: true, attributes: [.posixPermissions: 0o700])
        try Data(contentsOf: providerFile(subscription, directory: staging)).write(to: target, options: .atomic)
        try FileManager.default.setAttributes([.posixPermissions: 0o600], ofItemAtPath: target.path)
        try cacheSubscriptionProxies(&updated, directory: directory)
        try saveNodeCache(merged, directory: directory)
        try saveSettings(updated, to: directory)
        settings = updated; nodes = merged
        message = "订阅已保存，共 \(imported.count) 个节点。"
    }
    func refreshSubscription(_ subscription: Subscription) {
        perform { try await self.saveSubscription(subscription) }
    }
    func refreshSubscriptions() {
        let candidate = settings
        perform { try await self.importSubscriptions(candidate) }
    }
    @Published var manualUDP: [String: Bool] = [:]
    func refreshManualUDP() async {
        let snapshot = settings.manualProxies ?? []
        manualUDP = [:]
        let providers = settings.subscriptions.compactMap { source -> (String, URL)? in
            let file = providerFile(source, directory: directory)
            return FileManager.default.fileExists(atPath: file.path) ? (source.provider, file) : nil
        }
        guard !snapshot.isEmpty || !providers.isEmpty, !settings.corePath.isEmpty else { return }
        do {
            let proxies = try snapshot.map { try $0.configuration() }
            let (support, imported) = try await withProviderCore(corePath: settings.corePath, providers: providers, proxies: proxies) { api in
                (try await api.udpSupport(), try await api.nodes(providerOrder: providers.map { $0.0 }))
            }
            let capabilities = Dictionary(imported.map { ($0.id, $0.supportsUDP) }, uniquingKeysWith: { first, _ in first })
            for index in nodes.indices {
                if let capability = capabilities[nodes[index].id] { nodes[index].supportsUDP = capability }
            }
            try saveNodeCache(nodes, directory: directory)
            let current = settings.manualProxies ?? []
            if snapshot.count == current.count, zip(snapshot, current).allSatisfy({ $0.id == $1.id && $0.type == $1.type && $0.fields == $1.fields }) { manualUDP = support }
        } catch { /* Unsupported or invalid core configuration remains unknown. */ }
    }
    func testDelay(_ node: Node) { testDelays([node]) }
    func testAllDelays() {
        guard !busy, !allNodes.isEmpty else { return }
        for index in nodes.indices {
            nodes[index].delayMilliseconds = nil
            nodes[index].delayFailed = false
        }
        for index in (settings.manualProxies ?? []).indices {
            settings.manualProxies?[index].delayMilliseconds = nil
            settings.manualProxies?[index].delayFailed = false
        }
        testDelays(allNodes)
    }
    private func testDelays(_ targets: [Node]) {
        guard !busy, !targets.isEmpty else { return }
        busy = true; isTestingDelays = true
        delayTask = Task {
            defer { self.testingNodes = []; self.isTestingDelays = false; self.busy = false; self.delayTask = nil }
            do {
            let parameters = try self.settings.delayTestParameters()
            let providers = self.settings.subscriptions.map { ($0.provider, providerFile($0, directory: self.directory)) }
            let proxies = try (self.settings.manualProxies ?? []).map { try $0.configuration() }
            let unified = self.option("unified-delay") != .boolean(false)
            try await withProviderCore(corePath: self.settings.corePath, providers: providers, proxies: proxies, unifiedDelay: unified) { api in
                try await withThrowingTaskGroup(of: (Int, Int?).self) { group in
                    @MainActor func enqueue(_ index: Int) {
                        let node = targets[index]
                        self.testingNodes.insert(node.id)
                        group.addTask {
                            try Task.checkCancellation()
                            let delay: Int?
                            do { delay = try await api.delay(node, testURL: parameters.url, timeoutMilliseconds: parameters.timeout) }
                            catch { try Task.checkCancellation(); delay = nil }
                            try Task.checkCancellation()
                            return (index, delay)
                        }
                    }
                    var nextIndex = min(5, targets.count)
                    for index in 0..<nextIndex { enqueue(index) }
                    while let (index, delay) = try await group.next() {
                        try Task.checkCancellation()
                        let node = targets[index]
                        self.testingNodes.remove(node.id)
                        if let cachedIndex = self.nodes.firstIndex(of: node) {
                            self.nodes[cachedIndex].delayMilliseconds = delay; self.nodes[cachedIndex].delayFailed = delay == nil
                        }
                        if let manualIndex = self.settings.manualProxies?.firstIndex(where: { $0.name == node.name && node.provider == "manual" }) {
                            self.settings.manualProxies?[manualIndex].delayMilliseconds = delay
                            self.settings.manualProxies?[manualIndex].delayFailed = delay == nil
                        }
                        self.message = delay.map { "\(node.name)：\($0) ms" } ?? "\(node.name)：延迟测试失败或超时"
                        if nextIndex < targets.count { enqueue(nextIndex); nextIndex += 1 }
                    }
                }
            }
            } catch {
                if Task.isCancelled { self.message = "已取消测速，已完成的结果已保留。" }
                else { self.error = error.localizedDescription }
            }
            do {
                try saveNodeCache(self.nodes, directory: self.directory)
                try self.save()
            } catch { self.error = error.localizedDescription }
        }
    }
    func cancelDelayTests() { delayTask?.cancel() }
    func startAll() {
        prepareConfig(.start)
    }
    func applyLive() {
        prepareConfig(.reload)
    }
    func previewConfig() {
        guard !busy, configPreview == nil else { return }
        do {
            configPreview = ConfigPreview(settings: settings, config: try generateConfig(settings), action: .preview)
        } catch { self.error = error.localizedDescription }
    }
    private func prepareConfig(_ action: ConfigAction) {
        guard configPreview == nil else { return }
        perform {
            if action == .start, self.nodes.isEmpty, !self.settings.subscriptions.isEmpty { try await self.importSubscriptions(self.settings) }
            let snapshot = self.settings
            try validateFieldValues(snapshot.options ?? [:], schema: documentSchemas.sections.flatMap(\.fields))
            let currentEndpoint = try controllerEndpoint(self.runtimeSettings)
            let newEndpoint = try controllerEndpoint(snapshot)
            let newAddress = snapshot.options?["external-controller"]?.text ?? "127.0.0.1:19090"
            let controllerChanged = self.activeController != newAddress || currentEndpoint.secret != newEndpoint.secret
            // Listening address and authentication belong to the controller service lifecycle.
            // A confirmed restart guarantees the UI and collector switch to a working new endpoint.
            let hasLocalRules = snapshot.options?["rule-providers"]?.object.values.contains { $0.object["type"] == .string("file") } ?? false
            let resolvedAction: ConfigAction = action == .reload && (controllerChanged || hasLocalRules || snapshot.corePath != self.runtimeSettings.corePath) ? .start : action
            self.configPreview = ConfigPreview(settings: snapshot, config: try generateConfig(snapshot), action: resolvedAction)
        }
    }
    func confirmConfig(_ preview: ConfigPreview) {
        guard !busy, preview.action != .preview, configPreview?.id == preview.id else { return }
        configPreview = nil
        perform {
            switch preview.action {
            case .preview: return
            case .start:
                try saveSettings(preview.settings, to: self.directory)
                self.settings = preview.settings
                try await installAndStartCore(settings: preview.settings, config: preview.config, directory: self.directory)
                try saveRuntimeSettings(preview.settings, to: self.directory)
                self.runtimeSettings = preview.settings
                try await startStatistics(directory: self.directory)
                self.message = "已按确认的配置启动服务，退出 GUI 后继续运行。"
            case .reload:
                try await self.api.reload(preview.config)
                try saveSettings(preview.settings, to: self.directory)
                try saveRuntimeSettings(preview.settings, to: self.directory)
                self.runtimeSettings = preview.settings
                self.settings = preview.settings
                try await upgradeRunningStatistics(directory: self.directory)
                self.message = "已应用确认的配置；重启持久化请点击“安装 / 启动全部”。已有连接保持原路由。"
            }
        }
    }
    func chooseCore() {
        let panel = NSOpenPanel(); panel.canChooseDirectories = false; panel.allowsMultipleSelection = false
        panel.message = "选择你信任的官方 macOS mihomo 二进制（之后将以管理员权限运行）"
        if panel.runModal() == .OK, let url = panel.url {
            settings.corePath = url.path
            do { try save() } catch { self.error = error.localizedDescription }
        }
    }
    func addRule(kind: RuleKind, value: String, node: Node?) throws {
        var candidate = settings
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        let normalized = [.domain, .suffix, .keyword, .wildcard].contains(kind) ? trimmed.lowercased() : trimmed
        guard !candidate.rules.contains(where: { $0.kind == kind && $0.value == normalized }) else { throw DeskError("相同规则已存在，请先删除旧规则") }
        candidate.rules.append(RouteRule(kind: kind, value: normalized, node: node))
        _ = try generateConfig(candidate)
        settings = candidate; try save()
    }
    func deleteRule(_ id: String) {
        settings.rules.removeAll { $0.id == id }
        do { try save(); message = "规则已删除，请应用配置。" } catch { self.error = error.localizedDescription }
    }
    func deleteSubscription(_ subscription: Subscription) {
        if settings.defaultNode?.provider == subscription.provider || settings.rules.contains(where: { $0.node?.provider == subscription.provider }) || (settings.proxyGroups ?? []).contains(where: { $0.targets.contains(where: { referencedNode($0)?.provider == subscription.provider }) }) {
            error = "该订阅仍被规则引用，请先调整相关出口。"; return
        }
        if settings.options?["rule-providers"]?.object.values.contains(where: { referencedNode($0.object["proxy"]?.text ?? "")?.provider == subscription.provider }) == true {
            error = "该订阅节点仍用于规则集下载，请先修改下载出口。"; return
        }
        settings.subscriptions.removeAll { $0.id == subscription.id }
        settings.subscriptionProxies?.removeValue(forKey: subscription.id)
        nodes.removeAll { $0.provider == subscription.provider }
        do { try save(); try saveNodeCache(nodes, directory: directory) }
        catch { self.error = error.localizedDescription }
    }
    func chooseApplicationPath() -> String? {
        let panel = NSOpenPanel(); panel.canChooseDirectories = false; panel.allowedContentTypes = [.application]
        if panel.runModal() == .OK, let url = panel.url,
           let bundle = Bundle(url: url), let executable = bundle.executableURL {
            return executable.path
        }
        return nil
    }
    func nodeLabel(_ node: Node) -> String {
        if node.provider == "manual" { return node.name + "（手动）" }
        let name = settings.subscriptions.first { $0.provider == node.provider }?.name ?? "未知订阅"
        return name + " / " + node.name
    }
    func manualProxy(for node: Node) -> ManualProxy? {
        guard node.provider == "manual" else { return nil }
        return settings.manualProxies?.first { $0.name == node.name }
    }
    func saveManualProxy(_ proxy: ManualProxy) throws {
        _ = try proxy.configuration()
        var candidate = settings
        var proxies = candidate.manualProxies ?? []
        if let index = proxies.firstIndex(where: { $0.id == proxy.id }) {
            let old = proxies[index].name
            proxies[index] = proxy
            for index in candidate.rules.indices where candidate.rules[index].node?.provider == "manual" && candidate.rules[index].node?.name == old { candidate.rules[index].node = proxy.node }
            if candidate.defaultNode?.provider == "manual", candidate.defaultNode?.name == old { candidate.defaultNode = proxy.node }
            var providers = candidate.options?["rule-providers"]?.object ?? [:]
            for name in providers.keys {
                var fields = providers[name]?.object ?? [:]
                if fields["proxy"] == .string("node:manual/" + old) || fields["proxy"] == .string(old) { fields["proxy"] = .string("node:" + proxy.node.id) }
                providers[name] = .object(fields)
            }
            if !providers.isEmpty { candidate.options?["rule-providers"] = .object(providers) }

            for index in candidate.proxyGroups?.indices ?? 0..<0 {
                let targets = candidate.proxyGroups?[index].targets ?? []
                candidate.proxyGroups?[index].targets = targets.map { $0 == "node:manual/" + old ? "node:" + proxy.node.id : $0 }
                if candidate.proxyGroups?[index].fields["default-selected"] == .string("node:manual/" + old) { candidate.proxyGroups?[index].fields["default-selected"] = .string("node:" + proxy.node.id) }
            }
        } else { proxies.append(proxy) }
        candidate.manualProxies = proxies
        if candidate.defaultNode == nil, candidate.defaultDirect != true, candidate.defaultPolicy == nil, candidate.defaultProxyGroup == nil { candidate.defaultNode = proxies.first?.node ?? nodes.first }
        _ = try generateConfig(candidate); try saveSettings(candidate, to: directory); settings = candidate
        message = "代理已保存，请预览并应用配置。"
    }
    func deleteManualProxy(_ proxy: ManualProxy) {
        if settings.defaultNode == proxy.node || settings.rules.contains(where: { $0.node == proxy.node }) || (settings.proxyGroups ?? []).contains(where: { $0.targets.contains("node:" + proxy.node.id) }) {
            error = "该代理仍被路由规则或 MATCH 使用，请先调整出口。"; return
        }
        if settings.options?["rule-providers"]?.object.values.contains(where: { $0.object["proxy"] == .string("node:" + proxy.node.id) || $0.object["proxy"] == .string(proxy.name) }) == true {
            error = "该代理仍用于规则集下载，请先修改下载出口。"; return
        }
        settings.manualProxies?.removeAll { $0.id == proxy.id }
        do { try save(); message = "代理已删除，请应用配置。" } catch { self.error = error.localizedDescription }
    }
    func targetID(node: Node?, builtin: String?, group: String? = nil) -> String { group.map { "group:" + $0 } ?? node.map { "node:" + $0.id } ?? "builtin:" + (builtin ?? "DIRECT") }
    func setDefaultTarget(_ target: String) {
        do {
            var candidate = settings
            let selected = allNodes.first { "node:" + $0.id == target }
                ?? (candidate.defaultNode.map { "node:" + $0.id == target } == true ? candidate.defaultNode : nil)
            if target.hasPrefix("node:"), selected == nil { throw DeskError("所选代理已失效，请重新选择出口") }
            candidate.defaultProxyGroup = target.hasPrefix("group:") ? String(target.dropFirst(6)) : nil
            candidate.defaultNode = selected
            candidate.defaultPolicy = target.hasPrefix("builtin:") ? String(target.dropFirst(8)) : nil
            candidate.defaultDirect = candidate.defaultPolicy == "DIRECT"
            _ = try generateConfig(candidate); try saveSettings(candidate, to: directory); settings = candidate
        } catch { self.error = error.localizedDescription }
    }
    func saveRule(_ rule: RouteRule) throws {
        var candidate = settings
        if let index = candidate.rules.firstIndex(where: { $0.id == rule.id }) { candidate.rules[index] = rule }
        else { candidate.rules.append(rule) }
        _ = try generateConfig(candidate); try saveSettings(candidate, to: directory); settings = candidate
        message = "路由规则已保存，请预览并应用配置。"
    }
    func setRuleTarget(_ rule: RouteRule, target: String) {
        do {
            var changed = rule
            changed.node = allNodes.first { "node:" + $0.id == target }
                ?? (rule.node.map { "node:" + $0.id == target } == true ? rule.node : nil)
            if target.hasPrefix("node:"), changed.node == nil { throw DeskError("所选代理已失效，请重新选择出口") }
            changed.proxyGroup = target.hasPrefix("group:") ? String(target.dropFirst(6)) : nil
            changed.builtin = target.hasPrefix("builtin:") ? String(target.dropFirst(8)) : nil
            try saveRule(changed)
        } catch { self.error = error.localizedDescription }
    }
    func moveRule(_ id: String, offset: Int) {
        guard let index = settings.rules.firstIndex(where: { $0.id == id }), settings.rules.indices.contains(index + offset) else { return }
        settings.rules.swapAt(index, index + offset)
        do { try save() } catch { self.error = error.localizedDescription }
    }
}

extension DeskModel {
    func saveProxyGroup(_ group: ProxyGroup) throws {
        var candidate = settings
        var groups = candidate.proxyGroups ?? []
        if let index = groups.firstIndex(where: { $0.id == group.id }) {
            let old = groups[index].name
            guard !groups.contains(where: { $0.id != group.id && $0.name == group.name }) else { throw DeskError("代理组名称已存在") }
            groups[index] = group
            for index in groups.indices {
                groups[index].targets = groups[index].targets.map { $0 == "group:" + old ? "group:" + group.name : $0 }
                if groups[index].fields["default-selected"] == .string("group:" + old) { groups[index].fields["default-selected"] = .string("group:" + group.name) }
            }
            for index in candidate.rules.indices where candidate.rules[index].proxyGroup == old { candidate.rules[index].proxyGroup = group.name }
            if candidate.defaultProxyGroup == old { candidate.defaultProxyGroup = group.name }
            for index in candidate.manualProxies?.indices ?? 0..<0 {
                if candidate.manualProxies?[index].fields["dialer-proxy"] == .string(old) { candidate.manualProxies?[index].fields["dialer-proxy"] = .string(group.name) }
            }
            var providers = candidate.options?["rule-providers"]?.object ?? [:]
            for name in providers.keys {
                var fields = providers[name]?.object ?? [:]
                if fields["proxy"] == .string("group:" + old) || fields["proxy"] == .string(old) { fields["proxy"] = .string("group:" + group.name) }
                providers[name] = .object(fields)
            }
            candidate.options?["rule-providers"] = .object(providers)
            rewriteSubRules(&candidate, old: old, new: group.name, provider: false)
        } else { groups.append(group) }
        candidate.proxyGroups = groups
        _ = try generateConfig(candidate); try saveSettings(candidate, to: directory); settings = candidate
    }
    func saveRuleProvider(name: String, type: String, fields: [String: ConfigValue], oldName: String?) throws {
        guard !name.isEmpty, !name.contains(","), !name.unicodeScalars.contains(where: { CharacterSet.controlCharacters.contains($0) }) else { throw DeskError("规则集名称无效") }
        var candidate = settings
        var providers = candidate.options?["rule-providers"]?.object ?? [:]
        guard name == oldName || providers[name] == nil else { throw DeskError("规则集名称已存在") }
        var fields = fields; fields["type"] = .string(type)
        try validateFieldValues(fields, schema: ruleProviderEditorFields(type))
        if type == "file" {
            guard FileManager.default.isReadableFile(atPath: fields["path"]?.text ?? "") else { throw DeskError("请选择可读取的本地规则文件") }
        }
        if let oldName, oldName != name {
            providers.removeValue(forKey: oldName)
            for index in candidate.rules.indices {
                if candidate.rules[index].kind == .ruleSet, candidate.rules[index].value == oldName { candidate.rules[index].value = name }
                else { candidate.rules[index].value = replacingProvider(candidate.rules[index].value, old: oldName, new: name) }
            }
            rewriteSubRules(&candidate, old: oldName, new: name, provider: true)
        }
        providers[name] = .object(fields)
        var options = candidate.options ?? [:]; options["rule-providers"] = .object(providers); candidate.options = options
        _ = try generateConfig(candidate); try saveSettings(candidate, to: directory); settings = candidate
    }
    func deleteResource(_ row: ResourceRow, groups: Bool) {
        do {
            var candidate = settings
            let subRules = candidate.options?["sub-rules"]?.object.values.flatMap(\.array).map(\.text) ?? []
            if groups {
                guard !(candidate.manualProxies ?? []).contains(where: { $0.fields["dialer-proxy"] == .string(row.name) }),
                      candidate.defaultProxyGroup != row.name,
                      !candidate.rules.contains(where: { $0.proxyGroup == row.name }),
                      !(candidate.proxyGroups ?? []).contains(where: { $0.id != row.id && $0.targets.contains("group:" + row.name) }),
                      !(candidate.options?["rule-providers"]?.object.values.contains(where: { $0.object["proxy"] == .string("group:" + row.name) || $0.object["proxy"] == .string(row.name) }) ?? false),
                      !subRules.contains(where: { $0.hasSuffix("," + row.name) }) else { throw DeskError("代理组仍被引用，请先调整引用") }
                candidate.proxyGroups?.removeAll { $0.id == row.id }
            } else {
                guard !candidate.rules.contains(where: { ($0.kind == .ruleSet && $0.value == row.name) || replacingProvider($0.value, old: row.name, new: "__check__") != $0.value }),
                      !subRules.contains(where: { replacingProvider($0, old: row.name, new: "__check__") != $0 }) else { throw DeskError("规则集仍被规则引用，请先调整规则") }
                var providers = candidate.options?["rule-providers"]?.object ?? [:]; providers.removeValue(forKey: row.name)
                candidate.options?["rule-providers"] = .object(providers)
            }
            _ = try generateConfig(candidate); try saveSettings(candidate, to: directory); settings = candidate
        } catch { self.error = error.localizedDescription }
    }
    private func replacingProvider(_ value: String, old: String, new: String) -> String {
        value.replacingOccurrences(of: "RULE-SET," + old + ",", with: "RULE-SET," + new + ",")
            .replacingOccurrences(of: "RULE-SET," + old + ")", with: "RULE-SET," + new + ")")
    }
    private func rewriteSubRules(_ candidate: inout ClashCore.Settings, old: String, new: String, provider: Bool) {
        var subRules = candidate.options?["sub-rules"]?.object ?? [:]
        for name in subRules.keys {
            subRules[name] = .array((subRules[name]?.array ?? []).map { entry in
                let text = entry.text
                return .string(provider ? replacingProvider(text, old: old, new: new) : text.hasSuffix("," + old) ? String(text.dropLast(old.count)) + new : text)
            })
        }
        if !subRules.isEmpty { candidate.options?["sub-rules"] = .object(subRules) }
    }
}
