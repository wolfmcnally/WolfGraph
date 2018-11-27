//
//  Graph.swift
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

public struct Graph: Codable {
    private typealias VertexEdges = [Vertex.ID: Set<Edge.ID>]

    let isUndirected: Bool
    var verticesByID: [Vertex.ID: Vertex]
    var edgesByID: [Edge.ID: Edge]
    private var attributes: Attributes
    private var outEdges: VertexEdges
    private var inEdges: VertexEdges

    private enum CodingKeys: String, CodingKey {
        case isUndirected
        case vertices
        case edges
        case attributes
    }

    /// Creates a new graph instance
    public init(isUndirected: Bool = true) {
        self.isUndirected = isUndirected
        verticesByID = [Vertex.ID: Vertex]()
        edgesByID = [Edge.ID: Edge]()
        attributes = Attributes()
        outEdges = VertexEdges()
        inEdges = VertexEdges()
    }

    /// The number of vertices in the graph.
    ///
    /// In graph theory, this is known as the graph's *order*.
    public var vertexCount: Int {
        return verticesByID.count
    }

    /// The number of edges in the graph.
    ///
    /// In graph theory, this is known as the graph's *size*.
    public var edgeCount: Int {
        return edgesByID.count
    }

    /// Returns the set of all vertices.
    public var vertices: Set<Vertex> {
        return Set(verticesByID.values)
    }

