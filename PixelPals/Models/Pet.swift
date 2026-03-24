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
        accessoryIDs: [String] = []
    ) {
        self.id = id
        self.name = name
        self.colorRaw = color.rawValue
        self.accessoryIDs = accessoryIDs
    }

    var color: PetColor {
        get { PetColor(rawValue: colorRaw) ?? .orangeTabby }
        set { colorRaw = newValue.rawValue }
    }

    var spriteName: String {
        color.spritePrefix
    }
}

// DTO for widget
struct PetDTO: Codable {
    let name: String
    let color: String
    let mood: String
    let accessoryIDs: [String]
}
