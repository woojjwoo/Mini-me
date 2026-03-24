import Foundation
import SwiftData

// MARK: - Room Types (v2: Multiple Rooms)

enum RoomType: String, Codable, CaseIterable, Identifiable {
    case bedroom
    case study
    case kitchen
    case gym
    case coffeeShop
    case rooftop

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .bedroom: "Bedroom"
        case .study: "Study"
        case .kitchen: "Kitchen"
        case .gym: "Gym"
        case .coffeeShop: "Coffee Shop"
        case .rooftop: "Rooftop"
        }
    }

    var icon: String {
        switch self {
        case .bedroom: "bed.double.fill"
        case .study: "book.fill"
        case .kitchen: "fork.knife"
        case .gym: "dumbbell.fill"
        case .coffeeShop: "cup.and.saucer.fill"
        case .rooftop: "sun.max.fill"
        }
    }

    var unlockPrice: Int {
        switch self {
        case .bedroom: 0       // free — starter room
        case .study: 500
        case .kitchen: 600
        case .gym: 750
        case .coffeeShop: 1000
        case .rooftop: 1500
        }
    }

    var description: String {
        switch self {
        case .bedroom: "Your cozy starter room"
        case .study: "A quiet space for learning and work"
        case .kitchen: "Cook up something good"
        case .gym: "Your personal workout space"
        case .coffeeShop: "A warm spot to chill and create"
        case .rooftop: "A breezy retreat above the city"
        }
    }
}

@Model
final class Room {
    @Attribute(.unique) var id: UUID
    var wallTheme: String
    var floorTheme: String
    var roomTypeRaw: String // RoomType rawValue
    var isActive: Bool      // which room shows on widget

    @Relationship(deleteRule: .cascade, inverse: \RoomSlotAssignment.room)
    var slots: [RoomSlotAssignment]

    init(
        id: UUID = UUID(),
        wallTheme: String = "default",
        floorTheme: String = "default",
        roomType: RoomType = .bedroom,
        isActive: Bool = true
    ) {
        self.id = id
        self.wallTheme = wallTheme
        self.floorTheme = floorTheme
        self.roomTypeRaw = roomType.rawValue
        self.isActive = isActive
        // Initialize with all 12 empty slots
        self.slots = SlotType.allCases.map { RoomSlotAssignment(slotType: $0) }
    }

    var roomType: RoomType {
        get { RoomType(rawValue: roomTypeRaw) ?? .bedroom }
        set { roomTypeRaw = newValue.rawValue }
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
