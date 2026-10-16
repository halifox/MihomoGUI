import SwiftUI
import AppKit
import ClashCore

@MainActor
final class DeskModel: ObservableObject {
    @Published var settings = Settings() { didSet { scheduleLiveUpdate() } }
    @Published var nodes: [Node] = []
    @Published var connections: [Connection] = []
    private var connectionsDate: Date?
    @Published var connectionSpeedsAvailable = false
    @Published var traffic: [DomainTrafficRow] = []
    @Published var statisticsError: String?
    @Published var testingNodes: Set<String> = []
    @Published var isTestingDelays = false
    private var delayTask: Task<Void, Never>?
    @Published var serviceLogs: String?
    @Published var rulePrefill: RouteRule?
    @Published var coreRunning = false
    @Published var lastSample: Date?
    @Published var busy = false
    @Published var error: String?
    @Published var message = "退出界面后，已启动的服务继续运行。"
    @Published var hours = 24
    @Published var trafficGrouping: TrafficGrouping = .domain
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
    private var liveUpdateTask: Task<Void, Never>?
    private var liveUpdatePending = false
    var configurationLocked: Bool { coreRunning || corePID != nil }

    init() {
        directory = (try? dataDirectory()) ?? FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent("Library/Application Support/ClashDesk")
        do {
            settings = try loadSettings(from: directory)
            let bundledCore = Bundle.main.bundleURL.appendingPathComponent("Contents/Helpers/mihomo")
            settings.corePath = bundledCore.path
            runtimeSettings = try loadRuntimeSettings(from: directory)
            if settings.ruleOrderMigrated == nil {
                settings.rules = settings.rules.filter { $0.kind.isProcess } + settings.rules.filter { !$0.kind.isProcess }
                settings.ruleOrderMigrated = true
            }
            nodes = try loadNodeCache(directory: directory, populateEndpoints: false)
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
        monitor = Task { [weak self] in
            if let self, self.settings.subscriptionProxies == nil {
                let snapshot = self.settings; let folder = self.directory
                do {
                    let cached = try await Task.detached {
                        var candidate = snapshot
                        try cacheSubscriptionProxies(&candidate, directory: folder)
                        return candidate.subscriptionProxies
                    }.value
                    if self.settings.subscriptionProxies == nil,
                       self.settings.subscriptions.map({ $0.id + $0.url }) == snapshot.subscriptions.map({ $0.id + $0.url }) {
                        self.settings.subscriptionProxies = cached; try self.save()
                    }
                } catch { self.error = error.localizedDescription }
            }
            if let self, self.nodes.contains(where: { $0.server == nil }) {
                let folder = self.directory
                do {
                    let populated = try await Task.detached { try loadNodeCache(directory: folder) }.value
                    let endpoints = Dictionary(populated.map { ($0.id, $0) }, uniquingKeysWith: { first, _ in first })
                    for index in self.nodes.indices {
                        if self.nodes[index].server == nil, let endpoint = endpoints[self.nodes[index].id] {
                            self.nodes[index].server = endpoint.server; self.nodes[index].port = endpoint.port
                        }
                    }
                } catch { self.error = error.localizedDescription }
            }
            if let self, self.nodes.isEmpty, !self.settings.subscriptions.isEmpty, !self.settings.corePath.isEmpty { self.refreshSubscriptions() }
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
            var live = try await api.connections()
            let now = Date()
            if let previousDate = connectionsDate {
                let elapsed = now.timeIntervalSince(previousDate)
                let previous = Dictionary(connections.map { ($0.id, $0) }, uniquingKeysWith: { _, last in last })
                if elapsed > 0 {
                    for index in live.indices {
                        guard let old = previous[live[index].id] else { continue }
                        live[index].downloadSpeed = Int64(Double(max(0, live[index].download - old.download)) / elapsed)
                        live[index].uploadSpeed = Int64(Double(max(0, live[index].upload - old.upload)) / elapsed)
                    }
                }
            }
            connectionSpeedsAvailable = connectionsDate != nil
            connectionsDate = now
            connections = live; coreRunning = true
        } catch { coreRunning = false; connections = []; connectionsDate = nil; connectionSpeedsAvailable = false }
        do {
            let folder = directory; let range = hours; let grouping = trafficGrouping
            let result = try await Task.detached {
                let database = try TrafficDatabase(url: folder.appendingPathComponent("traffic.sqlite"), readOnly: true)
                return (try database.groupedRows(since: Date().addingTimeInterval(-Double(range) * 3600), by: grouping), try database.lastSample())
            }.value
            guard grouping == trafficGrouping, range == hours else { return }
            if traffic != result.0 { traffic = result.0 }
            if lastSample != result.1 { lastSample = result.1 }
            if statisticsError != nil { statisticsError = nil }
        } catch { lastSample = nil; traffic = []; statisticsError = error.localizedDescription }
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
        guard !configurationLocked, !busy else { return }
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
        flushConfigurationSave()
        busy = true
        Task {
            defer { busy = false }
            do { try await operation(); await refresh() }
            catch { self.error = error.localizedDescription }
        }
    }
    func save() throws { try saveSettings(settings, to: directory) }
    func importSubscriptions(_ candidate: ClashCore.Settings) async throws {
        let staging = FileManager.default.temporaryDirectory.appendingPathComponent("clashdesk-update-" + UUID().uuidString)
        try FileManager.default.createDirectory(at: staging, withIntermediateDirectories: true, attributes: [.posixPermissions: 0o700])
        defer { try? FileManager.default.removeItem(at: staging) }
        let fetched = try await fetchSubscriptionData(candidate.subscriptions, corePath: candidate.corePath, directory: staging)
        let imported = fetched.nodes
        var updated = candidate
        updated.subscriptions = fetched.subscriptions
        let sources = updated.subscriptions.map { source in
            (source.id, providerFile(source, directory: staging))
        }
        updated.subscriptionProxies = try await Task.detached {
            var cached: [String: [ConfigValue]] = [:]
            for (id, file) in sources { cached[id] = try readSubscriptionProxies(file).map { ConfigValue(native: $0) } }
            return cached
        }.value
        let updatedAt = Date()
        for index in updated.subscriptions.indices { updated.subscriptions[index].lastUpdatedAt = updatedAt }
        if updated.defaultNode == nil, updated.defaultDirect != true, updated.defaultPolicy == nil, updated.defaultProxyGroup == nil { updated.defaultNode = updated.manualProxies?.first?.node ?? imported.first }
        var merged = imported
        let previous = Dictionary(uniqueKeysWithValues: nodes.map { ($0.id, $0) })
        for index in merged.indices {
            merged[index].delayMilliseconds = previous[merged[index].id]?.delayMilliseconds
            merged[index].delayFailed = previous[merged[index].id]?.delayFailed
        }
        try await commitSubscriptionUpdate(updated, nodes: merged, sources: updated.subscriptions, staging: staging)
        settings = updated; nodes = merged
        message = "已拉取并保存 \(nodes.count) 个节点。可在规则表修改 MATCH 的出口。"
    }
    func saveSubscription(_ subscription: Subscription) async throws {
        flushConfigurationSave()
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
        let sourceFile = providerFile(subscription, directory: staging)
        let entries = try await Task.detached { try readSubscriptionProxies(sourceFile).map { ConfigValue(native: $0) } }.value
        var cached = updated.subscriptionProxies ?? [:]; cached[subscription.id] = entries
        updated.subscriptionProxies = cached
        try await commitSubscriptionUpdate(updated, nodes: merged, sources: [subscription], staging: staging)
        settings = updated; nodes = merged
        message = "订阅已保存，共 \(imported.count) 个节点。"
    }
    private func commitSubscriptionUpdate(_ updated: ClashCore.Settings, nodes: [Node], sources: [Subscription], staging: URL) async throws {
        let folder = directory
        try await Task.detached {
            _ = try generateConfig(updated)
            var files = try sources.map { ("providers/" + $0.id + ".yaml", try Data(contentsOf: providerFile($0, directory: staging))) }
            files.append(("nodes.json", try JSONEncoder().encode(nodes)))
            files.append(("settings.json", try JSONEncoder().encode(updated)))
            try commitFiles(files, directory: folder)
        }.value
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
        perform {
            if self.nodes.isEmpty, !self.settings.subscriptions.isEmpty { try await self.importSubscriptions(self.settings) }
            let snapshot = self.settings
            try validateFieldValues(snapshot.options ?? [:], schema: documentSchemas.sections.flatMap(\.fields))
            _ = try controllerEndpoint(snapshot)
            try await installAndStartCore(settings: snapshot, config: generateConfig(snapshot), directory: self.directory)
            self.runtimeSettings = snapshot
            try await startStatistics(directory: self.directory)
            self.message = "配置已校验并启动。"
        }
    }
    private func scheduleLiveUpdate() {
        guard configurationLocked else { return }
        liveUpdatePending = true
        guard liveUpdateTask == nil else { return }
        liveUpdateTask = Task { [weak self] in
            guard let self else { return }
            defer { self.liveUpdateTask = nil }
            while self.liveUpdatePending {
                try? await Task.sleep(nanoseconds: 500_000_000)
                if self.busy { continue }
                self.liveUpdatePending = false
                guard self.configurationLocked, self.hasUnappliedChanges else { continue }
                let snapshot = self.settings
                self.busy = true
                do {
                    let config = try generateConfig(snapshot)
                    let previous = try generateConfig(self.runtimeSettings)
                    try await self.api.reload(config)
                    do {
                        try await persistCoreConfiguration(config)
                    } catch {
                        let persistenceError = error
                        do { try await self.api.reload(previous) }
                        catch { self.busy = false; self.error = "保存运行配置失败，回滚也失败：\(error.localizedDescription)"; return }
                        throw persistenceError
                    }
                    self.runtimeSettings = snapshot
                    try saveRuntimeSettings(snapshot, to: self.directory)
                    self.message = "修改已自动应用。"
                } catch {
                    self.error = "修改已保存在本地，但自动应用失败：\(error.localizedDescription)"
                }
                self.busy = false
            }
        }
    }
    func nodeLabel(_ node: Node) -> String {
        if node.provider == "manual" { return node.name + "（手动）" }
        let name = settings.subscriptions.first { $0.provider == node.provider }?.name ?? "未知订阅"
        return name + " / " + node.name
    }
    func nodeLabelWithDelay(_ node: Node) -> String {
        let delay: String
        if testingNodes.contains(node.id) { delay = "测试中…" }
        else if node.delayFailed == true { delay = "超时" }
        else { delay = node.delayMilliseconds.map { "\($0) ms" } ?? "未测试" }
        return nodeLabel(node) + " / " + delay
    }

}
