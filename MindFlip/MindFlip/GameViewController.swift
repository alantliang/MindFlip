import UIKit
import SpriteKit
import AVFoundation

class GameViewController: UIViewController {
    var scene: GameScene!
    var level: Level!
    // var moves: Int!
    // var time:
    
    @IBOutlet weak var resetButton: UIButton!
    
    lazy var backgroundMusic: AVAudioPlayer = {
        let url = NSBundle.mainBundle().URLForResource("Super Street Fighter IV - Theme of Ryu", withExtension: "mp3")
        let player = AVAudioPlayer(contentsOfURL: url, error: nil)
        player.numberOfLoops = -1
        return player
        }()
    
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    override func shouldAutorotate() -> Bool {
        return true
    }
    
    override func supportedInterfaceOrientations() -> Int {
        return Int(UIInterfaceOrientationMask.AllButUpsideDown.rawValue)
    }
    
    @IBAction func printReset() {
        println("Reset pressed")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        println("GameViewController loaded")
        
        // Configure the view.
        let skView = view as SKView
        skView.multipleTouchEnabled = false
        
        // Create and configure the scene.
        scene = GameScene(size: skView.bounds.size)
        scene.scaleMode = .AspectFill
        
        // Present the scene.
        level = Level(filename: "Level_oneblock")
        scene.level = level
        scene.addTiles()
        scene.addSpritesForObstacles()
        skView.presentScene(scene)
        backgroundMusic.play()
    }
}