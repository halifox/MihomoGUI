import SwiftUI
import AppKit
import ClashCore

struct ResourceRow: Identifiable {
    var id: String
    var name: String
    var type: String
    var fields: [String: ConfigValue]
    var group: ProxyGroup?
}

struct ResourceEditorView: View {
    @EnvironmentObject var model: DeskModel
    @Environment(\.dismiss) private var dismiss
    let groups: Bool
    let original: ResourceRow?
    @State private var name: String
    @State private var type: String
    @State private var fields: [String: ConfigValue]
    @State private var targets: [String]
    @State private var error: String?
    init(groups: Bool, original: ResourceRow? = nil) {
        self.groups = groups; self.original = original
        _name = State(initialValue: original?.name ?? "")
        _type = State(initialValue: original?.type ?? (groups ? "select" : "http"))
        _fields = State(initialValue: original?.fields ?? (groups ? [:] : ["behavior": .string("domain"), "format": .string("yaml"), "interval": .integer(600)]))
        _targets = State(initialValue: original?.group?.targets ?? [])
    }
    var schema: [EditorField] { groups ? groupEditorFields(type) : ruleProviderEditorFields(type) }
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text((original == nil ? "添加" : "编辑") + (groups ? "代理组" : "规则集")).font(.title2.bold())
            if !groups {
                formRow("name *") { TextField("规则集名称", text: $name).textFieldStyle(.roundedBorder) }
                formRow("type *") {
                    Picker("类型", selection: $type) {
                        ForEach(["http", "file", "inline"], id: \.self) { Text(optionLabel($0)).tag($0) }
                    }.labelsHidden()
                }
            }
            ScrollView {
                VStack(alignment: .leading, spacing: 6) {
                    if groups {
                        HStack(spacing: 12) {
                            FieldKeyLabel(title: "name *", key: "name").frame(width: 200, alignment: .leading)
                            TextField("代理组名称", text: $name).textFieldStyle(.roundedBorder)
                        }.padding(.vertical, 3)
                        HStack(spacing: 12) {
                            FieldKeyLabel(title: "type *", key: "type").frame(width: 200, alignment: .leading)
                            Picker("类型", selection: $type) {
                                ForEach(["select", "url-test", "fallback", "load-balance"], id: \.self) { Text(optionLabel($0)).tag($0) }
                            }.labelsHidden()
                            Spacer(minLength: 0)
                        }.padding(.vertical, 3)
                        HStack(alignment: .top, spacing: 12) {
                            FieldKeyLabel(title: "proxies", key: "proxies", description: "引入节点或其他代理组作为成员。成员顺序可通过上下移按钮调整；fallback 会按顺序选择可用成员。").frame(width: 200, alignment: .leading)
                            VStack(alignment: .leading, spacing: 4) {
                                ForEach(targets.indices, id: \.self) { index in
                                    HStack {
                                        memberPicker(index)
                                        Button { targets.swapAt(index, index - 1) } label: { formActionIcon("arrow.up") }.buttonStyle(.bordered).controlSize(.regular).help("上移").disabled(index == 0)
                                        Button { targets.swapAt(index, index + 1) } label: { formActionIcon("arrow.down") }.buttonStyle(.bordered).controlSize(.regular).help("下移").disabled(index + 1 == targets.count)
                                        DeleteButton(title: "删除成员", message: "确定删除第 \(index + 1) 个成员吗？此操作无法撤销。") {
                                            guard targets.indices.contains(index) else { return }
                                            targets.remove(at: index)
                                        }
                                    }
                                }
                                Button { targets.append(model.allNodes.first.map { "node:" + $0.id } ?? "builtin:REJECT") } label: { Label("添加成员", systemImage: "plus") }
                            }
                        }.padding(.vertical, 3)
                    }
                    ForEach(schema) { field in
                        if groups && field.path == "default-selected" {
                            HStack {
                                FieldKeyLabel(title: "default-selected", key: "default-selected").frame(width: 200, alignment: .leading)
                                Picker("默认成员", selection: Binding(get: {
                                    let selected = fields["default-selected"]?.text ?? ""
                                    return selected.isEmpty ? targets.first ?? "" : selected
                                }, set: { fields["default-selected"] = .string($0) })) {
                                    if targets.isEmpty { Text("空（Empty）").tag("") }
                                    ForEach(Array(Set(targets)).sorted(), id: \.self) { target in Text(memberLabel(target)).tag(target) }
                                }.labelsHidden()
                            }
                        } else {
                            VisualField(field: field, value: Binding(get: {
                                fields[field.path] ?? (field.path == "lazy" ? .boolean(true) : nil)
                            }, set: { fields[field.path] = $0 }), compact: true)
                        }
                        if field.path == "path", type == "file" {
                            Button("选择规则文件") {
                                let panel = NSOpenPanel(); panel.canChooseDirectories = false
                                if panel.runModal() == .OK, let url = panel.url { fields["path"] = .string(url.path) }
                            }
                        }
                    }
                    if !groups && type == "http" {
                        HStack {
                            FieldKeyLabel(title: "proxy", key: "proxy").frame(width: 200, alignment: .leading)
                            PolicyPicker(model: model, selection: Binding(get: { fields["proxy"]?.text ?? "builtin:DIRECT" }, set: { fields["proxy"] = .string($0) }))
                        }
                    }
                }
            }
            if let error { Text(error).foregroundStyle(.red).textSelection(.enabled) }
            HStack {
                Spacer()
                Button("取消") { dismiss() }.keyboardShortcut(.cancelAction)
                Button("保存") { save() }.buttonStyle(.borderedProminent)
            }
        }.padding(16).controlSize(.regular).frame(width: 720, height: 560)
        .environment(\.formHelpDocument, groups ? "proxy-groups/" + type + ".md" : "rule-providers/index.md")
        .onChange(of: type) { _ in
            let allowed = Set(schema.map(\.path) + (groups ? [] : ["proxy"]))
            fields = fields.filter { allowed.contains($0.key) }
            if groups && type != "select" {
                if fields["url"] == nil { fields["url"] = .string("https://www.gstatic.com/generate_204") }
                if fields["interval"] == nil { fields["interval"] = .integer(300) }
                if fields["timeout"] == nil { fields["timeout"] = .integer(5000) }
                if fields["lazy"] == nil { fields["lazy"] = .boolean(true) }
            }
            if !groups && type == "inline" { fields["payload"] = fields["payload"] ?? .array([]) }
        }
    }
    func memberLabel(_ target: String) -> String {
        if let node = model.allNodes.first(where: { "node:" + $0.id == target }) { return model.nodeLabel(node) }
        return target.hasPrefix("group:") ? "代理组 / " + target.dropFirst(6) : target.hasPrefix("builtin:") ? optionLabel(String(target.dropFirst(8))) : "已失效：" + target
    }
    func memberPicker(_ index: Int) -> some View {
        Picker("成员", selection: Binding(get: { targets.indices.contains(index) ? targets[index] : "" }, set: {
            if targets.indices.contains(index) { targets[index] = $0 }
        })) {
            Text(optionLabel("DIRECT")).tag("builtin:DIRECT")
            Text(optionLabel("REJECT")).tag("builtin:REJECT")
            Text(optionLabel("REJECT-DROP")).tag("builtin:REJECT-DROP")
            if targets.indices.contains(index), !["builtin:DIRECT", "builtin:REJECT", "builtin:REJECT-DROP"].contains(targets[index]),
               !model.allNodes.contains(where: { "node:" + $0.id == targets[index] }),
               !(model.settings.proxyGroups ?? []).contains(where: { "group:" + $0.name == targets[index] }) {
                Text(memberLabel(targets[index])).tag(targets[index])
            }
            ForEach(model.allNodes) { Text(model.nodeLabel($0)).tag("node:" + $0.id) }
            ForEach((model.settings.proxyGroups ?? []).filter { $0.id != original?.group?.id }) { Text("代理组 / " + $0.name).tag("group:" + $0.name) }
        }.labelsHidden()
    }
    func save() {
        do {
            let name = name.trimmingCharacters(in: .whitespacesAndNewlines)
            let fields = fields.filter { $0.value != .string("") }
            if groups {
                var group = ProxyGroup(name: name, type: type, targets: targets, fields: fields)
                if let existing = original?.group { group.id = existing.id }
                try model.saveProxyGroup(group)
            } else { try model.saveRuleProvider(name: name, type: type, fields: fields, oldName: original?.name) }
            dismiss()
        } catch { self.error = error.localizedDescription }
    }
}

