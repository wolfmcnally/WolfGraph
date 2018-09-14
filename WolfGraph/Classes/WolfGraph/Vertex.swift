//
//  Vertex.swift
//  WolfGraph
//
//  Created by Wolf McNally on 9/13/18.
//  Copyright © 2018 Wolf McNally.
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

/// A vertex, part of a generalized graph structure
public struct Vertex: Hashable, Codable {

    /// A unique ID assigned to a vertex
    public struct ID: Codable, Hashable, CustomStringConvertible {
        private let uuid: UUID

        init() {
            uuid = UUID()
        }

        public init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            uuid = try container.decode(UUID.self)
        }

        public func encode(to encoder: Encoder) throws {
            var container = encoder.singleValueContainer()
            try container.encode(uuid)
        }

        public var description: String {
            return uuid.description
        }
    }

    /// The unique ID of this vertex
    public let id: ID
    var attributes: Attributes

    /// Creates a new instance with a unique ID.
    public init() {
        id = ID()
        attributes = Attributes()
    }

    private enum CodingKeys: String, CodingKey {
        case id = "vertex"
        case attributes
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(ID.self, forKey: .id)
        attributes = try container.decodeIfPresent(Attributes.self, forKey: .attributes) ?? Attributes()
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        if !attributes.isEmpty {
            try container.encode(attributes, forKey: .attributes)
        }
    }

    public static func == (lhs: Vertex, rhs: Vertex) -> Bool {
        return lhs.id == rhs.id
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

extension Vertex: CustomStringConvertible {
    public var description: String {
        if let concept = concept {
            return "\(type(of: self))(\(id), \"\(concept)\")"
        }
        return "\(type(of: self))(\(id))"
    }
}
