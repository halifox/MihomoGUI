import SwiftUI
import AppKit
import ClashCore

struct CustomFieldEditor: View {
    @Binding var fields: [String: ConfigValue]
    @State private var path = ""
    @State private var kind = "string"
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            formRow("字段路径", help: "额外配置字段的路径。嵌套字段使用点号分隔，例如 realm-opts.realm-id。") { TextField("", text: $path) }
            formRow("type", help: "额外字段的数据类型，可选择文本、整数、开关、列表或键值表。") {
                Picker("类型", selection: $kind) {
                    Text("文本（string）").tag("string"); Text("整数（integer）").tag("integer"); Text("开关（boolean）").tag("boolean")
                    Text("列表（list）").tag("list"); Text("键值表（map）").tag("map")
                }.labelsHidden()
            }
            HStack {
                Spacer()
                Button("添加字段") {
                    fields[path] = emptyValue(EditorField(path, kind: kind, elementKind: "string")); path = ""
                }.disabled(path.isEmpty || fields[path] != nil)
            }
        }
    }
}
