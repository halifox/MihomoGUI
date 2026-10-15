import SwiftUI
import AppKit
import ClashCore

// Compare underlying values so byte counts, dates and delays sort numerically.
struct TableSort<Row>: SortComparator {
    var order: SortOrder = .forward
    let column: String
    private let comparison: (Row, Row) -> ComparisonResult
    init<Value: Comparable>(_ column: String, value: @escaping (Row) -> Value) {
        self.column = column
        comparison = { lhs, rhs in
            let a = value(lhs), b = value(rhs)
            return a < b ? .orderedAscending : a > b ? .orderedDescending : .orderedSame
        }
    }
    func compare(_ lhs: Row, _ rhs: Row) -> ComparisonResult {
        let result = comparison(lhs, rhs)
        return order == .forward ? result : result == .orderedAscending ? .orderedDescending : result == .orderedDescending ? .orderedAscending : .orderedSame
    }
    static func == (lhs: Self, rhs: Self) -> Bool { lhs.column == rhs.column && lhs.order == rhs.order }
    func hash(into hasher: inout Hasher) { hasher.combine(column); hasher.combine(order) }
}

// Keep a single active column and cycle ascending → descending → original row order.
func tableSortBinding<Row>(_ state: Binding<[TableSort<Row>]>) -> Binding<[TableSort<Row>]> {
    Binding(get: { state.wrappedValue }, set: { proposed in
        guard var next = proposed.first else {
            state.wrappedValue = []
            return
        }
        if let current = state.wrappedValue.first, current.column == next.column {
            if current.order == .reverse {
                state.wrappedValue = []
                return
            }
            next.order = .reverse
        } else {
            next.order = .forward
        }
        state.wrappedValue = [next]
    })
}
