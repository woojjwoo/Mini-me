import Foundation
import SwiftData

@Model
final class Player {
    @Attribute(.unique) var id: UUID
    var coins: Int
    var ownedItemIDs: [String]
    var currentStreak: Int
    var longestStreak: Int
    var totalDaysCompleted: Int
    var hasCompletedOnboarding: Bool
    var isPremium: Bool
    var lastCompletedDate: Date?
    var unlockedMilestoneIDs: [String]

    init(
        id: UUID = UUID(),
        coins: Int = 0,
        ownedItemIDs: [String] = [],
        currentStreak: Int = 0,
        longestStreak: Int = 0,
        totalDaysCompleted: Int = 0,
        hasCompletedOnboarding: Bool = false,
        isPremium: Bool = false,
        unlockedMilestoneIDs: [String] = []
    ) {
        self.id = id
        self.coins = coins
        self.ownedItemIDs = ownedItemIDs
        self.currentStreak = currentStreak
        self.longestStreak = longestStreak
        self.totalDaysCompleted = totalDaysCompleted
        self.hasCompletedOnboarding = hasCompletedOnboarding
        self.isPremium = isPremium
        self.unlockedMilestoneIDs = unlockedMilestoneIDs
    }

    // v2: Manual status override
    var manualStatusRaw: String? // ManualStatus rawValue, nil = auto mood
    var manualStatusExpiresAt: Date?

    var manualStatus: ManualStatus? {
        get {
            guard let raw = manualStatusRaw else { return nil }
            // Check expiry
            if let expires = manualStatusExpiresAt, Date.now > expires {
                return nil
            }
            return ManualStatus(rawValue: raw)
        }
        set {
            manualStatusRaw = newValue?.rawValue
        }
    }

    func ownsItem(_ itemID: String) -> Bool {
        ownedItemIDs.contains(itemID)
    }

    func canAfford(_ price: Int) -> Bool {
        coins >= price
    }
}

// MARK: - Manual Status (v2: Sick Day / Status Modes)

enum ManualStatus: String, Codable, CaseIterable, Identifiable {
    case sick
    case vacation
    case mentalHealthDay
    case traveling

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .sick: "Sick Day"
        case .vacation: "Vacation"
        case .mentalHealthDay: "Rest Day"
        case .traveling: "Traveling"
        }
    }

    var emoji: String {
        switch self {
        case .sick: "🤒"
        case .vacation: "🏖️"
        case .mentalHealthDay: "🧘"
        case .traveling: "✈️"
        }
    }

    var avatarDescription: String {
        switch self {
        case .sick: "Resting with a cold towel and thermometer"
        case .vacation: "Relaxing on vacation"
        case .mentalHealthDay: "Taking a mental health day"
        case .traveling: "On the go"
        }
    }

    var moodOverride: PetMood {
        switch self {
        case .sick: .sleeping
        case .vacation: .happy
        case .mentalHealthDay: .neutral
        case .traveling: .happy
        }
    }
}
