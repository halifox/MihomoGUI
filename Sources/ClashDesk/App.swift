import SwiftUI
import Darwin
import ClashCore

@main
struct ClashDeskApp: App {
    @NSApplicationDelegateAdaptor(DeskAppDelegate.self) private var appDelegate
    @StateObject private var model = DeskModel()
    var body: some Scene {
        WindowGroup("ClashDesk") {
            DeskView().environmentObject(model).frame(minWidth: 800, minHeight: 400)
                .background(InitialWindowSize())
                .task { model.startMonitor() }
        }
        .defaultSize(width: 800, height: 400)
        .windowToolbarStyle(.unified)
        .commands {
            CommandGroup(after: .appInfo) {
                Button("启动 Clash 内核") { model.startCore() }.disabled(model.busy || model.coreActive)
            }
        }
    }
}

final class DeskAppDelegate: NSObject, NSApplicationDelegate {
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        true
    }
}

// Apply during window attachment to avoid resizing after the first display.
struct InitialWindowSize: NSViewRepresentable {
    func makeNSView(context: Context) -> NSView { LaunchSizeView() }
    func updateNSView(_ nsView: NSView, context: Context) {}
}

final class LaunchSizeView: NSView {
    private var sized = false
    override func viewDidMoveToWindow() {
        super.viewDidMoveToWindow()
        guard !sized, let window else { return }
        sized = true
        window.setContentSize(NSSize(width: 800, height: 400))
    }
}

enum DeskPage: Int, CaseIterable, Identifiable {
    case dashboard, general, subscriptions, outbound, groups, ruleSets, rules, connections, logs
    var id: Int { rawValue }
    var title: String { ["仪表盘", "全局配置", "代理订阅", "出站代理", "代理分组", "规则集合", "路由规则", "活动连接", "内核日志"][rawValue] }
    var icon: String { ["gauge", "slider.horizontal.3", "link", "network", "square.stack.3d.up", "folder", "list.bullet.rectangle", "arrow.left.arrow.right", "doc.text"][rawValue] }
}

struct DeskView: View {
    @EnvironmentObject var model: DeskModel
    @State private var page: DeskPage? = .dashboard
    var body: some View {
        NavigationSplitView {
            List(DeskPage.allCases, selection: $page) { page in
                Label(page.title, systemImage: page.icon).tag(page)
            }.listStyle(.sidebar)
                .navigationSplitViewColumnWidth(min: 170, ideal: 190, max: 230)
        } detail: {
            Group {
                switch page ?? .dashboard {
                case .general: GeneralConfigurationView()
                case .subscriptions: SubscriptionsView()
                case .outbound: OutboundProxiesView()
                case .groups: ProxyGroupsView()
                case .ruleSets: RuleProvidersView().disabled(model.busy || model.configurationLocked)
                case .rules: RulesView()
                case .connections: ConnectionsView()
                case .logs: CoreLogsView()
                case .dashboard: DashboardView()
                }
            }.navigationTitle((page ?? .dashboard).title)
                .tableStyle(.inset(alternatesRowBackgrounds: true))
                .id(page ?? .dashboard)
        }
        .onReceive(NotificationCenter.default.publisher(for: NSApplication.willTerminateNotification)) { _ in model.flushConfigurationSave() }
        .onDisappear { model.flushConfigurationSave() }
        .alert("操作未完成", isPresented: Binding(get: { model.error != nil }, set: { if !$0 { model.error = nil } })) {
            Button("确定") { model.error = nil }
        } message: { Text(model.error ?? "") }
        .sheet(item: $model.rulePrefill) { prefill in
            RuleEditorView(prefill: prefill)
        }

    }
}
