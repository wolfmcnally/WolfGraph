import XCTest
import WolfGraph

extension AttributeName {
    static let color = AttributeName("color")
}

class Tests: XCTestCase {
    func test1() throws {
        var g1 = Graph()
        let wolfVertex = Vertex()
        let lunaVertex = Vertex()
        try g1.insert(wolfVertex)

        var g2 = g1
        try g2.insert(lunaVertex)
        let e = Edge(from: wolfVertex, to: lunaVertex)
        try g2.insert(e)
        try g2.setValue(of: wolfVertex, for: .concept, to: "Wolf")
        try g2.setValue(of: wolfVertex, for: .color, to: "green")
        try g2.setValue(of: lunaVertex, for: .concept, to: "Luna")
        try g2.setValue(of: e, for: .relation, to: "loves")

        //g1.dump()
        //print("")
        g2.dump()
        //
        //v1.dump()
        //let name: String = try g2.attribute(of: v1, key: "name")!
        //print(name)
        //g2.vertices[v1.id]!.dump()
        print(try g2.inEdges(of: wolfVertex))
        print(try g2.outEdges(of: wolfVertex))

        print(try g2.inEdges(of: lunaVertex))
        print(try g2.outEdges(of: lunaVertex))

        print(try g2.successors(of: wolfVertex))
        print(try g2.predecessors(of: lunaVertex))
    }

    func test2() throws {
        var v = Vertex()
        v.concept = "Wolf"
        v.dump()
    }
}
