import Foundation

let NumColumns = 8
let NumRows = 8

class Level {
    private var tiles = Array2D<Tile>(columns: NumColumns, rows: NumRows)
    private var obstacles = Array2D<Obstacle>(columns: NumColumns, rows: NumRows)
    private var obstaclesSet = Set<Obstacle>()
    private var graph: Graph!
    
    init(filename: String) {
        if let dictionary = Dictionary<String, AnyObject>.loadJSONFromBundle(filename) {
            if let tilesArray: AnyObject = dictionary["tiles"] {
                setupTiles(tilesArray)
                if let blocksArray: AnyObject = dictionary["obstacles"] {
                    setupObstacles(blocksArray)
                    var walkable: [[Int]] = getWalkable(tilesArray as [[Int]], myObstacles: blocksArray as [[Int]])
                    setupGraph(walkable)
                }
            }
        }
    }
    
    func getGraph() -> Graph {
        return graph
    }
    
    func getObstacles() -> Set<Obstacle> {
        return obstaclesSet
    }
    
    func getWalkable(myTiles: [[Int]], myObstacles: [[Int]]) -> [[Int]] {
        // assuming height and width are same for both
        var walkable: [[Int]] = emptyMatrix(NumRows, columns: NumColumns)
        for y in Range(start: 0, end: NumRows - 1) {
            for x in Range(start: 0, end: NumColumns - 1) {
                if myTiles[y][x] == 1 || myObstacles[y][x] == 0 {
                    walkable[y][x] = 1
                } else {
                    walkable[y][x] = 0
                }
            }
        }
        return walkable
    }
    
    func emptyMatrix(rows: Int, columns: Int) -> [[Int]] {
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
    
    func setupTiles(tilesArray: AnyObject) {
        for (row, rowArray) in enumerate(tilesArray as [[Int]]) {
            let tileRow = NumRows - row - 1
            for (column, value) in enumerate(rowArray) {
                if value == 1 {
                    tiles[column, tileRow] = Tile()
                }
            }
        }
    }
    
    func setupObstacles(obstaclesArray: AnyObject) {
        for (row, rowArray) in enumerate(obstaclesArray as [[Int]]) {
            let tileRow = NumRows - row - 1
            for (column, value) in enumerate(rowArray) {
                if value == 1 {
                    let block = Block(column: column, row: row)
                    obstacles[column, tileRow] = block
                    obstaclesSet.addElement(block)
                }
            }
        }
    }
    
    func setupGraph(tilesArray: AnyObject) {
        graph = Graph(walkable: tilesArray as [[Int]])
    }
    
    func tileAtColumn(column: Int, row: Int) -> Tile? {
        assert(column >= 0 && column < NumColumns)
        assert(row >= 0 && row < NumRows)
        return tiles[column, row]
    }
}