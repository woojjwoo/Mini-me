import Foundation
import SwiftData

// The 12 pre-set slots in the isometric room
enum SlotType: String, Codable, CaseIterable, Identifiable {
    case bed
    case desk
    case deskChair
    case shelf
    case floorCenter
    case wallDecor1
    case wallDecor2
    case cozyCorner
    case sideTable
    case windowArea
    case petBed
    case accentItem

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .bed: "Bed Area"
        case .desk: "Desk Area"
        case .deskChair: "Desk Chair"
        case .shelf: "Shelf / Bookcase"
        case .floorCenter: "Floor Center"
        case .wallDecor1: "Wall Decor (Left)"
        case .wallDecor2: "Wall Decor (Right)"
        case .cozyCorner: "Cozy Corner"
        case .sideTable: "Side Table"
        case .windowArea: "Window Area"
        case .petBed: "Chill Spot"
        case .accentItem: "Accent Item"
        }
    }

    // Fixed isometric position in SpriteKit scene (x, y offsets from room origin)
    var scenePosition: (x: CGFloat, y: CGFloat) {
        switch self {
        case .bed:          (x: 180, y: 60)
        case .desk:         (x: -120, y: 120)
        case .deskChair:    (x: -80, y: 80)
        case .shelf:        (x: -160, y: 160)
        case .floorCenter:  (x: 0, y: 0)
        case .wallDecor1:   (x: -100, y: 200)
        case .wallDecor2:   (x: 100, y: 200)
        case .cozyCorner:   (x: -140, y: -20)
        case .sideTable:    (x: 140, y: 100)
        case .windowArea:   (x: 0, y: 220)
        case .petBed:       (x: 60, y: -40)
        case .accentItem:   (x: 120, y: -60)
        }
    }

    // Z-order: higher values render on top
    var zPosition: CGFloat {
        switch self {
        case .windowArea:   1
        case .wallDecor1:   2
        case .wallDecor2:   2
        case .shelf:        3
        case .desk:         4
        case .bed:          4
        case .sideTable:    5
        case .deskChair:    6
        case .cozyCorner:   6
        case .floorCenter:  3
        case .petBed:       7
        case .accentItem:   7
        }
    }
}

@Model
final class RoomSlotAssignment {
    @Attribute(.unique) var id: UUID
    var slotType: String // SlotType rawValue
    var itemID: String?  // nil = empty slot

    var room: Room?

    init(
        id: UUID = UUID(),
        slotType: SlotType,
        itemID: String? = nil
    ) {
        self.id = id
        self.slotType = slotType.rawValue
        self.itemID = itemID
    }

    var slot: SlotType {
        get { SlotType(rawValue: slotType) ?? .floorCenter }
        set { slotType = newValue.rawValue }
    }

    var isEmpty: Bool { itemID == nil }
}
