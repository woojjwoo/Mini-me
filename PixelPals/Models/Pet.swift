import Foundation
import SwiftData

enum PetMood: String, Codable {
    case sleeping
    case happy
    case neutral
    case bored
    case sad
    case celebrating

    var spriteSuffix: String {
        switch self {
        case .sleeping: "sleep"
        case .happy: "happy"
        case .neutral: "idle"
        case .bored: "bored"
        case .sad: "sad"
        case .celebrating: "celebrate"
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
        switch self {
        case .orangeTabby: "avatar_warm"
        case .black: "avatar_dark"
        case .white: "avatar_light"
        }
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

    var spriteName: String {
        color.spritePrefix
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
