import SpriteKit

class RoomScene: SKScene {
    private var room: Room
    private var pet: Pet?
    private var currentMood: PetMood
    private var slotNodes: [String: SKSpriteNode] = [:]
    private var roomOrigin: CGPoint = .zero
    private var assetScale: CGFloat = 1.2
    
    // Character Nodes
    private var petNode = SKNode() // Parent: Handles Position/Flipping
    private var visualNode = SKSpriteNode() // Child: Handles Texture/Blinking/Bobbing
    private var shadowNode = SKShapeNode()

    init(room: Room, pet: Pet?, mood: PetMood, size: CGSize) {
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

        // 1. Background
        if let bgTexture = loadTexture(named: "room_base_lofi_v2_1774708398444") {
            let bgNode = SKSpriteNode(texture: bgTexture)
            bgNode.position = roomOrigin
            bgNode.setScale(assetScale)
            bgNode.zPosition = -1000
            addChild(bgNode)
        }

        // 2. Items
        for slot in SlotType.allCases {
            guard let assignment = room.assignment(for: slot),
                  let itemID = assignment.itemID,
                  let item = ItemCatalog.item(byID: itemID) else { continue }

            let pos = slot.scenePosition
            let node = createItemNode(for: item)
            node.position = CGPoint(x: roomOrigin.x + (pos.x * assetScale), y: roomOrigin.y + (pos.y * assetScale))
            node.setScale(assetScale)
            node.zPosition = -node.position.y
            node.name = slot.rawValue
            worldLayer.addChild(node)
            slotNodes[slot.rawValue] = node
        }

        setupPet()
    }

    private func setupPet() {
        let petScale: CGFloat = 0.25
        
        // Shadow (Child of worldLayer, not petNode, to keep it flat on floor)
        shadowNode = SKShapeNode(ellipseOf: CGSize(width: 30, height: 10))
        shadowNode.fillColor = .black.withAlphaComponent(0.2)
        shadowNode.strokeColor = .clear
        shadowNode.zPosition = -1 // Bottom of worldLayer
        worldLayer.addChild(shadowNode)

        // Visual Sprite
        let spriteName = pet?.spriteName(for: currentMood) ?? "minime_idle_1774711350053"
        visualNode = SKSpriteNode(texture: loadTexture(named: spriteName))
        visualNode.anchorPoint = CGPoint(x: 0.5, y: 0)
        visualNode.setScale(petScale)
        
        // Pet Root Node
        petNode.addChild(visualNode)
        worldLayer.addChild(petNode)
        petNode.name = "pet"

        startLifeAnimations()
        updatePetPosition(for: currentMood, animated: false)
    }

    override func update(_ currentTime: TimeInterval) {
        // dynamic sorting
        for node in worldLayer.children {
            if node == shadowNode { continue }
            node.zPosition = -node.position.y
        }
        shadowNode.position = petNode.position
    }

    func updatePetPosition(for mood: PetMood, animated: Bool) {
        self.currentMood = mood
        
        // Update visual
        let spriteName = pet?.spriteName(for: mood) ?? "minime_idle_1774711350053"
        visualNode.texture = loadTexture(named: spriteName)

        let offset = mood.roomOffset
        let targetPos = CGPoint(x: roomOrigin.x + (offset.x * assetScale), y: roomOrigin.y + (offset.y * assetScale))

        if !animated {
            petNode.position = targetPos
            return
        }

        walkTo(target: targetPos)
    }

    private func walkTo(target: CGPoint) {
        petNode.removeAction(forKey: "walk")
        
        let isMovingLeft = target.x < petNode.position.x
        petNode.xScale = isMovingLeft ? -1 : 1 // Flip parent node

        // Stardew style hop on the VISUAL node (doesn't affect shadow/parent position)
        let hop = SKAction.sequence([
            SKAction.moveBy(x: 0, y: 10, duration: 0.15),
            SKAction.moveBy(x: 0, y: -10, duration: 0.15)
        ])
        
        let dist = hypot(target.x - petNode.position.x, target.y - petNode.position.y)
        let duration = Double(max(0.4, dist / 70.0))
        let hopCount = Int(duration / 0.3)
        
        let move = SKAction.move(to: target, duration: duration)
        let hops = SKAction.repeat(hop, count: hopCount)
        
        petNode.run(move, withKey: "walk")
        visualNode.run(hops)
    }

    private func startLifeAnimations() {
        // Breathing (on visualNode)
        let breathe = SKAction.repeatForever(SKAction.sequence([
            SKAction.scaleY(to: 0.24, duration: 1.5),
            SKAction.scaleY(to: 0.25, duration: 1.5)
        ]))
        visualNode.run(breathe, withKey: "breathe")

        // Blinking (on visualNode)
        let blink = SKAction.repeatForever(SKAction.sequence([
            SKAction.wait(forDuration: 4.0, withRange: 2.0),
            SKAction.scaleY(to: 0.05, duration: 0.05),
            SKAction.scaleY(to: 0.25, duration: 0.05)
        ]))
        visualNode.run(blink, withKey: "blink")
    }

    // MARK: - Handlers & Notifications

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
        HapticService.heavy()
    }

    private var speechBubble: SKNode?
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
        bubble.run(SKAction.sequence([SKAction.wait(forDuration: 3.0), SKAction.removeFromParent()]))
    }

    private func handleTap(at location: CGPoint) {
        let nodes = nodes(at: location)
        for node in nodes {
            if node.name == "pet" {
                showThought("Hey! ✨")
                visualNode.run(SKAction.sequence([SKAction.moveBy(x: 0, y: 30, duration: 0.1), SKAction.moveBy(x: 0, y: -30, duration: 0.1)]))
                return
            }
            if let name = node.name, let _ = SlotType(rawValue: name) {
                showThought("Nice spot! 👍")
                return
            }
        }
    }

    #if os(iOS)
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first { handleTap(at: touch.location(in: self)) }
    }
    #endif

    private func createItemNode(for item: ShopItem) -> SKSpriteNode {
        if let texture = loadTexture(named: item.spriteName) {
            let node = SKSpriteNode(texture: texture)
            node.anchorPoint = CGPoint(x: 0.5, y: 0)
            return node
        } else {
            let node = SKSpriteNode(color: .gray, size: CGSize(width: 40, height: 40))
            node.anchorPoint = CGPoint(x: 0.5, y: 0)
            return node
        }
    }

    private func loadTexture(named name: String) -> SKTexture? {
        let texture = SKTexture(imageNamed: name)
        texture.filteringMode = .nearest
        return texture
    }
}
