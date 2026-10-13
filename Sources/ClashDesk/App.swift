import SwiftUI
import ClashCore

@main
struct ClashDeskApp: App {
    @StateObject private var model = DeskModel()
    var body: some Scene {
        WindowGroup("ClashDesk") {
            DeskView().environmentObject(model).frame(minWidth: 1000, minHeight: 680)
                .task { model.startMonitor() }
        }
        .commands {
            CommandGroup(after: .appInfo) {
                Button("安装 / 启动全部服务") { model.startAll() }.disabled(model.busy)
            }
        }
    }
}

func bytes(_ value: Int64) -> String {
    ByteCountFormatter.string(fromByteCount: value, countStyle: .binary)
}

struct DeskView: View {
    @EnvironmentObject var model: DeskModel
    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 12) {
                Image(systemName: "network").font(.title2).foregroundStyle(.blue)
                VStack(alignment: .leading) {
                    Text("ClashDesk · 0.2").font(.title2.bold())
                    Text("内核 \(model.coreRunning ? "在线" : "离线") · 统计 \(statsStatus)").font(.caption).foregroundStyle(.secondary)
                }
                Spacer()
                if model.busy { ProgressView().controlSize(.small) }
                Button("安装 / 启动全部") { model.startAll() }.disabled(model.busy)
                Button("应用运行配置") { model.applyLive() }.disabled(model.busy || !model.coreRunning)
                Menu("停止") {
                    Button("停止代理") { model.perform { try await stopCore() } }
                    Button("停止统计") { model.perform { try await stopStatistics() } }
                    Button("停止全部服务") {
                        model.perform { try await stopCore(); try await stopStatistics() }
                    }
                }.disabled(model.busy)
            }.padding(20)
            Divider()
            TabView {
                SettingsView().tabItem { Label("配置与节点", systemImage: "gearshape") }
                RulesView().tabItem { Label("规则", systemImage: "line.3.horizontal.decrease.circle") }
                ConnectionsView().tabItem { Label("当前连接", systemImage: "arrow.left.arrow.right") }
                StatisticsView().tabItem { Label("域名流量", systemImage: "chart.bar") }
            }.padding(16)
            Divider()
            HStack {
                Text(model.message).font(.caption).foregroundStyle(.secondary).textSelection(.enabled)
                Spacer()
            }.padding(12)
        }
        .alert("操作未完成", isPresented: Binding(get: { model.error != nil }, set: { if !$0 { model.error = nil } })) {
            Button("确定") { model.error = nil }
        } message: { Text(model.error ?? "") }
    }
    var statsStatus: String {
        guard let sample = model.lastSample else { return "未采集" }
        return Date().timeIntervalSince(sample) < 20 ? "采集中" : "采集已暂停"
    }
}

struct NodePicker: View {
    @EnvironmentObject var model: DeskModel
    let title: String
    @Binding var selection: Node?
    var nilTitle = "直连"
    var body: some View {
        Picker(title, selection: $selection) {
            Text(nilTitle).tag(Optional<Node>.none)
            if let selected = selection, !model.nodes.contains(selected) {
                Text(model.nodeLabel(selected) + "（未验证 / 已失效）").tag(Optional(selected))
            }
            ForEach(model.nodes) { node in
                Text(model.nodeLabel(node)).tag(Optional(node))
            }
        }
    }
}

struct SettingsView: View {
    @EnvironmentObject var model: DeskModel
    @State private var name = ""
    @State private var url = ""
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            GroupBox("1. mihomo 二进制路径") {
                HStack {
                    Text(model.settings.corePath.isEmpty ? "尚未配置" : model.settings.corePath)
                        .font(.caption.monospaced()).textSelection(.enabled)
                    Spacer()
                    Button("选择文件") { model.chooseCore() }.disabled(model.busy)
                }.padding(6)
            }
            GroupBox("2. TUN") {
                HStack {
                    Toggle("接管系统流量", isOn: $model.settings.tun)
                        .disabled(model.busy)
                        .onChange(of: model.settings.tun) { _ in
                            do { try model.save() } catch { model.error = error.localizedDescription }
                        }
                    Spacer()
                    Text("启动时需要管理员授权 · IPv6 暂未接管").font(.caption).foregroundStyle(.secondary)
                }.padding(6)
            }
            GroupBox("3. 订阅节点") {
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(model.settings.subscriptions) { subscription in
                        HStack {
                            Text(subscription.name).frame(width: 150, alignment: .leading)
                            Text(URL(string: subscription.url)?.host ?? "无效地址").foregroundStyle(.secondary)
                            Spacer()
                            Button("删除订阅") { model.deleteSubscription(subscription) }.disabled(model.busy)
                        }
                    }
                    HStack {
                        TextField("订阅名称", text: $name).frame(width: 150)
                        SecureField("HTTPS Clash YAML 订阅地址", text: $url)
                        Button("添加并拉取") { model.addSubscription(name: name, url: url) }
                            .disabled(model.busy || model.settings.corePath.isEmpty || name.trimmingCharacters(in: .whitespaces).isEmpty || url.isEmpty)
                        Button("重新拉取") { model.refreshSubscriptions() }
                            .disabled(model.busy || model.settings.subscriptions.isEmpty)
                    }
                    Text("立即下载并缓存节点；无需启动 TUN。首次导入后，MATCH 默认指向第一个节点。")
                        .font(.caption).foregroundStyle(.secondary)
                }.padding(6)
            }
            HStack {
                Text("节点（\(model.nodes.count)）").font(.headline)
                Spacer()
                Text("延迟测试通过选定节点访问测试站点").font(.caption).foregroundStyle(.secondary)
            }
            Table(model.nodes) {
                TableColumn("节点名称") { node in Text(node.name).textSelection(.enabled) }
                TableColumn("协议") { node in Text(node.protocolName ?? "—") }.width(110)
                TableColumn("订阅") { node in
                    Text(model.settings.subscriptions.first { $0.provider == node.provider }?.name ?? "—")
                }.width(150)
                TableColumn("延迟") { node in
                    if model.testingNode == node.id { Text("测试中…") }
                    else if node.delayFailed == true { Text("失败 / 超时").foregroundStyle(.red) }
                    else { Text(node.delayMilliseconds.map { "\($0) ms" } ?? "未测试").monospacedDigit() }
                }.width(110)
                TableColumn("测试延迟") { node in
                    Button("测试延迟") { model.testDelay(node) }.disabled(model.busy)
                }.width(100)
            }
            Text("节点与测试结果保存在本地。规则在下一页的表格中编辑；配置完成后点击“安装 / 启动全部”。")
                .font(.caption).foregroundStyle(.secondary)
        }
    }
}

