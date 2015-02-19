import Foundation

let NumColumns = 8
let NumRows = 8

class Level {
    private var tiles = Array2D<Tile>(columns: NumColumns, rows: NumRows)
    private var graph: Graph!
    
    init(filename: String) {
        if let dictionary = Dictionary<String, AnyObject>.loadJSONFromBundle(filename) {
            if let tilesArray: AnyObject = dictionary["tiles"] {
                setupTiles(tilesArray)
                setupGraph(tilesArray)
            }
        }
    }
    
    func getGraph() -> Graph {
        return graph
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
    
    func setupGraph(tilesArray: AnyObject) {
        graph = Graph(walkable: tilesArray as [[Int]])
    }
    
    func tileAtColumn(column: Int, row: Int) -> Tile? {
        assert(column >= 0 && column < NumColumns)
        assert(row >= 0 && row < NumRows)
        return tiles[column, row]
    }
}