//
//  Attributes.swift
//  WolfGraph
//
//  Created by Wolf McNally on 9/13/18.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

import Foundation
import WolfGraphics

struct AttributeValue: Codable, CustomStringConvertible {
    let value: Any

    init(_ value: Any) {
        self.value = value
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()

        switch self.value {
        case let bool as Bool:
            try container.encode(bool)
        case let int as Int:
            try container.encode(int)
        case let double as Double:
            try container.encode(double)
        case let value as StringEncodable:
            try container.encode(value.stringEncoding)
        case let array as [GraphAttribute]:
            try container.encode(AttributeArray(array))
        case let dictionary as [String: GraphAttribute]:
            try container.encode(Attributes(dictionary))
        default:
            let context = EncodingError.Context(codingPath: container.codingPath, debugDescription: "AnyCodable value cannot be encoded")
            throw EncodingError.invalidValue(self.value, context)
        }
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()

        if let bool = try? container.decode(Bool.self) {
            self.init(bool)
        } else if let int = try? container.decode(Int.self) {
            self.init(int)
        } else if let double = try? container.decode(Double.self) {
            self.init(double)
        } else if let string = try? container.decode(String.self) {
            let value = try decodeString(string)
            self.init(value)
        } else if let array = try? container.decode(AttributeArray.self) {
            self.init(array.array)
        } else if let dictionary = try? container.decode(Attributes.self) {
            self.init(dictionary.dictionary)
        } else {
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "AnyCodable value cannot be decoded")
        }
    }

    var description: String {
        return String(describing: value)
    }
}

struct AttributeArray: Codable, CustomStringConvertible {
    let array: [Any]

    init(_ array: [Any]) {
        self.array = array
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.unkeyedContainer()
        for element in array {
            try container.encode(AttributeValue(element))
        }
    }

    init(from decoder: Decoder) throws {
        var array = [Any]()
        var container = try decoder.unkeyedContainer()
        while !container.isAtEnd {
            let v = try container.decode(AttributeValue.self)
            array.append(v.value)
        }
        self.array = array
    }

    var description: String {
        return array.description
    }
}

public struct Attributes: Codable, CustomStringConvertible {
    var dictionary: [String: Any]

    public init(_ dictionary: [String: Any]) {
        self.dictionary = dictionary
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: AnyKey.self)
        for (key, value) in dictionary {
            switch value {
            case let bool as Bool:
                try container.encode(bool, forKey: AnyKey(key))
            case let int as Int:
                try container.encode(int, forKey: AnyKey(key))
            case let double as Double:
                try container.encode(double, forKey: AnyKey(key))
            case let value as StringEncodable:
                try container.encode(value.stringEncoding, forKey: AnyKey(key))
            case let array as [GraphAttribute]:
                try container.encode(AttributeArray(array), forKey: AnyKey(key))
            case let dictionary as [String: GraphAttribute]:
                try container.encode(Attributes(dictionary), forKey: AnyKey(key))
            default:
                let context = EncodingError.Context(codingPath: container.codingPath, debugDescription: "Value cannot be encoded")
                throw EncodingError.invalidValue(value, context)
            }
        }
    }

    public init(from decoder: Decoder) throws {
        var dictionary = [String: Any]()
        let container = try decoder.container(keyedBy: AnyKey.self)
        for key in container.allKeys {
            let keyString = key.stringValue
            if let bool = try? container.decode(Bool.self, forKey: key) {
                dictionary[keyString] = bool
            } else if let int = try? container.decode(Int.self, forKey: key) {
                dictionary[keyString] = int
            } else if let double = try? container.decode(Double.self, forKey: key) {
                dictionary[keyString] = double
            } else if let string = try? container.decode(String.self, forKey: key) {
                let value = try decodeString(string)
                dictionary[keyString] = value
            } else if let attributeArray = try? container.decode(AttributeArray.self, forKey: key) {
                dictionary[keyString] = attributeArray.array
            } else if let attributeDictionary = try? container.decode(Attributes.self, forKey: key) {
                dictionary[keyString] = attributeDictionary.dictionary
            } else {
                throw DecodingError.dataCorruptedError(forKey: key, in: container, debugDescription: "Value cannot be decoded")
            }
        }
        self.dictionary = dictionary
    }

    /// Creates a new, empty instance.
    public init() {
        dictionary = [String: GraphAttribute]()
    }

    /// Sets the value for this key.
    public mutating func setValue(for key: AttributeName, to value: Any?) {
        dictionary[key.rawValue] = value
    }

    /// Returns the value for this key.
    ///
    /// Returns `nil` if the key does not exist.
    /// Throws if they key cannot be cast to the required return type.
    public func value<T>(for key: AttributeName) throws -> T? {
        guard let value = dictionary[key.rawValue] else { return nil }
        guard let typedValue = value as? T else {
            throw GraphError("Attribute type mismatch.")
        }
        return typedValue
    }

    /// Removes the key.
    public mutating func removeValue(for key: AttributeName) {
        dictionary.removeValue(forKey: key.rawValue)
    }

    /// A Boolean value indicating whether the instance is empty.
    public var isEmpty: Bool {
        return dictionary.isEmpty
    }

    public var description: String {
        return dictionary.description
    }
}

extension Attributes: Equatable {
    public static func == (lhs: Attributes, rhs: Attributes) -> Bool {
        return equalAttributes(lhs.dictionary, rhs.dictionary)
    }

    static func equalAttributes(_ lhs: Any, _ rhs: Any) -> Bool {
        guard type(of: lhs) == type(of: rhs) else {
            return false
        }
        if let l = lhs as? Bool, let r = rhs as? Bool {
            guard l == r else { return false }
        } else if let l = lhs as? Int, let r = rhs as? Int {
            guard l == r else { return false }
        } else if let l = lhs as? Double, let r = rhs as? Double {
            guard l == r else { return false }
        } else if let l = lhs as? String, let r = rhs as? String {
            guard l == r else { return false }
        } else if let l = lhs as? Date, let r = rhs as? Date {
            // Because not every decimal of Double accuracy survives ISO8601 encoding.
            guard abs(l.timeIntervalSinceReferenceDate - r.timeIntervalSinceReferenceDate) < 0.001 else { return false }
        } else if let l = lhs as? URL, let r = rhs as? URL {
            guard l == r else { return false }
        } else if let l = lhs as? UUID, let r = rhs as? UUID {
            guard l == r else { return false }
        } else if let l = lhs as? Point, let r = rhs as? Point {
            guard l == r else { return false }
        } else if let l = lhs as? Size, let r = rhs as? Size {
            guard l == r else { return false }
        } else if let l = lhs as? Rect, let r = rhs as? Rect {
            guard l == r else { return false }
        } else if let l = lhs as? Color, let r = rhs as? Color {
            guard l == r else { return false }
        } else if let l = lhs as? [Any], let r = rhs as? [Any] {
            guard l.count == r.count else { return false }
            for i in 0 ..< l.count {
                guard equalAttributes(l[i], r[i]) else { return false }
            }
        } else if let l = lhs as? [String: Any], let r = rhs as? [String: Any] {
            let keys = l.keys.sorted()
            guard keys == r.keys.sorted() else { return false }
            for key in keys {
                guard equalAttributes(l[key]!, r[key]!) else { return false }
            }
        } else {
            return false
        }
        return true
    }
}
