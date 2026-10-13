import SwiftUI
import AppKit
import ClashCore

@MainActor
final class DeskModel: ObservableObject {
    @Published var settings = Settings()
    @Published var nodes: [Node] = []
    @Published var connections: [Connection] = []
    @Published var traffic: [DomainTrafficRow] = []
    @Published var testingNode: String?
    @Published var coreRunning = false
    @Published var lastSample: Date?
    @Published var busy = false
    @Published var error: String?
    @Published var message = "退出界面后，已启动的服务继续运行。"
    @Published var hours = 24
    let directory: URL
    private var monitor: Task<Void, Never>?

    init() {
        directory = (try? dataDirectory()) ?? FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent("Library/Application Support/ClashDesk")
        do {
            settings = try loadSettings(from: directory)
            nodes = try loadNodeCache(directory: directory)
            if settings.defaultNode == nil, settings.defaultDirect != true { settings.defaultNode = nodes.first }
            // Persist the API secret before starting any service.
            try saveSettings(settings, to: directory)
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
    var api: CoreAPI { CoreAPI(secret: settings.secret) }
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
        let imported = try await fetchSubscriptions(candidate.subscriptions, corePath: candidate.corePath, directory: directory)
        var updated = candidate
        if updated.defaultNode == nil, updated.defaultDirect != true { updated.defaultNode = imported.first }
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
    func addSubscription(name: String, url: String) {
        var candidate = settings
        candidate.subscriptions.append(Subscription(name: name.trimmingCharacters(in: .whitespacesAndNewlines),
                                                    url: url.trimmingCharacters(in: .whitespacesAndNewlines)))
        perform { try await self.importSubscriptions(candidate) }
    }
    func refreshSubscriptions() {
        let candidate = settings
        perform { try await self.importSubscriptions(candidate) }
    }
    func testDelay(_ node: Node) {
        perform {
            self.testingNode = node.id
            defer { self.testingNode = nil }
            do {
                let providers = self.settings.subscriptions.map { ($0.provider, providerFile($0, directory: self.directory)) }
                let delay = try await withProviderCore(corePath: self.settings.corePath, providers: providers) { api in
                    try await api.delay(node)
                }
                if let index = self.nodes.firstIndex(of: node) {
                    self.nodes[index].delayMilliseconds = delay; self.nodes[index].delayFailed = false
                }
                self.message = "\(node.name)：\(delay) ms"
            } catch {
                if let index = self.nodes.firstIndex(of: node) {
                    self.nodes[index].delayMilliseconds = nil; self.nodes[index].delayFailed = true
                }
                self.message = "\(node.name)：延迟测试失败或超时"
            }
            try saveNodeCache(self.nodes, directory: self.directory)
        }
    }
    func startAll() {
        perform {
            if self.nodes.isEmpty { try await self.importSubscriptions(self.settings) }
            let config = try generateConfig(self.settings)
            try self.save()
            try await installAndStartCore(settings: self.settings, config: config, directory: self.directory)
            try await startStatistics(directory: self.directory)
            self.message = "服务已交给 launchd。内核可能需要几秒完成订阅初始化。"
        }
    }
    func applyLive() {
        perform {
            let config = try generateConfig(self.settings)
            // Apply first, save only after the core accepts it.
            try await self.api.reload(config)
            try self.save()
            self.message = "配置已应用到运行中的内核；重启持久化请点击“安装 / 启动全部”。已有连接保持原路由。"
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
        let normalized = kind.isProcess ? trimmed : trimmed.lowercased()
        guard !candidate.rules.contains(where: { $0.kind == kind && $0.value == normalized }) else { throw DeskError("相同规则已存在，请先删除旧规则") }
        candidate.rules.append(RouteRule(kind: kind, value: normalized, node: node))
        _ = try generateConfig(candidate)
        settings = candidate; try save()
    }
    func updateRule(_ id: String, kind: RuleKind? = nil, value: String? = nil, node: Node?? = nil) {
        do {
            var candidate = settings
            guard let index = candidate.rules.firstIndex(where: { $0.id == id }) else { return }
            if let kind { candidate.rules[index].kind = kind }
            if let value { candidate.rules[index].value = value.trimmingCharacters(in: .whitespacesAndNewlines) }
            if let node { candidate.rules[index].node = node }
            _ = try generateConfig(candidate)
            try saveSettings(candidate, to: directory); settings = candidate
            message = "规则已保存，点击“应用运行配置”使其生效。"
        } catch { self.error = error.localizedDescription }
    }
    func setDefault(_ node: Node?) {
        do {
            var candidate = settings
            candidate.defaultNode = node; candidate.defaultDirect = node == nil
            _ = try generateConfig(candidate)
            try saveSettings(candidate, to: directory); settings = candidate
            message = "MATCH 出口已保存，点击“应用运行配置”使其生效。"
        } catch { self.error = error.localizedDescription }
    }
    func deleteRule(_ id: String) {
        settings.rules.removeAll { $0.id == id }
        do { try save(); message = "规则已删除，请应用配置。" } catch { self.error = error.localizedDescription }
    }
    func deleteSubscription(_ subscription: Subscription) {
        if settings.defaultNode?.provider == subscription.provider || settings.rules.contains(where: { $0.node?.provider == subscription.provider }) {
            error = "该订阅仍被规则引用，请先调整相关出口。"; return
        }
        settings.subscriptions.removeAll { $0.id == subscription.id }
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
        let name = settings.subscriptions.first { $0.provider == node.provider }?.name ?? "未知订阅"
        return name + " / " + node.name
    }
    func unavailable(_ node: Node?) -> Bool {
        guard !nodes.isEmpty, let node else { return false }
        return !nodes.contains(node)
    }
}
