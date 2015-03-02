// Contains Model information about our level
// obstacles Currently contains the state of all our objects including the hero and all obstacles he/she will face.

import Foundation

let NumColumns = 8
let NumRows = 8

class Level {
    private var tiles = Array2D<Tile>(columns: NumColumns, rows: NumRows)
    private var obstacles = Array2D<Obstacle>(columns: NumColumns, rows: NumRows) // might want a different data structures to access all obstacles. Make separate class? that has a list?
    private var obstaclesSet = Set<Obstacle>()
    private var hero: Hero!
    private var destCell: DestCell!
    private var graph: Graph!
    private var startPosition: (Int, Int)!
    
    init(filename: String) {
        if let dictionary = Dictionary<String, AnyObject>.loadJSONFromBundle(filename) {
            if let tilesArray: AnyObject = dictionary["tiles"] {
                setupTiles(tilesArray)
            }
            if let blocksArray: AnyObject = dictionary["obstacles"] {
                setupObstacles(blocksArray)
            }
            if let startList: AnyObject = dictionary["starting"] {
                println("Startlist exists")
                let startList = startList as [Int]
                startPosition = (startList[0], startList[1])
                hero = Hero(column: startList[0], row: startList[1])
                // need to allow for multiple objects on same cell
                // for now just add destCell manually
                destCell = DestCell(column: startList[0], row: startList[1])
                obstacles[startList[0], startList[1]] = hero
                obstaclesSet.addElement(hero) // why do we use obstaclesSet? faster lookup?
            }
        }
        setupGraph(getWalkable())
    }
    
    func isWalkable(column: Int, row: Int) -> Bool {
        return graph.getNode(column, y: row).walkable
    }
    
    func moveDestCell(column: Int, row: Int) {
        destCell.column = column
        destCell.row = row
    }
    
    func flipHorizontal() {
        println("level.flipHorizontal")
        // for obstacle in obstacles, if flippable, flip over the middle line
        // assume we have an even number of lines
        let horizontal: Int = NumRows/2
        let maxRowIndex: Int = NumRows - 1
        // flip bottom half
        var newObstacles = Array2D<Obstacle>(columns: NumColumns, rows: NumRows)
        for y in Range(start: 0, end: NumRows) {
            for x in Range(start: 0, end: NumColumns) {
                if var currentObstacle: Obstacle = obstacles[x, y] {
                    if currentObstacle.flippable {
                        // flip over horizontal axis
                        let flipy = maxRowIndex - y
                        currentObstacle.column = x
                        currentObstacle.row = flipy
                        newObstacles[x, flipy] = currentObstacle
                    } else {
                        // will run into some problems if reflecting onto the hero
                        newObstacles[x, y] = currentObstacle
                    }
                }
            }
        }
        obstacles = newObstacles
    }
    
    func getHero() -> Hero {
        return hero
    }
    
    func getGraph() -> Graph {
        return graph
    }
    
    func getObstaclesSet() -> Set<Obstacle> {
        return obstaclesSet
    }
    
    func getObstacles() -> Array2D<Obstacle> {
        return obstacles
    }
    
    func getStartPosition() -> (Int, Int)? {
        return startPosition
    }
    
    func getDestCell() -> DestCell {
        return destCell
    }
    
    func getWalkable() -> Array2D<Int> {
        // assuming height and width are same for both
        var walkable = Array2D<Int>(columns: NumColumns, rows: NumRows)
        for y in Range(start: 0, end: NumRows - 1) {
            for x in Range(start: 0, end: NumColumns - 1) {
                walkable[x, y] = 0
                if let tile = tiles[x, y] {
                    walkable[x, y] = 1
                    if let obstacle = obstacles[x, y] {
                        if !obstacle.walkable {
                            walkable[x, y] = 0
                        }
                    }
                }
            }
        }
        return walkable
    }
    
    private func emptyMatrix(rows: Int, columns: Int) -> [[Int]] {
        // TODO(liang): currently returns 8 by 8. Learn how to intialize arrays in swift!
        return [[0, 0, 0, 0, 0, 0, 0, 0],
            [0, 0, 0, 0, 0, 0, 0, 0],
            [0, 0, 0, 0, 0, 0, 0, 0],
            [0, 0, 0, 0, 0, 0, 0, 0],
            [0, 0, 0, 0, 0, 0, 0, 0],
            [0, 0, 0, 0, 0, 0, 0, 0],
            [0, 0, 0, 0, 0, 0, 0, 0],
            [0, 0, 0, 0, 0, 0, 0, 0]]
    }
    
    private func setupTiles(tilesArray: AnyObject) {
        for (row, rowArray) in enumerate(tilesArray as [[Int]]) {
            let tileRow = NumRows - row - 1
            for (column, value) in enumerate(rowArray) {
                if value == 1 {
                    tiles[column, tileRow] = Tile()
                }
            }
        }
    }
    
    private func setupObstacles(obstaclesArray: AnyObject) {
        for (row, rowArray) in enumerate(obstaclesArray as [[Int]]) {
            // convert the row so that the bottom row has index 0 instead of the top row
            let tileRow = NumRows - row - 1
            for (column, value) in enumerate(rowArray) {
                if value == 1 {
                    println("setupObstacles: \(column), \(tileRow)")
                    let block = Block(column: column, row: tileRow)
                    obstacles[column, tileRow] = block
                    obstaclesSet.addElement(block) // why do we use obstaclesSet? faster lookup?
                }
            }
        }
    }
    
    private func setupGraph(walkable: Array2D<Int>) {
        graph = Graph(walkable: walkable)
    }
    
    func tileAtColumn(column: Int, row: Int) -> Tile? {
        assert(column >= 0 && column < NumColumns)
        assert(row >= 0 && row < NumRows)
        return tiles[column, row]
    }
}