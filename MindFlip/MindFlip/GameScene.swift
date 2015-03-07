// Part of the View. Put animations and things that interact with the screen here


import SpriteKit

class GameScene: SKScene {
    var level: Level!
    
    var initialCell: (Int, Int)?
    var endCell: (Int, Int)?
    var initialPoint: CGPoint?
    var endPoint: CGPoint?
    
    let TileWidth: CGFloat = 40.5 // 4.5 * 8. original was 32
    let TileHeight: CGFloat = 40.5 // 4.5 * 9. original was 36
    
    let gameLayer = SKNode()
    let tilesLayer = SKNode()
    let playerLayer = SKNode()
    
    let randomSounds = ["Ryu_Shinkuu_Tatsumaki_Sound_Effect.mp3",
        "Ryu_Hadouken_Sound_Effect.mp3",
        "Ryu_Shoryuken_Sound_Effect.mp3",
        "Ryu_Tatsumaki_Senpuu_Kyaku_Sound_Effect.mp3",
        "Ryu_Shoryuken_Sound_FX.mp3"
    ]
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder) is not used in this app")
    }
    
    override init(size: CGSize) {
        super.init(size: size)
        
        anchorPoint = CGPoint(x: 0.5, y: 0.5)
        
        let background = SKSpriteNode(imageNamed: "Background")
        addChild(background)
        
        addChild(gameLayer)
        
        let layerPosition = CGPoint(
            x: -TileWidth * CGFloat(NumColumns) / 2,
            y: -TileHeight * CGFloat(NumRows) / 2)
        
        tilesLayer.position = layerPosition
        gameLayer.addChild(tilesLayer)
        playerLayer.position = layerPosition
        gameLayer.addChild(playerLayer)
    }
    
    override func didMoveToView(view: SKView) {
        println("Moved to gamescene view")
        // currently add destCell here. Think of a better way
        addSpriteForDestCell()
    }
    
    func pointForColumn(column: Int, row: Int) -> CGPoint {
        return CGPoint(
            x: CGFloat(column)*TileWidth + TileWidth/2,
            y: CGFloat(row)*TileHeight + TileHeight/2)
    }
    
    func convertPoint(point: CGPoint) -> (success: Bool, column: Int, row: Int) {
        if point.x >= 0 && point.x < CGFloat(NumColumns)*TileWidth &&
            point.y >= 0 && point.y < CGFloat(NumRows)*TileHeight {
                return (true, Int(point.x / TileWidth), Int(point.y / TileHeight))
        } else {
            return (false, 0, 0)  // invalid location
        }
    }
    
    func addTiles() {
        for row in 0..<NumRows {
            for column in 0..<NumColumns {
                if let tile = level.tileAtColumn(column, row: row) {
                    let tileNode = SKSpriteNode(imageNamed: "Tile")
                    tileNode.position = pointForColumn(column, row: row)
                    tileNode.size = CGSize(width: TileWidth, height: TileHeight)
                    tilesLayer.addChild(tileNode)
                }
            }
        }
    }
    
    func addSpritesForObstacles() {
        let objs: [GameObj] = level.getAllObjs()
        for obstacle in objs {
            if obstacle.obstacleType == ObstacleType.DestCell {
                continue
            }
            let sprite = SKSpriteNode(imageNamed: obstacle.obstacleType.spriteName)
            sprite.position = pointForColumn(obstacle.column, row: obstacle.row)
            println("\(obstacle.column), \(obstacle.row)")
            if obstacle.obstacleType != ObstacleType.Hero {
                sprite.size = CGSize(width: TileWidth, height: TileHeight)
            }
            sprite.zPosition = 100
            playerLayer.addChild(sprite)
            obstacle.sprite = sprite
        }
    }
    
    func addSpriteForDestCell() {
        var destCell: DestCell = level.getDestCell()
        var sprite: SKSpriteNode = SKSpriteNode(color: UIColor.greenColor(), size: CGSize(width: TileWidth, height: TileHeight))
        sprite.alpha = 0.3
        sprite.zPosition = 90
        sprite.position = pointForColumn(destCell.column, row: destCell.row)
        playerLayer.addChild(sprite)
        destCell.sprite = sprite
    }
    
    func moveSpriteForDestCell(column: Int, row: Int) {
        var destCell: DestCell = level.getDestCell()
        destCell.sprite!.position = pointForColumn(column, row: row)
    }
    
    func moveHero(column: Int, row: Int) {
        // currently is managing the model and the view. Need to split up the jobs
        let hero = level.getHero()
        let start = hero.getCoords()
        let goal = (column, row)
        // first we should check if a path even exists
        let bestPath = AStar(graph: level.getGraph(), start: start, goal: goal).run()
        
        
        var actions: [SKAction] = []
        var prevColumn = hero.column
        var prevRow = hero.row
        for (index, node) in enumerate(bestPath) {
            if index == 0 {
                continue
            }
            // move one space
            var groupActions: [SKAction] = []
            let goalPosition = pointForColumn(node.x, row: node.y)
            if let walkDirection = getWalk((prevColumn, prevRow), end: (node.x, node.y)) {
                groupActions.append(walkDirection)
            }
            let move = SKAction.moveTo(goalPosition, duration: 0.3)
            // move.timingMode = .EaseOut
            groupActions.append(move)
            actions.append(SKAction.group(groupActions))
            prevColumn = node.x
            prevRow = node.y
        }
        level.moveHero(goal.0, row: goal.1)
        hero.sprite?.runAction(SKAction.sequence(actions), completion: {
            self.userInteractionEnabled = true
            println("Set userInteractionEnabled to true")})
    }
    
    func getWalk(start: (Int, Int), end: (Int, Int)) -> SKAction? {
        var action: SKAction?
        if end.0 > start.0 {
            action = getAnimateWalk("RIGHT")
        } else if end.1 > start.1 {
            action = getAnimateWalk("UP")
        } else if end.0 < start.0 {
            action = getAnimateWalk("LEFT")
        } else if end.1 < start.1 {
            action = getAnimateWalk("DOWN")
        } else {
            // hero.removeActionForKey("running")
        }
        return action
    }
    
    func getAnimateWalk(direction: String) -> SKAction {
        // how does this know to animate hero? Because of the name?
        let heroDownAnim = SKAction.animateWithTextures([
            SKTexture(imageNamed: "hero_front_01"),
            SKTexture(imageNamed: "hero_front_02")
            ], timePerFrame: 0.15)
        
        let heroRightAnim = SKAction.animateWithTextures([
            SKTexture(imageNamed: "hero_right_01"),
            SKTexture(imageNamed: "hero_right_02")
            ], timePerFrame: 0.15)
        
        let heroLeftAnim = SKAction.animateWithTextures([
            SKTexture(imageNamed: "hero_left_01"),
            SKTexture(imageNamed: "hero_left_02")
            ], timePerFrame: 0.15)
        
        let heroUpAnim = SKAction.animateWithTextures([
            SKTexture(imageNamed: "hero_back_01"),
            SKTexture(imageNamed: "hero_back_02")
            ], timePerFrame: 0.15)
        
        var currentAnim: SKAction?
        switch direction {
        case "DOWN":
            currentAnim = heroDownAnim
        case "RIGHT":
            currentAnim = heroRightAnim
        case "LEFT":
            currentAnim = heroLeftAnim
        case "UP":
            currentAnim = heroUpAnim
        default:
            println("\(direction) is not handled")
        }
        
        return SKAction.repeatAction(currentAnim!, count: 1)
    }
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        let touch = touches.anyObject() as UITouch
        let location = touch.locationInNode(tilesLayer)
        println("Touched: \(location.x), \(location.y)")
        initialPoint = location
        let (success, column, row) = convertPoint(location)
        if success {
            // Later can handle if initial touch is not in tilesLayer
            initialCell = (column, row)
        }
    }
    
    override func touchesEnded(touches: NSSet, withEvent event: UIEvent) {
        let touch = touches.anyObject() as UITouch
        let location = touch.locationInNode(tilesLayer)
        endPoint = location
        let (success, column, row) = convertPoint(location)
        if success {
            endCell = (column, row)
            if isSwipe() {
                flip()
            } else if isMove(column, row: row) {
                if level.isWalkable(column, row: row) && isAStar() {
                    self.userInteractionEnabled = false
                    println("Set userInteractionEnabled to false")
                    moveDest(column, row: row)
                    moveHero(column, row: row)
                }
            }
        }
    }
    
    func moveDest(column: Int, row: Int) {
        level.moveDestCell(column, row: row)
        moveSpriteForDestCell(column, row: row)
    }
    
    func flip() {
        let direction = CGVector(dx: endPoint!.x - initialPoint!.x, dy: endPoint!.y - initialPoint!.y)
        let angle = atan2(direction.dy, direction.dx)
        var deg = Double(angle * CGFloat(180.0 / M_PI))
        // each direction is 45 degrees. Give additional half of that as margin for error
        let delta: Double = 45.0/2
        if (deg >= 0) {
            // we are flipping up
            if (0.0 + delta > deg) {
                println("right")
                flipRight()
            } else if (45.0 + delta >= deg && deg >= 45 - delta) {
                println("up-right")
                flipUpRight()
            } else if (90 + delta > deg && deg > 90 - delta) {
                println("up")
                flipUp()
            } else if (135 + delta >= deg && deg >= 135 - delta) {
                println("up-left")
                flipUpLeft()
            } else if (180 >= deg && deg > 180 - delta) {
                println("left")
                flipRight()
            } else {
                println("Did not expect to get here: \(deg)")
            }
        } else {
            let absDeg: Double = abs(deg)
            // we are going down
            if (0.0 + delta > absDeg) {
                println("right")
                flipRight()
            } else if (45.0 + delta >= absDeg && absDeg >= 45 - delta) {
                println("down-right")
                flipUpLeft()
            } else if (90 + delta > absDeg && absDeg > 90 - delta) {
                println("down")
                flipUp()
            } else if (135 + delta >= absDeg && absDeg >= 135 - delta) {
                println("down-left")
                flipUpRight()
            } else if (180 >= absDeg && absDeg > 180 - delta) {
                println("left")
                flipRight()
            } else {
                println("Did not expect to get here: \(deg)")
            }
        }
        return
    }
    
    func flipUp() {
        println("Flip up")
        self.userInteractionEnabled = false
        level.flipUp()
        animateObstacleMoves(enableTouch)
        playFlipSound()
    }
    
    func flipRight() {
        println("Flip right")
        self.userInteractionEnabled = false
        level.flipRight()
        animateObstacleMoves(enableTouch)
        playFlipSound()
    }
    
    func flipUpRight() {
        println("Flip up right")
        self.userInteractionEnabled = false
        level.flipUpRight()
        animateObstacleMoves(enableTouch)
        playFlipSound()
    }
    
    func flipUpLeft() {
        println("Flip up left")
        self.userInteractionEnabled = false
        level.flipUpLeft()
        animateObstacleMoves(enableTouch)
        playFlipSound()
    }
    
    func playFlipSound() {
        let range: UInt32 = UInt32(randomSounds.count)
        let index: Int = Int(arc4random_uniform(range))
        let soundFile = randomSounds[index]
        let flipSound = SKAction.playSoundFileNamed(soundFile, waitForCompletion: false)
        runAction(flipSound)
    }
    
    func animateObstacleMoves(completion: () -> ()) {
        // var groupActions: [SKAction] = []
        let cells = level.getCells()
        for x in Range(start:0, end: NumColumns) {
            for y in Range(start: 0, end: NumRows) { // if we put this in a set, less interation
                if let cell = cells[x, y]? {
                    for obj in cell.gameObjects {
                        let goalPosition = pointForColumn(obj.column, row: obj.row)
                        let move = SKAction.moveTo(goalPosition, duration: 0.3)
                        move.timingMode = .EaseOut
                        obj.sprite!.runAction(move)
                    }
                }
            }
        }
        runAction(SKAction.waitForDuration(0.31), completion: completion)
    }
    
    func enableTouch() {
        println("Enabling touch & reset graph")
        level.resetGraph()
        self.userInteractionEnabled = true
    }
    
    func isSwipe() -> Bool {
        // this assumes a swipe happens always inside the tilelayer currently
        return !(endCell?.0 == initialCell?.0 && endCell?.1 == initialCell?.1)
    }
    
    func isAStar() -> Bool {
        return true
    }
    
    func isMove(column: Int, row: Int) -> Bool {
        let hero = level.getHero()
        return ((column == initialCell?.0) && (row == initialCell?.1) &&
            !((column == hero.column) && (row == hero.row)))
    }

    
    override func touchesCancelled(touches: NSSet, withEvent event: UIEvent) {
        touchesEnded(touches, withEvent: event)
    }
}
