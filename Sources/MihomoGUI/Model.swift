import SwiftUI
import AppKit
import MihomoGUICore

@MainActor
final class MihomoGUIModel: ObservableObject {
    @Published var settings = Settings() { didSet { scheduleLiveUpdate() } }
    @Published var nodes: [Node] = []
    @Published var connections: [Connection] = []
    @Published var connectionsError: String?
    @Published var connectionsLoaded = false
    @Published var uploadTotal: Int64?
    @Published var downloadTotal: Int64?
    private var connectionsRefreshID = UUID()
    private var udpRefreshID = UUID()
    @Published var runtimeConfigurationUncertain = false
    private var connectionsDate: Date?
    @Published var connectionSpeedsAvailable = false
    @Published var testingNodes: Set<String> = []
    @Published var isTestingDelays = false
    private var delayTask: Task<Void, Never>?
    enum SubscriptionUpdatePhase { case fetching, cancelling, saving }
    @Published var subscriptionUpdatePhase: SubscriptionUpdatePhase?
    private var subscriptionTask: Task<Void, Never>?

    @Published var rulePrefill: RouteRule?
    @Published var coreRunning = false
    @Published var busy = false
    enum ServiceOperation { case starting, stopping }
    @Published var serviceOperation: ServiceOperation?
    @Published var error: String?
    @Published var message = "退出界面后，已启动的服务继续运行。"
    @Published var coreMemory: Int64?
    @Published var coreVersion: String?
    @Published var coreServiceLoaded = false
    @Published var corePID: Int?
    private var runtimeSettings = MihomoGUICore.Settings()
    private var diagnosticsDate = Date.distantPast
    private(set) var configurationFormatUnsupported = false
    let directory: URL
    private var monitor: Task<Void, Never>?
    private var configurationSaveTask: Task<Void, Never>?
    private var configurationSavePending = false
    private var liveUpdateTask: Task<Void, Never>?
    private var liveUpdatePending = false
    var configurationLocked: Bool { coreActive }

