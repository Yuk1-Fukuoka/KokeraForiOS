import UIKit
import SpriteKit

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addBackgroundView()
    }
    
    func addBackgroundView() {
        let skView = SKView(frame: view.bounds)
        skView.translatesAutoresizingMaskIntoConstraints = false
        view.insertSubview(skView, at: 0)
        
        NSLayoutConstraint.activate([
            skView.topAnchor.constraint(equalTo: view.topAnchor),
            skView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            skView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            skView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        let scene = GameScene(size: skView.bounds.size)
        scene.scaleMode = .aspectFill
        skView.presentScene(scene)
    }
}

class GameScene: SKScene {
    
    private var backgroundNode: SKSpriteNode!
    private var isGeneratingImages = false
    
    override func didMove(to view: SKView) {
        backgroundColor = .white
        
        // 背景ノードを追加
        backgroundNode = SKSpriteNode(color: .clear, size: size)
        backgroundNode.position = CGPoint(x: size.width / 2, y: size.height / 2)
        addChild(backgroundNode)
        
        // 最初の画像を生成
        generateImages()
    }
    
    func generateImages() {
        // 画像生成中であれば処理を終了
        guard !isGeneratingImages else { return }
        isGeneratingImages = true
        
        let isKaki = Bool.random()
        
        let spriteName = isKaki ? "kaki_small" : "kokera_small"
        let sprite = SKSpriteNode(imageNamed: spriteName)
        
        let xRange = sprite.size.width / 2...size.width - sprite.size.width / 2
        let y = size.height + sprite.size.height / 2
        
        sprite.position = CGPoint(x: CGFloat.random(in: xRange), y: y)
        backgroundNode.addChild(sprite)
        
        let destinationY = -size.height / 2 - sprite.size.height / 2
        let moveAction = SKAction.moveTo(y: destinationY, duration: 3)
        let removeAction = SKAction.removeFromParent()
        let sequence: SKAction = SKAction.sequence([moveAction, removeAction])
        
        sprite.run(sequence) {
            sprite.removeFromParent()
            self.isGeneratingImages = false
            // 一定の時間後に再度画像を生成
            self.run(SKAction.wait(forDuration: 0.5)) {
                self.generateImages()
            }
        }
    }
}