    /// Returns the set of all edges
    public var edges: Set<Edge> {
        return Set(edgesByID.values)
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

    private mutating func removeInEdge(for edge: Edge) {
        inEdges.removeValue(forKey: edge.headID)
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

    private mutating func removeOutEdge(for edge: Edge) {
        outEdges.removeValue(forKey: edge.tailID)
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        isUndirected = try container.decodeIfPresent(Bool.self, forKey: .isUndirected) ?? false

        let verticesArray = try container.decode([Vertex].self, forKey: .vertices)
        verticesByID = [Vertex.ID: Vertex]()
        for vertex in verticesArray {
            verticesByID[vertex.id] = vertex
        }

        let edgesArray = try container.decode([Edge].self, forKey: .edges)
        edgesByID = [Edge.ID: Edge]()
        for edge in edgesArray {
            edgesByID[edge.id] = edge
        }

        attributes = try container.decodeIfPresent(Attributes.self, forKey: .attributes) ?? Attributes()

        outEdges = VertexEdges()
        inEdges = VertexEdges()
        for edge in edgesByID.values {
            insertInEdge(for: edge)
            insertOutEdge(for: edge)
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        if isUndirected {
            try container.encode(isUndirected, forKey: .isUndirected)
        }
        try container.encode(Array(verticesByID.values), forKey: .vertices)
        try container.encode(Array(edgesByID.values), forKey: .edges)
        if !attributes.isEmpty {
            try container.encode(attributes, forKey: .attributes)
        }
    }

    /// Returns `false` if the vertex is unknown, `true` otherwise.
    public func contains(_ vertex: Vertex) -> Bool {
        return verticesByID.keys.contains(vertex.id)
    }

    /// Returns `false` if the edge is unknown, `true` otherwise.
    public func contains(_ edge: Edge) -> Bool {
        return edgesByID.keys.contains(edge.id)
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
        verticesByID[vertex.id] = vertex
    }

    /// Removes the vertex from the graph, along with all of its incident edges.
    ///
    /// Throws if the vertex is unknown.
    public mutating func remove(_ vertex: Vertex) throws {
        try checkContains(vertex)
        for edge in try incidentEdges(of: vertex) {
            try remove(edge)
        }
        verticesByID.removeValue(forKey: vertex.id)
    }

    /// Inserts the edge into the graph.
    ///
    /// Throws if attempting to insert a duplicate edge.
    /// Throws if the head or tail of the edge are unknown.
    public mutating func insert(_ edge: Edge) throws {
        try checkDoesNotContain(edge)
        edgesByID[edge.id] = edge
        try checkContains(tail(of: edge))
        try checkContains(head(of: edge))
        insertInEdge(for: edge)
        insertOutEdge(for: edge)
    }

    /// Removes the edge from the graph
    ///
    /// Throws if the edge is unknown.
    public mutating func remove(_ edge: Edge) throws {
        try checkContains(edge)
        edgesByID.removeValue(forKey: edge.id)
        removeInEdge(for: edge)
        removeOutEdge(for: edge)
    }

    /// Returns true if any of `tail`'s out edges goes to `head`.
    ///
    /// Throws if either vertex is unknown.
    public func hasEdge(from tail: Vertex, to head: Vertex) throws -> Bool {
        let tailOutEdges = try outEdges(of: tail)
        for edge in tailOutEdges {
            if try self.head(of: edge) == head {
                return true
            }
        }
        return false
    }

    public func hasEdge(_ a: Vertex, _ b: Vertex) throws -> Bool {
        return try hasEdge(from: a, to: b) || hasEdge(from: b, to: a)
    }

    //
    // MARK: - Edge ends
    //

    /// Returns the vertex at the tail of the edge.
    public func tail(of edge: Edge) throws -> Vertex {
        try checkContains(edge)
        return verticesByID[edge.tailID]!
    }

    /// Returns the vertex at the head of the edge.
    public func head(of edge: Edge) throws -> Vertex {
        try checkContains(edge)
        return verticesByID[edge.headID]!
    }

    /// Returns the count of in-edges of the vertex.
    public func inEdgesCount(of vertex: Vertex) throws -> Int {
        try checkContains(vertex)
        return inEdges[vertex.id]?.count ?? 0
    }

    /// Returns the in-edges of the vertex.
    public func inEdges(of vertex: Vertex) throws -> Set<Edge> {
        try checkContains(vertex)
        let a = (self.inEdges[vertex.id] ?? Set<Edge.ID>()).map { self.edgesByID [$0]! }
        return Set(a)
    }

    /// Returns the count of out-edges of the vertex.
    public func outEdgesCount(of vertex: Vertex) throws -> Int {
        try checkContains(vertex)
        return outEdges[vertex.id]?.count ?? 0
    }

    /// Returns the count of all edges contected to the vertex.
    public func incidentEdgesCount(of vertex: Vertex) throws -> Int {
        return try inEdgesCount(of: vertex) + outEdgesCount(of: vertex)
    }

    /// Returns the out-edges of the vertex.
    public func outEdges(of vertex: Vertex) throws -> Set<Edge> {
        try checkContains(vertex)
        let a = (self.outEdges[vertex.id] ?? Set<Edge.ID>()).map { self.edgesByID[$0]! }
        return Set(a)
    }

    /// Return the set of all edges connected to the vertex.
    public func incidentEdges(of vertex: Vertex) throws -> Set<Edge> {
        return try inEdges(of: vertex).union(outEdges(of: vertex))
    }

    /// Returns the predecessors of the vertex.
    public func predecessors(of vertex: Vertex) throws -> Set<Vertex> {
        let a = try inEdges(of: vertex).map { try self.tail(of: $0) }
        return Set(a)
    }

    /// Returns the successors of the vertex.
    public func successors(of vertex: Vertex) throws -> Set<Vertex> {
        let a = try outEdges(of: vertex).map { try self.head(of: $0) }
        return Set(a)
    }

    /// Returns the neighbors of the vertex.
    public func neigbors(of vertex: Vertex) throws -> Set<Vertex> {
        return try predecessors(of: vertex).union(successors(of: vertex))
    }

    //
    // MARK: - Graph Attributes
    //

    /// Set the value for the key on this graph.
    public mutating func setValue(for key: AttributeName, to value: GraphAttribute) {
        attributes.setValue(for: key, to: value)
    }

    /// Returns the value for the key on this graph.
    public func value<T>(for key: AttributeName) throws -> T? {
        return try attributes.value(for: key)
    }

    /// Removes the key on this graph.
    public mutating func removeValue(for key: AttributeName) {
        attributes.removeValue(for: key)
    }

    //
    // MARK: - Vertex Attributes
    //

    /// Set the value of the key on the vertex.
    ///
    /// Throws if the vertex is unknown.
    public mutating func setValue(of vertex: Vertex, for key: AttributeName, to value: GraphAttribute) throws {
        try checkContains(vertex)
        verticesByID[vertex.id]!.attributes.setValue(for: key, to: value)
    }

    /// Returns the value of the key on the vertex.
    ///
    /// Throws if the vertex is unknown.
    public func value<T>(of vertex: Vertex, for key: AttributeName) throws -> T? {
        try checkContains(vertex)
        return try verticesByID[vertex.id]!.attributes.value(for: key)
    }

    /// Removes the key on the vertex.
    ///
    /// Throws if the vertex is unknown.
    public mutating func removeValue(of vertex: Vertex, for key: AttributeName) throws {
        try checkContains(vertex)
        verticesByID[vertex.id]!.attributes.removeValue(for: key)
    }

    //
    // MARK: - Edge Attributes
    //

    /// Set the value of the key on the edge.
    public mutating func setValue(of edge: Edge, for key: AttributeName, to value: GraphAttribute) throws {
        try checkContains(edge)
        edgesByID[edge.id]!.attributes.setValue(for: key, to: value)
    }

    /// Returns the value of the key on the edge.
    public func value<T: GraphAttribute>(of edge: Edge, for key: AttributeName) throws -> T? {
        try checkContains(edge)
        return try edgesByID[edge.id]!.attributes.value(for: key)
    }

    /// Removes the key on the edge.
    ///
    /// Throws if the edge is unknown.
    public mutating func removeValue(of edge: Edge, for key: AttributeName) throws {
        try checkContains(edge)
        edgesByID[edge.id]!.attributes.removeValue(for: key)
    }
}
