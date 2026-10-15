import SwiftUI
import AppKit
import ClashCore

import Darwin

struct RouteMenu: View {
    @EnvironmentObject var model: DeskModel
    let kind: RuleKind
    let value: String
    var isIPv4: Bool { !kind.isProcess && validCIDR(value + "/32") }
    var isIPv6: Bool { !kind.isProcess && validCIDR(value + "/128") }
    var body: some View {
        if !value.isEmpty && !["未知目标", "未知 IP", "未知端口", "未知程序"].contains(value) {
            Section("添加路由规则") {
                if kind.isProcess {
                    Button {
                        open(.processName, (value as NSString).lastPathComponent)
                    } label: { Label("进程名称（PROCESS-NAME）", systemImage: "app") }
                    if value.hasPrefix("/") {
                        Button { open(.processPath, value) } label: { Label("进程路径（PROCESS-PATH）", systemImage: "folder") }
                    }
                } else if isIPv4 || isIPv6 {
                    Button {
                        open(isIPv4 ? .ipCIDR : .ipCIDR6, value + (isIPv4 ? "/32" : "/128"))
                    } label: { Label("目标 IP（\(isIPv4 ? "IP-CIDR /32" : "IP-CIDR6 /128")）", systemImage: "network") }
                    Button {
                        open(isIPv4 ? .ipCIDR : .ipCIDR6, subnet)
                    } label: { Label("目标网段（\(isIPv4 ? "IP-CIDR /24" : "IP-CIDR6 /64")）", systemImage: "network") }
                } else if kind == .destinationPort {
                    Button { open(.destinationPort, value) } label: { Label("目标端口（DST-PORT）", systemImage: "number") }
                } else if kind == .domain {
                    Button { open(.domain, value) } label: { Label("完整域名（DOMAIN）", systemImage: "globe") }
                    Button { open(.suffix, value) } label: { Label("域名后缀（DOMAIN-SUFFIX）", systemImage: "text.end") }
                    Button { open(.keyword, value) } label: { Label("域名关键词（DOMAIN-KEYWORD）", systemImage: "text.magnifyingglass") }
                }
            }
        }
    }
    var subnet: String {
        if isIPv4 {
            return value.split(separator: ".").prefix(3).joined(separator: ".") + ".0/24"
        }
        var address = [UInt8](repeating: 0, count: 16)
        let parsed = address.withUnsafeMutableBytes { inet_pton(AF_INET6, value, $0.baseAddress) }
        guard parsed == 1 else { return value + "/64" }
        for index in 8..<16 { address[index] = 0 }
        var buffer = [CChar](repeating: 0, count: Int(INET6_ADDRSTRLEN))
        let converted = address.withUnsafeBytes { inet_ntop(AF_INET6, $0.baseAddress, &buffer, socklen_t(buffer.count)) }
        return (converted == nil ? value : String(cString: buffer)) + "/64"
    }
    func open(_ kind: RuleKind, _ value: String) {
        model.rulePrefill = RouteRule(kind: kind, value: value, node: nil)
    }
}
