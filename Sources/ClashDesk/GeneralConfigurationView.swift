import SwiftUI
import ClashCore

struct GeneralConfigurationView: View {
    @EnvironmentObject var model: DeskModel
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 6) {
                    ConfigurationRows(fields: documentSchemas.configuration).padding(6)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }.padding(.trailing, 4)
            }.disabled(model.busy || model.configurationLocked)

        }.padding(20)
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
                        model.option(field.path)
                    }, set: { model.setOption(field.path, value: $0) }),
                                allowUnset: model.baseOption(field.path) == nil, compact: true, inputEnabled: field.unavailableReason == nil && fieldEnabled(field.path))
                        .environment(\.formHelpDocument, field.document ?? "general.md")
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
