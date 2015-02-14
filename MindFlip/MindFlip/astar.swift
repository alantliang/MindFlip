//
//  astar.swift
//  MindFlip
//
//  Created by Alan Liang on 2/10/15.
//  Copyright (c) 2015 fsa. All rights reserved.
//

import Foundation

public class Node: Hashable {
    // the x and y values will not change after a node is initialized
    let x, y: Int
    var neighbors: [Node] = []
    var walkable = true
    
    public var hashValue : Int {
        get {
            return "\(self.x),\(self.y)".hashValue
        }
    }
    
    init(x: Int, y: Int) {
        self.x = x
        self.y = y
    }
    
    public func connect(nodes: [Node]) {
        neighbors.extend(nodes)
    }
    
}

public func ==(lhs: Node, rhs: Node) -> Bool {
    return lhs.hashValue == rhs.hashValue
}

public class Graph {
    var nodes: [Node] = []
    var width: Int
    var height: Int
    
    init(width: Int, height: Int) {
        self.width = width
        self.height = height
        createNodes()
        connectNodes()
    }
    
    private func createNodes() {
        for x in Range(start: 0, end: width) {
            for y in Range(start: 0, end: height) {
                nodes.append(Node(x: x, y: y))
            }
        }
    }
    
    private func connectNodes() {
        // Connects nodes to all neighbors. We want to connect the bottom node to the top node and the left node to the right most node like in pacman
        for node in nodes {
            let upNode = getNode(node.x, y: node.y + 1)
            let rightNode = getNode(node.x + 1, y: node.y)
            let leftNode = getNode(node.x - 1, y: node.y)
            let downNode = getNode(node.x, y: node.y - 1)
            // filter on walkable nodes
            node.connect([upNode, rightNode, leftNode, downNode])
        }
    }
    
    private func getNode(x: Int, y: Int) -> Node {
        // returns node at a given x, y coordinate
        var foundNode: Node!
        for node in nodes {
            if node.x == x && node.y == y {
                foundNode = node
                break
            }
        }
        return foundNode!
    }
}

public class Astar {
//    A star algorithm with help from wikipedia.
//    
//    graph - Graph object that contains our nodes with neighbors
//    start - name (str) of a node that we are starting at
//    goal - name (str) of the node that we want to reach
//    
//    WARNING: We use the name of the nodes as immutable indexes for dictionaries.
    
    var graph: Graph
    let start: (Int, Int)
    let goal: (Int, Int)
    var closedSet: [Node]
    var openSet: [Node]
    var cameFrom: Dictionary<Node, String>
    var costFromStart: Dictionary<Node, Int>
    var heuristicCostFromStart: Dictionary<Node, Int>
    
    init(graph: Graph, start: (Int, Int), goal: (Int, Int)) {
        self.graph = graph
        self.start = start
        self.goal = goal
        closedSet = [graph.getNode(start.0, y: start.1)]
        openSet = []
        cameFrom = Dictionary<Node, String>()
        costFromStart = Dictionary<Node, Int>()
        heuristicCostFromStart = Dictionary<Node, Int>()
    }
    
    
}