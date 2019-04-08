//
//  GeneralGraph.swift
//  WolfGraph
//
//  Created by Wolf McNally on 10/11/18.
//

import Foundation

extension Graph: GeneralGraph { }

public protocol GeneralGraph {
    /// The number of vertices in the graph.
    ///
    /// In graph theory, this is known as the graph's *order*.
    var vertexCount: Int { get }

    /// The number of edges in the graph.
    ///
    /// In graph theory, this is known as the graph's *size*.
    var edgeCount: Int { get }

    /// Returns the set of all vertices.
    var vertices: Set<Vertex> { get }

    /// Returns the set of all edges.
    var edges: Set<Edge> { get }

    /// Returns `false` if the vertex is unknown, `true` otherwise.
    func contains(_ vertex: Vertex) -> Bool

    /// Returns `false` if the edge is unknown, `true` otherwise.
    func contains(_ edge: Edge) -> Bool

    /// Inserts the vertex into the graph.
    ///
    /// Throws if attempting to insert a duplicate vertex.
    mutating func insert(_ vertex: Vertex) throws

    /// Removes the vertex from the graph, along with all of its incident edges.
    ///
    /// Throws if the vertex is unknown.
    mutating func remove(_ vertex: Vertex) throws

    /// Inserts the edge into the graph.
    ///
    /// Throws if attempting to insert a duplicate edge.
    /// Throws if the head or tail of the edge are unknown.
    mutating func insert(_ edge: Edge) throws

    //
    // MARK: - Edge ends
    //

    /// Returns the count of all edges contected to the vertex.
    func incidentEdgesCount(of vertex: Vertex) throws -> Int

    /// Return the set of all edges connected to the vertex.
    func incidentEdges(of vertex: Vertex) throws -> Set<Edge>

    /// Returns the neighbors of the vertex.
    func neigbors(of vertex: Vertex) throws -> Set<Vertex>

    //
    // MARK: - Graph Attributes
    //

    /// Set the value for the key on this graph.
    mutating func setValue(for key: AttributeName, to value: GraphAttribute)

    /// Returns the value for the key on this graph.
    func value<T>(for key: AttributeName) throws -> T?

    /// Removes the key on this graph.
    mutating func removeValue(for key: AttributeName)

    //
    // MARK: - Vertex Attributes
    //

    /// Set the value of the key on the vertex.
    ///
    /// Throws if the vertex is unknown.
    mutating func setValue(of vertex: Vertex, for key: AttributeName, to value: GraphAttribute) throws

    /// Returns the value of the key on the vertex.
    ///
    /// Throws if the vertex is unknown.
    func value<T>(of vertex: Vertex, for key: AttributeName) throws -> T?

    /// Removes the key on the vertex.
    ///
    /// Throws if the vertex is unknown.
    mutating func removeValue(of vertex: Vertex, for key: AttributeName) throws

    //
    // MARK: - Edge Attributes
    //

    /// Set the value of the key on the edge.
    mutating func setValue(of edge: Edge, for key: AttributeName, to value: GraphAttribute) throws

    /// Returns the value of the key on the edge.
    func value<T: GraphAttribute>(of edge: Edge, for key: AttributeName) throws -> T?

    /// Removes the key on the edge.
    ///
    /// Throws if the edge is unknown.
    mutating func removeValue(of edge: Edge, for key: AttributeName) throws
}

extension AttributeName {
    public static let label = AttributeName("label")
}

// MARK: - Vertex `label` attribute
extension GeneralGraph {
    public mutating func setLabel(of vertex: Vertex, to label: String) throws {
        try setValue(of: vertex, for: .label, to: label)
    }

    public func label(of vertex: Vertex) throws -> String? {
        return try value(of: vertex, for: .label)
    }

    public mutating func removeLabel(of vertex: Vertex) throws {
        try removeValue(of: vertex, for: .label)
    }
}

// MARK: - Edge `label` attribute
extension GeneralGraph {
    public mutating func setLabel(of edge: Edge, to label: String) throws {
        try setValue(of: edge, for: .label, to: label)
    }

    public func label(of edge: Edge) throws -> String? {
        return try value(of: edge, for: .label)
    }

    public mutating func removeLabel(of edge: Edge) throws {
        try removeValue(of: edge, for: .label)
    }
}
