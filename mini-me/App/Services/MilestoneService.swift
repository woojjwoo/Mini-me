import Foundation
import SwiftData

@Observable
final class MilestoneService {
    private let modelContext: ModelContext
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    /// Checks for and unlocks any new milestones based on player progress.
    /// Returns a list of newly unlocked milestone IDs.
    func checkMilestones(player: Player, dayLogs: [DayLog]) -> [String] {
        var newlyUnlocked: [String] = []
        
        let totalBlocksCompleted = dayLogs.reduce(0) { $0 + $1.completedBlockIDs.count }
        
        // Example Milestone 1: First 10 blocks completed
        if totalBlocksCompleted >= 10 && !player.unlockedMilestoneIDs.contains("milestone_10_blocks") {
            player.unlockedMilestoneIDs.append("milestone_10_blocks")
            newlyUnlocked.append("milestone_10_blocks")
            // Reward: Give player a trophy item or coins
            player.ownedItemIDs.append("trophy_bronze")
        }
        
        // Example Milestone 2: 7-Day Streak
        if player.longestStreak >= 7 && !player.unlockedMilestoneIDs.contains("milestone_7_streak") {
            player.unlockedMilestoneIDs.append("milestone_7_streak")
            newlyUnlocked.append("milestone_7_streak")
            player.ownedItemIDs.append("trophy_silver")
        }
        
        if !newlyUnlocked.isEmpty {
            try? modelContext.save()
        }
        
        return newlyUnlocked
    }
}
