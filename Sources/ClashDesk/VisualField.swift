import SwiftUI
import AppKit
import ClashCore

struct VisualField: View {
    let field: EditorField
    @Binding var value: ConfigValue?
    var allowUnset = true
    var compact = false
    var labelWidth: CGFloat = 200
    var inputEnabled = true
    var defaultValue: ConfigValue?
    private var displayedValue: ConfigValue {
        value ?? defaultValue ?? field.initialValue ?? (field.kind == "boolean" || field.kind == "list" || field.kind == "map" || field.kind == "object" ? emptyValue(field) : .string(""))
    }
    var inputValue: Binding<ConfigValue> {
        Binding(get: { displayedValue }, set: {
            guard $0 != displayedValue else { return }
            value = $0
        })
    }
    var body: some View {
        if compact { compactRow.controlSize(.regular) }
        else { legacyRow }
    }
    var compactRow: some View {
        HStack(alignment: field.kind == "list" || field.kind == "map" || field.kind == "object" ? .top : .center, spacing: 12) {
            FieldKeyLabel(title: field.title + (field.required ? " *" : ""), key: field.path,
                          description: field.description, hint: field.hint, kind: field.kind, unavailableReason: field.unavailableReason, helpDocument: field.document)
                .frame(width: labelWidth, alignment: .leading)
            VisualValue(field: field, value: inputValue, compact: true).disabled(!inputEnabled)
            Spacer(minLength: 0)

        }.padding(.vertical, 3)
    }
    var legacyRow: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                FieldKeyLabel(title: field.title, key: field.path, description: field.description, hint: field.hint, kind: field.kind, unavailableReason: field.unavailableReason, helpDocument: field.document)
                if field.required { Text("必填").font(.caption).foregroundStyle(.orange) }
                Spacer()
                if allowUnset && !field.required {
                    Toggle("设置此项", isOn: Binding(get: { value != nil }, set: { value = $0 ? displayedValue : nil }))
                        .toggleStyle(.checkbox).font(.caption).help("未设置时使用内核默认值")
                }
            }
            VisualValue(field: field, value: inputValue)
                .disabled(value == nil && !field.required && allowUnset)
            if !field.description.isEmpty {
                Text(field.description).font(.caption).foregroundStyle(.secondary).fixedSize(horizontal: false, vertical: true)
            }
        }.padding(.vertical, 3)
    }
}
