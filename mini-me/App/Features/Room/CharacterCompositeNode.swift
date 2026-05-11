import SpriteKit
import SwiftUI

// Manages the Mini Me character in the SpriteKit room as composited layers.
//
// Layer order (bottom → top):
//   body (skin)  →  outfit  →  hair  →  eyes
//
// When per-part sprite assets exist (minime_body_idle.png etc.) they are loaded
// and individually tinted. Until then the node falls back to rendering
// MiniMeAvatarView via ImageRenderer and uses body as the single full sprite.
//
// All public methods must be called on the main thread.
final class CharacterCompositeNode: SKNode {

    // MARK: - Layers

    private let bodyLayer   = SKSpriteNode()   // skin / full-composite fallback
    private let outfitLayer = SKSpriteNode()
    private let hairLayer   = SKSpriteNode()
    private let eyesLayer   = SKSpriteNode()

    // Rendered-texture cache keyed by character fingerprint
    private var textureCache: [String: SKTexture] = [:]

    // MARK: - Init

    override init() {
        super.init()
        let stack: [(SKSpriteNode, Int)] = [
            (bodyLayer, 0), (outfitLayer, 1), (hairLayer, 2), (eyesLayer, 3)
        ]
        for (layer, z) in stack {
            layer.anchorPoint = CGPoint(x: 0.5, y: 0)
            layer.zPosition   = CGFloat(z)
            addChild(layer)
        }
    }

    required init?(coder: NSCoder) { fatalError() }

    // MARK: - Public API

    /// Full update: picks layered sprites if available, otherwise composite render.
    func apply(pet: Pet, mood: PetMood) {
        let key = moodKey(mood)
        if hasLayeredSprites(moodKey: key) {
            applyLayered(pet: pet, moodKey: key)
        } else {
            applyComposite(pet: pet)
        }
    }

    /// Call after the user saves character changes so stale textures are discarded.
    func invalidateCache() {
        textureCache.removeAll()
    }

    // MARK: - Layered sprite path (production assets)

    private func hasLayeredSprites(moodKey: String) -> Bool {
        UIImage(named: "minime_body_\(moodKey)") != nil
    }

    private func applyLayered(pet: Pet, moodKey: String) {
        outfitLayer.isHidden = false
        hairLayer.isHidden   = false
        eyesLayer.isHidden   = false

        configure(bodyLayer,
                  imageName: "minime_body_\(moodKey)",
                  tint: UIColor(pet.skinTone.color),
                  blend: 1.0)

        configure(outfitLayer,
                  imageName: "minime_outfit_\(pet.characterOutfitStyle.rawValue)_\(moodKey)",
                  tint: UIColor(pet.characterOutfitStyle.shirtColor),
                  blend: 0.75)

        configure(hairLayer,
                  imageName: "minime_hair_\(pet.hairStyle.rawValue)_\(moodKey)",
                  tint: UIColor(pet.hairColor.color),
                  blend: 1.0)

        configure(eyesLayer,
                  imageName: "minime_eyes_\(pet.eyeSize.rawValue)_\(moodKey)",
                  tint: .clear,
                  blend: 0)
    }

    private func configure(_ node: SKSpriteNode, imageName: String, tint: UIColor, blend: CGFloat) {
        let tex = SKTexture(imageNamed: imageName)
        tex.filteringMode = .nearest
        node.texture          = tex
        node.size             = tex.size()
        node.color            = tint
        node.colorBlendFactor = blend
    }

    // MARK: - Composite render fallback (current mode — no per-part sprites yet)

    private func applyComposite(pet: Pet) {
        // Only the body layer is used; outfit/hair/eyes are hidden
        outfitLayer.isHidden = true
        hairLayer.isHidden   = true
        eyesLayer.isHidden   = true

        let overrides = resolveOutfitOverrides(pet: pet)
        let fingerprint = "\(pet.hairStyleRaw)|\(pet.hairColorRaw)|\(pet.skinToneRaw)|\(pet.eyeSizeRaw)|\(pet.outfitStyleRaw)|\(pet.faceShapeRaw)|\(overrides.shirt?.description ?? "")|\(overrides.shoe?.description ?? "")"
        let texture: SKTexture

        if let cached = textureCache[fingerprint] {
            texture = cached
        } else {
            texture = renderTexture(for: pet, shirtOverride: overrides.shirt, shoeOverride: overrides.shoe)
            textureCache[fingerprint] = texture
        }

        bodyLayer.texture          = texture
        bodyLayer.size             = texture.size()
        bodyLayer.colorBlendFactor = 0
        bodyLayer.isHidden         = false
    }

    /// Renders MiniMeAvatarView at a large pixel size so the SpriteKit scene can
    /// scale it down to the correct room size (petBaseScale ≈ 0.35).
    /// At pixelSize=18 the canvas is 360×540 pt → displayed at 79×119 pt in room.
    private func renderTexture(for pet: Pet, shirtOverride: Color?, shoeOverride: Color?) -> SKTexture {
        let view = MiniMeAvatarView(
            hairStyle:          pet.hairStyle,
            hairColor:          pet.hairColor,
            skinTone:           pet.skinTone,
            eyeSize:            pet.eyeSize,
            outfitStyle:        pet.characterOutfitStyle,
            faceShape:          pet.faceShape,
            shirtColorOverride: shirtOverride,
            shoeColorOverride:  shoeOverride,
            pixelSize:          18
        )

        let renderer   = ImageRenderer(content: view)
        renderer.scale = 1.0

        if let uiImage = renderer.uiImage {
            let tex = SKTexture(image: uiImage)
            tex.filteringMode = .nearest
            return tex
        }

        // Last-resort fallback: use the existing static sprite
        let fallback = SKTexture(imageNamed: "minime_idle_1774711350053")
        fallback.filteringMode = .nearest
        return fallback
    }

    // MARK: - Outfit Override Resolution

    private func resolveOutfitOverrides(pet: Pet) -> (shirt: Color?, shoe: Color?) {
        var shirt: Color? = nil
        var shoe: Color? = nil
        for id in pet.equippedOutfitIDs {
            guard let item = OutfitCatalog.outfit(byID: id) else { continue }
            switch item.outfitSlot {
            case .top:
                switch id {
                case "outfit_hoodie":   shirt = Color(hex: "C4956A")
                case "outfit_gymtank":  shirt = Color(hex: "E8985E")
                case "outfit_blazer":   shirt = Color(hex: "3D5A80")
                case "outfit_pajamas":  shirt = Color(hex: "8B6F5E")
                default: break
                }
            case .shoes:
                switch id {
                case "outfit_sneakers": shoe = Color(hex: "F0F0F0")
                case "outfit_slippers": shoe = Color(hex: "9B7B5A")
                default: break
                }
            default: break
            }
        }
        return (shirt, shoe)
    }

    // MARK: - Helpers

    private func characterFingerprint(pet: Pet) -> String {
        "\(pet.hairStyleRaw)|\(pet.hairColorRaw)|\(pet.skinToneRaw)|\(pet.eyeSizeRaw)|\(pet.outfitStyleRaw)|\(pet.faceShapeRaw)"
    }

    private func moodKey(_ mood: PetMood) -> String {
        switch mood {
        case .sleeping:               return "sleeping"
        case .happy, .celebrating:   return "happy"
        default:                      return "idle"
        }
    }
}
