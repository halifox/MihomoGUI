import SwiftUI
import AppKit
import MihomoGUICore

struct VisualValue: View {
    let field: EditorField
    @Binding var value: ConfigValue
    var compact = false
    var body: some View { input }
    private var displayedText: String {
        if field.kind == "choice", value.text.isEmpty,
           let defaultValue = field.defaultHint, (field.choices ?? []).contains(defaultValue) {
            return defaultValue
        }
        return value.text
    }
    private var text: Binding<String> {
        Binding(get: { displayedText }, set: {
            guard $0 != displayedText else { return }
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
                if field.defaultHint == nil || !(field.choices ?? []).contains(field.defaultHint ?? "") {
                    Text(field.required ? "请选择（Select）" : "空（Empty）").tag("")
                }
                if !value.text.isEmpty, !(field.choices ?? []).contains(value.text) { Text(optionLabel(value.text)).tag(value.text) }
                ForEach(field.choices ?? [], id: \.self) { Text(optionLabel($0)).tag($0) }
            }.labelsHidden())
        case "secret": return AnyView(SecretField(field.title, text: text))
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
        default: return AnyView(TextField(field.defaultHint ?? "", text: text).textFieldStyle(.roundedBorder))
        }
    }
}

func typedPath(_ path: String, in object: [String: ConfigValue]) -> ConfigValue? {
    guard validConfigPath(path) else { return nil }
    let parts = path.split(separator: ".", maxSplits: 1).map(String.init)
    if parts.count == 1 { return object[path] }
    return typedPath(parts[1], in: object[parts[0]]?.object ?? [:])
}

func setTypedPath(_ path: String, value: ConfigValue?, in object: inout [String: ConfigValue]) {
    guard validConfigPath(path) else { return }
    let parts = path.split(separator: ".", maxSplits: 1).map(String.init)
    if parts.count == 1 { object[path] = value; return }
    var nested = object[parts[0]]?.object ?? [:]
    setTypedPath(parts[1], value: value, in: &nested)
    object[parts[0]] = nested.isEmpty ? nil : .object(nested)
}

// Shared by schema-defined credentials and subscription URLs; visibility belongs to this field.
struct SecretField: View {
    let title: String
    @Binding var text: String
    @State private var revealed = false

    init(_ title: String, text: Binding<String>) {
        self.title = title
        _text = text
    }

    var body: some View {
        HStack {
            Group {
                if revealed { TextField(title, text: $text) }
                else { SecureField(title, text: $text) }
            }.textFieldStyle(.roundedBorder)
                .privacySensitive(!revealed)
            Button { revealed.toggle() } label: {
                Image(systemName: revealed ? "eye.slash" : "eye")
            }
            .buttonStyle(.borderless)
            .help(revealed ? "隐藏" + title : "显示" + title)
            .accessibilityLabel(revealed ? "隐藏" + title : "显示" + title)
        }
        .onDisappear { revealed = false }
    }
}
