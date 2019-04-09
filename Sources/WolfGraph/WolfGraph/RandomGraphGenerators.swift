//
//  RandomGraphGenerators.swift
//  WolfGraph
//
//  Created by Wolf McNally on 10/15/18.
//

import Foundation
import WolfCore
import WolfGraphics

public func generateRandomGeometricGraph(vertexCount: Int, radius: Double) -> Graph {

    var generator = SystemRandomNumberGenerator()
    return generateRandomGeometricGraph(vertexCount: vertexCount, radius: radius, using: &generator)
}

public func generateRandomGeometricGraph<T>(vertexCount: Int, radius: Double, using generator: inout T) -> Graph where T: RandomNumberGenerator {
    var graph = Graph()
    guard vertexCount >= 1 else { return graph }

    var vertices = [Vertex]()
    for _ in 0 ..< vertexCount {
        let vertex = Vertex(using: &generator)
        vertices.append(vertex)
        try! graph.insert(vertex)
        let x = Double.random(in: -1 .. 1, using: &generator)
        let y = Double.random(in: -1 .. 1, using: &generator)
        let position = Point(x: x, y: y)
        try! graph.setValue(of: vertex, for: .position, to: position)
    }

    guard vertexCount >= 2 else { return graph }

    for i in 0 ... vertexCount - 2 {
        for j in i + 1 ... vertexCount - 1 {
            let tail = vertices[i]
            let head = vertices[j]
            let tailPosition: Point = try! graph.value(of: tail, for: .position)!
            let headPosition: Point = try! graph.value(of: head, for: .position)!
            let distance = (headPosition - tailPosition).magnitude
            if distance <= radius {
                let edge = Edge(from: tail, to: head, using: &generator)
                try! graph.insert(edge)
            }
        }
    }

    return graph
}

private func lettersForIndex(_ index: Int) -> String {
    var remainder = index
    var result = ""
    let alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"

    repeat {
        let offset = remainder % alphabet.count
        let letterIndex = alphabet.index(alphabet.startIndex, offsetBy: offset)
        result += String(alphabet[letterIndex])
        remainder /= alphabet.count
    } while remainder > 0

    return result
}

public func withVerticesLabeledByNumbers(_ graph: Graph) -> Graph {
    return graph •• { g in
        for (index, vertex) in g.vertices.enumerated() {
            let label = String(index)
            try! g.setValue(of: vertex, for: .label, to: label)
        }
    }
}

public func withVerticesLabeledByLetters(_ graph: Graph) -> Graph {
    return graph •• { g in
        for (index, vertex) in Array(g.vertices).sorted().enumerated() {
            let label = lettersForIndex(index)
            try! g.setValue(of: vertex, for: .label, to: label)
        }
    }
}

public func withEdgesLabeledByNumbers(_ graph: Graph) -> Graph {
    return graph •• { g in
        for (index, edge) in Array(g.edges).sorted().enumerated() {
            let label = String(index)
            try! g.setValue(of: edge, for: .label, to: label)
        }
    }
}
