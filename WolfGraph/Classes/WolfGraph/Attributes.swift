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
import WolfAnyCodable

public struct Attributes: Codable {
    private var attrs: [String: AnyCodable]

    /// Creates a new, empty instance.
    public init() {
        attrs = [String: AnyCodable]()
    }

    /// Sets the value for this key.
    public mutating func setValue(for key: AttributeName, to value: Codable) {
        attrs[key.rawValue] = AnyCodable(value)
    }

    /// Returns the value for this key.
    ///
    /// Returns `nil` if the key does not exist.
    /// Throws if they key cannot be cast to the required return type.
    public func value<T: Codable>(for key: AttributeName) throws -> T? {
        guard let value = attrs[key.rawValue]?.value else {
            return nil
        }
        guard let typedValue = value as? T else {
            throw GraphError("Attribute type mismatch.")
        }
        return typedValue
    }

    /// Removes the key.
    public mutating func removeValue(for key: AttributeName) {
        attrs.removeValue(forKey: key.rawValue)
    }

    /// A Boolean value indicating whether the instance is empty.
    public var isEmpty: Bool {
        return attrs.isEmpty
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(attrs)
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        attrs = try container.decode([String: AnyCodable].self)
    }
}
