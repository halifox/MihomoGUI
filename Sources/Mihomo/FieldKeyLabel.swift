import SwiftUI
import AppKit
import MihomoCore

struct FieldKeyLabel: View {
    let title: String
    let key: String
    var description = ""
    var hint = ""
    var kind = ""
    var unavailableReason: String?
    var helpDocument: String?
    var translate = true
    @State private var platformPresented = false
    @Environment(\.formHelpDocument) private var context
    var displayTitle: String {
        guard translate else { return title }
        let translated = configFieldTitle(key, document: context.isEmpty ? "general.md" : context)
        return translated + (title.hasSuffix(" *") ? " *" : "")
    }
    var body: some View {
        HStack(spacing: 6) {
            Text(displayTitle).textSelection(.enabled).help(key)
            FieldHelpButton(key: key, description: description, hint: hint, kind: kind)
                .environment(\.formHelpDocument, helpDocument ?? context)
            if let reason = unavailableReason {
                Button { platformPresented.toggle() } label: {
                    Image(systemName: "exclamationmark.circle").font(.system(size: 12)).foregroundStyle(.orange)
                }
                .buttonStyle(.borderless).help("查看平台说明").accessibilityLabel(key + " 平台说明")
                .popover(isPresented: $platformPresented, arrowEdge: .top) {
                    Text(reason).fixedSize(horizontal: false, vertical: true)
                        .padding(14).frame(width: 280, alignment: .leading)
                }
            }
            Spacer(minLength: 0)
        }
    }
}
