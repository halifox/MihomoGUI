import SwiftUI
import Darwin
import MihomoGUICore

@main
struct MihomoGUIApp: App {
    @NSApplicationDelegateAdaptor(MihomoGUIAppDelegate.self) private var appDelegate
    @StateObject private var model = MihomoGUIModel()
    var body: some Scene {
        WindowGroup("MihomoGUI") {
            MihomoGUIView().environmentObject(model).frame(minWidth: 800, minHeight: 400)
                .task { model.startMonitor() }
        }
        .defaultSize(width: 800, height: 400)
        .windowToolbarStyle(.unified)
        .commands {
            CommandGroup(after: .appInfo) {
                Button("启动 mihomo 内核") { model.startCore() }.disabled(model.busy || model.coreActive)
            }
        }
    }
}

final class MihomoGUIAppDelegate: NSObject, NSApplicationDelegate {
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        true
    }
}

enum MihomoGUIPage: Int, CaseIterable, Identifiable {
    case dashboard, general, subscriptions, outbound, groups, ruleSets, rules, connections, logs
    var id: Int { rawValue }
    var title: String { ["仪表盘", "全局配置", "代理订阅", "出站代理", "代理分组", "规则集合", "路由规则", "活动连接", "内核日志"][rawValue] }
    var icon: String { ["gauge", "slider.horizontal.3", "link", "network", "square.stack.3d.up", "folder", "list.bullet.rectangle", "arrow.left.arrow.right", "doc.text"][rawValue] }
}

struct MihomoGUIView: View {
    @EnvironmentObject var model: MihomoGUIModel
    @State private var page: MihomoGUIPage? = .dashboard
    var body: some View {
        NavigationSplitView {
            List(MihomoGUIPage.allCases, selection: $page) { page in
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
                case .ruleSets: RuleProvidersView()
                case .rules: RulesView()
                case .connections: ConnectionsView()
                case .logs: CoreLogsView()
                case .dashboard: DashboardView()
                }
            }.navigationTitle((page ?? .dashboard).title)
                .tableStyle(.inset(alternatesRowBackgrounds: true))
                .id(page ?? .dashboard)
        }
        .safeAreaInset(edge: .top, spacing: 0) {
            if model.runtimeConfigurationUncertain || (model.coreActive && model.hasUnappliedChanges) {
                HStack {
                    Text(model.runtimeConfigurationUncertain
                         ? "运行配置尚未确认，请重新应用；连接不可用时请停止并重新启动内核。"
                         : model.busy ? "正在执行操作；本地修改尚未确认应用。" : "本地修改尚未应用到运行内核。")
                        .font(.caption).foregroundStyle(.orange)
                    Spacer()
                    Button("重新应用") { model.retryLiveUpdate() }
                        .disabled(model.busy || !model.coreActive)
                }
                .padding(8).background(.bar)
            }
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