private let matchRowID = "default-match"
struct RuleTableItem: Identifiable {
    var id: String
    var rule: RouteRule?
}

struct RuleValueCell: View {
    @EnvironmentObject var model: DeskModel
    let rule: RouteRule
    @State private var draft = ""
    var body: some View {
        TextField("匹配内容", text: $draft)
            .disabled(model.busy)
            .onAppear { draft = rule.value }
            .onChange(of: rule.value) { draft = $0 }
            .onSubmit { model.updateRule(rule.id, value: draft) }
            .help("修改后按回车保存")
    }
}

struct RulesView: View {
    @EnvironmentObject var model: DeskModel
    @State private var selection: String?
    @State private var adding = false
    var rows: [RuleTableItem] {
        let ordered = model.settings.rules.filter { $0.kind.isProcess } + model.settings.rules.filter { !$0.kind.isProcess }
        return ordered.map { RuleTableItem(id: $0.id, rule: $0) } + [RuleTableItem(id: matchRowID, rule: nil)]
    }
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("规则").font(.headline)
                Text("程序规则 → 域名规则 → MATCH").font(.caption).foregroundStyle(.secondary)
                Spacer()
                Button { adding = true } label: { Image(systemName: "plus") }.disabled(model.busy).help("添加规则")
                Button {
                    if let selection { model.deleteRule(selection); self.selection = nil }
                } label: { Image(systemName: "minus") }
                    .disabled(selection == nil || selection == matchRowID || model.busy).help("删除选中规则")
            }
            Table(rows, selection: $selection) {
                TableColumn("规则类型") { row in
                    if let rule = row.rule {
                        Picker("", selection: Binding(get: { rule.kind }, set: { model.updateRule(rule.id, kind: $0) })) {
                            ForEach(RuleKind.allCases, id: \.self) { Text($0.rawValue).tag($0) }
                        }.labelsHidden().disabled(model.busy)
                    } else { Text("MATCH").bold() }
                }.width(180)
                TableColumn("匹配内容") { row in
                    if let rule = row.rule { RuleValueCell(rule: rule) }
                    else { Text("所有未命中规则的连接").foregroundStyle(.secondary) }
                }
                TableColumn("节点 / 直连") { row in
                    if let rule = row.rule {
                        NodePicker(title: "", selection: Binding(get: { rule.node }, set: { model.updateRule(rule.id, node: .some($0)) }))
                            .labelsHidden().disabled(model.busy)
                    } else {
                        NodePicker(title: "", selection: Binding(get: { model.settings.defaultNode }, set: { model.setDefault($0) }),
                                   nilTitle: model.nodes.isEmpty && model.settings.defaultDirect != true ? "等待导入节点" : "直连")
                            .labelsHidden().disabled(model.busy || model.nodes.isEmpty)
                    }
                }.width(300)
                TableColumn("操作") { row in
                    HStack {
                        Button { adding = true } label: { Image(systemName: "plus") }.disabled(model.busy)
                        Button { model.deleteRule(row.id) } label: { Image(systemName: "minus") }
                            .disabled(row.id == matchRowID || model.busy)
                    }
                }.width(90)
            }
            Text("节点和规则类型可以直接修改；匹配内容修改后按回车保存。MATCH 保留在最后，不能删除。保存后点击“应用运行配置”。")
                .font(.caption).foregroundStyle(.secondary)
            Text("修改规则影响新连接。应用的辅助进程可以从“当前连接”右键添加程序规则。")
                .font(.caption).foregroundStyle(.secondary)
        }
        .sheet(isPresented: $adding) { AddRuleView() }
    }
}

