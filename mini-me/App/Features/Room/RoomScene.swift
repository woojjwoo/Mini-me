import SpriteKit

class RoomScene: SKScene {
    private var room: Room
    private var pet: Pet?
    private var currentMood: PetMood
    private var currentActivity: PetActivity = .idling
    /// Which scene background to render (drives `room_<scene>_empty.png` lookup
    /// and per-activity character pose for the widget pipeline).
    /// Defaults to `room.roomType` if nil at init.
    private var sceneRoomType: RoomType
    private var slotNodes: [String: SKSpriteNode] = [:]
    private var roomOrigin: CGPoint = .zero
    private var assetScale: CGFloat = 1.2

    // Character Nodes
    private var petNode = SKNode()
    private var visualNode = SKSpriteNode()
    private var shadowNode = SKShapeNode()
    private var speechBubble: SKNode?

    // Friend Nodes — keyed by userID, shown during social blocks
    private var friendNodes: [String: SKNode] = [:]

    /// Up to 3 friend slot offsets relative to roomOrigin (isometric floor positions)
    private let friendSlotOffsets: [CGPoint] = [
        CGPoint(x: 62, y: 6),
        CGPoint(x: 108, y: -8),
        CGPoint(x: -58, y: 6)
    ]

    // Lighting
    private var lastAppliedHour: Int = -1

    // Physical Constants
    private let petBaseScale: CGFloat = 0.22
    private var spawnPoint: CGPoint {
        // Center of the floor area in the scene background
        return CGPoint(x: roomOrigin.x, y: roomOrigin.y - 20)
    }

    /// Optional frame index for animated-widget pre-baking. When set, the
    /// character sprite lookup tries `minime_<activity>_f<frameIndex>` first
    /// before falling back to the unsuffixed sprite. Has no effect at runtime
    /// inside the main app (always nil there); only used by WidgetSnapshotBakery
    /// to produce per-frame snapshot variants.
    private let spriteFrameIndex: Int?

