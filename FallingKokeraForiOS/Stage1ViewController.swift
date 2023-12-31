import UIKit
import SpriteKit
import GameplayKit
import AVFoundation

class Stage1ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        let skView = SKView(frame: view.bounds)
        view.addSubview(skView)

        let scene = StageScene(size: skView.bounds.size)
        skView.presentScene(scene)
    }
}

class StageScene: SKScene, SKPhysicsContactDelegate {

    var playerBar: SKSpriteNode!
    var scoreLabel: UILabel!
    var kakiScoreNode: SKSpriteNode!
    var score: Int = 0 {
        didSet {
            scoreLabel.text = "\(score)/1"
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
        playerBar.physicsBody?.isDynamic = false

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

        generateImages()

        // 画面の一番下に透明な長方形を設置
        let groundNode = SKSpriteNode(color: .clear, size: CGSize(width: size.width, height: 1))
        groundNode.position = CGPoint(x: size.width / 2, y: 0)
        addChild(groundNode)

        groundNode.physicsBody = SKPhysicsBody(rectangleOf: groundNode.size)
        groundNode.physicsBody?.categoryBitMask = PhysicsCategory.ground.rawValue
        groundNode.physicsBody?.collisionBitMask = 0
        groundNode.physicsBody?.contactTestBitMask = PhysicsCategory.kaki.rawValue
        groundNode.physicsBody?.isDynamic = false
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }

        let touchLocation = touch.location(in: self)
        let newX = touchLocation.x.clamped(to: playerBar.size.width / 2...size.width - playerBar.size.width / 2)
        playerBar.position.x = newX
    }

    func generateImages() {
        let kaki = SKSpriteNode(imageNamed: "kaki_nomal")
        let kokera = SKSpriteNode(imageNamed: "kokera_nomal")

        let startX = kaki.size.width / 2 + 50 // 修正: 画面左端から50の位置にオフセット
        let endX = size.width - kaki.size.width / 2 - 50 // 修正: 画面右端から50の位置にオフセット
        let y = size.height - kaki.size.height / 2

        kaki.position = CGPoint(x: startX, y: y)
        kokera.position = CGPoint(x: endX, y: y)

        kaki.name = "kaki"
        kokera.name = "kokera"

        addChild(kaki)
        addChild(kokera)

        kakiList.append(kaki)

        let destinationY = -kaki.size.height / 2
        let moveAction = SKAction.moveTo(y: destinationY, duration: 6)
        let removeAction = SKAction.removeFromParent()
        let sequence = SKAction.sequence([moveAction, removeAction])

        kaki.run(sequence)
        kokera.run(sequence)

        kaki.physicsBody = SKPhysicsBody(rectangleOf: kaki.size)
        kaki.physicsBody?.categoryBitMask = PhysicsCategory.kaki.rawValue
        kaki.physicsBody?.collisionBitMask = 0
        kaki.physicsBody?.contactTestBitMask = PhysicsCategory.player.rawValue
        kaki.physicsBody?.isDynamic = true

        kokera.physicsBody = SKPhysicsBody(rectangleOf: kokera.size)
        kokera.physicsBody?.categoryBitMask = PhysicsCategory.kokera.rawValue
        kokera.physicsBody?.collisionBitMask = 0
        kokera.physicsBody?.contactTestBitMask = PhysicsCategory.player.rawValue
        kokera.physicsBody?.isDynamic = true
    }

    func didBegin(_ contact: SKPhysicsContact) {
        let contactMask = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask

        if contactMask == (PhysicsCategory.kaki.rawValue | PhysicsCategory.player.rawValue) {
            if contact.bodyA.node?.name == "kaki" {
                contact.bodyA.node?.removeFromParent()
                if let index = kakiList.firstIndex(of: contact.bodyA.node as! SKSpriteNode) {
                    kakiList.remove(at: index)
                }
            } else if contact.bodyB.node?.name == "kaki" {
                contact.bodyB.node?.removeFromParent()
                if let index = kakiList.firstIndex(of: contact.bodyB.node as! SKSpriteNode) {
                    kakiList.remove(at: index)
                }
            }
            score += 1

            if score >= 1 {
                //スコアが1になったら、gameclearというStoryboard IDの画面に遷移
                clearControlView()
            }
        } else if contactMask == (PhysicsCategory.kokera.rawValue | PhysicsCategory.player.rawValue) {
            // kokeraとプレイヤーバーが接触した場合、gameover_kokeraというStoryboard IDの画面に遷移
            failControlView(withIdentifier: "gameover_kokera")
        } else if contactMask == (PhysicsCategory.kaki.rawValue | PhysicsCategory.ground.rawValue) {
            // kakiと地面が接触した場合、gameover_kakiというStoryboard IDの画面に遷移
            failControlView(withIdentifier: "gameover_kaki")
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

enum PhysicsCategory: UInt32 {
    case player = 1
    case kaki = 2
    case kokera = 4
    case ground = 8
}

extension Comparable {
    func clamped(to range: ClosedRange<Self>) -> Self {
        return min(max(self, range.lowerBound), range.upperBound)
    }
}