struct AddRuleView: View {
    @EnvironmentObject var model: DeskModel
    @Environment(\.dismiss) private var dismiss
    @State private var kind = RuleKind.domain
    @State private var value = ""
    @State private var node: Node?
    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            Text("添加规则").font(.title2.bold())
            Picker("类型", selection: $kind) {
                ForEach(RuleKind.allCases, id: \.self) { Text($0.title).tag($0) }
            }
            TextField(kind.isProcess ? "进程名称或可执行文件完整路径" : "example.com", text: $value)
            if kind == .processPath {
                Button("选择应用") { if let path = model.chooseApplicationPath() { value = path } }
            }
            NodePicker(title: "节点 / 直连", selection: $node)
            HStack {
                Spacer()
                Button("取消") { dismiss() }.keyboardShortcut(.cancelAction)
                Button("添加") {
                    do { try model.addRule(kind: kind, value: value, node: node); model.message = "规则已保存，请应用运行配置。"; dismiss() }
                    catch { model.error = error.localizedDescription }
                }.disabled(value.isEmpty).keyboardShortcut(.defaultAction)
            }
        }.padding(24).frame(width: 520)
    }
}

struct RouteMenu: View {
    @EnvironmentObject var model: DeskModel
    let kind: RuleKind
    let value: String
    var body: some View {
        Menu("添加\(kind.isProcess ? "程序" : "域名")规则") {
            Button("直连") { add(nil) }
            ForEach(model.nodes) { node in Button(model.nodeLabel(node)) { add(node) } }
        }
    }
    func add(_ node: Node?) {
        do { try model.addRule(kind: kind, value: value, node: node); model.message = "规则已保存，请点击“应用运行配置”。" }
        catch { model.error = error.localizedDescription }
    }
}

struct StatisticsView: View {
    @EnvironmentObject var model: DeskModel
    var activeCounts: [String: Int] { Dictionary(model.connections.map { ($0.domain, 1) }, uniquingKeysWith: +) }
    var body: some View {
        let counts = activeCounts
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("域名流量").font(.title3.bold())
                Spacer()
                Picker("时间范围", selection: $model.hours) {
                    Text("最近 24 小时").tag(24); Text("最近 7 天").tag(168); Text("最近 30 天").tag(720)
                }.frame(width: 220)
            }
            Text("按域名汇总上传与下载 · 显示流量最大的 500 个域名 · 时间精度为小时")
                .font(.caption).foregroundStyle(.secondary)
                Table(model.traffic) {
                    TableColumn("域名 / IP") { row in
                        Text(row.domain).textSelection(.enabled).contextMenu { RouteMenu(kind: .domain, value: row.domain) }
                    }
                    TableColumn("程序数") { row in Text(String(row.processCount)) }.width(80)
                    TableColumn("出口数") { row in Text(String(row.outboundCount)) }.width(80)
                    TableColumn("当前连接数") { row in Text(String(counts[row.domain] ?? 0)) }.width(100)
                    TableColumn("上传") { row in Text(bytes(row.upload)).monospacedDigit() }.width(100)
                    TableColumn("下载") { row in Text(bytes(row.download)).monospacedDigit() }.width(100)
                    TableColumn("总流量") { row in Text(bytes(row.upload + row.download)).monospacedDigit() }.width(100)
                }
                .overlay {
                    if model.traffic.isEmpty {
                        Text("暂无统计。启动服务后访问网站，数据会自动显示。").foregroundStyle(.secondary).allowsHitTesting(false)
                    }
                }
            Text("识别不到域名的连接按 IP 显示。短连接和采集暂停期间可能遗漏；统计后台重启会重新建立基线，避免重复累计。")
                .font(.caption).foregroundStyle(.secondary)
        }
    }
}

struct ConnectionsView: View {
    @EnvironmentObject var model: DeskModel
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("当前连接（\(model.connections.count)）").font(.title3.bold())
            Text("右键域名或程序可添加规则；新规则应用后可断开旧连接，让应用重新建立连接。")
                .font(.caption).foregroundStyle(.secondary)
            Table(model.connections) {
                TableColumn("域名 / IP") { connection in
                    Text(connection.domain).textSelection(.enabled).contextMenu { RouteMenu(kind: .domain, value: connection.domain) }
                }
                TableColumn("程序") { connection in
                    Text(connection.process).help(connection.process).contextMenu {
                        if connection.process != "未知程序" {
                            RouteMenu(kind: connection.process.hasPrefix("/") ? .processPath : .processName, value: connection.process)
                        }
                    }
                }
                TableColumn("协议") { connection in Text(connection.metadata.network ?? "—") }.width(65)
                TableColumn("出口") { connection in Text(connection.outbound) }
                TableColumn("上传") { connection in Text(bytes(connection.upload)) }.width(90)
                TableColumn("下载") { connection in Text(bytes(connection.download)) }.width(100)
                TableColumn("操作") { connection in
                    Button("断开") { model.perform { try await model.api.closeConnection(connection.id) } }
                        .disabled(model.busy)
                }.width(70)
            }
        }
    }
}
