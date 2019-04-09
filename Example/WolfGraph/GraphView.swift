//
//  GraphView.swift
//  WolfGraph_Example
//
//  Created by Wolf McNally on 10/10/18.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import WolfKit

class GraphView: View {
    override func setup() {
        contentMode = .redraw
    }

    var graph: Graph! {
        didSet {
            setNeedsDisplay()
        }
    }

    private lazy var vertexSize = CGSize(width: 40, height: 40)

    private func point(for position: Point) -> CGPoint {
        let r = bounds.insetBy(dx: vertexSize.width / 2, dy: vertexSize.height / 2)
        let x = CGFloat(position.x).lerped(from: -1 .. 1, to: r.minX .. r.maxX)
        let y = CGFloat(position.y).lerped(from: -1 .. 1, to: r.minY .. r.maxY)
        return CGPoint(x: x, y: y)
    }

    override func draw(_ rect: CGRect) {
        super.draw(rect)

        drawIntoCurrentContext { context in
            //drawCrossedBox(into: context, frame: bounds)
            do {
                var vertexPaths = [Vertex.ID: CGPath]()
                var vertexCenters = [Vertex.ID: CGPoint]()
                var edgePaths = [Edge.ID: CGPath]()
                var edgeCenters = [Edge.ID: CGPoint]()

                func makeVertexPaths() throws {
                    for vertex in graph.vertices {
                        let position: Point = try graph.value(of: vertex, for: .position)!
                        let center = point(for: position)
                        let frame = CGRect(center: center, size: vertexSize)
                        let path = CGPath(ellipseIn: frame, transform: nil)
                        vertexPaths[vertex.id] = path
                        vertexCenters[vertex.id] = center
                    }
                }

                func makeEdgePaths() throws {
                    for edge in graph.edges {
                        let tail = try graph.tail(of: edge)
                        let head = try graph.head(of: edge)
                        let tailPosition: Point = try graph.value(of: tail, for: .position)!
                        let headPosition: Point = try graph.value(of: head, for: .position)!
                        let tailPoint = point(for: tailPosition)
                        let headPoint = point(for: headPosition)

                        let tailPath = vertexPaths[tail.id]!
                        let headPath = vertexPaths[head.id]!

                        let line = LineSegment(from: tailPoint, to: headPoint)
                        var linePath = CGPath.makeWithLine(line)
                        (_, linePath) = linePath.splitAtFirstIntersection(with: tailPath)
                        (linePath, _) = linePath.splitAtFirstIntersection(with: headPath)

                        let center = line.compute(0.5)
                        edgeCenters[edge.id] = center

                        let tailTerminus = linePath.tailTerminus
                        let headTerminus = linePath.headTerminus

                        let lineWidth: CGFloat = 1
                        let strokedLinePath = linePath.stroked(width: lineWidth)
                        let lineCGPath = strokedLinePath
                            .composedWith(arrowhead: .openCircle, at: tailTerminus, scale: lineWidth)
                            .composedWith(arrowhead: .triangle, at: headTerminus, scale: lineWidth)

                        edgePaths[edge.id] = lineCGPath
                    }
                }

                func drawEdges() throws {
                    for edge in graph.edges {
                        context.setFillColor(OSColor.red.cgColor)
                        let path = edgePaths[edge.id]!
                        context.addPath(path)
                        context.fillPath()
                        if let label = try graph.label(of: edge) {
                            let font = UIFont.boldSystemFont(ofSize: 12)
                            let attributes: [NSAttributedString.Key : Any] = [.foregroundColor: UIColor.white, .font: font]
                            let size = (label as NSString).size(withAttributes: attributes)
                            let center = edgeCenters[edge.id]!
                            let frame = CGRect(center: center, size: size)
                            (label as NSString).draw(in: frame, withAttributes: attributes)
                        }
                    }
                }

                func drawVertices() throws {
                    for vertex in graph.vertices {
                        context.setFillColor(OSColor.darkGray.cgColor)
                        context.setStrokeColor(OSColor.white.cgColor)
                        context.setLineWidth(1)
                        let cgPath = vertexPaths[vertex.id]!
                        context.addPath(cgPath)
                        context.fillPath()
                        context.addPath(cgPath)
                        context.strokePath()
                        if let label = try graph.label(of: vertex) {
                            let font = UIFont.boldSystemFont(ofSize: 24)
                            let attributes: [NSAttributedString.Key : Any] = [.foregroundColor: UIColor.white, .font: font]
                            let size = (label as NSString).size(withAttributes: attributes)
                            let center = vertexCenters[vertex.id]!
                            let frame = CGRect(center: center, size: size)
                            (label as NSString).draw(in: frame, withAttributes: attributes)
                        }
                    }
                }

                try makeVertexPaths()
                try makeEdgePaths()
                try drawVertices()
                try drawEdges()

            } catch {
                logError(error)
            }
        }
    }
}
