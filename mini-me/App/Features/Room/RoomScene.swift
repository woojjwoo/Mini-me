import SpriteKit
import SwiftUI

class RoomScene: SKScene {
    private var room: Room
    private var pet: Pet?
    private var currentMood: PetMood
    private var currentActivity: PetActivity = .idling
    private var slotNodes: [String: SKSpriteNode] = [:]
    private var roomOrigin: CGPoint = .zero
    private var assetScale: CGFloat = 1.2

    // Character nodes
    private var petNode       = SKNode()
    private var compositeNode = CharacterCompositeNode()   // replaces single visualNode
    private var shadowNode    = SKShapeNode()
    private var speechBubble: SKNode?
    private var legsNode: SKNode?
    private var phoneNode: SKLabelNode?
    private var sittingYOffset: CGFloat = 0

    private let petBaseScale: CGFloat = 0.35
    private var spawnPoint: CGPoint {
        CGPoint(x: roomOrigin.x, y: roomOrigin.y - 20)
    }

    init(room: Room, pet: Pet?, mood: PetMood, streakCount: Int, size: CGSize) {
        self.room        = room
        self.pet         = pet
        self.currentMood = mood
        super.init(size: size)
    }

    required init?(coder aDecoder: NSCoder) { fatalError() }

    override func didMove(to view: SKView) {
        self.backgroundColor = .clear
        self.roomOrigin = CGPoint(x: size.width / 2, y: size.height / 2)
        setupRoom()
    }

    private var worldLayer = SKNode()

    // MARK: - Room setup

    private func setupRoom() {
        removeAllChildren()
        addChild(worldLayer)

        if let bgTexture = loadTexture(named: "room_base_lofi_v2_1774708398444") {
            let bgNode = SKSpriteNode(texture: bgTexture)
            bgNode.position  = roomOrigin
            bgNode.setScale(assetScale)
            bgNode.zPosition = -2000
            addChild(bgNode)
        }

        for slot in SlotType.allCases {
            guard let assignment = room.assignment(for: slot),
                  let itemID    = assignment.itemID,
                  let item      = ItemCatalog.item(byID: itemID) else { continue }

            let pos  = slot.scenePosition
            let node = createItemNode(for: item)
            node.position = CGPoint(
                x: roomOrigin.x + (pos.x * assetScale),
                y: roomOrigin.y + (pos.y * assetScale)
            )
            node.setScale(assetScale)
            node.name = slot.rawValue
            worldLayer.addChild(node)
            slotNodes[slot.rawValue] = node
        }

        setupPet()
    }

    private func setupPet() {
        // Shadow — flat ellipse on the floor
        shadowNode = SKShapeNode(ellipseOf: CGSize(width: 30, height: 10))
        shadowNode.fillColor   = .black.withAlphaComponent(0.2)
        shadowNode.strokeColor = .clear
        shadowNode.zPosition   = -1
        worldLayer.addChild(shadowNode)

        // Composite character node
        compositeNode = CharacterCompositeNode()
        compositeNode.setScale(petBaseScale)

        if let pet = pet {
            compositeNode.apply(pet: pet, mood: currentMood)
        } else {
            // No pet yet — show neutral idle sprite as bare body layer placeholder
        }

        petNode = SKNode()
        petNode.addChild(compositeNode)
        petNode.position = spawnPoint
        petNode.name     = "pet"
        worldLayer.addChild(petNode)

        startLifeAnimations()
        updateForActivity(.idling)
    }

    // MARK: - Y-Sort depth update

    override func update(_ currentTime: TimeInterval) {
        for node in worldLayer.children {
            if node === shadowNode { continue }
            node.zPosition = -node.position.y
        }
        shadowNode.position = petNode.position
    }

    // MARK: - Character update (called when Pet model changes)

    func updateCharacter(pet: Pet, mood: PetMood) {
        self.pet         = pet
        self.currentMood = mood
        compositeNode.invalidateCache()
        compositeNode.apply(pet: pet, mood: mood)
    }

    // MARK: - Walking engine

    func updateForActivity(_ activity: PetActivity) {
        currentActivity = activity

        // Re-apply character with potentially different mood texture
        if let pet = pet {
            compositeNode.apply(pet: pet, mood: currentMood)
        }

        let offset    = activity.roomOffset
        let targetPos = CGPoint(
            x: roomOrigin.x + (offset.x * assetScale),
            y: roomOrigin.y + (offset.y * assetScale)
        )

        walkTo(target: targetPos) { [weak self] in
            self?.applyActivityPose(activity)
        }
    }

