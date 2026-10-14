import SwiftUI
import ClashCore

struct VisualField: View {
    let field: EditorField
    @Binding var value: ConfigValue?
    var allowUnset = true
    var compact = false
    var body: some View {
        if compact { compactRow }
        else { legacyRow }
    }
    var compactRow: some View {
        HStack(alignment: field.kind == "list" || field.kind == "map" || field.kind == "object" ? .top : .center, spacing: 20) {
            Text(field.title).font(.system(.body, design: .monospaced))
                .frame(width: 230, alignment: .leading).textSelection(.enabled)
                .help(field.description)
            VisualValue(field: field, value: Binding(get: {
                value ?? (field.kind == "boolean" ? .boolean(false) : field.kind == "list" || field.kind == "map" || field.kind == "object" ? emptyValue(field) : .string(""))
            }, set: { value = $0 }), compact: true)
            Spacer(minLength: 0)
        }.padding(.vertical, 10)
    }
    var legacyRow: some View {
        VStack(alignment: .leading, spacing: 7) {
            HStack {
                Text(field.title).font(.system(.body, design: .monospaced)).textSelection(.enabled)
                if field.required { Text("必填").font(.caption).foregroundStyle(.orange) }
                Spacer()
                if allowUnset && !field.required {
                    Toggle("设置此项", isOn: Binding(get: { value != nil }, set: { value = $0 ? emptyValue(field) : nil }))
                        .toggleStyle(.checkbox).font(.caption).help("未设置时使用内核默认值")
                }
            }
            VisualValue(field: field, value: Binding(get: { value ?? emptyValue(field) }, set: { value = $0 }))
                .disabled(value == nil && !field.required && allowUnset)
            if !field.description.isEmpty {
                Text(field.description).font(.caption).foregroundStyle(.secondary).fixedSize(horizontal: false, vertical: true)
            }
        }.padding(.vertical, 6)
    }
}

struct VisualValue: View {
    let field: EditorField
    @Binding var value: ConfigValue
    var compact = false
    var body: some View { input }
    private var text: Binding<String> {
        Binding(get: { value.text }, set: {
            if field.kind == "integer", let integer = Int($0) { value = .integer(integer) }
            else if field.kind == "number", let number = Double($0) { value = .number(number) }
            else { value = .string($0) }
        })
    }
    private var input: AnyView {
        switch field.kind {
        case "boolean":
            return AnyView(Toggle(compact ? "" : value == .boolean(true) ? "开启" : "关闭", isOn: Binding(get: { value == .boolean(true) }, set: { value = .boolean($0) })))
        case "choice":
            return AnyView(Picker("", selection: text) {
                if !(field.choices ?? []).contains(value.text) { Text(value.text.isEmpty ? "请选择" : value.text).tag(value.text) }
                ForEach(field.choices ?? [], id: \.self) { Text($0).tag($0) }
            }.labelsHidden())
        case "secret": return AnyView(SecureField(field.hint, text: text).textFieldStyle(.roundedBorder))
        case "list": return AnyView(ValueList(field: field, value: $value, compact: compact))
        case "map": return AnyView(ValueMap(field: field, value: $value, compact: compact))
        case "object":
            return AnyView(VStack(alignment: .leading) {
                ForEach(field.children ?? []) { child in
                    VisualField(field: child, value: Binding(get: { typedPath(child.path, in: value.object) }, set: {
                        var object = value.object; setTypedPath(child.path, value: $0, in: &object); value = .object(object)
                    }), compact: compact)
                }
            })
        default: return AnyView(TextField(field.hint, text: text).textFieldStyle(.roundedBorder))
        }
    }
}

func typedPath(_ path: String, in object: [String: ConfigValue]) -> ConfigValue? {
    let parts = path.split(separator: ".", maxSplits: 1).map(String.init)
    if parts.count == 1 { return object[path] }
    return typedPath(parts[1], in: object[parts[0]]?.object ?? [:])
}

func setTypedPath(_ path: String, value: ConfigValue?, in object: inout [String: ConfigValue]) {
    let parts = path.split(separator: ".", maxSplits: 1).map(String.init)
    if parts.count == 1 { object[path] = value; return }
    var nested = object[parts[0]]?.object ?? [:]
    setTypedPath(parts[1], value: value, in: &nested)
    object[parts[0]] = nested.isEmpty ? nil : .object(nested)
}

struct ValueList: View {
    let field: EditorField
    @Binding var value: ConfigValue
    var compact = false
    var item: EditorField {
        EditorField("item", kind: field.elementKind ?? "string", children: field.children)
    }
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ForEach(value.array.indices, id: \.self) { index in
                HStack(alignment: .top) {
                    if item.kind == "object" {
                        DisclosureGroup("第 \(index + 1) 项") { element(index) }
                    } else { element(index) }
                    Button {
                        var array = value.array; guard array.indices.contains(index) else { return }
                        array.remove(at: index); value = .array(array)
                    } label: { Image(systemName: "minus.circle") }
                }
            }
            Button {
                var array = value.array; array.append(emptyValue(item)); value = .array(array)
            } label: { Label("添加一项", systemImage: "plus") }.controlSize(.small)
        }
    }
    func element(_ index: Int) -> some View {
        VisualValue(field: item, value: Binding(get: {
            value.array.indices.contains(index) ? value.array[index] : emptyValue(item)
        }, set: {
            var array = value.array; guard array.indices.contains(index) else { return }
            array[index] = $0; value = .array(array)
        }), compact: compact)
    }
}

struct ValueMap: View {
    let field: EditorField
    @Binding var value: ConfigValue
    var compact = false
    @State private var key = ""
    var item: EditorField { EditorField("value", kind: field.elementKind ?? "string", children: field.children) }
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ForEach(value.object.keys.sorted(), id: \.self) { name in
                GroupBox {
                    HStack {
                        Text(name).font(.system(.caption, design: .monospaced)).textSelection(.enabled)
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
                            })) { Text("单值").tag("string"); Text("列表").tag("list") }.frame(width: 180)
                        }
                        Button { var object = value.object; object.removeValue(forKey: name); value = .object(object) }
                            label: { Image(systemName: "minus.circle") }
                    }
                    VisualValue(field: itemSpec(name), value: Binding(get: { value.object[name] ?? emptyValue(item) }, set: {
                        var object = value.object; object[name] = $0; value = .object(object)
                    }), compact: compact)
                }
            }
            HStack {
                TextField("键 / 名称", text: $key).textFieldStyle(.roundedBorder)
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

struct CustomFieldEditor: View {
    @Binding var fields: [String: ConfigValue]
    @State private var path = ""
    @State private var kind = "string"
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                TextField("字段路径，例如 realm-opts.handshake-timeout", text: $path)
                Picker("类型", selection: $kind) {
                    Text("文本").tag("string"); Text("整数").tag("integer"); Text("开关").tag("boolean")
                    Text("列表").tag("list"); Text("键值表").tag("map")
                }.frame(width: 130)
                Button("添加字段") {
                    fields[path] = emptyValue(EditorField(path, kind: kind, elementKind: "string")); path = ""
                }.disabled(path.isEmpty || fields[path] != nil)
            }
        }
    }
}
