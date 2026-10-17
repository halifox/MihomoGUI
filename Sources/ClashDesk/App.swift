import SwiftUI
import Darwin
import ClashCore

@main
struct ClashDeskApp: App {
    @StateObject private var model = DeskModel()
    var body: some Scene {
        WindowGroup("ClashDesk") {
            DeskView().environmentObject(model).frame(minWidth: 800, minHeight: 400)
                .background(InitialWindowSize())
                .task { model.startMonitor() }
        }
        .defaultSize(width: 900, height: 400)
        .windowToolbarStyle(.unified)
        .commands {
            CommandGroup(after: .appInfo) {
                Button("安装 / 启动全部服务") { model.startAll() }.disabled(model.busy)
            }
        }
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
        window.setContentSize(NSSize(width: 900, height: 400))
    }
}

enum DeskPage: Int, CaseIterable, Identifiable {
    case general, subscriptions, outbound, groups, ruleSets, rules, connections, traffic, logs, settings
    var id: Int { rawValue }
    var title: String { ["全局配置", "代理订阅", "出站代理", "代理分组", "规则集合", "路由规则", "活动连接", "流量统计", "内核日志", "应用设置"][rawValue] }
    var icon: String { ["slider.horizontal.3", "link", "network", "square.stack.3d.up", "folder", "list.bullet.rectangle", "arrow.left.arrow.right", "chart.bar", "doc.text", "gearshape"][rawValue] }
}

struct DeskView: View {
    @EnvironmentObject var model: DeskModel
    @State private var page: DeskPage? = .general
    var body: some View {
        NavigationSplitView {
            List(DeskPage.allCases, selection: $page) { page in
                Label(page.title, systemImage: page.icon).tag(page)
            }.listStyle(.sidebar)
                .navigationSplitViewColumnWidth(min: 170, ideal: 190, max: 230)
        } detail: {
            Group {
                switch page ?? .general {
                case .general: GeneralConfigurationView()
                case .subscriptions: SubscriptionsView()
                case .outbound: OutboundProxiesView()
                case .groups: ProxyGroupsView()
                case .ruleSets: RuleProvidersView().disabled(model.busy || model.configurationLocked)
                case .rules: RulesView()
                case .connections: ConnectionsView()
                case .traffic: StatisticsView()
                case .logs: CoreLogsView()
                case .settings: AppSettingsView()
                }
            }.navigationTitle((page ?? .general).title)
                .tableStyle(.inset(alternatesRowBackgrounds: true))
                .id(page ?? .general)
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