    private func walkTo(target: CGPoint, completion: (() -> Void)? = nil) {
        let dx = target.x - roomOrigin.x
        let dy = target.y - roomOrigin.y
        if abs(dx) > 120 || abs(dy) > 80 { completion?(); return }

        petNode.removeAction(forKey: "walk")
        compositeNode.run(SKAction.scale(to: petBaseScale, duration: 0.2))

        petNode.xScale = target.x < petNode.position.x ? -1 : 1

        let dist     = hypot(target.x - petNode.position.x, target.y - petNode.position.y)
        let duration = Double(max(0.4, dist / 70.0))

        let move = SKAction.move(to: target, duration: duration)
        let hop  = SKAction.repeat(
            SKAction.sequence([
                SKAction.moveBy(x: 0, y: 10, duration: 0.15),
                SKAction.moveBy(x: 0, y: -10, duration: 0.15)
            ]),
            count: Int(duration / 0.3)
        )

        petNode.run(move, withKey: "walk")
        compositeNode.run(hop) { completion?() }
    }

    private func applyActivityPose(_ activity: PetActivity) {
        hideSittingLegs()
        hidePhoneSlacking()

        compositeNode.removeAllActions()
        startLifeAnimations()

        let isCafe = room.roomType == .coffeeShop

        switch activity {
        case .working:
            if isCafe {
                showSittingLegs()
            } else {
                compositeNode.run(
                    SKAction.scaleX(to: petBaseScale * 1.05, y: petBaseScale * 0.9, duration: 0.3)
                )
            }
        case .reading where isCafe:
            showSittingLegs()
        case .idling where isCafe:
            showSittingLegs()
        case .slacking:
            if isCafe { showSittingLegs() }
            showPhoneSlacking()
        case .sleeping:
            compositeNode.run(
                SKAction.scaleX(to: petBaseScale * 1.1, y: petBaseScale * 0.8, duration: 0.3)
            )
        default:
            compositeNode.run(SKAction.scale(to: petBaseScale, duration: 0.3))
        }
    }

    // MARK: - Overlay animations

    private func showSittingLegs() {
        legsNode?.removeFromParent()

        sittingYOffset = 18
        petNode.position.y += sittingYOffset

        let container   = SKNode()
        let skinUIColor = pet.map { UIColor($0.skinTone.color) } ?? UIColor(red: 0.91, green: 0.60, blue: 0.37, alpha: 1)
        let shoeColor   = UIColor(red: 0.25, green: 0.18, blue: 0.12, alpha: 1)

        for side: CGFloat in [-1, 1] {
            let leg = SKShapeNode(rectOf: CGSize(width: 5, height: 14), cornerRadius: 2)
            leg.fillColor   = skinUIColor
            leg.strokeColor = .clear
            leg.position    = CGPoint(x: side * 7, y: 0)
            container.addChild(leg)

            let foot = SKShapeNode(rectOf: CGSize(width: 8, height: 4), cornerRadius: 2)
            foot.fillColor   = shoeColor
            foot.strokeColor = .clear
            foot.position    = CGPoint(x: side * 7, y: -10)
            container.addChild(foot)
        }

        container.position = CGPoint(x: 0, y: -12)
        petNode.addChild(container)
        legsNode = container

        let swing = SKAction.repeatForever(SKAction.sequence([
            SKAction.rotate(byAngle:  0.12, duration: 0.7),
            SKAction.rotate(byAngle: -0.12, duration: 0.7)
        ]))
        container.run(swing, withKey: "dangle")

        let kick = SKAction.sequence([
            SKAction.wait(forDuration: Double.random(in: 3...7)),
            SKAction.rotate(byAngle:  0.4, duration: 0.18),
            SKAction.rotate(byAngle: -0.4, duration: 0.25),
            SKAction.rotate(toAngle:  0,   duration: 0.18)
        ])
        container.run(SKAction.repeatForever(kick), withKey: "kick")
    }

    private func hideSittingLegs() {
        guard legsNode != nil else { return }
        legsNode?.removeFromParent()
        legsNode = nil
        petNode.position.y -= sittingYOffset
        sittingYOffset = 0
    }

    private func showPhoneSlacking() {
        phoneNode?.removeFromParent()

        let phone = SKLabelNode(text: "📱")
        phone.fontSize = 12
        phone.position = CGPoint(x: 18, y: 20)
        petNode.addChild(phone)
        phoneNode = phone

        compositeNode.run(SKAction.rotate(toAngle: -0.15, duration: 0.3))

        let bob = SKAction.repeatForever(SKAction.sequence([
            SKAction.moveBy(x: 0, y: 2, duration: 1.0),
            SKAction.moveBy(x: 0, y: -2, duration: 1.0)
        ]))
        phone.run(bob, withKey: "bob")

        let putAway = SKAction.sequence([
            SKAction.wait(forDuration: Double.random(in: 8...14)),
            SKAction.fadeOut(withDuration: 0.3),
            SKAction.run { [weak self] in
                self?.compositeNode.run(SKAction.rotate(toAngle: 0, duration: 0.3))
            },
            SKAction.wait(forDuration: 2.0),
            SKAction.fadeIn(withDuration: 0.3),
            SKAction.run { [weak self] in
                self?.compositeNode.run(SKAction.rotate(toAngle: -0.15, duration: 0.3))
            }
        ])
        phone.run(SKAction.repeatForever(putAway), withKey: "cycle")
    }

