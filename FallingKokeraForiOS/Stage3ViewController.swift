import UIKit
import SpriteKit
import GameplayKit
import AVFoundation

class Stage3ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        let skView = SKView(frame: view.bounds)
        view.addSubview(skView)

        let scene = StageScene3(size: skView.bounds.size)
        scene.scaleMode = .aspectFill
        skView.presentScene(scene)
    }
}

class StageScene3: SKScene, SKPhysicsContactDelegate {
    
    var playerBar: SKSpriteNode!
    var scoreLabel: UILabel!
    var kakiScoreNode: SKSpriteNode!
    var score: Int = 0 {
        didSet {
            scoreLabel.text = "\(score)/1"
            if score >= 1 {
                clearControlView()
            }
        }
    }
    
    var kakiList: [SKSpriteNode] = []
    
    override func didMove(to view: SKView) {
        backgroundColor = .white
        
        physicsWorld.contactDelegate = self
        physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        
        playerBar = SKSpriteNode(color: .black, size: CGSize(width: 100, height: 10))
        playerBar.position = CGPoint(x: size.width / 2, y: 100)
        addChild(playerBar)
        
        playerBar.physicsBody = SKPhysicsBody(rectangleOf: playerBar.size)
        playerBar.physicsBody?.categoryBitMask = PhysicsCategory.player.rawValue
        playerBar.physicsBody?.collisionBitMask = 0
        playerBar.physicsBody?.contactTestBitMask = PhysicsCategory.kaki.rawValue | PhysicsCategory.kokera.rawValue
        playerBar.physicsBody?.isDynamic = true
        
        scoreLabel = UILabel()
        scoreLabel.frame = CGRect(x: size.width - 70, y: 65, width: 200, height: 70)
        scoreLabel.textColor = .black
        scoreLabel.font = UIFont.systemFont(ofSize: 36)
        scoreLabel.text = "\(score)/1"
        view.addSubview(scoreLabel)
        
        kakiScoreNode = SKSpriteNode(imageNamed: "kakiscore.png")
        kakiScoreNode.anchorPoint = CGPoint(x: 0, y: 0.5)
        kakiScoreNode.position = CGPoint(x: size.width - 140, y: size.height - 100)
        kakiScoreNode.setScale(0.25)
        addChild(kakiScoreNode)
        
        let groundNode = SKSpriteNode(color: .clear, size: CGSize(width: size.width, height: 1))
        groundNode.position = CGPoint(x: size.width / 2, y: 0)
        addChild(groundNode)
        
        groundNode.physicsBody = SKPhysicsBody(rectangleOf: groundNode.size)
        groundNode.physicsBody?.categoryBitMask = PhysicsCategory.ground.rawValue
        groundNode.physicsBody?.collisionBitMask = 0
        groundNode.physicsBody?.contactTestBitMask = PhysicsCategory.kaki.rawValue
        groundNode.physicsBody?.isDynamic = false
        
        let waitAction = SKAction.wait(forDuration: 1)
        let generateAction = SKAction.run { [weak self] in
            self?.generateImages()
        }
        let sequence: SKAction = SKAction.sequence([waitAction, generateAction])
        run(SKAction.repeatForever(sequence))
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        
        let touchLocation = touch.location(in: self)
        let newX = touchLocation.x.clamped(to: playerBar.size.width / 2...size.width - playerBar.size.width / 2)
        playerBar.position.x = newX
    }
    
