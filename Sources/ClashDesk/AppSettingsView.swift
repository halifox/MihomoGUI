import SwiftUI
import ClashCore

struct AppSettingsView: View {
    @EnvironmentObject var model: DeskModel
    @State private var configurationText: String?

    var body: some View {
        Form {
            Section {
                Button("查看配置文件") {
                    do { configurationText = String(decoding: try generateConfig(model.settings), as: UTF8.self) }
                    catch { model.error = error.localizedDescription }
                }
                .disabled(model.busy)
                .help("查看当前设置生成的完整配置文件")
            }
        }
        .toggleStyle(.checkbox)
        .formStyle(.grouped)
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
    }
}
