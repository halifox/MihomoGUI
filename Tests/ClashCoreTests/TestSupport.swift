// A minimal runner for Command Line Tools installations that do not ship XCTest.
#if !canImport(XCTest)
import Foundation
import ClashCore

class XCTestCase {}

func XCTAssertEqual<T: Equatable>(_ actual: @autoclosure () throws -> T, _ expected: @autoclosure () throws -> T) {
    do { guard try actual() == expected() else { fatalError("Equality assertion failed") } }
    catch { fatalError("Unexpected error: \(error)") }
}
func XCTAssertTrue(_ expression: @autoclosure () throws -> Bool) {
    do { guard try expression() else { fatalError("Expected true") } }
    catch { fatalError("Unexpected error: \(error)") }
}
func XCTAssertNotNil<T>(_ expression: @autoclosure () throws -> T?) {
    do { guard try expression() != nil else { fatalError("Expected non-nil") } }
    catch { fatalError("Unexpected error: \(error)") }
}
func XCTUnwrap<T>(_ value: T?) throws -> T {
    guard let value else { throw DeskError("Expected non-nil") }
    return value
}
func XCTAssertThrowsError<T>(_ expression: @autoclosure () throws -> T) {
    do { _ = try expression() }
    catch { return }
    fatalError("Expected error")
}
#endif