    init(
        room: Room,
        pet: Pet?,
        mood: PetMood,
        streakCount: Int,
        size: CGSize,
        sceneRoomType: RoomType? = nil,
        initialActivity: PetActivity = .idling,
        spriteFrameIndex: Int? = nil
    ) {
        self.room = room
        self.pet = pet
        self.currentMood = mood
        self.sceneRoomType = sceneRoomType ?? (RoomType(rawValue: room.roomTypeRaw) ?? .bedroom)
        self.currentActivity = initialActivity
        self.spriteFrameIndex = spriteFrameIndex
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

        // 1. Background — looked up by sceneRoomType.
        // We try, in order:
        //   1. `room_<scene>_empty` (the new widget-pivot scene PNGs from /art)
        //   2. `room_bedroom_empty` (existing canonical bedroom)
        //   3. `room_base_lofi_v2_1774708398444` (legacy fallback so we never
        //      ship a blank background while sprites are still being produced)
        let bgCandidates = [
            "room_\(sceneRoomType.rawValue)_empty",
            "room_bedroom_empty",
            "room_base_lofi_v2_1774708398444"
        ]
        if let bgName = bgCandidates.first(where: { UIImage(named: $0) != nil }),
           let bgTexture = loadTexture(named: bgName) {
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

        // Apply current time-of-day lighting immediately on load
        let hour = Calendar.current.component(.hour, from: .now)
        lastAppliedHour = hour
        applyTimeOfDay(TimeOfDayService.phase(forHour: hour))
    }

    private func setupPet() {
        // 1. Shadow (Stays flat on floor)
        shadowNode = SKShapeNode(ellipseOf: CGSize(width: 30, height: 10))
        shadowNode.fillColor = .black.withAlphaComponent(0.2)
        shadowNode.strokeColor = .clear
        shadowNode.zPosition = -1
        worldLayer.addChild(shadowNode)

        // 2. Visual Sprite — initial texture comes from current activity,
        // not just current mood. This way an off-screen render call that
        // sets initialActivity = .working will paint the working pose
        // before any update loop runs.
        let spriteName = textureNameForActivity(currentActivity)
        visualNode = SKSpriteNode(texture: loadTexture(named: spriteName))

        // CRITICAL FIX: Anchor Point at Feet
        visualNode.anchorPoint = CGPoint(x: 0.5, y: 0)
        visualNode.setScale(petBaseScale)

        // 3. Pet Root Node (Handles Floor Position)
        petNode.addChild(visualNode)
        worldLayer.addChild(petNode)
        petNode.name = "pet"

        // CRITICAL FIX: Spawn inside the room, not at (0,0).
        // Position is also driven by activity (e.g. working → at desk).
        petNode.position = positionForActivity(currentActivity)

        startLifeAnimations()
    }

    /// Where in the scene the character stands for a given activity.
    /// Uses `PetActivity.roomOffset` (already defined on the model) but
    /// transformed into scene coordinates.
    private func positionForActivity(_ activity: PetActivity) -> CGPoint {
        let offset = activity.roomOffset
        return CGPoint(
            x: roomOrigin.x + (offset.x * assetScale),
            y: roomOrigin.y + (offset.y * assetScale)
        )
    }

    override func update(_ currentTime: TimeInterval) {
        // Continuous Y-Sorting for Depth
        for node in worldLayer.children {
            if node == shadowNode { continue }
            node.zPosition = -node.position.y
        }
        shadowNode.position = petNode.position

        // Time-of-day lighting — cheap hour comparison, acts at most once per hour
        let hour = Calendar.current.component(.hour, from: .now)
        if hour != lastAppliedHour {
            lastAppliedHour = hour
            applyTimeOfDay(TimeOfDayService.phase(forHour: hour))
        }
    }

    func applyTimeOfDay(_ tod: TimeOfDay) {
        childNode(withName: "timeOverlay")?.removeFromParent()
        guard tod != .day else { return }

        let (r, g, b, a): (CGFloat, CGFloat, CGFloat, CGFloat)
        switch tod {
        case .morning: (r, g, b, a) = (1.0, 0.60, 0.20, 0.10)
        case .sunset:  (r, g, b, a) = (0.90, 0.30, 0.10, 0.18)
        case .night:   (r, g, b, a) = (0.10, 0.05, 0.40, 0.28)
        case .day:     return
        }

        let overlay = SKSpriteNode(
            color: SKColor(red: r, green: g, blue: b, alpha: 1),
            size: self.size
        )
        overlay.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        overlay.position = CGPoint(x: size.width / 2, y: size.height / 2)
        overlay.zPosition = 500
        overlay.name = "timeOverlay"
        overlay.alpha = 0
        addChild(overlay)
        overlay.run(SKAction.fadeAlpha(to: a, duration: 2.0))
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

    /// Map each PetActivity to its sprite asset name, with graceful fallback
    /// when the activity-specific sprite hasn't been produced yet.
    /// Production order (per docs/SPRITE_PRODUCTION_MANIFEST.md):
    ///   minime_working, minime_exercising, minime_eating, minime_reading,
    ///   minime_socializing — each falls back to `minime_idle` until landed.
    private func textureNameForActivity(_ activity: PetActivity) -> String {
        let preferred: String
        switch activity {
        case .sleeping: preferred = "minime_sleeping"
        case .working: preferred = "minime_working"
        case .reading: preferred = "minime_reading"
        case .eating: preferred = "minime_eating"
        case .stretching: preferred = "minime_exercising"
        case .slacking: preferred = "minime_socializing"
        case .walking, .idling: preferred = "minime_idle"
        }

        // If the bakery requested a specific frame variant for animation
        // (e.g. `minime_working_f2`), try it first. Falls back gracefully
        // to the base sprite when the variant hasn't been generated yet.
        if let frame = spriteFrameIndex {
            let framed = "\(preferred)_f\(frame)"
            if UIImage(named: framed) != nil { return framed }
        }

        // Try the preferred new-style name; fall back to legacy timestamped
        // name (still in xcassets) if the new sprite hasn't landed yet; final
        // fallback is the timestamped idle.
        if UIImage(named: preferred) != nil { return preferred }
        let legacy: String
        switch activity {
        case .sleeping: legacy = "minime_sleeping_1774711364657"
        default: legacy = "minime_idle_1774711350053"
        }
        return legacy
    }

    /// Returns true when at least one frame variant exists for the given
    /// activity (`minime_<activity>_f1` through `_f3`). Used by the bakery
    /// to skip re-renders when a pose has no animation art yet.
    static func hasFrameVariants(for activity: PetActivity) -> Bool {
        let base: String
        switch activity {
        case .sleeping:                  base = "minime_sleeping"
        case .working:                   base = "minime_working"
        case .reading:                   base = "minime_reading"
        case .eating:                    base = "minime_eating"
        case .stretching:                base = "minime_exercising"
        case .slacking:                  base = "minime_socializing"
        case .walking, .idling:          base = "minime_idle"
        }
        return UIImage(named: "\(base)_f1") != nil
    }

    /// Public API: switch the character's activity (and pose) live.
    /// Used by the schedule pipeline when a block becomes active.
    func setActivity(_ activity: PetActivity) {
        currentActivity = activity
        // Swap to the new sprite
        if let texture = loadTexture(named: textureNameForActivity(activity)) {
            visualNode.texture = texture
            visualNode.size = texture.size()
        }
        // Walk to the activity's location
        let target = positionForActivity(activity)
        walkTo(target: target) { [weak self] in
            self?.applyActivityPose(activity)
        }
    }

    /// Public API: re-skin the scene for a different RoomType. Tears down
    /// and rebuilds — appropriate for off-screen pre-baking, not live use.
    func setSceneRoomType(_ roomType: RoomType) {
        sceneRoomType = roomType
        setupRoom()
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
        guard let touch = touches.first else { return }
        let loc = touch.location(in: self)
        let tappedNodes = nodes(at: loc)
        for node in tappedNodes {
            // Own pet tap
            if node.name == "pet" {
                visualNode.run(SKAction.sequence([
                    SKAction.scale(to: petBaseScale * 1.2, duration: 0.1),
                    SKAction.scale(to: petBaseScale, duration: 0.1)
                ]))
                return
            }
            // Friend tap — name is "friend_<userID>"
            if let name = node.name, name.hasPrefix("friend_") {
                let userID = String(name.dropFirst("friend_".count))
                // Walk up to the container node
                let containerNode = friendNodes[userID] ?? node
                if let friend = friendPresence(for: userID) {
                    showFriendReaction(for: friend, node: containerNode)
                }
                return
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

    // MARK: - Friend Presence

    /// Call this whenever friend presence or current activity changes.
    /// Shows up to 3 friends' mini-mes in the scene during social blocks,
    /// removes them all otherwise.
    func updateFriends(_ friends: [FriendPresence], isSocialBlock: Bool) {
        // Remove nodes for friends no longer present
        let incomingIDs = Set(isSocialBlock ? friends.prefix(3).map(\.userID) : [])
        for (uid, node) in friendNodes where !incomingIDs.contains(uid) {
            node.run(SKAction.sequence([
                SKAction.fadeOut(withDuration: 0.3),
                SKAction.removeFromParent()
            ]))
            friendNodes.removeValue(forKey: uid)
        }

        guard isSocialBlock else { return }

        let slots = friendSlotOffsets
        for (index, friend) in friends.prefix(3).enumerated() {
            guard friendNodes[friend.userID] == nil else { continue }

            let offset = slots[index]
            let pos = CGPoint(
                x: roomOrigin.x + offset.x * assetScale,
                y: roomOrigin.y + offset.y * assetScale
            )

            let container = SKNode()
            container.position = pos
            container.name = "friend_\(friend.userID)"
            container.alpha = 0

            // Sprite
            let spriteName = UIImage(named: "minime_socializing") != nil ? "minime_socializing" : "minime_idle_1774711350053"
            let sprite = SKSpriteNode(texture: loadTexture(named: spriteName))
            sprite.setScale(petBaseScale * 0.9)
            sprite.anchorPoint = CGPoint(x: 0.5, y: 0)
            sprite.name = "friend_\(friend.userID)"
            container.addChild(sprite)

            // Name label
            let label = SKLabelNode(text: friend.displayName)
            label.fontName = "Menlo-Bold"
            label.fontSize = 8
            label.fontColor = SKColor(red: 0.97, green: 0.90, blue: 0.83, alpha: 1)
            label.position = CGPoint(x: 0, y: sprite.size.height * petBaseScale * 0.9 + 6)
            label.name = "friend_\(friend.userID)"
            container.addChild(label)

            // Gentle breathe
            let breathe = SKAction.repeatForever(SKAction.sequence([
                SKAction.scaleX(to: petBaseScale * 0.9 * 1.01, y: petBaseScale * 0.9 * 0.99, duration: 1.8),
                SKAction.scaleX(to: petBaseScale * 0.9 * 0.99, y: petBaseScale * 0.9 * 1.01, duration: 1.8)
            ]))
            sprite.run(breathe, withKey: "breathe")

            worldLayer.addChild(container)
            container.run(SKAction.fadeIn(withDuration: 0.4))
            friendNodes[friend.userID] = container
        }
    }

    /// Show a floating "Hi!" reaction above a friend's sprite.
    private func showFriendReaction(for friend: FriendPresence, node: SKNode) {
        let bubble = SKNode()
        let label = SKLabelNode(text: "Hi from \(friend.displayName)! 👋")
        label.fontName = "Menlo-Bold"
        label.fontSize = 9
        label.fontColor = .black
        let bg = SKShapeNode(
            rectOf: CGSize(width: label.frame.width + 14, height: 18),
            cornerRadius: 5
        )
        bg.fillColor = SKColor(red: 1.0, green: 0.95, blue: 0.78, alpha: 1)
        bg.strokeColor = SKColor(red: 0.18, green: 0.12, blue: 0.04, alpha: 0.8)
        bg.lineWidth = 1
        bubble.addChild(bg)
        bubble.addChild(label)
        bubble.position = CGPoint(x: 0, y: 44)
        node.addChild(bubble)
        bubble.run(SKAction.sequence([
            SKAction.wait(forDuration: 2.5),
            SKAction.fadeOut(withDuration: 0.3),
            SKAction.removeFromParent()
        ]))
        // Bounce the friend sprite
        if let sprite = node.children.first(where: { $0.name?.hasPrefix("friend_") == true }) as? SKSpriteNode {
            sprite.run(SKAction.sequence([
                SKAction.scale(to: petBaseScale * 0.9 * 1.15, duration: 0.1),
                SKAction.scale(to: petBaseScale * 0.9, duration: 0.1)
            ]))
        }
    }

    /// Convenience: find a FriendPresence by userID from the live service.
    private func friendPresence(for userID: String) -> FriendPresence? {
        FriendPresenceService.shared.friends.first { $0.userID == userID }
    }

    /// Capture the scene's current state as a UIImage and write it to the App
    /// Group container. Saves under BOTH the scene-specific filename
    /// (`room_diorama_<scene>_<activity>.png`) AND the generic fallback
    /// (`room_diorama.png`) — the widget tries the scene-specific one first
    /// and uses the generic one only if missing.
    func takeWidgetSnapshot() {
        guard let view = self.view else { return }
        let renderer = UIGraphicsImageRenderer(size: view.bounds.size)
        let image = renderer.image { ctx in
            view.drawHierarchy(in: view.bounds, afterScreenUpdates: true)
        }
        WidgetDataService.shared.saveRoomSnapshot(image)
        WidgetDataService.shared.saveSceneSnapshot(image, scene: sceneRoomType, activity: currentActivity)
    }
}
