//
//  GraphViewController.swift
//  WolfGraph_Example
//
//  Created by Wolf McNally on 10/10/18.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import WolfKit

class GraphViewController: AppViewController {
    private var tapAction: GestureRecognizerAction?

    private lazy var stackView = VerticalStackView() • { (🍒: VerticalStackView) in
        🍒.spacing = 10
    }

    private lazy var seedLabel = Label() • { (🍒: Label) in
        🍒.textColor = .lightText
        🍒.textAlignment = .center
        🍒.font = UIFont.boldSystemFont(ofSize: 24)
    }

    private lazy var graphView = GraphView() • { (🍒: GraphView) in
        tapAction = 🍒.addAction(for: UITapGestureRecognizer()) { [unowned self] _ in
            self.nextGraph()
        }
    }

    var seed: Int = 0

    private func makeGraph() -> Graph {
        var generator = SeededRandomNumberGenerator(seed: seed)
        let vertexCount = 20
        let radius = 0.5
//        let vertexCount = 2
//        let radius = 2.0
        return generateRandomGeometricGraph(vertexCount: vertexCount, radius: radius, using: &generator) |> withVerticesLabeledByLetters |> withEdgesLabeledByNumbers
    }

    override func build() {
        super.build()

        view.backgroundColor = UIColor(white: 0.05, alpha: 1.0)

        view => [
            stackView => [
                seedLabel,
                graphView
            ]
        ]

        stackView.constrainFrameToSafeArea()
    }

    private func nextGraph() {
        seed += 1
        seedLabel.text = String(seed)
        graphView.graph = makeGraph()
    }

    private var repeatCancelable: Cancelable?

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        nextGraph()

//        repeatCancelable = dispatchRepeatedOnMain(atInterval: 1) { [unowned self] _ in
//            self.nextGraph()
//        }
    }
}
