import SwiftUI
import AppKit
import ClashCore

struct ValueMap: View {
    let field: EditorField
    @Binding var value: ConfigValue
    var compact = false
    @State private var key = ""
    var item: EditorField { EditorField("value", kind: field.elementKind ?? "string", children: field.children) }
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            ForEach(value.object.keys.sorted(), id: \.self) { name in
                GroupBox {
                    HStack {
                        FieldKeyLabel(title: name, key: field.path + "." + name, description: "该键对应的配置值。可以按此项支持的格式填写单值或列表。", translate: false)
                        Spacer()
                        if field.elementKind == "list" {
                            Picker("值类型", selection: Binding(get: {
                                if case .array = value.object[name] { return "list" }; return "string"
                            }, set: { kind in
                                var object = value.object
                                let current = object[name] ?? .string("")
                                if kind == "list" {
                                    if case .array = current { object[name] = current }
                                    else { object[name] = .array([current]) }
                                } else {
                                    if case .array = current { object[name] = current.array.first ?? .string("") }
                                    else { object[name] = current }
                                }
                                value = .object(object)
                            })) { Text("单值（string）").tag("string"); Text("列表（list）").tag("list") }.frame(width: 180)
                        }
                        DeleteButton(message: "确定删除“\(name)”吗？此操作无法撤销。") {
                            var object = value.object; object.removeValue(forKey: name); value = .object(object)
                        }
                    }
                    VisualValue(field: itemSpec(name), value: Binding(get: { value.object[name] ?? emptyValue(item) }, set: {
                        var object = value.object; object[name] = $0; value = .object(object)
                    }), compact: compact)
                }
            }
            HStack {
                FieldKeyLabel(title: "键名", key: "key", description: "新建键值条目的名称，不能与现有名称重复。", translate: false).frame(width: 70, alignment: .leading)
                TextField("", text: $key).textFieldStyle(.roundedBorder)
                Button {
                    let name = key.trimmingCharacters(in: .whitespacesAndNewlines)
                    var object = value.object; object[name] = emptyValue(item); value = .object(object); key = ""
                } label: { Label("添加", systemImage: "plus") }.disabled(key.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || value.object[key] != nil)
            }
        }
    }
    func itemSpec(_ key: String) -> EditorField {
        if field.elementKind == "list", let value = value.object[key], case .array = value { return item }
        if field.elementKind == "list" { return EditorField("value", kind: "string") }
        return item
    }
}
