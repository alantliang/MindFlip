//
//  AstarTest.swift
//  MindFlip
//
//  Created by Alan Liang on 2/15/15.
//  Copyright (c) 2015 fsa. All rights reserved.
//

import Foundation
import XCTest

class AstarTests: XCTestCase {
    func testHappyPath() {
        let graph = Graph(width: 3, height: 3)
        var algo = AStar(graph: graph, start: (0, 0), goal: (1, 1))
        var path = algo.run()
        for node in path {
            println("\(node.x), \(node.y)")
        }
        var expectedNodes = [Node(x: 0, y: 0), Node(x: 0, y: 1), Node(x: 1, y: 1)] // this is arbitrary on how we determine tie breaks
        XCTAssertEqual(expectedNodes, path, "the algorithm should return these nodes")
    }
}