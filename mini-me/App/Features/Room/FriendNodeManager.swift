import SpriteKit
import UIKit

/// Owns the SpriteKit node graph for visiting friend mini-mes during social
/// blocks. Extracted from RoomScene so the scene file stays focused on the
/// player character + room rendering.
///
/// Architecture:
///   - `RoomScene` owns one `FriendNodeManager` and forwards `updateFriends`
///     calls to it.
///   - The manager attaches/removes friend container nodes under a parent
///     world layer (passed in at init).
///   - Touch handling stays in the scene; the scene calls `tappedFriend(at:)`
///     to find the right friend and shows a reaction via `showReaction`.
final class FriendNodeManager {

    // MARK: - Configuration

    /// Where the player character is rendered, in scene coordinates. The
    /// manager places friends at offsets relative to this point.
    var roomOrigin: CGPoint

    /// Asset scale applied uniformly to room layout (mirrors `RoomScene`).
    var assetScale: CGFloat

    /// Base scale used for the player character. Friends render at 0.9× this.
    let petBaseScale: CGFloat

    /// Up to 3 friend slot offsets relative to roomOrigin (isometric floor).
    /// Tuned for the coffee shop scene; visible during social blocks only.
    private let friendSlotOffsets: [CGPoint] = [
        CGPoint(x: 62, y: 6),
        CGPoint(x: 108, y: -8),
        CGPoint(x: -58, y: 6)
    ]

    // MARK: - State

    /// Parent layer the friend container nodes attach to. Set to the scene's
    /// `worldLayer` so friends Y-sort correctly with other floor objects.
    private weak var parentLayer: SKNode?

    /// Friend container nodes keyed by userID. Each container holds the
    /// sprite + name label + breathing animation.
    private var friendNodes: [String: SKNode] = [:]

    // MARK: - Init

    init(parentLayer: SKNode, roomOrigin: CGPoint, assetScale: CGFloat, petBaseScale: CGFloat) {
        self.parentLayer = parentLayer
        self.roomOrigin = roomOrigin
        self.assetScale = assetScale
        self.petBaseScale = petBaseScale
    }

    // MARK: - Public API

    /// Add/remove friend nodes to match the incoming list. When
    /// `isSocialBlock` is false (or list is empty), all friends fade out.
    func update(friends: [FriendPresence], isSocialBlock: Bool) {
        // Remove nodes for friends no longer present
        let incomingIDs = Set(isSocialBlock ? friends.prefix(3).map(\.userID) : [])
        for (uid, node) in friendNodes where !incomingIDs.contains(uid) {
            // Stop child animations before removing — defensive against retain
            // cycles when many friends churn in/out across short time windows.
            node.removeAllActions()
            for child in node.children {
                child.removeAllActions()
            }
            node.run(SKAction.sequence([
                SKAction.fadeOut(withDuration: 0.3),
                SKAction.removeFromParent()
            ]))
            friendNodes.removeValue(forKey: uid)
        }

        guard isSocialBlock, let parent = parentLayer else { return }

        for (index, friend) in friends.prefix(3).enumerated() {
            guard friendNodes[friend.userID] == nil else { continue }

            let offset = friendSlotOffsets[index]
            let pos = CGPoint(
                x: roomOrigin.x + offset.x * assetScale,
                y: roomOrigin.y + offset.y * assetScale
            )

            let container = makeFriendNode(friend: friend, at: pos)
            parent.addChild(container)
            container.run(SKAction.fadeIn(withDuration: 0.4))
            friendNodes[friend.userID] = container
        }
    }

    /// Find the friend container at a touch location. Returns the userID and
    /// the container node so the caller can attach a reaction bubble.
    func tappedFriend(at nodes: [SKNode]) -> (userID: String, node: SKNode)? {
        for node in nodes {
            guard let name = node.name, name.hasPrefix("friend_") else { continue }
            let userID = String(name.dropFirst("friend_".count))
            let container = friendNodes[userID] ?? node
            return (userID, container)
        }
        return nil
    }

    /// Show a floating "Hi!" reaction above the given friend's container.
    func showReaction(for friend: FriendPresence, on node: SKNode) {
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

        // Bounce the friend sprite for tactile feedback
        if let sprite = node.children.first(where: { $0.name?.hasPrefix("friend_") == true }) as? SKSpriteNode {
            sprite.run(SKAction.sequence([
                SKAction.scale(to: petBaseScale * 0.9 * 1.15, duration: 0.1),
                SKAction.scale(to: petBaseScale * 0.9, duration: 0.1)
            ]))
        }
    }

    // MARK: - Internal

    private func makeFriendNode(friend: FriendPresence, at pos: CGPoint) -> SKNode {
        let container = SKNode()
        container.position = pos
        container.name = "friend_\(friend.userID)"
        container.alpha = 0

        // Sprite: prefer activity-matched if landed, fall back to socializing,
        // then to legacy idle so the widget never crashes pre-art.
        let preferredName = spriteName(for: friend.activity)
        let textureName: String = {
            if UIImage(named: preferredName) != nil { return preferredName }
            if UIImage(named: "minime_socializing") != nil { return "minime_socializing" }
            return "minime_idle_1774711350053"
        }()
        let texture = SKTexture(imageNamed: textureName)
        texture.filteringMode = .nearest

        let sprite = SKSpriteNode(texture: texture)
        sprite.setScale(petBaseScale * 0.9)
        sprite.anchorPoint = CGPoint(x: 0.5, y: 0)
        sprite.name = "friend_\(friend.userID)"
        container.addChild(sprite)

        // Name label above the sprite
        let label = SKLabelNode(text: friend.displayName)
        label.fontName = "Menlo-Bold"
        label.fontSize = 8
        label.fontColor = SKColor(red: 0.97, green: 0.90, blue: 0.83, alpha: 1)
        label.position = CGPoint(x: 0, y: sprite.size.height * petBaseScale * 0.9 + 6)
        label.name = "friend_\(friend.userID)"
        container.addChild(label)

        // Gentle breathe — same magnitude as the player character
        let s = petBaseScale * 0.9
        let breathe = SKAction.repeatForever(SKAction.sequence([
            SKAction.scaleX(to: s * 1.01, y: s * 0.99, duration: 1.8),
            SKAction.scaleX(to: s * 0.99, y: s * 1.01, duration: 1.8)
        ]))
        sprite.run(breathe, withKey: "breathe")

        return container
    }

    /// Map a friend's PetActivity to a sprite name, mirroring the resolver
    /// used by FriendPresence.sprite (UIKit) and RoomScene.textureNameForActivity.
    private func spriteName(for activity: PetActivity) -> String {
        switch activity {
        case .sleeping:   return "minime_sleeping"
        case .working:    return "minime_working"
        case .reading:    return "minime_reading"
        case .eating:     return "minime_eating"
        case .stretching: return "minime_exercising"
        case .slacking:   return "minime_socializing"
        case .walking, .idling: return "minime_idle"
        }
    }
}
