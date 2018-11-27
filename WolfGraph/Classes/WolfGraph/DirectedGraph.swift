//
//  DirectedGraph.swift
//  WolfGraph
//
//  Created by Wolf McNally on 10/11/18.
//

import Foundation

extension Graph: DirectedGraph { }

public protocol DirectedGraph: GeneralGraph {
    //
    // MARK: - Edge ends
    //

    /// Returns the vertex at the tail of the edge.
    func tail(of edge: Edge) throws -> Vertex

    /// Returns the vertex at the head of the edge.
    func head(of edge: Edge) throws -> Vertex

    /// Returns true if any of `tail`'s out edges goes to `head`.
    ///
    /// Throws if either vertex is unknown.
    func hasEdge(from tail: Vertex, to head: Vertex) throws -> Bool

    /// Returns the count of in-edges of the vertex.
    func inEdgesCount(of vertex: Vertex) throws -> Int

    /// Returns the in-edges of the vertex.
    func inEdges(of vertex: Vertex) throws -> Set<Edge>

    /// Returns the count of out-edges of the vertex.
    func outEdgesCount(of vertex: Vertex) throws -> Int

    /// Returns the out-edges of the vertex.
    func outEdges(of vertex: Vertex) throws -> Set<Edge>

    /// Returns the predecessors of the vertex.
    func predecessors(of vertex: Vertex) throws -> Set<Vertex>

    /// Returns the successors of the vertex.
    func successors(of vertex: Vertex) throws -> Set<Vertex>
}
