import SpriteKit

class RoomScene: SKScene {
    private var room: Room
    private var pet: Pet?
    private var currentMood: PetMood
    private var currentActivity: PetActivity = .idling
    private var slotNodes: [String: SKSpriteNode] = [:]
    private var roomOrigin: CGPoint = .zero
    private var assetScale: CGFloat = 1.2
    
    // Character Nodes
    private var petNode = SKNode() 
    private var visualNode = SKSpriteNode() 
    private var shadowNode = SKShapeNode()
    private var speechBubble: SKNode?
    
    // Physical Constants
    private let petBaseScale: CGFloat = 0.22
    private var spawnPoint: CGPoint {
        // Center of the floor area in the Lofi v2 background
        return CGPoint(x: roomOrigin.x, y: roomOrigin.y - 20)
    }

    init(room: Room, pet: Pet?, mood: PetMood, streakCount: Int, size: CGSize) {
        self.room = room
        self.pet = pet
        self.currentMood = mood
        super.init(size: size)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func didMove(to view: SKView) {
        self.backgroundColor = .clear
        self.roomOrigin = CGPoint(x: size.width / 2, y: size.height / 2)
        setupRoom()
    }

    private var worldLayer = SKNode()

    private func setupRoom() {
        removeAllChildren()
        addChild(worldLayer)

        // 1. Background (Static)
        if let bgTexture = loadTexture(named: "room_base_lofi_v2_1774708398444") {
            let bgNode = SKSpriteNode(texture: bgTexture)
            bgNode.position = roomOrigin
            bgNode.setScale(assetScale)
            bgNode.zPosition = -2000 // Far background
            addChild(bgNode)
        }

        // 2. Place Items into World Layer for sorting
        for slot in SlotType.allCases {
            guard let assignment = room.assignment(for: slot),
                  let itemID = assignment.itemID,
                  let item = ItemCatalog.item(byID: itemID) else { continue }

            let pos = slot.scenePosition
            let node = createItemNode(for: item)
            // Position relative to floor
            node.position = CGPoint(x: roomOrigin.x + (pos.x * assetScale), y: roomOrigin.y + (pos.y * assetScale))
            node.setScale(assetScale)
            node.name = slot.rawValue
            worldLayer.addChild(node)
            slotNodes[slot.rawValue] = node
        }

        setupPet()
    }

    private func setupPet() {
        // 1. Shadow (Stays flat on floor)
        shadowNode = SKShapeNode(ellipseOf: CGSize(width: 30, height: 10))
        shadowNode.fillColor = .black.withAlphaComponent(0.2)
        shadowNode.strokeColor = .clear
        shadowNode.zPosition = -1 
        worldLayer.addChild(shadowNode)

        // 2. Visual Sprite
        let spriteName = pet?.spriteName(for: currentMood) ?? "minime_idle_1774711350053"
        visualNode = SKSpriteNode(texture: loadTexture(named: spriteName))
        
        // CRITICAL FIX: Anchor Point at Feet
        visualNode.anchorPoint = CGPoint(x: 0.5, y: 0)
        visualNode.setScale(petBaseScale)
        
        // 3. Pet Root Node (Handles Floor Position)
        petNode.addChild(visualNode)
        worldLayer.addChild(petNode)
        petNode.name = "pet"
        
        // CRITICAL FIX: Spawn inside the room, not at (0,0)
        petNode.position = spawnPoint

        startLifeAnimations()
        updateForActivity(.idling)
    }

    override func update(_ currentTime: TimeInterval) {
        // CRITICAL FIX: Continuous Y-Sorting for Depth
        // Objects with lower Y (closer to bottom) get higher Z (closer to eye)
        for node in worldLayer.children {
            if node == shadowNode { continue }
            node.zPosition = -node.position.y
        }
        
        // Sync shadow to pet floor position
        shadowNode.position = petNode.position
    }

    // MARK: - Walking Engine

    func updateForActivity(_ activity: PetActivity) {
        self.currentActivity = activity
        
        let textureName = textureNameForActivity(activity)
        visualNode.texture = loadTexture(named: textureName)

        let offset = activity.roomOffset
        let targetPos = CGPoint(x: roomOrigin.x + (offset.x * assetScale), y: roomOrigin.y + (offset.y * assetScale))
        
        walkTo(target: targetPos) { [weak self] in
            self?.applyActivityPose(activity)
        }
    }

    private func walkTo(target: CGPoint, completion: (() -> Void)? = nil) {
        // CRITICAL FIX: Constrain target to Floor Bounds
        let dx = target.x - roomOrigin.x
        let dy = target.y - roomOrigin.y
        
        // Simple diamond-ish bounds check for isometric floor
        if abs(dx) > 120 || abs(dy) > 80 {
            completion?()
            return
        }

        petNode.removeAction(forKey: "walk")
        
        // Ensure uniform scale during walk reset
        visualNode.run(SKAction.scale(to: petBaseScale, duration: 0.2))
        
        let isMovingLeft = target.x < petNode.position.x
        // CRITICAL FIX: Flip only xScale, keep yScale identical
        petNode.xScale = isMovingLeft ? -1 : 1 

        let dist = hypot(target.x - petNode.position.x, target.y - petNode.position.y)
        let duration = Double(max(0.4, dist / 70.0))
        let move = SKAction.move(to: target, duration: duration)
        
        // Walking hop: Only on visualNode to keep petNode on floor for sorting
        let hop = SKAction.repeat(SKAction.sequence([
            SKAction.moveBy(x: 0, y: 10, duration: 0.15),
            SKAction.moveBy(x: 0, y: -10, duration: 0.15)
        ]), count: Int(duration / 0.3))

        petNode.run(move, withKey: "walk")
        visualNode.run(hop) { completion?() }
    }

    private func applyActivityPose(_ activity: PetActivity) {
        visualNode.removeAllActions()
        startLifeAnimations()

        switch activity {
        case .working:
            // Uniform subtle squash
            visualNode.run(SKAction.scaleX(to: petBaseScale * 1.05, y: petBaseScale * 0.9, duration: 0.3))
        case .sleeping:
            visualNode.run(SKAction.scaleX(to: petBaseScale * 1.1, y: petBaseScale * 0.8, duration: 0.3))
        default:
            visualNode.run(SKAction.scale(to: petBaseScale, duration: 0.3))
        }
    }

    private func startLifeAnimations() {
        // CRITICAL FIX: Proportional Breathing (Subtle)
        let breathe = SKAction.repeatForever(SKAction.sequence([
            SKAction.scaleX(to: petBaseScale * 1.01, y: petBaseScale * 0.99, duration: 1.5),
            SKAction.scaleX(to: petBaseScale * 0.99, y: petBaseScale * 1.01, duration: 1.5)
        ]))
        visualNode.run(breathe, withKey: "breathe")
    }

    // MARK: - Helpers

    private func textureNameForActivity(_ activity: PetActivity) -> String {
        switch activity {
        case .sleeping: return "minime_sleeping_1774711364657"
        default: return "minime_idle_1774711350053"
        }
    }

    func showThought(_ text: String) {
        speechBubble?.removeFromParent()
        let bubble = SKNode()
        let label = SKLabelNode(text: text)
        label.fontName = "Menlo-Bold"; label.fontSize = 10; label.fontColor = .black
        let bg = SKShapeNode(rectOf: CGSize(width: label.frame.width + 16, height: 20), cornerRadius: 6)
        bg.fillColor = .white; bg.strokeColor = .black; bg.lineWidth = 1
        bubble.addChild(bg); bubble.addChild(label)
        bubble.position = CGPoint(x: 0, y: 60)
        petNode.addChild(bubble)
        self.speechBubble = bubble
        bubble.run(SKAction.sequence([SKAction.wait(forDuration: 3.5), SKAction.removeFromParent()]))
    }

    private func loadTexture(named name: String) -> SKTexture? {
        let texture = SKTexture(imageNamed: name)
        texture.filteringMode = .nearest
        return texture
    }

    private func createItemNode(for item: ShopItem) -> SKSpriteNode {
        let node: SKSpriteNode
        if let texture = loadTexture(named: item.spriteName) {
            node = SKSpriteNode(texture: texture)
        } else {
            node = SKSpriteNode(color: SKColor.gray, size: CGSize(width: 40, height: 40))
        }
        node.anchorPoint = CGPoint(x: 0.5, y: 0) // Align items by feet too
        return node
    }

    #if os(iOS)
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let loc = touch.location(in: self)
            let tappedNodes = nodes(at: loc)
            for node in tappedNodes {
                if node.name == "pet" {
                    visualNode.run(SKAction.sequence([
                        SKAction.scale(to: petBaseScale * 1.2, duration: 0.1),
                        SKAction.scale(to: petBaseScale, duration: 0.1)
                    ]))
                    return
                }
            }
        }
    }
    #endif

    func showCoinShower() {
        for _ in 0..<8 {
            let coin = SKLabelNode(text: "🪙")
            coin.fontSize = 18
            coin.position = CGPoint(x: petNode.position.x + CGFloat.random(in: -20...20), y: petNode.position.y + 50)
            addChild(coin)
            let move = SKAction.moveBy(x: CGFloat.random(in: -30...30), y: 100, duration: 0.8)
            coin.run(SKAction.sequence([move, SKAction.fadeOut(withDuration: 0.2), SKAction.removeFromParent()]))
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
            let dest = CGPoint(x: petNode.position.x + CGFloat.random(in: -40...40), y: petNode.position.y + CGFloat.random(in: 0...60))
            s.run(SKAction.sequence([SKAction.move(to: dest, duration: 0.6), SKAction.fadeOut(withDuration: 0.2), SKAction.removeFromParent()]))
        }
    }

    func takeWidgetSnapshot() {
        guard let view = self.view else { return }
        let renderer = UIGraphicsImageRenderer(size: view.bounds.size)
        let image = renderer.image { ctx in
            view.drawHierarchy(in: view.bounds, afterScreenUpdates: true)
        }
        WidgetDataService.shared.saveRoomSnapshot(image)
    }
}
