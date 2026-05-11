import SwiftUI

// Pixel art character renderer for onboarding + settings.
// Grid: 20×30 pixels, each pixel = 7pt → 140×210pt frame.
struct MiniMeAvatarView: View {
    var hairStyle: HairStyle = .short
    var hairColor: HairColor = .black
    var skinTone: SkinTone = .fair
    var eyeSize: EyeSize = .medium
    var outfitStyle: OutfitStyle = .casual
    var faceShape: FaceShape = .round
    var shirtColorOverride: Color? = nil
    var shoeColorOverride: Color? = nil
    /// Points per pixel. Default 7 (onboarding). Use larger values (e.g. 20) for SpriteKit texture export.
    var pixelSize: CGFloat = 7

    private var ps: CGFloat { pixelSize }

    var body: some View {
        Canvas { context, _ in
            let skin  = skinTone.color
            let shade = skinTone.shadowColor
            let hair  = hairColor.color
            let shirt = shirtColorOverride ?? outfitStyle.shirtColor
            let pants = outfitStyle.pantsColor
            let shoe  = shoeColorOverride ?? outfitStyle.shoeColor

            // Helper: fill a rectangle at grid (col, row) with optional dimensions
            func px(_ c: Int, _ r: Int, _ w: Int, _ h: Int, _ color: Color) {
                context.fill(
                    Path(CGRect(x: CGFloat(c) * ps, y: CGFloat(r) * ps,
                                width: CGFloat(w) * ps, height: CGFloat(h) * ps)),
                    with: .color(color)
                )
            }

            // ── LAYER 1: HAIR BACK (side locks behind head for long/medium) ──────
            switch hairStyle {
            case .long:
                px(3, 4, 2, 9, hair)    // left long lock behind head
                px(15, 4, 2, 9, hair)   // right long lock
                px(3, 13, 2, 5, hair)   // continues past neck
                px(15, 13, 2, 5, hair)
            case .medium:
                px(3, 4, 2, 6, hair)
                px(15, 4, 2, 6, hair)
            default: break
            }

            // ── LAYER 2: HEAD (skin with light shading) ──────────────────────────
            switch faceShape {
            case .round:
                px(7,  3, 6, 1, skin)
                px(6,  4, 8, 1, skin)
                px(5,  5, 10, 6, skin)
                px(6, 11, 8, 1, skin)
                px(7, 12, 6, 1, skin)
                px(14, 5, 1, 6, shade)
            case .angular:
                px(6,  3, 8, 2, skin)
                px(5,  5, 10, 6, skin)
                px(6, 11, 8, 2, skin)
                px(14, 3, 1, 8, shade)
            case .soft:
                px(8,  3, 4, 1, skin)
                px(7,  4, 6, 1, skin)
                px(5,  5, 10, 5, skin)
                px(6, 10, 8, 1, skin)
                px(7, 11, 6, 1, skin)
                px(8, 12, 4, 1, skin)
                px(14, 5, 1, 5, shade)
            }

            // ── LAYER 3: NECK ────────────────────────────────────────────────────
            px(8, 13, 4, 2, skin)

            // ── LAYER 4: TORSO (shirt) ───────────────────────────────────────────
            px(5, 15, 10, 7, shirt)     // main torso

            // ── LAYER 5: ARMS (shirt sleeves) ────────────────────────────────────
            px(2, 15, 4, 6, shirt)      // left arm
            px(14, 15, 4, 6, shirt)     // right arm

            // ── LAYER 6: HANDS (skin) ────────────────────────────────────────────
            px(1, 20, 4, 3, skin)       // left hand
            px(15, 20, 4, 3, skin)      // right hand

            // ── LAYER 7: LEGS (pants) ────────────────────────────────────────────
            px(5, 22, 4, 6, pants)      // left leg
            px(11, 22, 4, 6, pants)     // right leg

            // ── LAYER 8: SHOES ───────────────────────────────────────────────────
            px(4, 27, 6, 2, shoe)       // left shoe (slightly wider than leg)
            px(10, 27, 6, 2, shoe)      // right shoe

            // ── LAYER 9: OUTFIT DETAILS ──────────────────────────────────────────
            switch outfitStyle {
            case .formal:
                px(8, 15, 4, 2, .white)         // shirt collar
                if let acc = outfitStyle.accentColor {
                    px(9, 16, 2, 5, acc)         // tie
                }
            case .sporty:
                if let acc = outfitStyle.accentColor {
                    px(2, 18, 4, 1, acc)         // left sleeve stripe
                    px(14, 18, 4, 1, acc)        // right sleeve stripe
                }
            case .cozy:
                // Sweater ribbing hints
                for r in [16, 18, 20] {
                    px(5, r, 10, 1, shirt.opacity(0.55))
                }
            case .street:
                if let acc = outfitStyle.accentColor {
                    px(8, 17, 4, 1, acc.opacity(0.5))   // graphic element
                }
            default: break
            }

            // ── LAYER 10: HAIR TOP ───────────────────────────────────────────────
            switch hairStyle {
            case .short:
                px(6,  2, 8, 2, hair)       // top cap
                px(5,  3, 1, 2, hair)        // left side
                px(14, 3, 1, 2, hair)        // right side

            case .medium:
                px(6,  1, 8, 3, hair)
                px(5,  2, 2, 3, hair)
                px(13, 2, 2, 3, hair)
                px(4,  3, 1, 2, hair)
                px(15, 3, 1, 2, hair)

            case .long:
                px(6,  1, 8, 3, hair)
                px(5,  2, 2, 3, hair)
                px(13, 2, 2, 3, hair)
                px(4,  3, 1, 2, hair)
                px(15, 3, 1, 2, hair)

            case .spiky:
                // Three jagged spikes
                px(6,  1, 2, 2, hair)       // spike left
                px(9,  0, 2, 3, hair)       // spike center (tallest)
                px(12, 1, 2, 2, hair)       // spike right
                px(5,  3, 10, 1, hair)      // base connecting row
                px(5,  2, 1, 1, hair)
                px(14, 2, 1, 1, hair)

            case .bun:
                px(8,  0, 4, 3, hair)       // the bun circle
                px(6,  2, 8, 2, hair)       // base connecting bun to head
                px(5,  3, 1, 2, hair)
                px(14, 3, 1, 2, hair)

            case .pixie:
                px(4,  2, 12, 2, hair)      // wide top base
                px(4,  1, 5, 2, hair)       // left-side sweep
                px(4,  3, 1, 2, hair)       // left edge
                px(14, 3, 1, 1, hair)       // right edge (shorter = asymmetric)
            }

            // ── LAYER 11: EYEBROWS ───────────────────────────────────────────────
            let brow = hair.opacity(0.85)
            let browRow = eyeSize == .large ? 5 : 6
            px(6,  browRow, 2, 1, brow)
            px(12, browRow, 2, 1, brow)

            // ── LAYER 12: EYES ───────────────────────────────────────────────────
            let eyeBlack = Color(hex: "1A1A1A")
            let hilight  = Color.white.opacity(0.75)
            switch eyeSize {
            case .small:
                px(7,  7, 1, 1, eyeBlack)
                px(12, 7, 1, 1, eyeBlack)

            case .medium:
                px(6,  7, 2, 1, eyeBlack)
                px(12, 7, 2, 1, eyeBlack)
                px(7,  7, 1, 1, hilight)     // sparkle
                px(13, 7, 1, 1, hilight)

            case .large:
                px(6,  6, 2, 2, eyeBlack)
                px(12, 6, 2, 2, eyeBlack)
                // Iris
                px(6,  7, 1, 1, Color(hex: "4488CC"))
                px(12, 7, 1, 1, Color(hex: "4488CC"))
                // Sparkle
                px(7,  6, 1, 1, hilight)
                px(13, 6, 1, 1, hilight)
            }

            // ── LAYER 13: MOUTH ──────────────────────────────────────────────────
            let lip = eyeBlack.opacity(0.65)
            px(7,  9, 1, 1, lip)            // left corner
            px(8,  10, 4, 1, lip)           // bottom curve
            px(11, 9, 1, 1, lip)            // right corner

            // ── LAYER 14: BLUSH ──────────────────────────────────────────────────
            let blush = Color(hex: "FF9BAA").opacity(0.55)
            px(5,  8, 2, 1, blush)
            px(13, 8, 2, 1, blush)
        }
        .frame(width: 20 * ps, height: 30 * ps)
        .compositingGroup()
    }
}

#Preview {
    HStack(spacing: 20) {
        MiniMeAvatarView(hairStyle: .long, hairColor: .pink, skinTone: .light, eyeSize: .large, outfitStyle: .casual, faceShape: .round)
        MiniMeAvatarView(hairStyle: .spiky, hairColor: .blue, skinTone: .medium, eyeSize: .medium, outfitStyle: .street, faceShape: .angular)
        MiniMeAvatarView(hairStyle: .bun, hairColor: .brown, skinTone: .tan, eyeSize: .small, outfitStyle: .formal, faceShape: .soft)
    }
    .padding()
    .background(Color(hex: "F5E6D3"))
}
