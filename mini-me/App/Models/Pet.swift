import Foundation
import SwiftData
import CoreGraphics

enum PetMood: String, Codable {
    case sleeping
    case happy
    case neutral
    case bored
    case sad
    case celebrating
    case focused    // at desk
    case eating     // at floor/table
    case walking    // movement state

    var spriteSuffix: String {
        switch self {
        case .sleeping: "sleeping_1774711364657"
        case .happy: "happy_1774711380382"
        case .walking: "idle_1774711350053" // We'll animate this via code since we don't have a walk cycle yet
        case .focused, .neutral, .bored, .sad, .celebrating, .eating: "idle_1774711350053"
        }
    }

    // Offset in the cropped coordinate space relative to the room center
    var roomOffset: CGPoint {
        switch self {
        case .sleeping: return CGPoint(x: 45, y: 35)    // Deep on the bed
        case .focused: return CGPoint(x: -45, y: 35)   // At the desk
        case .eating: return CGPoint(x: 0, y: 0)       // Center floor
        default: return CGPoint(x: 0, y: -20)          // Lower floor
        }
    }

    var displayEmoji: String {
        switch self {
        case .sleeping: "😴"
        case .happy: "😊"
        case .neutral: "🙂"
        case .bored: "🥱"
        case .sad: "😢"
        case .celebrating: "🥳"
        case .focused: "🧠"
        case .eating: "🍲"
        case .walking: "🚶"
        }
    }
}

enum PetColor: String, Codable, CaseIterable, Identifiable {
    case orangeTabby
    case black
    case white

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .orangeTabby: "Warm Tone"
        case .black: "Dark Tone"
        case .white: "Light Tone"
        }
    }

    var spritePrefix: String {
        "minime"
    }
}

@Model
final class Pet {
    @Attribute(.unique) var id: UUID
    var name: String
    var colorRaw: String // PetColor rawValue
    var accessoryIDs: [String]

    init(
        id: UUID = UUID(),
        name: String = "Pixel",
        color: PetColor = .orangeTabby,
        accessoryIDs: [String] = [],
        equippedOutfitIDs: [String] = []
    ) {
        self.id = id
        self.name = name
        self.colorRaw = color.rawValue
        self.accessoryIDs = accessoryIDs
        self.equippedOutfitIDs = equippedOutfitIDs
    }

    var color: PetColor {
        get { PetColor(rawValue: colorRaw) ?? .orangeTabby }
        set { colorRaw = newValue.rawValue }
    }

    // v2: Equipped outfit per slot
    var equippedOutfitIDs: [String] // OutfitItem IDs currently worn

    func spriteName(for mood: PetMood) -> String {
        "minime_\(mood.spriteSuffix)"
    }

    var spriteName: String {
        spriteName(for: .neutral)
    }

    func isWearing(_ outfitID: String) -> Bool {
        equippedOutfitIDs.contains(outfitID)
    }

    func equip(_ outfitID: String) {
        guard let outfit = OutfitCatalog.outfit(byID: outfitID) else { return }
        // Remove any existing outfit in the same slot
        equippedOutfitIDs.removeAll { id in
            guard let existing = OutfitCatalog.outfit(byID: id) else { return false }
            return existing.outfitSlot == outfit.outfitSlot
        }
        equippedOutfitIDs.append(outfitID)
    }

    func unequip(_ outfitID: String) {
        equippedOutfitIDs.removeAll { $0 == outfitID }
    }

    func equippedOutfit(for slot: OutfitSlot) -> OutfitItem? {
        for id in equippedOutfitIDs {
            if let outfit = OutfitCatalog.outfit(byID: id), outfit.outfitSlot == slot {
                return outfit
            }
        }
        return nil
    }
}

// DTO for widget
struct PetDTO: Codable {
    let name: String
    let color: String
    let mood: String
    let accessoryIDs: [String]
    let equippedOutfitIDs: [String]
}
