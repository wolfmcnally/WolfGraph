//
//  UndirectedGraph.swift
//  WolfGraph
//
//  Created by Wolf McNally on 10/11/18.
//

import Foundation

extension Graph: UndirectedGraph { }

public protocol UndirectedGraph: GeneralGraph {
    func hasEdge(_ a: Vertex, _ b: Vertex) throws -> Bool
}
