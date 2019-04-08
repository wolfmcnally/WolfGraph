//
//  RandomLayout.swift
//  WolfGraph
//
//  Created by Wolf McNally on 10/10/18.
//

import Foundation
import WolfCore
import WolfGeometry

extension AttributeName {
    public static let position = AttributeName("position")
}

//extension Vertex {
//    public var position: Point? {
//        get { return try! attributes.value(for: .position) }
//        set {
//            attributes.setValue(for: .position, to: ["x": newValue!.x, "y": newValue!.y])
//        }
//    }
//}

public func randomLayout<G: GeneralGraph>(of graph: G) -> G {
    var graph = graph

    for vertex in graph.vertices {
        let x = Double.random(in: -1 .. 1)
        let y = Double.random(in: -1 .. 1)
        let position = Point(x: x, y: y)
        try! graph.setValue(of: vertex, for: .position, to: position)
    }

    return graph
}
