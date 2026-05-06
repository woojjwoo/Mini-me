import Foundation
import SwiftUI
import UIKit

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

    var fallbackEmoji: String {
        switch self {
        case .bedroom:    "🛏️"
        case .study:      "💻"
        case .kitchen:    "🍳"
        case .gym:        "🏋️"
        case .coffeeShop: "☕"
        case .rooftop:    "🌆"
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

/// Minimal schedule block representation shared via App Group.
/// The main app pre-resolves scene + activity so the widget
/// doesn't need to replicate the BlockCategory mapping logic.
struct WidgetTimeBlock: Codable, Identifiable {
    let id: UUID
    let category: String       // BlockCategory rawValue
    let label: String
    let startHour: Int
    let startMinute: Int
    let durationMinutes: Int
    let sortOrder: Int
    let scene: String          // RoomType rawValue (pre-resolved)
    let activity: String       // PetActivity rawValue (pre-resolved)

    /// Minutes since midnight this block starts
    var startMinuteOfDay: Int { startHour * 60 + startMinute }
    /// Minutes since midnight this block ends
    var endMinuteOfDay: Int { startMinuteOfDay + durationMinutes }
}

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

    /// Returns today's schedule blocks sorted by start time.
    /// Empty array if no blocks have been saved yet.
    func readScheduleBlocks() -> [WidgetTimeBlock] {
        guard let data = defaults?.data(forKey: "widget_schedule_blocks") else { return [] }
        let blocks = (try? JSONDecoder().decode([WidgetTimeBlock].self, from: data)) ?? []
        return blocks.sorted { $0.startMinuteOfDay < $1.startMinuteOfDay }
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

// MARK: - Shared snapshot loader (used by both widget and Live Activity)

/// Number of frames per animated pose loop. Must match
/// `WidgetSnapshotBakery.frameCount` in the main app.
let widgetFrameCount: Int = 3

/// Load the snapshot for a (scene, activity) pair, optionally for a specific
/// animation frame. Cascade:
///   1. `room_diorama_<scene>_<activity>_f<frame>.png` (animated frame)
///   2. `room_diorama_<scene>_<activity>.png`          (base, no animation)
///   3. `room_diorama.png`                             (generic fallback)
///
/// When `frame` is nil the first step is skipped — used by callers that don't
/// care about animation (e.g. Live Activity static renders).
///
/// Critical property: even if zero frame variants have been baked yet, this
/// loader returns the same base image for every frame index, so the timeline
/// can request frames 1/2/3 without breaking — animation just doesn't visibly
/// happen until the bakery actually produces variants.
func loadSceneSnapshot(scene: RoomType, activity: PetActivity, frame: Int? = nil) -> UIImage? {
    let groupID = "group.com.woojjwoo.pixieme.shared"
    guard let container = FileManager.default.containerURL(
        forSecurityApplicationGroupIdentifier: groupID) else { return nil }

    if let frame = frame {
        let framed = container.appendingPathComponent(
            "room_diorama_\(scene.rawValue)_\(activity.rawValue)_f\(frame).png")
        if let img = UIImage(contentsOfFile: framed.path) { return img }
    }

    let specific = container.appendingPathComponent(
        "room_diorama_\(scene.rawValue)_\(activity.rawValue).png")
    if let img = UIImage(contentsOfFile: specific.path) { return img }

    let fallback = container.appendingPathComponent("room_diorama.png")
    return UIImage(contentsOfFile: fallback.path)
}
