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

    init(
        id: UUID = UUID(),
        coins: Int = 0,
        ownedItemIDs: [String] = [],
        currentStreak: Int = 0,
        longestStreak: Int = 0,
        totalDaysCompleted: Int = 0,
        hasCompletedOnboarding: Bool = false,
        isPremium: Bool = false
    ) {
        self.id = id
        self.coins = coins
        self.ownedItemIDs = ownedItemIDs
        self.currentStreak = currentStreak
        self.longestStreak = longestStreak
        self.totalDaysCompleted = totalDaysCompleted
        self.hasCompletedOnboarding = hasCompletedOnboarding
        self.isPremium = isPremium
    }

    func ownsItem(_ itemID: String) -> Bool {
        ownedItemIDs.contains(itemID)
    }

    func canAfford(_ price: Int) -> Bool {
        coins >= price
    }
}
