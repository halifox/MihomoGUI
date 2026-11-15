import SwiftUI
import AppKit
import MihomoCore

struct PolicyPicker: View {
    @ObservedObject var model: MihomoModel
    @Binding var selection: String
    var body: some View {
        Picker("出口", selection: $selection) {
            Text(optionLabel("DIRECT")).tag("builtin:DIRECT")
            Text(optionLabel("REJECT")).tag("builtin:REJECT")
            Text(optionLabel("REJECT-DROP")).tag("builtin:REJECT-DROP")
            if selection.hasPrefix("node:"), !model.allNodes.contains(where: { "node:" + $0.id == selection }) {
                Text("已失效：" + selection.dropFirst(5)).tag(selection)
            }
            ForEach(model.settings.proxyGroups ?? []) { Text("代理组 / " + $0.name).tag("group:" + $0.name) }
            ForEach(model.allNodes) { node in Text(model.nodeLabelWithDelay(node)).tag("node:" + node.id) }
        }.labelsHidden()
    }
}