    func generateImages() {
        if kakiList.count >= 1 {
            return // 既にkakiが生成されている場合は処理を終了
        }
        
        if let existingKokera1 = childNode(withName: "kokera1") as? SKSpriteNode,
           let existingKokera2 = childNode(withName: "kokera2") as? SKSpriteNode {
            // 既にkokera1とkokera2が存在する場合は処理を終了
            if existingKokera1.parent != nil && existingKokera2.parent != nil {
                return
            }
        }
        
        let kokera1 = SKSpriteNode(imageNamed: "kokera_nomal")
        let kokera2 = SKSpriteNode(imageNamed: "kokera_nomal")
        
        let startX1: CGFloat = kokera1.size.width / 2 + 25
        let startX2: CGFloat = size.width - kokera2.size.width / 2 - 25
        let y: CGFloat = size.height - kokera1.size.height / 2
        
        kokera1.position = CGPoint(x: startX1, y: y)
        kokera2.position = CGPoint(x: startX2, y: y)
        
        kokera1.name = "kokera1"
        kokera2.name = "kokera2"
        
        addChild(kokera1)
        addChild(kokera2)
        
        let destinationY: CGFloat = -kokera1.size.height / 2
        let moveAction = SKAction.moveTo(y: destinationY, duration: 5)
        let removeAction = SKAction.removeFromParent()
        let sequence: SKAction = SKAction.sequence([moveAction, removeAction])
        
        kokera1.run(sequence)
        kokera2.run(sequence)
        
        kokera1.physicsBody = SKPhysicsBody(rectangleOf: kokera1.size)
        kokera1.physicsBody?.categoryBitMask = PhysicsCategory.kokera.rawValue
        kokera1.physicsBody?.collisionBitMask = 0
        kokera1.physicsBody?.contactTestBitMask = PhysicsCategory.player.rawValue
        kokera1.physicsBody?.isDynamic = true
        
        kokera2.physicsBody = SKPhysicsBody(rectangleOf: kokera2.size)
        kokera2.physicsBody?.categoryBitMask = PhysicsCategory.kokera.rawValue
        kokera2.physicsBody?.collisionBitMask = 0
        kokera2.physicsBody?.contactTestBitMask = PhysicsCategory.player.rawValue
        kokera2.physicsBody?.isDynamic = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) { [weak self] in
            self?.addKaki()
        }
    }
    
    func addKaki() {
        if kakiList.count >= 1 {
            return // 既にkakiが生成されている場合は処理を終了
        }
        
        let kaki = SKSpriteNode(imageNamed: "kaki_nomal")
        let startX = size.width / 2
        let y = size.height - kaki.size.height / 2
        
        kaki.position = CGPoint(x: startX, y: y)
        kaki.name = "kaki"
        addChild(kaki)
        kakiList.append(kaki)
        
        let destinationY = -kaki.size.height / 2
        let moveAction = SKAction.moveTo(y: destinationY, duration: 5)
        let removeAction = SKAction.removeFromParent()
        let sequence: SKAction = SKAction.sequence([moveAction, removeAction])
        
        kaki.run(sequence)
        
        kaki.physicsBody = SKPhysicsBody(rectangleOf: kaki.size)
        kaki.physicsBody?.categoryBitMask = PhysicsCategory.kaki.rawValue
        kaki.physicsBody?.collisionBitMask = 0
        kaki.physicsBody?.contactTestBitMask = PhysicsCategory.player.rawValue
        kaki.physicsBody?.isDynamic = true
    }
    
    
    func didBegin(_ contact: SKPhysicsContact) {
        let contactMask = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask
        
        if contactMask == (PhysicsCategory.kaki.rawValue | PhysicsCategory.player.rawValue) {
            if contact.bodyA.node?.name == "kaki" {
                contact.bodyA.node?.removeFromParent()
                score += 1
            } else if contact.bodyB.node?.name == "kaki" {
                contact.bodyB.node?.removeFromParent()
                score += 1
            }
        }
    }
    
    func clearControlView() {
        DispatchQueue.main.async {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            if let clearViewController = storyboard.instantiateViewController(withIdentifier: "gameclear") as? UIViewController {
                clearViewController.modalPresentationStyle = .fullScreen
                
                // ナビゲーションスタックをクリアしてPush遷移
                if let navigationController = self.view?.window?.rootViewController as? UINavigationController {
                    navigationController.setViewControllers([clearViewController], animated: true)
                }
            }
        }
    }
    
    func failControlView(withIdentifier identifier: String) {
        DispatchQueue.main.async {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            if let failViewController = storyboard.instantiateViewController(withIdentifier: identifier) as? UIViewController {
                failViewController.modalPresentationStyle = .fullScreen
                
                // ナビゲーションスタックをクリアしてPush遷移
                if let navigationController = self.view?.window?.rootViewController as? UINavigationController {
                    navigationController.setViewControllers([failViewController], animated: true)
                }
            }
        }
    }
}
