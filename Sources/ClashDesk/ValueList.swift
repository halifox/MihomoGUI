import SwiftUI
import AppKit
import ClashCore

struct ValueList: View {
    let field: EditorField
    @Binding var value: ConfigValue
    var compact = false
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
                    DeleteButton(message: "确定删除第 \(index + 1) 项吗？此操作无法撤销。") {
                        var array = value.array; guard array.indices.contains(index) else { return }
                        array.remove(at: index); value = .array(array)
                    }
                }
            }
            Button {
                var array = value.array; array.append(emptyValue(item)); value = .array(array)
            } label: { Label("添加一项", systemImage: "plus") }.controlSize(.regular)
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
