import SwiftUI
import Darwin
import ClashCore

@main
struct ClashDeskApp: App {
    @StateObject private var model = DeskModel()
    var body: some Scene {
        WindowGroup("ClashDesk") {
            DeskView().environmentObject(model).frame(minWidth: 800, minHeight: 600)
                .background(InitialWindowSize())
                .task { model.startMonitor() }
        }
        .defaultSize(width: 800, height: 600)
        .windowToolbarStyle(.unified)
        .commands {
            CommandGroup(after: .appInfo) {
                Button("安装 / 启动全部服务") { model.startAll() }.disabled(model.busy)
            }
        }
    }
}

// Apply once per new window so a restored frame cannot override the requested launch size.
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
        DispatchQueue.main.async { [weak window] in
            window?.setContentSize(NSSize(width: 800, height: 600))
        }
    }
}

enum DeskPage: Int, CaseIterable, Identifiable {
    case general, subscriptions, outbound, groups, ruleSets, rules, connections, traffic
    var id: Int { rawValue }
    var title: String { ["全局配置", "代理订阅", "出站代理", "代理分组", "规则集合", "路由规则", "活动连接", "流量统计"][rawValue] }
    var icon: String { ["slider.horizontal.3", "link", "network", "square.stack.3d.up", "folder", "list.bullet.rectangle", "arrow.left.arrow.right", "chart.bar"][rawValue] }
}

struct DeskView: View {
    @EnvironmentObject var model: DeskModel
    @State private var page: DeskPage? = .general
    var body: some View {
        VStack(spacing: 0) {
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
                    }
                }.navigationTitle((page ?? .general).title)
                    .tableStyle(.inset(alternatesRowBackgrounds: true))
                    .id(page ?? .general)
            }

        }
        .onReceive(NotificationCenter.default.publisher(for: NSApplication.willTerminateNotification)) { _ in model.flushConfigurationSave() }
        .onDisappear { model.flushConfigurationSave() }
        .alert("操作未完成", isPresented: Binding(get: { model.error != nil }, set: { if !$0 { model.error = nil } })) {
            Button("确定") { model.error = nil }
        } message: { Text(model.error ?? "") }
        .sheet(isPresented: Binding(get: { model.serviceLogs != nil }, set: { if !$0 { model.serviceLogs = nil } })) {
            VStack(alignment: .leading) {
                Text("内核日志 · core.log").font(.title2)
                ScrollView { Text(model.serviceLogs ?? "").font(.system(.body, design: .monospaced)).textSelection(.enabled).frame(maxWidth: .infinity, alignment: .leading) }
                Button("关闭") { model.serviceLogs = nil }.keyboardShortcut(.cancelAction)
            }.padding(20).frame(width: 760, height: 520)
        }
        .sheet(item: $model.rulePrefill) { prefill in
            RuleEditorView(prefill: prefill)
        }

    }
}
