// Contains Model information about our level
// obstacles Currently contains the state of all our objects including the hero and all obstacles he/she will face.

import Foundation

let NumColumns = 8
let NumRows = 8
let MaxColumnIndex = NumColumns - 1
let MaxRowIndex = NumRows - 1


class Cell {
    // Cell for every cell in our graph
    var tile: Tile?
    var gameObjects: [GameObj] = []
    var x: Int?
    var y: Int?
     var walkable: Bool {
        get {
            var walkable = false
            if let tileExists = tile? {
                walkable = gameObjects.reduce(true, combine: {$0 && $1.walkable})
            }
            return walkable
        }
    }
    
    init(x: Int, y: Int) {
        self.x = x
        self.y = y
    }
    
    func removeGameObj(obj: GameObj) {
        for (index, obj) in enumerate(self.gameObjects) {
            if (obj == obj) {
                gameObjects.removeAtIndex(index)
                break
            } else {
                // possibly raise exception
            }
        }
    }
    
    func addGameObj(obj: GameObj) {
        gameObjects.append(obj)
    }
}

class Level {
    private var cells = Array2D<Cell>(columns: NumColumns, rows: NumRows)
    private var tiles = Array2D<Tile>(columns: NumColumns, rows: NumRows)
    private var hero: Hero! // we always want a reference to the hero
    private var destCell: DestCell!
    private var graph: Graph! // make this calculated
    private var start: (x: Int, y: Int)!
    
    init(filename: String) {
        setupCells()
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
                start = (x: startList[0], y: startList[1])
                hero = Hero(column: start.x, row: start.y)
                destCell = DestCell(column: start.x, row: start.y)
                cells[start.x, start.y]!.addGameObj(hero)
                cells[start.x, start.y]!.addGameObj(destCell)
            }
        }
        setupGraph(getWalkable())
    }
    
    func isWalkable(column: Int, row: Int) -> Bool {
        return graph.getNode(column, y: row).walkable
    }
    
    func moveDestCell(column: Int, row: Int) {
        moveObj(destCell, x: column, y: row)
    }
    
    func moveHero(column: Int, row: Int) {
        moveObj(hero, x: column, y: row)
    }
    
    func flipUp() {
        flip(flipUpAlgo)
    }
    
    func flipRight() {
        flip(flipRightAlgo)
    }
    
    func flipUpRight() {
        flip(flipUpRightAlgo)
    }
    
    func flipUpLeft() {
        flip(flipUpLeftAlgo)
    }
    
    func getHero() -> Hero {
        return hero
    }
    
    func getGraph() -> Graph {
        return graph
    }
    
    func getAllObjs() -> [GameObj] {
        var allObjs: [GameObj] = []
        for y in Range(start: 0, end: NumRows) {
            for x in Range(start: 0, end: NumColumns) {
                if let curCell = cells[x, y]? {
                    allObjs += curCell.gameObjects
                }
            }
        }
        return allObjs
    }
    
    func getCells() -> Array2D<Cell> {
        return cells
    }
    
    func getDestCell() -> DestCell {
        return destCell
    }
    
    func getWalkable() -> Array2D<Int> {
        // assuming height and width are same for both
        var walkable = Array2D<Int>(columns: NumColumns, rows: NumRows)
        for y in Range(start: 0, end: NumRows) {
            for x in Range(start: 0, end: NumColumns) {
                walkable[x, y] = 0
                if let cell = cells[x, y]? {
                    if cell.walkable {
                        walkable[x, y] = 1
                    }
                }
            }
        }
        return walkable
    }
    
    func resetGraph() {
        setupGraph(getWalkable())
    }
    
    func tileAtColumn(column: Int, row: Int) -> Tile? {
        assert(column >= 0 && column < NumColumns)
        assert(row >= 0 && row < NumRows)
        return cells[column, row]!.tile
    }


    private func flip(flipAlgo: (x: Int, y: Int) -> (x: Int, y: Int)) {
        // for obstacle in obstacles, if flippable, flip using flip algorithm
        var newLocations = Array2D<[GameObj]>(columns: NumColumns, rows: NumRows)
        for y in 0..<NumRows {
            for x in 0..<NumColumns {
                newLocations[x, y] = []
            }
        }
        for y in 0..<NumRows {
            for x in 0..<NumColumns {
                for obj in cells[x, y]!.gameObjects {
                    if obj.flippable {
                        var newCoords = flipAlgo(x: x, y: y)
                        newLocations[newCoords.x, newCoords.y]!.append(obj)
                    } else {
                        newLocations[x, y]!.append(obj)
                    }
                }
            }
        }
        moveAll(newLocations)
    }
    
    private func moveAll(newLocations: Array2D<[GameObj]>) {
        for y in 0..<NumRows {
            for x in 0..<NumColumns {
                for obj in newLocations[x, y]! {
                    moveObj(obj, x: x, y: y)
                }
            }
        }
    }
    
    private func moveObj(obj: GameObj, x: Int, y: Int) {
        // remove obj from parent cell and move to new cell
        var oldx = obj.column
        var oldy = obj.row
        obj.column = x
        obj.row = y
        cells[x, y]!.addGameObj(obj)
        cells[oldx, oldy]!.removeGameObj(obj)
    }
    
    private func flipUpAlgo(x: Int, y:Int) -> (x: Int, y: Int) {
        var flipx = x
        var flipy = MaxRowIndex - y
        return (x: flipx, y: flipy)
    }
    
    private func flipRightAlgo(x: Int, y: Int) -> (x: Int, y: Int) {
        let flipx = MaxColumnIndex - x
        let flipy = y
        return (x: flipx, y: flipy)
    }
    
    private func flipUpRightAlgo(x: Int, y: Int) -> (x: Int, y: Int) {
        let flipx = MaxColumnIndex - y
        let flipy = MaxRowIndex - x
        return (x: flipx, y: flipy)
    }
    
    private func flipUpLeftAlgo(x: Int, y: Int) -> (x: Int, y: Int) {
        let flipx = y
        let flipy = x
        return (x: flipx, y: flipy)
    }
    
    private func setupCells() {
        for row in Range(start: 0, end: NumRows) {
            for col in Range(start: 0, end: NumColumns) {
                cells[col, row] = Cell(x: col, y: row)
            }
        }
    }
    
    private func setupTiles(tilesArray: AnyObject) {
        for (row, rowArray) in enumerate(tilesArray as [[Int]]) {
            let tileRow = NumRows - row - 1
            for (column, value) in enumerate(rowArray) {
                if value == 1 {
                    cells[column, tileRow]!.tile = Tile()
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
                    cells[column, tileRow]!.addGameObj(block)
                } else if value == 3 {
                    println("setupObstacles: \(column), \(tileRow)")
                    let collectable = Collectable(column: column, row: tileRow)
                    cells[column, tileRow]!.addGameObj(collectable)
                }
            }
        }
    }
    
    private func setupGraph(walkable: Array2D<Int>) {
        graph = Graph(walkable: walkable)
    }
}