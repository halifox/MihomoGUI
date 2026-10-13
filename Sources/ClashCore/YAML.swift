import Foundation
import CoreFoundation

// Only serialize configuration values; subscription parsing stays with mihomo.
// Single-quoted strings preserve regex backslashes, URLs, emoji and apostrophes.
public func yamlData(_ object: [String: Any], keyOrder: [String] = []) throws -> Data {
    func scalar(_ value: Any) throws -> String {
        if let string = value as? String {
            let reserved: Set<String> = ["true", "false", "yes", "no", "on", "off", "y", "n", "null"]
            if string.range(of: "^[A-Za-z_][A-Za-z0-9_.-]*$", options: .regularExpression) != nil,
               !reserved.contains(string.lowercased()) { return string }
            if string.unicodeScalars.contains(where: { CharacterSet.controlCharacters.contains($0) }) {
                let data = try JSONSerialization.data(withJSONObject: string, options: [.fragmentsAllowed, .withoutEscapingSlashes])
                return String(decoding: data, as: UTF8.self)
            }
            return "'" + string.replacingOccurrences(of: "'", with: "''") + "'"
        }
        if let number = value as? NSNumber {
            if CFGetTypeID(number) == CFBooleanGetTypeID() { return number.boolValue ? "true" : "false" }
            return number.stringValue
        }
        if value is NSNull { return "null" }
        if let array = value as? [Any], array.isEmpty { return "[]" }
        if let dictionary = value as? [String: Any], dictionary.isEmpty { return "{}" }
        throw DeskError("配置包含不支持的 YAML 值")
    }
    func isBlock(_ value: Any) -> Bool {
        if let dictionary = value as? [String: Any] { return !dictionary.isEmpty }
        if let array = value as? [Any] { return !array.isEmpty }
        return false
    }
    func lines(_ value: Any, indent: Int, order: [String] = []) throws -> [String] {
        let padding = String(repeating: " ", count: indent)
        if let dictionary = value as? [String: Any] {
            let ordered = order.filter { dictionary[$0] != nil } + dictionary.keys.filter { !order.contains($0) }.sorted()
            return try ordered.flatMap { key -> [String] in
                let value = dictionary[key]!
                let label = try scalar(key)
                if isBlock(value) { return [padding + label + ":"] + (try lines(value, indent: indent + 2)) }
                return [padding + label + ": " + (try scalar(value))]
            }
        }
        if let array = value as? [Any] {
            return try array.flatMap { item -> [String] in
                if isBlock(item) {
                    var nested = try lines(item, indent: indent + 2, order: ["name", "type"])
                    nested[0] = padding + "- " + nested[0].dropFirst(indent + 2)
                    return nested
                }
                return [padding + "- " + (try scalar(item))]
            }
        }
        return [padding + (try scalar(value))]
    }
    return Data((try lines(object, indent: 0, order: keyOrder).joined(separator: "\n") + "\n").utf8)
}
