import Foundation
import SwiftData

@Observable
final class CoinService {
    private let modelContext: ModelContext

    // Coin rewards (from design spec)
    static let coinsPerBlock = 10
    static let morningBonus = 15
    static let afternoonBonus = 15
    static let eveningBonus = 15
    static let perfectDayBonus = 50
    static let streak3Bonus = 25
    static let streak7Bonus = 75
    static let streak30Bonus = 300

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    func completeBlock(blockID: UUID, player: Player, dayLog: DayLog, schedule: DailySchedule) -> Int {
        guard !dayLog.isBlockCompleted(blockID) else { return 0 }

        dayLog.completedBlockIDs.append(blockID)
        var earned = Self.coinsPerBlock

        // Check section bonuses
        let blocks = schedule.sortedBlocks
        earned += checkSectionBonuses(dayLog: dayLog, blocks: blocks)

        // Check perfect day
        if dayLog.completedBlockIDs.count == blocks.count {
            earned += Self.perfectDayBonus
        }

        dayLog.coinsEarned += earned
        player.coins += earned

        return earned
    }

    func purchaseItem(itemID: String, player: Player) -> Bool {
        guard let item = ItemCatalog.item(byID: itemID) else { return false }
        guard player.canAfford(item.price) else { return false }
        guard !player.ownsItem(itemID) else { return false }

        player.coins -= item.price
        player.ownedItemIDs.append(itemID)
        return true
    }

    private func checkSectionBonuses(dayLog: DayLog, blocks: [TimeBlock]) -> Int {
        var bonus = 0

        let morningBlocks = blocks.filter { $0.startHour < 12 }
        let afternoonBlocks = blocks.filter { $0.startHour >= 12 && $0.startHour < 17 }
        let eveningBlocks = blocks.filter { $0.startHour >= 17 }

        if !morningBlocks.isEmpty && morningBlocks.allSatisfy({ dayLog.isBlockCompleted($0.id) }) {
            bonus += Self.morningBonus
        }
        if !afternoonBlocks.isEmpty && afternoonBlocks.allSatisfy({ dayLog.isBlockCompleted($0.id) }) {
            bonus += Self.afternoonBonus
        }
        if !eveningBlocks.isEmpty && eveningBlocks.allSatisfy({ dayLog.isBlockCompleted($0.id) }) {
            bonus += Self.eveningBonus
        }

        return bonus
    }
}
