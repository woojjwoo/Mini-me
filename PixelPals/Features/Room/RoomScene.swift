import SpriteKit

/// SpriteKit scene that renders the isometric room with pre-set slots.
/// Each slot has a fixed position — no grid math, no z-sorting complexity.
class RoomScene: SKScene {
    private var room: Room
    private var slotNodes: [String: SKSpriteNode] = [:] // slotType -> node

    init(room: Room, size: CGSize) {
        self.room = room
        super.init(size: size)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func didMove(to view: SKView) {
        backgroundColor = .clear
        setupRoom()
    }

    private func setupRoom() {
        removeAllChildren()

        let roomOrigin = CGPoint(x: size.width / 2, y: size.height / 2 - 40)

        // Draw floor (isometric diamond)
        let floor = createFloorNode()
        floor.position = roomOrigin
        floor.zPosition = 0
        addChild(floor)

        // Draw back walls
        let leftWall = createWallNode(isLeft: true)
        leftWall.position = CGPoint(x: roomOrigin.x - 100, y: roomOrigin.y + 80)
        leftWall.zPosition = 0.5
        addChild(leftWall)

        let rightWall = createWallNode(isLeft: false)
        rightWall.position = CGPoint(x: roomOrigin.x + 100, y: roomOrigin.y + 80)
        rightWall.zPosition = 0.5
        addChild(rightWall)

        // Place items in pre-set slots
        for slot in SlotType.allCases {
            guard let assignment = room.assignment(for: slot),
                  let itemID = assignment.itemID,
                  let item = ItemCatalog.item(byID: itemID) else {
                continue
            }

            let pos = slot.scenePosition
            let node = createItemNode(for: item)
            node.position = CGPoint(
                x: roomOrigin.x + pos.x,
                y: roomOrigin.y + pos.y
            )
            node.zPosition = slot.zPosition
            node.name = slot.rawValue
            addChild(node)
            slotNodes[slot.rawValue] = node
        }

        // Add pet
        addPetNode(at: roomOrigin)
    }

    // MARK: - Node Factories

    private func createFloorNode() -> SKShapeNode {
        // Isometric diamond floor
        let path = CGMutablePath()
        let w: CGFloat = 200
        let h: CGFloat = 100
        path.move(to: CGPoint(x: 0, y: h))     // top
        path.addLine(to: CGPoint(x: w, y: 0))   // right
        path.addLine(to: CGPoint(x: 0, y: -h))  // bottom
        path.addLine(to: CGPoint(x: -w, y: 0))  // left
        path.closeSubpath()

        let node = SKShapeNode(path: path)
        node.fillColor = SKColor(red: 0.85, green: 0.78, blue: 0.68, alpha: 1.0) // warm wood
        node.strokeColor = SKColor(red: 0.7, green: 0.63, blue: 0.53, alpha: 1.0)
        node.lineWidth = 1
        return node
    }

    private func createWallNode(isLeft: Bool) -> SKShapeNode {
        let path = CGMutablePath()
        let w: CGFloat = 200
        let h: CGFloat = 100
        let wallH: CGFloat = 120

        if isLeft {
            path.move(to: CGPoint(x: -w, y: 0))
            path.addLine(to: CGPoint(x: 0, y: h))
            path.addLine(to: CGPoint(x: 0, y: h + wallH))
            path.addLine(to: CGPoint(x: -w, y: wallH))
            path.closeSubpath()
        } else {
            path.move(to: CGPoint(x: 0, y: h))
            path.addLine(to: CGPoint(x: w, y: 0))
            path.addLine(to: CGPoint(x: w, y: wallH))
            path.addLine(to: CGPoint(x: 0, y: h + wallH))
            path.closeSubpath()
        }

        let node = SKShapeNode(path: path)
        node.fillColor = isLeft ?
            SKColor(red: 0.92, green: 0.87, blue: 0.80, alpha: 1.0) :
            SKColor(red: 0.88, green: 0.83, blue: 0.76, alpha: 1.0)
        node.strokeColor = SKColor(red: 0.7, green: 0.63, blue: 0.53, alpha: 0.5)
        node.lineWidth = 1
        return node
    }

    private func createItemNode(for item: ShopItem) -> SKSpriteNode {
        // Try to load the sprite, fall back to a colored placeholder
        if let texture = loadTexture(named: item.spriteName) {
            let node = SKSpriteNode(texture: texture)
            node.setScale(2.0) // Scale up pixel art
            return node
        }

        // Placeholder: colored rectangle with label
        let node = SKSpriteNode(color: placeholderColor(for: item.category), size: CGSize(width: 40, height: 40))
        let label = SKLabelNode(text: String(item.name.prefix(4)))
        label.fontSize = 10
        label.fontName = "Menlo-Bold"
        label.fontColor = .white
        label.verticalAlignmentMode = .center
        node.addChild(label)
        return node
    }

    private func addPetNode(at origin: CGPoint) {
        // Placeholder pet — will be replaced with actual sprite
        let petNode = SKSpriteNode(color: SKColor(red: 1.0, green: 0.72, blue: 0.3, alpha: 1.0), size: CGSize(width: 24, height: 24))
        petNode.position = CGPoint(x: origin.x + 30, y: origin.y - 20)
        petNode.zPosition = 10
        petNode.name = "pet"

        // Idle animation: bob up and down
        let bobUp = SKAction.moveBy(x: 0, y: 4, duration: 1.0)
        let bobDown = SKAction.moveBy(x: 0, y: -4, duration: 1.0)
        bobUp.timingMode = .easeInEaseOut
        bobDown.timingMode = .easeInEaseOut
        let bob = SKAction.repeatForever(SKAction.sequence([bobUp, bobDown]))

        // Occasional wander: move to a random nearby spot, pause, return
        let wander = SKAction.repeatForever(SKAction.sequence([
            SKAction.wait(forDuration: 5.0, withRange: 4.0),
            SKAction.run { [weak petNode] in
                guard let petNode = petNode else { return }
                let dx = CGFloat.random(in: -40...40)
                let dy = CGFloat.random(in: -20...20)
                let target = CGPoint(x: origin.x + 30 + dx, y: origin.y - 20 + dy)

                // Flip direction based on movement
                let scaleX: CGFloat = dx < 0 ? -1.0 : 1.0
                let flip = SKAction.scaleX(to: scaleX, duration: 0.1)

                let walk = SKAction.move(to: target, duration: 1.2)
                walk.timingMode = .easeInEaseOut
                let pause = SKAction.wait(forDuration: 2.0, withRange: 1.5)
                let returnHome = SKAction.move(to: CGPoint(x: origin.x + 30, y: origin.y - 20), duration: 1.2)
                returnHome.timingMode = .easeInEaseOut
                let flipBack = SKAction.scaleX(to: 1.0, duration: 0.1)

                petNode.run(SKAction.sequence([flip, walk, pause, flipBack, returnHome]))
            }
        ]))

        // Occasional stretch: squash and stretch
        let stretch = SKAction.repeatForever(SKAction.sequence([
            SKAction.wait(forDuration: 8.0, withRange: 5.0),
            SKAction.scaleY(to: 0.7, duration: 0.15),
            SKAction.scaleY(to: 1.2, duration: 0.2),
            SKAction.scaleY(to: 1.0, duration: 0.15),
        ]))

        petNode.run(bob, withKey: "bob")
        petNode.run(wander, withKey: "wander")
        petNode.run(stretch, withKey: "stretch")

        addChild(petNode)
    }

    private func loadTexture(named name: String) -> SKTexture? {
        // Check if the asset exists in the bundle
        #if canImport(UIKit)
        guard let _ = UIImage(named: name) else { return nil }
        #elseif canImport(AppKit)
        guard let _ = NSImage(named: name) else { return nil }
        #endif
        let texture = SKTexture(imageNamed: name)
        texture.filteringMode = .nearest // Crisp pixel art rendering
        return texture
    }

    private func placeholderColor(for category: ItemCategory) -> SKColor {
        switch category {
        case .furniture: SKColor(red: 0.55, green: 0.38, blue: 0.26, alpha: 1.0)
        case .decor: SKColor(red: 0.36, green: 0.55, blue: 0.35, alpha: 1.0)
        case .electronics: SKColor(red: 0.3, green: 0.3, blue: 0.5, alpha: 1.0)
        case .cozy: SKColor(red: 0.8, green: 0.6, blue: 0.4, alpha: 1.0)
        case .fun: SKColor(red: 0.7, green: 0.3, blue: 0.5, alpha: 1.0)
        case .wallFloor: SKColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 1.0)
        }
    }

    // MARK: - Touch / Click (tap to select slot)

    #if os(iOS)
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        handleTap(at: location)
    }
    #elseif os(macOS)
    override func mouseDown(with event: NSEvent) {
        let location = event.location(in: self)
        handleTap(at: location)
    }
    #endif

    private func handleTap(at location: CGPoint) {
        let tappedNodes = nodes(at: location)

        for node in tappedNodes {
            if let name = node.name, SlotType(rawValue: name) != nil {
                HapticService.light()
                SoundService.playTapSound()

                // Pulse animation on tap
                let scale = SKAction.sequence([
                    SKAction.scale(to: 2.3, duration: 0.1),
                    SKAction.scale(to: 2.0, duration: 0.1),
                ])
                node.run(scale)
            } else if node.name == "pet" {
                // Pet interaction — tap the cat!
                HapticService.medium()

                let jump = SKAction.sequence([
                    SKAction.moveBy(x: 0, y: 12, duration: 0.15),
                    SKAction.moveBy(x: 0, y: -12, duration: 0.15),
                ])
                jump.timingMode = .easeOut
                let spin = SKAction.rotate(byAngle: .pi * 2, duration: 0.4)
                node.run(SKAction.group([jump, spin]))
            }
        }
    }
}
