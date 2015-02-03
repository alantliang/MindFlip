import SpriteKit

class GameScene: SKScene {
    var level: Level!
    var selectedColumn: Int?
    var selectedRow: Int?
    var hero: SKSpriteNode! = SKSpriteNode(imageNamed: "person_00")
    
    let TileWidth: CGFloat = 36.0 // 4.5 * 8. original was 32
    let TileHeight: CGFloat = 40.5 // 4.5 * 9. original was 36
    
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
        
        let layerPosition = CGPoint(
            x: -TileWidth * CGFloat(NumColumns) / 2,
            y: -TileHeight * CGFloat(NumRows) / 2)
        
        tilesLayer.position = layerPosition
        gameLayer.addChild(tilesLayer)
        selectedColumn = nil
        selectedRow = nil
        hero.position = CGPoint(x: 0, y: 0)
        hero.xScale = 0.4 * 0.7
        hero.yScale = 0.5 * 0.7
        gameLayer.addChild(hero)
        animateWalkDown()
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
                    tileNode.xScale = 1.125 // this changes the size of the image? Or does it change the model? should only be image
                    tileNode.yScale = 1.125
                    tilesLayer.addChild(tileNode)
                }
            }
        }
    }
    
//    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
//    }
    
    func animateWalkDown()
    {
        // how does this know to animate hero? Because of the name?
        let hero_down_anim = SKAction.animateWithTextures([
            SKTexture(imageNamed: "hero_01"),
            SKTexture(imageNamed: "hero_02")
            ], timePerFrame: 0.4)
        
        let run = SKAction.repeatActionForever(hero_down_anim)
        hero.runAction(run, withKey: "running")
    }
    
    override func touchesEnded(touches: NSSet, withEvent event: UIEvent) {
        let touch = touches.anyObject() as UITouch
        let location = touch.locationInNode(tilesLayer)
        let (success, column, row) = convertPoint(location)
        if success {
            selectedColumn = column
            selectedRow = row
            println("Column: \(selectedColumn), Row: \(selectedRow)")
        }
    }
//
//    override func touchesCancelled(touches: NSSet, withEvent event: UIEvent) {
//        touchesEnded(touches, withEvent: event)
//    }
}