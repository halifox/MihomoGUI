import SwiftUI
import AppKit
import MihomoGUICore

struct ValueList: View {
    let field: EditorField
    @Binding var value: ConfigValue
    var compact = false
    var addTitle = "添加一项"
    var item: EditorField {
        EditorField("item", kind: field.elementKind ?? "string", children: field.children)
    }
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            ForEach(value.array.indices, id: \.self) { index in
                HStack(alignment: .top) {
                    if item.kind == "object" {
                        DisclosureGroup("第 \(index + 1) 项") { element(index) }
                    } else { element(index) }
                    Button(role: .destructive) {
                        var array = value.array; guard array.indices.contains(index) else { return }
                        array.remove(at: index); value = .array(array)
                    } label: { formActionIcon("trash") }
                        .help("删除第 \(index + 1) 项")
                        .accessibilityLabel("删除第 \(index + 1) 项")
                }
            }
            Button {
                var array = value.array; array.append(emptyValue(item)); value = .array(array)
            } label: { Label(addTitle, systemImage: "plus") }.controlSize(.regular)
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
