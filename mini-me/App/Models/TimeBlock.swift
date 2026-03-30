import Foundation
import SwiftData

@Model
final class TimeBlock: Identifiable {
    @Attribute(.unique) var id: UUID
    var category: String // BlockCategory rawValue (SwiftData can't store enums directly)
    var label: String
    var startHour: Int
    var startMinute: Int
    var durationMinutes: Int // 30 or 60
    var sortOrder: Int

    var schedule: DailySchedule?

    init(
        id: UUID = UUID(),
        category: BlockCategory,
        label: String,
        startHour: Int,
        startMinute: Int = 0,
        durationMinutes: Int = 60,
        sortOrder: Int = 0
    ) {
        self.id = id
        self.category = category.rawValue
        self.label = label
        self.startHour = startHour
        self.startMinute = startMinute
        self.durationMinutes = durationMinutes
        self.sortOrder = sortOrder
    }

    var blockCategory: BlockCategory {
        get { BlockCategory(rawValue: category) ?? .custom }
        set { category = newValue.rawValue }
    }

    var startTimeString: String {
        let hour = startHour % 12 == 0 ? 12 : startHour % 12
        let period = startHour < 12 ? "AM" : "PM"
        if startMinute == 0 {
            return "\(hour):00 \(period)"
        }
        return "\(hour):\(String(format: "%02d", startMinute)) \(period)"
    }

    var endHour: Int {
        let totalMinutes = startHour * 60 + startMinute + durationMinutes
        return (totalMinutes / 60) % 24
    }

    var endMinute: Int {
        let totalMinutes = startHour * 60 + startMinute + durationMinutes
        return totalMinutes % 60
    }
}

// Codable representation for widget sharing & future sync
struct TimeBlockDTO: Codable, Identifiable {
    let id: UUID
    let category: String
    let label: String
    let startHour: Int
    let startMinute: Int
    let durationMinutes: Int
    let sortOrder: Int

    init(from block: TimeBlock) {
        self.id = block.id
        self.category = block.category
        self.label = block.label
        self.startHour = block.startHour
        self.startMinute = block.startMinute
        self.durationMinutes = block.durationMinutes
        self.sortOrder = block.sortOrder
    }
}
