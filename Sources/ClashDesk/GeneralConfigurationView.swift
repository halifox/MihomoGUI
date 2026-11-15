import SwiftUI
import ClashCore

struct GeneralConfigurationView: View {
    var body: some View {
        ScrollView {
            ConfigurationRows(fields: documentSchemas.configuration).padding(6)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.trailing, 4)
        }
        .padding(20)
    }


}

private struct ConfigurationRows: View {
    @EnvironmentObject var model: DeskModel
    let fields: [EditorField]

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            ForEach(fields) { field in
                if field.kind == "group" {
                    GroupBox {
                        ConfigurationRows(fields: field.children ?? []).padding(4)
                    }
                } else {
                    VisualField(field: field, value: Binding(get: {
                        model.settings.options?[field.path]
                    }, set: { model.setOption(field.path, value: $0) }),
                                compact: true, inputEnabled: !model.busy && !model.configurationLocked && field.unavailableReason == nil && fieldEnabled(field.path), defaultValue: model.baseOption(field.path))
                        .environment(\.formHelpDocument, field.document ?? "general.md")
                    if field.path == "unified-delay" {
                        formRow("延迟测试地址") {
                            TextField("https://www.gstatic.com/generate_204", text: Binding(get: {
                                model.settings.delayTestURL ?? ""
                            }, set: {
                                let updated = $0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : $0
                                guard updated != model.settings.delayTestURL else { return }
                                model.settings.delayTestURL = updated
                                model.scheduleConfigurationSave()
                            })).disabled(model.busy || model.configurationLocked)
                        }
                        formRow("延迟超时（毫秒）") {
                            TextField("5000", text: Binding(get: {
                                model.settings.delayTestTimeoutMilliseconds.map(String.init) ?? ""
                            }, set: {
                                guard $0 != (model.settings.delayTestTimeoutMilliseconds.map(String.init) ?? "") else { return }
                                let text = $0.trimmingCharacters(in: .whitespacesAndNewlines)
                                guard text.isEmpty || Int(text) != nil else { return }
                                let updated = text.isEmpty ? nil : Int(text)
                                guard updated != model.settings.delayTestTimeoutMilliseconds else { return }
                                model.settings.delayTestTimeoutMilliseconds = updated
                                model.scheduleConfigurationSave()
                            })).disabled(model.busy || model.configurationLocked)
                                .frame(width: 150)
                        }
                    }
                }
            }
        }
    }
    func fieldEnabled(_ path: String) -> Bool {
        for parent in ["dns", "sniffer", "tun"] {
            if path.hasPrefix(parent + "."), path != parent + ".enable" {
                return model.option(parent + ".enable") == .boolean(true)
            }
        }
        if path.hasPrefix("external-controller-cors.") {
            return !(model.option("external-controller")?.text.isEmpty ?? true)
        }
        return true
    }

}
