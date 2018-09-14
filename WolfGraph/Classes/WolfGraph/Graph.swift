//
//  Graph.swift
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

public struct Graph: Codable {
    private typealias VertexEdges = [Vertex.ID: Set<Edge.ID>]
    private var vertices: [Vertex.ID: Vertex]
    private var edges: [Edge.ID: Edge]
    private var attributes: Attributes
    private var outEdges: VertexEdges
    private var inEdges: VertexEdges

    private enum CodingKeys: String, CodingKey {
        case vertices
        case edges
        case attributes
    }

    /// Creates a new graph instance
    public init() {
        vertices = [Vertex.ID: Vertex]()
        edges = [Edge.ID: Edge]()
        attributes = Attributes()
        outEdges = VertexEdges()
        inEdges = VertexEdges()
    }

    private mutating func insertInEdge(for edge: Edge) {
        let edgeID = edge.id
        let headID = edge.headID
        if inEdges[headID] == nil {
            inEdges[headID] = Set<Edge.ID>([edgeID])
        } else {
            inEdges[headID]!.insert(edgeID)
        }
    }

    private mutating func insertOutEdge(for edge: Edge) {
        let edgeID = edge.id
        let tailID = edge.tailID
        if outEdges[tailID] == nil {
            outEdges[tailID] = Set<Edge.ID>([edgeID])
        } else {
            outEdges[tailID]!.insert(edgeID)
        }
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        let verticesArray = try container.decode([Vertex].self, forKey: .vertices)
        vertices = [Vertex.ID: Vertex]()
        for vertex in verticesArray {
            vertices[vertex.id] = vertex
        }

        let edgesArray = try container.decode([Edge].self, forKey: .edges)
        edges = [Edge.ID: Edge]()
        for edge in edgesArray {
            edges[edge.id] = edge
        }

        attributes = try container.decodeIfPresent(Attributes.self, forKey: .attributes) ?? Attributes()

        outEdges = VertexEdges()
        inEdges = VertexEdges()
        for edge in edges.values {
            insertInEdge(for: edge)
            insertOutEdge(for: edge)
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(Array(vertices.values), forKey: .vertices)
        try container.encode(Array(edges.values), forKey: .edges)
        if !attributes.isEmpty {
            try container.encode(attributes, forKey: .attributes)
        }
    }

    /// Returns `false` if the vertex is unknown, `true` otherwise.
    public func contains(_ vertex: Vertex) -> Bool {
        return vertices.keys.contains(vertex.id)
    }

    /// Returns `false` if the edge is unknown, `true` otherwise.
    public func contains(_ edge: Edge) -> Bool {
        return edges.keys.contains(edge.id)
    }

    /// Throws if the vertex is unknown. No effect otherwise.
    public func checkContains(_ vertex: Vertex) throws {
        guard contains(vertex) else {
            throw GraphError("Unknown vertex")
        }
    }

    /// Throws if the edge is unknown. No effect otherwise.
    public func checkContains(_ edge: Edge) throws {
        guard contains(edge) else {
            throw GraphError("Unknown edge")
        }
    }

    /// Throws unless the vertex is unknown. No effect otherwise.
    public func checkDoesNotContain(_ vertex: Vertex) throws {
        guard !contains(vertex) else {
            throw GraphError("Duplicate vertex")
        }
    }

    /// Throws unless the edge is unknown. No effect otherwise.
    public func checkDoesNotContain(_ edge: Edge) throws {
        guard !contains(edge) else {
            throw GraphError("Duplicate edge")
        }
    }

    /// Inserts the vertex into the graph.
    ///
    /// Throws if attempting to insert a duplicate vertex.
    public mutating func insert(_ vertex: Vertex) throws {
        try checkDoesNotContain(vertex)
        vertices[vertex.id] = vertex
    }

    /// Inserts the edge into the graph.
    ///
    /// Throws if attempting to insert a duplicate edge.
    /// Throws if the head or tail of the edge are unknown.
    public mutating func insert(_ edge: Edge) throws {
        try checkDoesNotContain(edge)
        edges[edge.id] = edge
        try checkContains(tail(of: edge))
        try checkContains(head(of: edge))
        insertInEdge(for: edge)
        insertOutEdge(for: edge)
    }

    //
    // Graph Attributes
    //

    /// Set the value for the key on this graph.
    public mutating func setValue(for key: AttributeName, to value: Codable) {
        attributes.setValue(for: key, to: value)
    }

    /// Returns the value for the key on this graph.
    public func value<T: Codable>(for key: AttributeName) throws -> T? {
        return try attributes.value(for: key)
    }

    //
    // Vertex Attributes
    //

    /// Set the value of the key on the vertex.
    ///
    /// Throws if the vertex is unknown.
    public mutating func setValue(of vertex: Vertex, for key: AttributeName, to value: Codable) throws {
        try checkContains(vertex)
        vertices[vertex.id]!.attributes.setValue(for: key, to: value)
    }

    /// Returns the value of the key on the vertex.
    ///
    /// Throws if the vertex is unknown.
    public func value<T: Codable>(of vertex: Vertex, for key: AttributeName) throws -> T? {
        try checkContains(vertex)
        return try vertices[vertex.id]!.attributes.value(for: key)
    }

    /// Removes the key on the vertex.
    ///
    /// Throws if the vertex is unknown.
    public mutating func removeValue(of vertex: Vertex, for key: AttributeName) throws {
        try checkContains(vertex)
        vertices[vertex.id]!.attributes.removeValue(for: key)
    }

    //
    // Edge Attributes
    //

    /// Set the value of the key on the edge.
    public mutating func setValue(of edge: Edge, for key: AttributeName, to value: Codable) throws {
        try checkContains(edge)
        edges[edge.id]!.attributes.setValue(for: key, to: value)
    }

    /// Returns the value of the key on the edge.
    public func value<T: Codable>(of edge: Edge, key: AttributeName) throws -> T? {
        try checkContains(edge)
        return try edges[edge.id]!.attributes.value(for: key)
    }

    /// Removes the key on the edge.
    ///
    /// Throws if the edge is unknown.
    public mutating func removeValue(of edge: Edge, for key: AttributeName) throws {
        try checkContains(edge)
        edges[edge.id]!.attributes.removeValue(for: key)
    }

    //
    // Edge ends
    //

    /// Returns the vertex at the tail of the edge.
    public func tail(of edge: Edge) throws -> Vertex {
        try checkContains(edge)
        return vertices[edge.tailID]!
    }

    /// Returns the vertex at the head of the edge.
    public func head(of edge: Edge) throws -> Vertex {
        try checkContains(edge)
        return vertices[edge.headID]!
    }

    /// Returns in in-edges of the vertex.
    public func inEdges(of vertex: Vertex) throws -> [Edge] {
        try checkContains(vertex)
        return (self.inEdges[vertex.id] ?? Set<Edge.ID>()).map { self.edges [$0]! }
    }

    /// Returns the out-edges of the vertex.
    public func outEdges(of vertex: Vertex) throws -> [Edge] {
        try checkContains(vertex)
        return (self.outEdges[vertex.id] ?? Set<Edge.ID>()).map { self.edges[$0]! }
    }

    /// Returns the predecessors of the vertex.
    public func predecessors(of vertex: Vertex) throws -> [Vertex] {
        return try inEdges(of: vertex).map { try self.tail(of: $0) }
    }

    /// Returns the successors of the vertex.
    public func successors(of vertex: Vertex) throws -> [Vertex] {
        return try outEdges(of: vertex).map { try self.head(of: $0) }
    }
}
