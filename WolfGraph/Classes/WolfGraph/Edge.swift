//
//  Edge.swift
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

/// An edge, part of a generalized graph structure
public struct Edge: Hashable, Codable, Comparable {
    /// A unique ID assigned to an edge
    public struct ID: Codable, Hashable, CustomStringConvertible, Comparable {
        private let uuid: UUID

        init() {
            uuid = UUID()
        }

        init<T>(using generator: inout T) where T: RandomNumberGenerator {
            uuid = UUID.random(using: &generator)
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

        public static func < (lhs: ID, rhs: ID) -> Bool {
            return lhs.uuid < rhs.uuid
        }
    }

    /// The unique ID of this edge.
    public let id: ID
    var attributes: Attributes
    var tailID: Vertex.ID
    var headID: Vertex.ID

    /// Creates a new instance with a unique ID pointing from `tail` to `head`.
    public init(from tail: Vertex, to head: Vertex) {
        id = ID()
        attributes = Attributes()
        self.tailID = tail.id
        self.headID = head.id
    }

    /// Creates a new instance pointing from `tail` to `head`
    /// with an ID produced by the provided random number
    /// generator.
    public init<T>(from tail: Vertex, to head: Vertex, using generator: inout T) where T: RandomNumberGenerator {
        id = ID(using: &generator)
        attributes = Attributes()
        self.tailID = tail.id
        self.headID = head.id
    }

    private enum CodingKeys: String, CodingKey {
        case id = "edge"
        case attributes
        case tailID = "tail"
        case headID = "head"
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(ID.self, forKey: .id)
        attributes = try container.decodeIfPresent(Attributes.self, forKey: .attributes) ?? Attributes()
        tailID = try container.decode(Vertex.ID.self, forKey: .tailID)
        headID = try container.decode(Vertex.ID.self, forKey: .headID)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        if !attributes.isEmpty {
            try container.encode(attributes, forKey: .attributes)
        }
        try container.encode(tailID, forKey: .tailID)
        try container.encode(headID, forKey: .headID)
    }

    public static func == (lhs: Edge, rhs: Edge) -> Bool {
        return lhs.id == rhs.id
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    public static func < (lhs: Edge, rhs: Edge) -> Bool {
        return lhs.id < rhs.id
    }
}

extension Edge: CustomStringConvertible {
    public var description: String {
        if let relation = relation {
            return "\(type(of: self))(\(id), \(tailID) -\(relation)-> \(headID))"
        }
        return "\(type(of: self))(\(id) \(tailID) --> \(headID))"
    }
}
