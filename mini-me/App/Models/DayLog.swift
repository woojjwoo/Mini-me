import Foundation
import SwiftData

@Model
final class DayLog {
    @Attribute(.unique) var id: UUID
    var date: Date
    var completedBlockIDs: [UUID]
    var coinsEarned: Int
    var bonusCoinsEarned: Int

    init(
        id: UUID = UUID(),
        date: Date = .now,
        completedBlockIDs: [UUID] = [],
        coinsEarned: Int = 0,
        bonusCoinsEarned: Int = 0
    ) {
        self.id = id
        self.date = Calendar.current.startOfDay(for: date)
        self.completedBlockIDs = completedBlockIDs
        self.coinsEarned = coinsEarned
        self.bonusCoinsEarned = bonusCoinsEarned
    }

    var totalCoins: Int { coinsEarned + bonusCoinsEarned }

    func isBlockCompleted(_ blockID: UUID) -> Bool {
        completedBlockIDs.contains(blockID)
    }

    func completionRate(totalBlocks: Int) -> Double {
        guard totalBlocks > 0 else { return 0 }
        return Double(completedBlockIDs.count) / Double(totalBlocks)
    }
}

// DTO for widget sharing
struct DayLogDTO: Codable {
    let date: Date
    let completedBlockIDs: [UUID]
    let coinsEarned: Int
    let totalBlocks: Int

    var completionRate: Double {
        guard totalBlocks > 0 else { return 0 }
        return Double(completedBlockIDs.count) / Double(totalBlocks)
    }
}