    private func hidePhoneSlacking() {
        guard phoneNode != nil else { return }
        phoneNode?.removeFromParent()
        phoneNode = nil
        compositeNode.run(SKAction.rotate(toAngle: 0, duration: 0.2))
    }

    private func startLifeAnimations() {
        let breathe = SKAction.repeatForever(SKAction.sequence([
            SKAction.scaleX(to: petBaseScale * 1.01, y: petBaseScale * 0.99, duration: 1.5),
            SKAction.scaleX(to: petBaseScale * 0.99, y: petBaseScale * 1.01, duration: 1.5)
        ]))
        compositeNode.run(breathe, withKey: "breathe")
    }

    // MARK: - Speech / effects

    func showThought(_ text: String) {
        speechBubble?.removeFromParent()
        let bubble = SKNode()
        let label  = SKLabelNode(text: text)
        label.fontName  = "Menlo-Bold"
        label.fontSize  = 10
        label.fontColor = .black

        let bg = SKShapeNode(
            rectOf: CGSize(width: label.frame.width + 16, height: 20),
            cornerRadius: 6
        )
        bg.fillColor   = .white
        bg.strokeColor = .black
        bg.lineWidth   = 1

        bubble.addChild(bg)
        bubble.addChild(label)
        bubble.position = CGPoint(x: 0, y: 60)
        petNode.addChild(bubble)
        speechBubble = bubble
        bubble.run(SKAction.sequence([
            SKAction.wait(forDuration: 3.5),
            SKAction.removeFromParent()
        ]))
    }

    func showCoinShower() {
        for _ in 0..<8 {
            let coin = SKLabelNode(text: "🪙")
            coin.fontSize = 18
            coin.position = CGPoint(
                x: petNode.position.x + CGFloat.random(in: -20...20),
                y: petNode.position.y + 50
            )
            addChild(coin)
            let move = SKAction.moveBy(x: CGFloat.random(in: -30...30), y: 100, duration: 0.8)
            coin.run(SKAction.sequence([
                move,
                SKAction.fadeOut(withDuration: 0.2),
                SKAction.removeFromParent()
            ]))
        }
        showThought("Coins! 💰")
    }

    func showCelebration() {
        showThought("PERFECT DAY! ✨")
        HapticService.celebration()
        showSparkles()
    }

    func showSparkles() {
        for _ in 0..<10 {
            let s = SKLabelNode(text: "✨")
            s.fontSize = 8
            s.position = petNode.position
            addChild(s)
            let dest = CGPoint(
                x: petNode.position.x + CGFloat.random(in: -40...40),
                y: petNode.position.y + CGFloat.random(in: 0...60)
            )
            s.run(SKAction.sequence([
                SKAction.move(to: dest, duration: 0.6),
                SKAction.fadeOut(withDuration: 0.2),
                SKAction.removeFromParent()
            ]))
        }
    }

    func takeWidgetSnapshot() {
        guard let view = self.view else { return }
        let renderer = UIGraphicsImageRenderer(size: view.bounds.size)
        let image = renderer.image { _ in
            view.drawHierarchy(in: view.bounds, afterScreenUpdates: true)
        }
        WidgetDataService.shared.saveRoomSnapshot(image)
    }

    // MARK: - Touch

    #if os(iOS)
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let loc = touch.location(in: self)
        if nodes(at: loc).contains(where: { $0.name == "pet" }) {
            compositeNode.run(SKAction.sequence([
                SKAction.scale(to: petBaseScale * 1.2, duration: 0.1),
                SKAction.scale(to: petBaseScale,       duration: 0.1)
            ]))
        }
    }
    #endif

    // MARK: - Helpers

    private func loadTexture(named name: String) -> SKTexture? {
        let t = SKTexture(imageNamed: name)
        t.filteringMode = .nearest
        return t
    }

    private func createItemNode(for item: ShopItem) -> SKSpriteNode {
        let node: SKSpriteNode
        if let texture = loadTexture(named: item.spriteName) {
            node = SKSpriteNode(texture: texture)
        } else {
            node = SKSpriteNode(color: .gray, size: CGSize(width: 40, height: 40))
        }
        node.anchorPoint = CGPoint(x: 0.5, y: 0)
        return node
    }
}
