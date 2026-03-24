import Foundation
import SwiftData

@Model
final class Room {
    @Attribute(.unique) var id: UUID
    var wallTheme: String
    var floorTheme: String

    @Relationship(deleteRule: .cascade, inverse: \RoomSlotAssignment.room)
    var slots: [RoomSlotAssignment]

    init(
        id: UUID = UUID(),
        wallTheme: String = "default",
        floorTheme: String = "default"
    ) {
        self.id = id
        self.wallTheme = wallTheme
        self.floorTheme = floorTheme
        // Initialize with all 12 empty slots
        self.slots = SlotType.allCases.map { RoomSlotAssignment(slotType: $0) }
    }

    func assignment(for slotType: SlotType) -> RoomSlotAssignment? {
        slots.first { $0.slotType == slotType.rawValue }
    }

    func placeItem(_ itemID: String, in slotType: SlotType) {
        if let assignment = assignment(for: slotType) {
            assignment.itemID = itemID
        }
    }

    func removeItem(from slotType: SlotType) {
        if let assignment = assignment(for: slotType) {
            assignment.itemID = nil
        }
    }

    var filledSlotCount: Int {
        slots.filter { !$0.isEmpty }.count
    }
}

// DTO for widget sharing & future sync
struct RoomDTO: Codable {
    let id: UUID
    let wallTheme: String
    let floorTheme: String
    let slots: [SlotAssignmentDTO]
}

struct SlotAssignmentDTO: Codable {
    let slotType: String
    let itemID: String?
}
