import XCTest
import WolfGraph
import WolfGeometry
import WolfColor

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
        try g2.setValue(of: wolfVertex, for: .color, to: Color.green)
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

    func test3() throws {
        var g = Graph()
        let wolfVertex = Vertex()
        let lunaVertex = Vertex()
        try g.insert(wolfVertex)
        try g.insert(lunaVertex)
        let e = Edge(from: wolfVertex, to: lunaVertex)
        try g.insert(e)

        let g2 = randomLayout(of: g)
        g2.dump()
    }

    func test4() throws {
        var attributes = Attributes()
        attributes.setValue(for: AttributeName("bool"), to: true)
        attributes.setValue(for: AttributeName("string"), to: "Wolf")
        attributes.setValue(for: AttributeName("int"), to: 53)
        attributes.setValue(for: AttributeName("double"), to: 42.001)
        attributes.setValue(for: AttributeName("point"), to: Point(x: -10, y: Double.pi))
        attributes.setValue(for: AttributeName("date"), to: Date())
        attributes.setValue(for: AttributeName("color"), to: Color.yellow)
        attributes.setValue(for: AttributeName("uuid"), to: UUID())
        attributes.setValue(for: AttributeName("url"), to: URL(string: "http://wolfmcnally.com")!)
        attributes.setValue(for: AttributeName("array"), to: [false, "Luna", 48, 43.5, Point.zero, Date()])
        attributes.setValue(for: AttributeName("dict"), to: ["string": "Luna", "int": 48, "date": Date()])
        //print(attributes)
        //attributes.dump()

        let encoder = JSONEncoder()
        let data = try encoder.encode(attributes)

        let decoder = JSONDecoder()
        let attributes2 = try decoder.decode(Attributes.self, from: data)
        //print(attributes2)
        //attributes2.dump()
        XCTAssert(attributes == attributes2)
        let data2 = try encoder.encode(attributes2)
        XCTAssert(data == data2)
    }
}
