//
//  GameScene.swift
//  MindFlip
//
//  Created by Alan Liang on 1/28/15.
//  Copyright (c) 2015 fsa. All rights reserved.
//

import SpriteKit

class GameScene: SKScene {
    var TileWidth: CGFloat = 32.0
    let TileHeight: CGFloat = 36.0
    
    let gameLayer = SKNode()
    let tilesLayer = SKNode()
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder) is not used in this app")
    }
    
    override init(size: CGSize) {
        super.init(size: size)
        
        anchorPoint = CGPoint(x: 0.5, y: 0.5)
        
        let background = SKSpriteNode(imageNamed: "Background")
        addChild(background)
        
        addChild(gameLayer)
        gameLayer.hidden = true
        
        let layerPosition = CGPoint(
            x: -TileWidth * CGFloat(NumColumns) / 2,
            y: -TileHeight * CGFloat(NumRows) / 2)
        tilesLayer.position = layerPosition
        gameLayer.addChild(tilesLayer)
    }
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        // do nothing right now
    }
   
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
    }
    
    func addTiles() {
        for row in 0..<NumRows {
            for column in 0..<NumColumns {
                if let tile = level.tileAtColumn(column, row: row) {
                    let tileNode = SKSpriteNode(imageNamed: "Tile")
                    tileNode.position = pointForColumn(column, row: row)
                    tilesLayer.addChild(tileNode)
                }
            }
        }
    }
}
