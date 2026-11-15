import SwiftUI
import AppKit
import MihomoGUICore

struct CustomFieldEditor: View {
    @Binding var fields: [String: ConfigValue]
    var reservedPaths: Set<String> = []
    var onAdd: () -> Void = {}
    @State private var path = ""
    @State private var kind = "string"
    var fieldPath: String { path.trimmingCharacters(in: .whitespacesAndNewlines) }
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            formRow("字段路径", help: "额外配置字段的路径。嵌套字段使用点号分隔，例如 realm-opts.realm-id。", labelWidth: editorLabelWidth) { TextField("", text: $path) }
            formRow("type", help: "额外字段的数据类型，可选择文本、整数、开关、列表或键值表。", labelWidth: editorLabelWidth) {
                Picker("类型", selection: $kind) {
                    Text("文本（string）").tag("string"); Text("整数（integer）").tag("integer"); Text("开关（boolean）").tag("boolean")
                    Text("列表（list）").tag("list"); Text("键值表（map）").tag("map")
                }.labelsHidden()
            }
            if !fieldPath.isEmpty && !validConfigPath(fieldPath) {
                Text("字段路径须由非空字段名组成，不能以点号开头、结尾或包含连续点号、空白字符。")
                    .font(.caption).foregroundStyle(.red)
            }
            HStack {
                Spacer()
                Button("添加字段") {
                    fields[fieldPath] = emptyValue(EditorField(fieldPath, kind: kind, elementKind: "string")); path = ""
                    onAdd()
                }.disabled(!validConfigPath(fieldPath) || fields[fieldPath] != nil || reservedPaths.contains(fieldPath))
            }
        }
    }
}
