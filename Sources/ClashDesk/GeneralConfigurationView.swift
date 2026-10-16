import SwiftUI
import ClashCore

struct GeneralConfigurationView: View {
    @EnvironmentObject var model: DeskModel
    @State private var configurationText: String?
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 6) {
                    ConfigurationRows(fields: documentSchemas.configuration).padding(6)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }.padding(.trailing, 4)
            }.disabled(model.busy || model.configurationLocked)

        }
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                HStack(spacing: 4) {
                    Button {
                        do {
                            configurationText = String(decoding: try generateConfig(model.settings), as: UTF8.self)
                        } catch {
                            model.error = error.localizedDescription
                        }
                    } label: {
                        toolbarIcon("配置预览", systemImage: "doc.text.magnifyingglass")
                    }.frame(width: 28, height: 28).disabled(model.busy).help("查看当前设置生成的完整配置文件")
                    Button { model.perform { model.serviceLogs = try await readCoreLog(directory: model.directory) } } label: {
                        toolbarIcon("日志预览", systemImage: "doc.text")
                    }.frame(width: 28, height: 28).disabled(model.busy).help("读取用户日志目录中的 core.log")
                    Button { model.toggleAllServices() } label: {
                        toolbarIcon(model.servicesActive ? "停止全部" : "启动全部", systemImage: model.servicesActive ? "stop.fill" : "play.fill")
                    }.frame(width: 28, height: 28).disabled(model.busy)
                }
                .buttonStyle(.bordered)
                .controlSize(.regular)
                .padding(.horizontal, 4)
                .padding(.vertical, 2)
            }
        }
        .sheet(isPresented: Binding(get: { configurationText != nil }, set: { if !$0 { configurationText = nil } })) {
            VStack(alignment: .leading, spacing: 12) {
                Text("完整配置 · config.yaml").font(.title2)
                Text("根据当前设置生成").font(.caption).foregroundStyle(.secondary)
                ScrollView([.horizontal, .vertical]) {
                    Text(configurationText ?? "")
                        .font(.system(.body, design: .monospaced))
                        .textSelection(.enabled)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                Button("关闭") { configurationText = nil }.keyboardShortcut(.cancelAction)
            }.padding(20).frame(width: 760, height: 520)
        }
        .padding(20)
    }
}

private struct ConfigurationRows: View {
    @EnvironmentObject var model: DeskModel
    let fields: [EditorField]

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            ForEach(fields) { field in
                if field.kind == "group" {
                    GroupBox {
                        ConfigurationRows(fields: field.children ?? []).padding(4)
                    }
                } else {
                    VisualField(field: field, value: Binding(get: {
                        model.settings.options?[field.path]
                    }, set: { model.setOption(field.path, value: $0) }),
                                compact: true, inputEnabled: field.unavailableReason == nil && fieldEnabled(field.path), defaultValue: model.baseOption(field.path))
                        .environment(\.formHelpDocument, field.document ?? "general.md")
                    if field.path == "unified-delay" {
                        formRow("延迟测试地址") {
                            HStack {
                                TextField("https://www.gstatic.com/generate_204", text: Binding(get: {
                                    model.settings.delayTestURL ?? ""
                                }, set: {
                                    let updated = $0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : $0
                                    guard updated != model.settings.delayTestURL else { return }
                                    model.settings.delayTestURL = updated
                                    model.scheduleConfigurationSave()
                                }))
                                Button {
                                    model.settings.delayTestURL = nil
                                    model.scheduleConfigurationSave()
                                } label: { Image(systemName: "arrow.uturn.backward") }
                                    .buttonStyle(.borderless)
                                    .help("恢复默认：https://www.gstatic.com/generate_204")
                                    .accessibilityLabel("延迟测试地址 恢复默认")
                                    .disabled(model.settings.delayTestURL == nil)
                            }
                        }
                        formRow("延迟超时（毫秒）") {
                            HStack {
                                TextField("5000", text: Binding(get: {
                                    model.settings.delayTestTimeoutMilliseconds.map(String.init) ?? ""
                                }, set: {
                                    guard $0 != (model.settings.delayTestTimeoutMilliseconds.map(String.init) ?? "") else { return }
                                    let text = $0.trimmingCharacters(in: .whitespacesAndNewlines)
                                    guard text.isEmpty || Int(text) != nil else { return }
                                    let updated = text.isEmpty ? nil : Int(text)
                                    guard updated != model.settings.delayTestTimeoutMilliseconds else { return }
                                    model.settings.delayTestTimeoutMilliseconds = updated
                                    model.scheduleConfigurationSave()
                                }))
                                    .frame(width: 150)
                                Button {
                                    model.settings.delayTestTimeoutMilliseconds = nil
                                    model.scheduleConfigurationSave()
                                } label: { Image(systemName: "arrow.uturn.backward") }
                                    .buttonStyle(.borderless)
                                    .help("恢复默认：5000 毫秒")
                                    .accessibilityLabel("延迟超时 恢复默认")
                                    .disabled(model.settings.delayTestTimeoutMilliseconds == nil)
                                Spacer(minLength: 0)
                            }
                        }
                    }
                }
            }
        }
    }
    func fieldEnabled(_ path: String) -> Bool {
        for parent in ["dns", "sniffer", "tun"] {
            if path.hasPrefix(parent + "."), path != parent + ".enable" {
                return model.option(parent + ".enable") == .boolean(true)
            }
        }
        if path.hasPrefix("external-controller-cors.") {
            return !(model.option("external-controller")?.text.isEmpty ?? true)
        }
        return true
    }

}
