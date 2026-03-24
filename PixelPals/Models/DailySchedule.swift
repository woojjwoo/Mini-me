import Foundation
import SwiftData

@Model
final class DailySchedule {
    @Attribute(.unique) var id: UUID
    var isWeekday: Bool
    var name: String // "Weekday" or "Weekend"

    @Relationship(deleteRule: .cascade, inverse: \TimeBlock.schedule)
    var blocks: [TimeBlock]

    init(
        id: UUID = UUID(),
        isWeekday: Bool = true,
        name: String = "Weekday",
        blocks: [TimeBlock] = []
    ) {
        self.id = id
        self.isWeekday = isWeekday
        self.name = name
        self.blocks = blocks
    }

    var sortedBlocks: [TimeBlock] {
        blocks.sorted { ($0.startHour * 60 + $0.startMinute) < ($1.startHour * 60 + $1.startMinute) }
    }

    var totalBlockMinutes: Int {
        blocks.reduce(0) { $0 + $1.durationMinutes }
    }
}
