// Part of the View. Put animations and things that interact with the screen here


import SpriteKit

class GameScene: SKScene {
    var level: Level!
    var heroColumn: Int!
    var heroRow: Int!
    // var hero: Hero!
    // var hero: SKSpriteNode! = SKSpriteNode(imageNamed: "hero_front_00")
    
    var initialCell: (Int, Int)?
    var endCell: (Int, Int)?
    var initialPoint: CGPoint?
    var endPoint: CGPoint?
    // var selectedGoal: (Int, Int)?
    
    let TileWidth: CGFloat = 40.5 // 4.5 * 8. original was 32
    let TileHeight: CGFloat = 40.5 // 4.5 * 9. original was 36
    var selectedCell: SKSpriteNode! = SKSpriteNode(color: UIColor.greenColor(), size: CGSize(width: 40.5, height: 40.5))
    
    let gameLayer = SKNode()
    let tilesLayer = SKNode()
    let playerLayer = SKNode()
    
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
        // hero.position = CGPoint(x: 0, y: 0)
        // hero.zPosition = 100
//        hero.xScale = 0.4 * 0.7
//        hero.yScale = 0.5 * 0.7
        // playerLayer.addChild(hero)
        selectedCell.alpha = 0.3
        selectedCell.zPosition = 90
        playerLayer.addChild(selectedCell)
    }
    
    override func didMoveToView(view: SKView) {
        println("Moved to gamescene view")
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
                    // tileNode.xScale = 1.125 // this changes the size of the image? Or does it change the model? should only be image
                    tileNode.size = CGSize(width: TileWidth, height: TileHeight)
                    // tileNode.yScale = 1.125
                    tilesLayer.addChild(tileNode)
                }
            }
        }
    }
    
    func addSpritesForObstacles() {
        let obstacles = level.getObstacles()
        for obstacle in obstacles {
            let sprite = SKSpriteNode(imageNamed: obstacle.obstacleType.spriteName)
            sprite.position = pointForColumn(obstacle.column, row: obstacle.row)
            if obstacle.obstacleType != ObstacleType.Hero {
                sprite.size = CGSize(width: TileWidth, height: TileHeight)
            }
            sprite.zPosition = 100
            playerLayer.addChild(sprite)
            obstacle.sprite = sprite
        }
    }
    
//    func addHero() {
//        // currently is adding hero and adding selected cell
//        let start = level.getStartPosition()!
//        heroColumn = start.0
//        heroRow = start.1
//        var startPosition = pointForColumn(start.0, row: start.1)
//        hero.position = startPosition
//        selectedCell.position = startPosition
//        println("Starting position \(level.getStartPosition())")
//    }
    
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
        hero.column = goal.0
        hero.row = goal.1
        hero.sprite?.runAction(SKAction.sequence(actions), completion: {
                self.userInteractionEnabled = true
                println("Set userInteractionEnabled to true")})
    }
    
    func moveSelected(column: Int, row: Int) {
        selectedCell.position = pointForColumn(column, row: row)
    }
    
//    func animateWalkOne(goal: Node) {
//        let goalPosition = pointForColumn(goal.x, row: goal.y)
//        let move = SKAction.moveTo(goalPosition, duration: 0.3)
//        // move.timingMode = .Linear
//        hero.runAction(move)
//    }
    
//    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
//    }
    
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
                    moveSelected(column, row: row)
                    moveHero(column, row: row)
                }
            }
        }
    }
    
    func flip() {
        let direction = CGVector(dx: endPoint!.x - initialPoint!.x, dy: endPoint!.y - initialPoint!.y)
        let angle = atan2(direction.dy, direction.dx)
        var deg = Double(angle * CGFloat(180.0 / M_PI))
        let delta: Double = 45.0/2 // each direction is 45 degrees. Give additional half of that as margin for error
        if (deg >= 0) {
            // we are flipping up
            if (0.0 + delta > deg) {
                println("right")
            } else if (45.0 + delta >= deg && deg >= 45 - delta) {
                println("up-right")
            } else if (90 + delta > deg && deg > 90 - delta) {
                println("up")
            } else if (135 + delta >= deg && deg >= 135 - delta) {
                println("up-left")
            } else if (180 >= deg && deg > 180 - delta) {
                println("left")
            } else {
                println("Did not expect to get here: \(deg)")
            }
        } else {
            let absDeg: Double = abs(deg)
            // we are going down
            if (0.0 + delta > absDeg) {
                println("right")
            } else if (45.0 + delta >= absDeg && absDeg >= 45 - delta) {
                println("down-right")
            } else if (90 + delta > absDeg && absDeg > 90 - delta) {
                println("down")
            } else if (135 + delta >= absDeg && absDeg >= 135 - delta) {
                println("down-left")
            } else if (180 >= absDeg && absDeg > 180 - delta) {
                println("left")
            } else {
                println("Did not expect to get here: \(deg)")
            }
        }
        
        println("Degrees: \(deg)")
        return
    }
    
    func flipHorizontal() {
        // for obstacle in obstacle:
        // if obstacle above line, flip below + 2x distance from middle line
        // if obstacle below line, flip up
        return
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
        
    
//
//    override func touchesCancelled(touches: NSSet, withEvent event: UIEvent) {
//        touchesEnded(touches, withEvent: event)
//    }
}
