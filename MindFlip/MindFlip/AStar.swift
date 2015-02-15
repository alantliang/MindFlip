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
    
    public func getCost(start: Node, end: Node) -> Int {
        return abs(start.x - end.x) + abs(start.y - end.y)
    }
    
    public func heuristicCostEstimate(start: Node, end: Node) -> Double {
        return sqrt((Double(start.x) - Double(end.x))**2 + (Double(start.y) - Double(end.y))**2)
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
        var foundNode: Node! // Is this the correct usage of forced unwrapping?
        var my_x = mod(x, self.width)  // allows character to move to the other side of the screen
        var my_y = mod(y, self.height)
        for node in nodes {
            if node.x == my_x && node.y == my_y {
                foundNode = node
                break
            }
        }
        return foundNode
    }
}

public class AStar {
//    A star algorithm with help from wikipedia.
//    
//    graph - Graph object that contains our nodes with neighbors
//    start - name (str) of a node that we are starting at
//    goal - name (str) of the node that we want to reach
    
    var graph: Graph
    var start: Node
    var goal: Node
    var closedSet: [Node] = [] // do we need sets instead of lists?
    var openSet: [Node] = []
    var cameFrom = Dictionary<Node, Node>()
    var costFromStart = Dictionary<Node, Int>()
    var heuristicCostFromStart = Dictionary<Node, Double>()
    
    init(graph: Graph, start: (Int, Int), goal: (Int, Int)) {
        self.graph = graph
        self.start = graph.getNode(start.0, y: start.1)
        self.goal = graph.getNode(goal.0, y: goal.1)
        openSet.append(self.start)
        costFromStart[self.start] = 0
        heuristicCostFromStart[self.start] = getHeuristicCostEstimate(self.start, goal: self.goal)
    }
    
    func run() -> [Node] {
        while openSet.count > 0 {
            var currentNode: Node = getMinHeuristicCostFromStartNode()
            if currentNode == goal {
                return reconstructPath()
            } else {
                // the happy path while the algo is running
                let index: Int = find(openSet, currentNode)!
                openSet.removeAtIndex(index)
                closedSet.append(currentNode)
                for neighbor in currentNode.neighbors {
                    if contains(closedSet, neighbor) {
                        continue
                    } else {
                        var cost = costFromStart[currentNode]! + graph.getCost(currentNode, end: neighbor)
                        if find(openSet, neighbor) == nil || cost < costFromStart[neighbor] {
                            cameFrom[neighbor] = currentNode
                            costFromStart[neighbor] = cost
                            heuristicCostFromStart[neighbor] = getHeuristicCostEstimate(neighbor, goal: goal)
                            if find(openSet, neighbor) == nil {
                                openSet.append(neighbor)
                            }
                        }
                    }
                }
            }
        }
        return []  // this is actually an error. How do we represent this? With optionals?
    }
    
    func getMinHeuristicCostFromStartNode() -> Node {
        var minHeuristicCost: Double = 99999.0  // arbitrary high number
        var returnNode: Node!
        
        for node in openSet {
            if heuristicCostFromStart[node] < minHeuristicCost {
                minHeuristicCost = heuristicCostFromStart[node]!
                returnNode = node
            }
        }
        return returnNode
    }
    
    func getHeuristicCostEstimate(start: Node, goal: Node) -> Double {
        return Double(costFromStart[start]!) + graph.heuristicCostEstimate(start, end: goal)
    }
    
    func reconstructPath() -> [Node] {
        var current: Node = goal
        var totalPath: [Node] = [current]
        while find(cameFrom.keys, current) != nil {
            current = cameFrom[current]!
            totalPath.append(current)
        }
        totalPath = totalPath.reverse()
        return totalPath
    }
}
