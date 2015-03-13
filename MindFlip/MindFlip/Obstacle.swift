//
//  Obstacle.swift
//  MindFlip
//
//  Created by Alan Liang on 2/19/15.
//  Copyright (c) 2015 fsa. All rights reserved.
//

import SpriteKit

struct PhysicsCategory {
    static let None: UInt32 = 0
    static let All: UInt32 = UInt32.max
    static let Hero: UInt32 = 0b1
    static let Block: UInt32 = 0b10
    static let Collectable: UInt32 = 0b11
}

enum ObstacleType: Int, Printable {
    case Unknown = 0, Hero, Block, DestCell, Collectable
    // we are keeping a lot of sprite information here, but maybe it should be
    // in the actual class. What is correct separation of model and view?
    var spriteName: String {
        let spriteNames = ["hero_front_00", "block", "selected_cell", "collectable"]
        return spriteNames[rawValue - 1]
    }
    var physicsCategory: UInt32 {
        let physicsCategory = [PhysicsCategory.Hero, PhysicsCategory.None, PhysicsCategory.None, PhysicsCategory.Collectable]
        return physicsCategory[rawValue - 1]
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
    
    func setSpriteCollision() {
        // override
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
    
    override func setSpriteCollision() {
        // assume sprite is set by this point
        self.sprite!.physicsBody = SKPhysicsBody(rectangleOfSize: self.sprite!.size)
        obstacleType.physicsCategory
        self.sprite!.physicsBody?.dynamic = true
        self.sprite!.physicsBody?.categoryBitMask = PhysicsCategory.Hero
        self.sprite!.physicsBody?.contactTestBitMask = PhysicsCategory.Collectable
        self.sprite!.physicsBody?.collisionBitMask = PhysicsCategory.None
        self.sprite!.physicsBody?.usesPreciseCollisionDetection = true
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

class Collectable: GameObj {
    init(column: Int, row: Int) {
        super.init(column: column, row: row, obstacleType: ObstacleType.Collectable)
        self.walkable = true
        self.flippable = false
    }
    
    override func setSpriteCollision() {
        // assume sprite is set by this point
        self.sprite!.physicsBody = SKPhysicsBody(rectangleOfSize: self.sprite!.size)
            obstacleType.physicsCategory
        self.sprite!.physicsBody?.dynamic = true
        self.sprite!.physicsBody?.categoryBitMask = PhysicsCategory.Collectable
        self.sprite!.physicsBody?.contactTestBitMask = PhysicsCategory.Hero
        self.sprite!.physicsBody?.collisionBitMask = PhysicsCategory.None
        self.sprite!.physicsBody?.usesPreciseCollisionDetection = true
    }
}
