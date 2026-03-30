import Foundation
import SwiftData

@Observable
final class StreakService {
    private let modelContext: ModelContext
    private let calendar = Calendar.current

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    /// Call at end of day or when app opens to update streak
    func updateStreak(player: Player, dayLog: DayLog, totalBlocks: Int) -> Int {
        let completionRate = dayLog.completionRate(totalBlocks: totalBlocks)

        // Need at least 50% completion to count as a streak day
        guard completionRate >= 0.5 else { return 0 }

        let today = calendar.startOfDay(for: .now)

        if let lastDate = player.lastCompletedDate {
            let lastDay = calendar.startOfDay(for: lastDate)
            let daysBetween = calendar.dateComponents([.day], from: lastDay, to: today).day ?? 0

            if daysBetween == 1 {
                // Consecutive day
                player.currentStreak += 1
            } else if daysBetween > 1 {
                // Streak broken
                player.currentStreak = 1
            }
            // daysBetween == 0 means already updated today
        } else {
            player.currentStreak = 1
        }

        player.lastCompletedDate = today
        player.longestStreak = max(player.longestStreak, player.currentStreak)
        player.totalDaysCompleted += 1

        return streakBonus(for: player.currentStreak)
    }

    func streakBonus(for streak: Int) -> Int {
        switch streak {
        case 30: return CoinService.streak30Bonus
        case 7: return CoinService.streak7Bonus
        case 3: return CoinService.streak3Bonus
        default: return 0
        }
    }

    /// Check if streak is at risk (no completions today, evening time)
    func isStreakAtRisk(player: Player) -> Bool {
        guard player.currentStreak > 0 else { return false }
        let hour = calendar.component(.hour, from: .now)
        guard hour >= 18 else { return false }

        let today = calendar.startOfDay(for: .now)
        if let lastDate = player.lastCompletedDate {
            return calendar.startOfDay(for: lastDate) != today
        }
        return true
    }
}
