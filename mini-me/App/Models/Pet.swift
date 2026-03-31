import Foundation
import SwiftData
import CoreGraphics

enum PetActivity: String, Codable {
    case idling, walking, working, reading, sleeping, eating, slacking, stretching

    // Mapping coordinates relative to room center
    var roomOffset: CGPoint {
        switch self {
        case .working:    return CGPoint(x: -45, y: 40)  // At Desk
        case .reading:    return CGPoint(x: -70, y: -10) // At Beanbag/Cozy Corner
        case .sleeping:   return CGPoint(x: 55, y: 15)   // In Bed
        case .eating:     return CGPoint(x: 10, y: -20)  // Near Table
        case .idling, .walking, .slacking, .stretching: 
            return CGPoint(x: 0, y: -30)                 // Center Floor
        }
    }
}

enum PetMood: String, Codable {
    case sleeping, happy, neutral, bored, sad, celebrating, focused, eating, walking

    var spriteSuffix: String {
        switch self {
        case .sleeping: "sleeping_1774711364657"
        case .happy: "happy_1774711380382"
        default: "idle_1774711350053"
        }
    }

    // Precise coordinates for the 248x248 room
    var roomOffset: CGPoint {
        switch self {
        case .sleeping: return CGPoint(x: 55, y: 15)    // In the bed
        case .focused: return CGPoint(x: -45, y: 40)   // Sitting at desk
        case .eating: return CGPoint(x: 10, y: -20)    // Center area
        default: return CGPoint(x: 0, y: -30)          // Floor center
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

    func shouldShowStreakBonus(days: Int) -> Bool {
        return days >= 3
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