    init(directory: URL? = nil) {
        self.directory = directory ?? ((try? dataDirectory()) ?? FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent("Library/Application Support/MihomoGUI"))
        let directory = self.directory
        runtimeConfigurationUncertain = FileManager.default.fileExists(atPath: directory.appendingPathComponent("runtime-update-pending").path)
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
            configurationFormatUnsupported = error is UnsupportedSettingsFormat
            self.error = error.localizedDescription
        }
    }
    func startMonitor() {
        guard monitor == nil, !configurationFormatUnsupported else { return }
        monitor = Task { [weak self] in
            if let self {
                await self.refresh()
            }
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
    var api: CoreAPI { get throws { try CoreAPI(settings: runtimeSettings) } }
    var allNodes: [Node] { (settings.manualProxies ?? []).map(\.node) + nodes }
    var coreActive: Bool { coreRunning || coreServiceLoaded || corePID != nil }
    var hasUnappliedChanges: Bool { runtimeConfigurationUncertain || runtimeConfigurationChanged(settings, applied: runtimeSettings) }
    func toggleCore() {
        if !coreActive { startCore(); return }
        perform {
            self.serviceOperation = .stopping
            defer { self.serviceOperation = nil }
            var failures: [String] = []
            do { try await stopCore() } catch { failures.append(error.localizedDescription) }
            await self.refreshDiagnostics()
            if !failures.isEmpty { throw MihomoGUIError(failures.joined(separator: "\n")) }
        }
    }
    var activeController: String { runtimeSettings.options?["external-controller"]?.text ?? "127.0.0.1:19090" }
    var connectionProxyNames: [String: String] {
        var names: [String: String] = [:]
        for (sourceIndex, subscription) in runtimeSettings.subscriptions.enumerated() {
            for (proxyIndex, proxy) in (runtimeSettings.subscriptionProxies?[subscription.id] ?? []).enumerated() {
                if let name = proxy.object["name"]?.text {
                    names[subscriptionProxyAlias(sourceIndex: sourceIndex, proxyIndex: proxyIndex)] = name
                }
            }
        }
        return names
    }
    func refresh() async {
        let refreshID = UUID()
        connectionsRefreshID = refreshID
        do {
            let snapshot = try await api.connectionSnapshot()
            var live = snapshot.connections
            try Task.checkCancellation()
            guard connectionsRefreshID == refreshID else { return }
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
            uploadTotal = snapshot.uploadTotal; downloadTotal = snapshot.downloadTotal
            connections = live; coreRunning = true; connectionsError = nil; connectionsLoaded = true
        } catch {
            guard !Task.isCancelled, connectionsRefreshID == refreshID else { return }
            let registered = (try? await runCommand("/bin/launchctl", ["print", "system/" + coreLabel])) != nil
            guard !Task.isCancelled, connectionsRefreshID == refreshID else { return }
            coreServiceLoaded = registered
            if !registered { corePID = nil }
            let stopped = !registered && serviceOperation != .starting
                && (error as? URLError)?.code == .cannotConnectToHost
            // HTTP and decoding failures still mean the controller is reachable.
            coreRunning = error is CoreAPIError
            uploadTotal = nil; downloadTotal = nil
            if stopped { connections = [] }
            connectionsDate = nil; connectionSpeedsAvailable = false; connectionsLoaded = true
            connectionsError = stopped ? nil : "连接读取失败：" + (error is URLError ? "控制接口无法连接或请求超时" : error.localizedDescription)
        }
        if Date().timeIntervalSince(diagnosticsDate) > 10 { await refreshDiagnostics() }
    }
    func refreshDiagnostics() async {
        diagnosticsDate = Date()
        coreServiceLoaded = (try? await runCommand("/bin/launchctl", ["print", "system/" + coreLabel])) != nil
        async let core = servicePID(domain: "system", label: coreLabel)
        async let memory = try? api.memory()
        async let version = try? api.version()
        corePID = await core
        coreMemory = await memory; coreVersion = await version
    }
    func baseOption(_ path: String) -> ConfigValue? {
        generalConfigurationDefaults(settings)[path]
    }
    func option(_ path: String) -> ConfigValue? { settings.options?[path] ?? baseOption(path) }
    func setOption(_ path: String, value: ConfigValue?) {
        guard !configurationLocked, !busy else { return }
        if path == "tun.enable" { settings.tun = nil }
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
    func importSubscriptions(_ candidate: MihomoGUICore.Settings) async throws {
        try Task.checkCancellation()
        let staging = FileManager.default.temporaryDirectory.appendingPathComponent("MihomoGUI-update-" + UUID().uuidString)
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
        rejectUnavailableRouteNodes(&updated, nodes: merged)
        try await commitSubscriptionUpdate(updated, nodes: merged, sources: updated.subscriptions, staging: staging)
        settings = updated; nodes = merged
        message = "已拉取并保存 \(nodes.count) 个节点。可在规则表修改 MATCH 的出口。"
    }
    func saveSubscription(_ subscription: Subscription) async throws {
        try Task.checkCancellation()
        flushConfigurationSave()
        var subscription = subscription
        subscription.name = subscription.name.trimmingCharacters(in: .whitespacesAndNewlines)
        subscription.url = subscription.url.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !subscription.name.isEmpty else { throw MihomoGUIError("请输入订阅名称") }
        guard !settings.subscriptions.contains(where: { $0.id != subscription.id && $0.url == subscription.url }) else {
            throw MihomoGUIError("该订阅地址已存在")
        }
        let staging = FileManager.default.temporaryDirectory.appendingPathComponent("MihomoGUI-subscription-" + UUID().uuidString)
        try FileManager.default.createDirectory(at: staging, withIntermediateDirectories: true, attributes: [.posixPermissions: 0o700])
        defer { try? FileManager.default.removeItem(at: staging) }
        let fetched = try await fetchSubscriptionData([subscription], corePath: settings.corePath, directory: staging)
        var imported = fetched.nodes
        subscription.usage = fetched.subscriptions.first?.usage
        guard !imported.isEmpty else { throw MihomoGUIError("订阅没有可用节点，未保存") }
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
        rejectUnavailableRouteNodes(&updated, nodes: merged)
        try await commitSubscriptionUpdate(updated, nodes: merged, sources: [subscription], staging: staging)
        settings = updated; nodes = merged
        message = "订阅已保存，共 \(imported.count) 个节点。"
    }
    private func commitSubscriptionUpdate(_ updated: MihomoGUICore.Settings, nodes: [Node], sources: [Subscription], staging: URL) async throws {
        let folder = directory
        let files = try await Task.detached {
            _ = try generateConfig(updated)
            var files = try sources.map { ("providers/" + $0.id + ".yaml", try Data(contentsOf: providerFile($0, directory: staging))) }
            files.append(("nodes.json", try JSONEncoder().encode(nodes)))
            files.append(("settings.json", try JSONEncoder().encode(updated)))
            return files
        }.value
        try Task.checkCancellation()
        // Once the atomic file transaction begins, finish it before accepting cancellation.
        if subscriptionUpdatePhase != nil { subscriptionUpdatePhase = .saving }
        try await Task.detached { try commitFiles(files, directory: folder) }.value
    }
    func refreshSubscription(_ subscription: Subscription) { startSubscriptionUpdate(subscription) }
    func refreshSubscriptions() { startSubscriptionUpdate() }

    func startSubscriptionUpdate(_ subscription: Subscription? = nil, completion: ((Error?) -> Void)? = nil) {
        guard !busy else { return }
        flushConfigurationSave()
        busy = true
        subscriptionUpdatePhase = .fetching
        let candidate = settings
        subscriptionTask = Task {
            var failure: Error?
            defer {
                busy = false
                subscriptionUpdatePhase = nil
                subscriptionTask = nil
                completion?(failure)
            }
            do {
                try Task.checkCancellation()
                if let subscription { try await saveSubscription(subscription) }
                else { try await importSubscriptions(candidate) }
            } catch {
                if Task.isCancelled {
                    failure = CancellationError()
                    message = "已取消订阅拉取，未保存修改。"
                } else {
                    failure = error
                    if completion == nil { self.error = error.localizedDescription }
                }
            }
        }
    }
    func cancelSubscriptionUpdate() {
        guard subscriptionUpdatePhase == .fetching else { return }
        subscriptionUpdatePhase = .cancelling
        subscriptionTask?.cancel()
    }
    @Published var manualUDP: [String: Bool] = [:]
    func refreshManualUDP() async {
        let requestID = UUID()
        udpRefreshID = requestID
        let sourceSettings = settings
        let snapshot = sourceSettings.manualProxies ?? []
        manualUDP = [:]
        let providers = sourceSettings.subscriptions.compactMap { source -> (String, URL)? in
            let file = providerFile(source, directory: directory)
            return FileManager.default.fileExists(atPath: file.path) ? (source.provider, file) : nil
        }
        guard !snapshot.isEmpty || !providers.isEmpty, !settings.corePath.isEmpty else { return }
        do {
            let proxies = try snapshot.map { try $0.configuration() }
            let (support, imported) = try await withProviderCore(corePath: sourceSettings.corePath, providers: providers, proxies: proxies) { api in
                (try await api.udpSupport(), try await api.nodes(providerOrder: providers.map { $0.0 }))
            }
            try Task.checkCancellation()
            let current = settings.manualProxies ?? []
            guard udpRefreshID == requestID, !busy,
                  sourceSettings.corePath == settings.corePath,
                  sourceSettings.subscriptions == settings.subscriptions,
                  sourceSettings.subscriptionProxies == settings.subscriptionProxies,
                  snapshot.count == current.count,
                  zip(snapshot, current).allSatisfy({ $0.id == $1.id && $0.type == $1.type && $0.fields == $1.fields }) else { return }
            let capabilities = Dictionary(imported.map { ($0.id, $0.supportsUDP) }, uniquingKeysWith: { first, _ in first })
            var updated = nodes
            for index in updated.indices {
                if let capability = capabilities[updated[index].id] { updated[index].supportsUDP = capability }
            }
            try saveNodeCache(updated, directory: directory)
            nodes = updated; manualUDP = support
        } catch {
            guard !Task.isCancelled, udpRefreshID == requestID else { return }
            self.error = "无法更新 UDP 能力：" + error.localizedDescription
        }
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
    func startCore() {
        guard !coreActive, !configurationFormatUnsupported else { return }
        perform {
            await self.refresh()
            guard !self.coreActive else { return }
            self.serviceOperation = .starting
            defer { self.serviceOperation = nil }
            if self.nodes.isEmpty, !self.settings.subscriptions.isEmpty { try await self.importSubscriptions(self.settings) }
            let snapshot = self.settings
            try validateFieldValues(snapshot.options ?? [:], schema: documentSchemas.sections.flatMap(\.fields))
            _ = try controllerEndpoint(snapshot)
            try await installAndStartCore(settings: snapshot, config: generateConfig(snapshot), directory: self.directory)
            let pending = self.directory.appendingPathComponent("runtime-update-pending")
            if FileManager.default.fileExists(atPath: pending.path) { try FileManager.default.removeItem(at: pending) }
            self.runtimeSettings = snapshot
            self.runtimeConfigurationUncertain = false
            self.message = "配置已校验并启动。"
        }
    }
    func retryLiveUpdate() {
        guard !busy else { return }
        scheduleLiveUpdate()
    }
    private func scheduleLiveUpdate() {
        guard configurationLocked, !configurationFormatUnsupported else { return }
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
                var ruleFiles: RuleFileUpdate?
                var applied = false
                do {
                    let config = try generateConfig(snapshot)
                    let previousSettings = self.runtimeSettings
                    let previous = try generateConfig(previousSettings)
                    let controller = try self.api
                    // This marker survives GUI termination between reload and durable confirmation.
                    let pending = self.directory.appendingPathComponent("runtime-update-pending")
                    try Data().write(to: pending, options: .atomic)
                    try FileManager.default.setAttributes([.posixPermissions: 0o600], ofItemAtPath: pending.path)
                    if self.runtimeConfigurationUncertain || snapshot.options?["rule-providers"] != previousSettings.options?["rule-providers"] {
                        ruleFiles = try await prepareRuleFileUpdate(snapshot)
                    }
                    // A lost response cannot prove that the core kept its previous configuration.
                    self.runtimeConfigurationUncertain = true
                    try await controller.reload(config)
                    var runtimeSaveAttempted = false
                    do {
                        try await persistCoreConfiguration(config)
                        runtimeSaveAttempted = true
                        try saveRuntimeSettings(snapshot, to: self.directory)
                    } catch {
                        let persistenceError = error
                        var failures: [String] = []
                        if let update = ruleFiles {
                            do { try await update.finish(restore: true); ruleFiles = nil }
                            catch { failures.append("规则文件恢复失败：" + error.localizedDescription) }
                        }
                        do { try await controller.reload(previous) }
                        catch { failures.append("内核回滚失败：" + error.localizedDescription) }
                        // A transport failure can follow a successful write; always restore
                        // the previous disk configuration before declaring rollback complete.
                        do { try await persistCoreConfiguration(previous) }
                        catch { failures.append("系统配置恢复失败：" + error.localizedDescription) }
                        if runtimeSaveAttempted {
                            do { try saveRuntimeSettings(previousSettings, to: self.directory) }
                            catch { failures.append("运行配置恢复失败：" + error.localizedDescription) }
                        }
                        if failures.isEmpty {
                            do { try FileManager.default.removeItem(at: pending) }
                            catch { failures.append("更新标记清理失败：" + error.localizedDescription) }
                        }
                        self.runtimeConfigurationUncertain = !failures.isEmpty
                        if !failures.isEmpty {
                            throw MihomoGUIError(persistenceError.localizedDescription + "；" + failures.joined(separator: "；") + "。请重试应用或重新启动服务。")
                        }
                        throw persistenceError
                    }
                    try FileManager.default.removeItem(at: pending)
                    self.runtimeSettings = snapshot
                    self.runtimeConfigurationUncertain = false
                    self.message = "修改已自动应用。"
                    applied = true
                } catch {
                    var detail = error.localizedDescription
                    if let update = ruleFiles {
                        do { try await update.finish(restore: true); ruleFiles = nil }
                        catch {
                            self.runtimeConfigurationUncertain = true
                            detail += "；规则文件恢复失败：" + error.localizedDescription
                        }
                    }
                    if FileManager.default.fileExists(atPath: self.directory.appendingPathComponent("runtime-update-pending").path) {
                        self.runtimeConfigurationUncertain = true
                    }
                    self.error = "修改已保存在本地，但自动应用失败：\(detail)"
                }
                if applied, let update = ruleFiles {
                    do { try await update.finish(restore: false) }
                    catch { self.error = "配置已应用，但规则文件备份清理失败：" + error.localizedDescription }
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
