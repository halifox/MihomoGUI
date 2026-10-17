import SwiftUI
import AppKit
import ClashCore

func tableColumnWidth(_ title: String, _ values: [String], numeric: Bool = false, monospaced: Bool = false,
                      padding: CGFloat = 0, unitSample: String? = nil) -> CGFloat {
    let font = monospaced ? NSFont.monospacedSystemFont(ofSize: NSFont.systemFontSize, weight: .regular)
        : numeric ? NSFont.monospacedDigitSystemFont(ofSize: NSFont.systemFontSize, weight: .regular)
        : NSFont.systemFont(ofSize: NSFont.systemFontSize)
    let header = (title as NSString).size(withAttributes: [.font: NSFont.systemFont(ofSize: NSFont.systemFontSize, weight: .semibold)]).width
    let content = values.lazy.flatMap { $0.components(separatedBy: .newlines) }
        .map { value in
            let width = (value as NSString).size(withAttributes: [.font: font]).width
            guard let unitSample else { return width }
            let number = value.hasSuffix("%") ? String(value.dropLast())
                : String(value.split(separator: " ", maxSplits: 1).first ?? "")
            let reserved = ((number + " " + unitSample) as NSString).size(withAttributes: [.font: font]).width
            return max(width, reserved)
        }.max() ?? 0
    // Keep room for the header's sort indicator without padding every cell as much.
    return ceil(max(header + 24, content + padding))
}

// Use the same full-data measurements for initial sizing and divider double-clicks.
struct TableColumnAutoFit: NSViewRepresentable {
    var widths: [CGFloat]
    func makeNSView(context: Context) -> TableColumnAutoFitView { TableColumnAutoFitView() }
    func updateNSView(_ view: TableColumnAutoFitView, context: Context) { view.widths = widths }
    static func dismantleNSView(_ view: TableColumnAutoFitView, coordinator: ()) { view.stopMonitoring() }
}

final class TableColumnAutoFitView: NSView {
    var widths: [CGFloat] = []
    private var monitor: Any?
    override func hitTest(_ point: NSPoint) -> NSView? { nil }
    override func viewDidMoveToWindow() {
        super.viewDidMoveToWindow()
        stopMonitoring()
        guard window != nil else { return }
        monitor = NSEvent.addLocalMonitorForEvents(matching: .leftMouseDown) { [weak self] event in
            guard let self else { return event }
            return self.handleMouseDown(event)
        }
    }
    // Header decorations can receive hit tests instead of NSTableHeaderView itself.
    // Resolve the actual table from our shared SwiftUI container instead.
    func tableView(in view: NSView) -> NSTableView? {
        if let table = view as? NSTableView { return table }
        for child in view.subviews {
            if let table = tableView(in: child) { return table }
        }
        return nil
    }
    func handleMouseDown(_ event: NSEvent) -> NSEvent? {
        guard event.clickCount == 2, let window, event.window === window else { return event }
        return fitColumn(at: event.locationInWindow) ? nil : event
    }
    func fitColumn(at location: NSPoint) -> Bool {
        var ancestor = superview
        while let container = ancestor {
            if let table = tableView(in: container), let header = table.headerView,
               table.tableColumns.count == widths.count {
                let point = header.convert(location, from: nil)
                guard header.visibleRect.contains(point) else { return false }
                for index in table.tableColumns.indices {
                    let rect = header.headerRect(ofColumn: index)
                    let edge = table.userInterfaceLayoutDirection == .rightToLeft ? rect.minX : rect.maxX
                    guard abs(point.x - edge) <= 4 else { continue }
                    let column = table.tableColumns[index]
                    column.width = min(column.maxWidth, max(column.minWidth, widths[index]))
                    return true
                }
                return false
            }
            ancestor = container.superview
        }
        return false
    }
    func stopMonitoring() {
        if let monitor { NSEvent.removeMonitor(monitor) }
        monitor = nil
    }
    deinit { stopMonitoring() }
}