extension DeskModel {
    func saveProxyGroup(_ group: ProxyGroup) throws {
        var candidate = settings
        var groups = candidate.proxyGroups ?? []
        if let index = groups.firstIndex(where: { $0.id == group.id }) {
            let old = groups[index].name
            guard !groups.contains(where: { $0.id != group.id && $0.name == group.name }) else { throw DeskError("代理组名称已存在") }
            groups[index] = group
            for index in groups.indices {
                groups[index].targets = groups[index].targets.map { $0 == "group:" + old ? "group:" + group.name : $0 }
                if groups[index].fields["default-selected"] == .string("group:" + old) { groups[index].fields["default-selected"] = .string("group:" + group.name) }
            }
            for index in candidate.rules.indices where candidate.rules[index].proxyGroup == old { candidate.rules[index].proxyGroup = group.name }
            if candidate.defaultProxyGroup == old { candidate.defaultProxyGroup = group.name }
            for index in candidate.manualProxies?.indices ?? 0..<0 {
                if candidate.manualProxies?[index].fields["dialer-proxy"] == .string(old) { candidate.manualProxies?[index].fields["dialer-proxy"] = .string(group.name) }
            }
            var providers = candidate.options?["rule-providers"]?.object ?? [:]
            for name in providers.keys {
                var fields = providers[name]?.object ?? [:]
                if fields["proxy"] == .string("group:" + old) || fields["proxy"] == .string(old) { fields["proxy"] = .string("group:" + group.name) }
                providers[name] = .object(fields)
            }
            candidate.options?["rule-providers"] = .object(providers)
            rewriteSubRules(&candidate, old: old, new: group.name, provider: false)
        } else { groups.append(group) }
        candidate.proxyGroups = groups
        _ = try generateConfig(candidate); try saveSettings(candidate, to: directory); settings = candidate
    }
    func saveRuleProvider(name: String, type: String, fields: [String: ConfigValue], oldName: String?) throws {
        guard !configurationLocked else { throw DeskError("Stop the core before editing rule providers") }
        guard !name.isEmpty, !name.contains(","), !name.unicodeScalars.contains(where: { CharacterSet.controlCharacters.contains($0) }) else { throw DeskError("规则集名称无效") }
        var candidate = settings
        var providers = candidate.options?["rule-providers"]?.object ?? [:]
        guard name == oldName || providers[name] == nil else { throw DeskError("规则集名称已存在") }
        var fields = fields; fields["type"] = .string(type)
        try validateFieldValues(fields, schema: ruleProviderEditorFields(type))
        if type == "file" {
            guard FileManager.default.isReadableFile(atPath: fields["path"]?.text ?? "") else { throw DeskError("请选择可读取的本地规则文件") }
        }
        if let oldName, oldName != name {
            providers.removeValue(forKey: oldName)
            for index in candidate.rules.indices {
                if candidate.rules[index].kind == .ruleSet, candidate.rules[index].value == oldName { candidate.rules[index].value = name }
                else { candidate.rules[index].value = replacingProvider(candidate.rules[index].value, old: oldName, new: name) }
            }
            rewriteSubRules(&candidate, old: oldName, new: name, provider: true)
        }
        providers[name] = .object(fields)
        var options = candidate.options ?? [:]; options["rule-providers"] = .object(providers); candidate.options = options
        _ = try generateConfig(candidate); try saveSettings(candidate, to: directory); settings = candidate
    }
    func deleteResource(_ row: ResourceRow, groups: Bool) {
        guard groups || !configurationLocked else { return }
        do {
            var candidate = settings
            let subRules = candidate.options?["sub-rules"]?.object.values.flatMap(\.array).map(\.text) ?? []
            if groups {
                guard !(candidate.manualProxies ?? []).contains(where: { $0.fields["dialer-proxy"] == .string(row.name) }),
                      candidate.defaultProxyGroup != row.name,
                      !candidate.rules.contains(where: { $0.proxyGroup == row.name }),
                      !(candidate.proxyGroups ?? []).contains(where: { $0.id != row.id && $0.targets.contains("group:" + row.name) }),
                      !(candidate.options?["rule-providers"]?.object.values.contains(where: { $0.object["proxy"] == .string("group:" + row.name) || $0.object["proxy"] == .string(row.name) }) ?? false),
                      !subRules.contains(where: { $0.hasSuffix("," + row.name) }) else { throw DeskError("代理组仍被引用，请先调整引用") }
                candidate.proxyGroups?.removeAll { $0.id == row.id }
            } else {
                guard !candidate.rules.contains(where: { ($0.kind == .ruleSet && $0.value == row.name) || replacingProvider($0.value, old: row.name, new: "__check__") != $0.value }),
                      !subRules.contains(where: { replacingProvider($0, old: row.name, new: "__check__") != $0 }) else { throw DeskError("规则集仍被规则引用，请先调整规则") }
                var providers = candidate.options?["rule-providers"]?.object ?? [:]; providers.removeValue(forKey: row.name)
                candidate.options?["rule-providers"] = .object(providers)
            }
            _ = try generateConfig(candidate); try saveSettings(candidate, to: directory); settings = candidate
        } catch { self.error = error.localizedDescription }
    }
    private func replacingProvider(_ value: String, old: String, new: String) -> String {
        value.replacingOccurrences(of: "RULE-SET," + old + ",", with: "RULE-SET," + new + ",")
            .replacingOccurrences(of: "RULE-SET," + old + ")", with: "RULE-SET," + new + ")")
    }
    private func rewriteSubRules(_ candidate: inout ClashCore.Settings, old: String, new: String, provider: Bool) {
        var subRules = candidate.options?["sub-rules"]?.object ?? [:]
        for name in subRules.keys {
            subRules[name] = .array((subRules[name]?.array ?? []).map { entry in
                let text = entry.text
                return .string(provider ? replacingProvider(text, old: old, new: new) : text.hasSuffix("," + old) ? String(text.dropLast(old.count)) + new : text)
            })
        }
        if !subRules.isEmpty { candidate.options?["sub-rules"] = .object(subRules) }
    }
}
