import Foundation
import SwiftUI

// MARK: - Enums (mirrored from main app — must match raw values exactly)

enum RoomType: String, Codable, CaseIterable {
    case bedroom
    case study
    case kitchen
    case gym
    case coffeeShop
    case rooftop

    var displayName: String {
        switch self {
        case .bedroom:    "Bedroom"
        case .study:      "Study"
        case .kitchen:    "Kitchen"
        case .gym:        "Gym"
        case .coffeeShop: "Coffee Shop"
        case .rooftop:    "Rooftop"
        }
    }
}

enum PetActivity: String, Codable {
    case idling, walking, working, reading, sleeping, eating, slacking, stretching
}

enum PetMood: String, Codable {
    case sleeping, happy, neutral, bored, sad, celebrating, focused, eating, walking

    var displayEmoji: String {
        switch self {
        case .sleeping:    "😴"
        case .happy:       "😊"
        case .neutral:     "😐"
        case .bored:       "🥱"
        case .sad:         "😢"
        case .celebrating: "🎉"
        case .focused:     "💻"
        case .eating:      "🍎"
        case .walking:     "🚶"
        }
    }
}

// MARK: - DTOs (must match encoding in main app's WidgetDataService)

struct PetDTO: Codable {
    let name: String
    let color: String
    let mood: String
    let accessoryIDs: [String]
    let equippedOutfitIDs: [String]
}

struct WidgetDayProgress: Codable {
    let completedBlocks: Int
    let totalBlocks: Int
    let coinsToday: Int
    let nextBlockLabel: String?
    let currentTaskName: String?
    let currentCategory: String?
    let date: Date

    var completionRate: Double {
        guard totalBlocks > 0 else { return 0 }
        return Double(completedBlocks) / Double(totalBlocks)
    }
}

// MARK: - Widget-side read-only data service

final class WidgetDataService {
    static let shared = WidgetDataService()

    static let appGroupID = "group.com.woojjwoo.pixieme.shared"

    private let defaults: UserDefaults?

    private init() {
        defaults = UserDefaults(suiteName: Self.appGroupID)
    }

    func readPetData() -> PetDTO? {
        guard let data = defaults?.data(forKey: "widget_pet_data") else { return nil }
        return try? JSONDecoder().decode(PetDTO.self, from: data)
    }

    func readDayProgress() -> WidgetDayProgress? {
        guard let data = defaults?.data(forKey: "widget_day_progress") else { return nil }
        return try? JSONDecoder().decode(WidgetDayProgress.self, from: data)
    }

    /// Returns the (scene, activity) pair the widget should render.
    /// Falls back to bedroom + idling if not set.
    func readActiveScene() -> (scene: RoomType, activity: PetActivity) {
        let sceneRaw    = defaults?.string(forKey: "widget_active_scene")    ?? RoomType.bedroom.rawValue
        let activityRaw = defaults?.string(forKey: "widget_active_activity") ?? PetActivity.idling.rawValue
        let scene    = RoomType(rawValue: sceneRaw)    ?? .bedroom
        let activity = PetActivity(rawValue: activityRaw) ?? .idling
        return (scene, activity)
    }
}

// MARK: - Color hex initializer

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 6:  (a, r, g, b) = (255, (int >> 16) & 0xFF, (int >> 8) & 0xFF, int & 0xFF)
        case 8:  (a, r, g, b) = ((int >> 24) & 0xFF, (int >> 16) & 0xFF, (int >> 8) & 0xFF, int & 0xFF)
        default: (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(.sRGB,
                  red:     Double(r) / 255,
                  green:   Double(g) / 255,
                  blue:    Double(b) / 255,
                  opacity: Double(a) / 255)
    }
}
