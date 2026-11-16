import SwiftUI
import MihomoGUICore

struct MapEntry: Identifiable {
    let id = UUID()
    var name: String
    var value: ConfigValue
}

struct InvalidMapPreference: PreferenceKey {
    static var defaultValue = false
    static func reduce(value: inout Bool, nextValue: () -> Bool) { value = value || nextValue() }
}

struct ValueMap: View {
    let field: EditorField
    @Binding var value: ConfigValue
    var compact = false
    @State private var entries: [MapEntry] = []
    @State private var published: ConfigValue?
    @FocusState private var focusedName: UUID?
    var isHeader: Bool { ["header", "headers"].contains(field.path.components(separatedBy: ".").last ?? "") }
    var supportsList: Bool { field.elementKind == "list" }
    var item: EditorField { EditorField("value", kind: isHeader ? "secret" : supportsList ? "string" : field.elementKind ?? "string", children: field.children) }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            ForEach($entries) { $entry in
                VStack(alignment: .leading, spacing: 3) {
                    HStack(alignment: .top, spacing: 8) {
                        TextField(isHeader ? "请求头名称" : "键名", text: $entry.name)
                            .textFieldStyle(.roundedBorder)
                            .frame(maxWidth: 160)
                            .focused($focusedName, equals: entry.id)
                            .accessibilityLabel(isHeader ? "请求头名称" : "键名")
                        VStack(alignment: .leading, spacing: 4) {
                            if supportsList, case .array = entry.value {
                                ValueList(field: EditorField("value", kind: "list", elementKind: isHeader ? "secret" : "string"), value: $entry.value, compact: compact, addTitle: "添加值")
                            } else {
                                VisualValue(field: item, value: $entry.value, compact: compact)
                            }
                            if supportsList && !isArray(entry.value) {
                                Button("添加值") {
                                    if case .array = entry.value {
                                        entry.value = .array(entry.value.array + [.string("")])
                                    } else { entry.value = .array([entry.value, .string("")]) }
                                }
                                .controlSize(.small)
                            }
                        }
                        Button(role: .destructive) {
                            entries.removeAll { $0.id == entry.id }
                        } label: { formActionIcon("trash") }
                        .help("删除" + (isHeader ? "请求头" : "条目"))
                        .accessibilityLabel("删除 \(entry.name)")
                    }
                    if let message = validation(entry) {
                        Text(message).font(.caption).foregroundStyle(.red)
                    }
                }
            }
            Button {
                let entry = MapEntry(name: "", value: emptyValue(item))
                entries.append(entry)
                focusedName = entry.id
            } label: { Label(isHeader ? "添加请求头" : "添加条目", systemImage: "plus") }
        }
        .preference(key: InvalidMapPreference.self, value: entries.contains { validation($0) != nil })
        .onAppear { if published == nil { reload() } }
        .onChange(of: entries.map { $0.name }) { _ in publish() }
        .onChange(of: entries.map { $0.value }) { _ in publish() }
        .onChange(of: value) { updated in
            if updated != published { reload() }
        }
    }

    func isArray(_ value: ConfigValue) -> Bool {
        if case .array = value { return true }; return false
    }
    func normalized(_ name: String) -> String { name.trimmingCharacters(in: .whitespacesAndNewlines) }
    func validation(_ entry: MapEntry) -> String? {
        mapEntryError(entry, entries: entries, isHeader: isHeader)
    }
    func reload() {
        entries = value.object.keys.sorted().map { MapEntry(name: $0, value: value.object[$0]!) }
        published = value
    }
    func publish() {
        guard !entries.contains(where: { validation($0) != nil }) else { return }
        let updated = ConfigValue.object(Dictionary(uniqueKeysWithValues: entries.map { (normalized($0.name), $0.value) }))
        guard updated != value else { return }
        published = updated
        value = updated
    }
}

func mapEntryError(_ entry: MapEntry, entries: [MapEntry], isHeader: Bool) -> String? {
        func normalized(_ name: String) -> String { name.trimmingCharacters(in: .whitespacesAndNewlines) }
        let name = normalized(entry.name)
        if name.isEmpty { return isHeader ? "请输入请求头名称" : "请输入键名" }
        if isHeader && !name.utf8.allSatisfy({ byte in
            (65...90).contains(byte) || (97...122).contains(byte) || (48...57).contains(byte) || "!#$%&'*+-.^_`|~".utf8.contains(byte)
        }) { return "请求头名称只能包含英文字母、数字及允许的符号，不能包含空格或冒号" }
        if entries.contains(where: { other in
            other.id != entry.id && (isHeader ? normalized(other.name).lowercased() == name.lowercased() : normalized(other.name) == name)
        }) { return isHeader ? "请求头名称重复（不区分大小写）" : "键名重复" }
        return nil
    }
