//
//  Obstacle.swift
//  MindFlip
//
//  Created by Alan Liang on 2/19/15.
//  Copyright (c) 2015 fsa. All rights reserved.
//

import SpriteKit

enum ObstacleType: Int, Printable {
    case Unknown = 0, Hero, Block, DestCell
    var spriteName: String {
        let spriteNames = ["hero_front_00", "block", "selected_cell"]
        
        return spriteNames[rawValue - 1]
    }
    var highlightedSpriteName: String {
        return spriteName + "-Highlighted"
    }
    var description: String {
        return spriteName
    }
}

class GameObj: Printable, Hashable {
    var column: Int
    var row: Int
    var obstacleType: ObstacleType
    var sprite: SKSpriteNode?
    var walkable: Bool = true
    var flippable: Bool = true
    var description: String {
        return "type: \(obstacleType) square (\(column), \(row)"
    }
    var hashValue: Int {
        return row * 10 + column
    }

    init(column: Int, row: Int, obstacleType: ObstacleType) {
        self.column = column
        self.row = row
        self.obstacleType = obstacleType
    }
    
    func getCoords() -> (Int, Int) {
        return (column, row)
    }
}

func ==(lhs: GameObj, rhs: GameObj) -> Bool {
    return lhs.column == rhs.column && lhs.row == rhs.row
}

class Block: GameObj {
    init(column: Int, row: Int) {
        super.init(column: column, row: row, obstacleType: ObstacleType.Block)
        self.walkable = false
        self.flippable = true
    }
}

class Hero: GameObj {
    init(column: Int, row: Int) {
        super.init(column: column, row: row, obstacleType: ObstacleType.Hero)
        self.walkable = true
        self.flippable = false
    }
}

class DestCell: GameObj {
    // cell to just see where the destination is
    init(column: Int, row: Int) {
        super.init(column: column, row: row, obstacleType: ObstacleType.DestCell)
        self.walkable = true
        self.flippable = false
    }
}
