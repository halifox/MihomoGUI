import SwiftUI
import AppKit
import ClashCore

// Bound the native search item created by .searchable in connections and logs.
struct ToolbarSearchWidth: NSViewRepresentable {
    let width: CGFloat

    func makeNSView(context: Context) -> SearchWidthView { SearchWidthView() }
    func updateNSView(_ view: SearchWidthView, context: Context) {
        view.searchWidth = width
        view.applyWidth()
    }

    final class SearchWidthView: NSView {
        var searchWidth: CGFloat = 180

        override func viewDidMoveToWindow() {
            super.viewDidMoveToWindow()
            NotificationCenter.default.removeObserver(self)
            guard window != nil else { return }
            NotificationCenter.default.addObserver(self, selector: #selector(toolbarItemWillBeAdded),
                                                  name: NSToolbar.willAddItemNotification, object: nil)
            applyWidth()
        }

        @objc private func toolbarItemWillBeAdded(_ notification: Notification) {
            guard let toolbar = notification.object as? NSToolbar, toolbar === window?.toolbar else { return }
            if let item = notification.userInfo?[NSToolbarUserInfoKey.itemKey] as? NSSearchToolbarItem {
                applyWidth(to: item)
            }
        }

        func applyWidth() {
            for case let item as NSSearchToolbarItem in window?.toolbar?.items ?? [] {
                applyWidth(to: item)
            }
        }

        private func applyWidth(to item: NSSearchToolbarItem) {
            item.preferredWidthForSearchField = searchWidth
            let field = item.searchField
            if let constraint = field.constraints.first(where: { $0.identifier == "ClashDesk.searchWidth" }) {
                constraint.constant = searchWidth
            } else {
                let constraint = field.widthAnchor.constraint(equalToConstant: searchWidth)
                constraint.identifier = "ClashDesk.searchWidth"
                constraint.isActive = true
            }
        }

        deinit { NotificationCenter.default.removeObserver(self) }
    }
}

// Icon-only controls need a square label so thin symbols cannot collapse the button height.
func formActionIcon(_ symbol: String) -> some View {
    Image(systemName: symbol).font(.system(size: 12, weight: .medium))
        .frame(width: 14, height: 14)
}

func formRow<Content: View>(_ title: String, help: String = "", labelWidth: CGFloat = 200, @ViewBuilder content: () -> Content) -> some View {
    HStack(alignment: .center, spacing: 12) {
        FieldKeyLabel(title: title, key: title.replacingOccurrences(of: " *", with: ""), description: help).frame(width: labelWidth, alignment: .leading)
        content().frame(maxWidth: .infinity, alignment: .leading)
    }.padding(.vertical, 3)
}

// Shared dimensions for subscription, proxy, resource, and route editing sheets.
let editorSheetWidth: CGFloat = 600
let editorLabelWidth: CGFloat = 160

private struct FormHelpDocumentKey: EnvironmentKey { static let defaultValue = "" }
extension EnvironmentValues {
    var formHelpDocument: String {
        get { self[FormHelpDocumentKey.self] }
        set { self[FormHelpDocumentKey.self] = newValue }
    }
}

func toolbarIcon(_ title: String, systemImage: String) -> some View {
    Image(systemName: systemImage)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .accessibilityLabel(title)
        .help(title)
}
