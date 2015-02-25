import SpriteKit

class GameScene: SKScene {
    var level: Level!
    var heroColumn: Int!
    var heroRow: Int!
    var hero: SKSpriteNode! = SKSpriteNode(imageNamed: "hero_front_00")
    
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
        hero.position = CGPoint(x: 0, y: 0)
        hero.zPosition = 100
//        hero.xScale = 0.4 * 0.7
//        hero.yScale = 0.5 * 0.7
        playerLayer.addChild(hero)
        selectedCell.alpha = 0.3
        selectedCell.zPosition = 90
        playerLayer.addChild(selectedCell)
    }
    
    override func didMoveToView(view: SKView) {
        println("Moved to gamescene view")
    }
    
    func addSpritesForObstacles(obstacles: Set<Obstacle>) {
        for obstacle in obstacles {
            let sprite = SKSpriteNode(imageNamed: obstacle.obstacleType.spriteName)
            sprite.position = pointForColumn(obstacle.column, row: obstacle.row)
            sprite.size = CGSize(width: TileWidth, height: TileHeight)
            playerLayer.addChild(sprite)
            obstacle.sprite = sprite
        }
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
    
    func addHero() {
        // currently is adding hero and adding selected cell
        let start = level.getStartPosition()!
        heroColumn = start.0
        heroRow = start.1
        var startPosition = pointForColumn(start.0, row: start.1)
        hero.position = startPosition
        selectedCell.position = startPosition
        println("Starting position \(level.getStartPosition())")
    }
    
    func moveHero(column: Int, row: Int) {
        let (success, startColumn, startRow) = convertPoint(hero.position)
        if success {
            let start = (startColumn, startRow)
            let goal = (column, row)
            let bestPath = AStar(graph: level.getGraph(), start: start, goal: goal).run()
            var actions: [SKAction] = []
            var prevColumn = heroColumn
            var prevRow = heroRow
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
            heroColumn = goal.0
            heroRow = goal.1
            hero.runAction(SKAction.sequence(actions), completion: {
                    self.userInteractionEnabled = true
                    println("Set userInteractionEnabled to true")})
        }
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
    
    func drawCustomImage(size: CGSize) -> UIImage {
        // Draw images in swift
        // Setup our ocntext here
        let bounds = CGRect(origin: CGPoint.zeroPoint, size: size)
        let opaque = false
        let scale: CGFloat = 0
        UIGraphicsBeginImageContextWithOptions(size, opaque, scale)
        let context = UIGraphicsGetCurrentContext()
        
        // Setup complete, do drawing here
        CGContextSetStrokeColorWithColor(context, UIColor.redColor().CGColor)
        CGContextSetLineWidth(context, 2.0)
        
        CGContextStrokeRect(context, bounds)
        
        CGContextBeginPath(context)
        CGContextMoveToPoint(context, CGRectGetMinX(bounds), CGRectGetMinY(bounds))
        CGContextAddLineToPoint(context, CGRectGetMaxX(bounds), CGRectGetMaxY(bounds))
        CGContextMoveToPoint(context, CGRectGetMaxX(bounds), CGRectGetMinY(bounds))
        CGContextAddLineToPoint(context, CGRectGetMinX(bounds), CGRectGetMaxY(bounds))
        CGContextStrokePath(context)
        
        // Drawing complete, retrieve the finished image and cleanup
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
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
                    moveSelected(column, row: row)
                    moveHero(column, row: row)
                }
            }

            // println("Column: \(selectedColumn), Row: \(selectedRow)")

            
            // selectedColumn = column
            // selectedRow = row
//            hero.removeActionForKey("running")
//            hero.texture = SKTexture(imageNamed: "hero_00")
        }
    }
    
    func flip() {
        println("Flip baby")
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
        return (column == initialCell?.0) && (row == initialCell?.1) && !((column == heroColumn) && (row == heroRow))
    }
        
    
//
//    override func touchesCancelled(touches: NSSet, withEvent event: UIEvent) {
//        touchesEnded(touches, withEvent: event)
//    }
}
