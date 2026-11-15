import SwiftUI
import AppKit
import MihomoGUICore

struct DeleteButton: View {
    var toolbar = false
    var title = "删除"
    var message = "确定删除此项吗？此操作无法撤销。"
    let action: () -> Void
    @State private var confirming = false

    var body: some View {
        Button(role: .destructive) { confirming = true } label: {
            if toolbar {
                toolbarIcon(title, systemImage: "trash")
            } else {
                Label(title, systemImage: "trash")
            }
        }
        .frame(width: toolbar ? 28 : nil, height: toolbar ? 28 : nil)
        .labelStyle(.iconOnly)
        .help(title)
        .controlSize(.regular)
        .alert("确认" + title, isPresented: $confirming) {
            Button("取消", role: .cancel) {}
            Button("确认删除", role: .destructive, action: action)
        } message: { Text(message) }
    }
}
