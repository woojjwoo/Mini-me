import Foundation
import SwiftData
import CoreGraphics

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
    // Coordinated for the 248x248 base background.
    var scenePosition: (x: CGFloat, y: CGFloat) {
        switch self {
        case .bed:          return (x: 55, y: -15)
        case .desk:         return (x: -50, y: 35)
        case .deskChair:    return (x: -35, y: 15)
        case .shelf:        return (x: -85, y: 55)
        case .floorCenter:  return (x: 0, y: -40)
        case .wallDecor1:   return (x: -60, y: 80)
        case .wallDecor2:   return (x: 20, y: 100)
        case .cozyCorner:   return (x: -70, y: -10)
        case .sideTable:    return (x: 85, y: 15)
        case .windowArea:   return (x: 0, y: 110)
        case .petBed:       return (x: 30, y: -50)
        case .accentItem:   return (x: 70, y: -60)
        }
    }

    // The "Solid" area an item occupies on the floor (relative to its center)
    // Used to prevent the character from walking through it.
    var footprint: CGRect {
        switch self {
        case .bed:          return CGRect(x: -40, y: -20, width: 80, height: 40)
        case .desk:         return CGRect(x: -30, y: -15, width: 60, height: 30)
        case .shelf:        return CGRect(x: -25, y: -10, width: 50, height: 20)
        case .sideTable:    return CGRect(x: -15, y: -10, width: 30, height: 20)
        default:            return .zero // Wall decor and small items aren't solid
        }
    }

    // Z-order: higher values render on top
    var zPosition: CGFloat {
        switch self {
        case .windowArea:   return 1
        case .wallDecor1:   return 2
        case .wallDecor2:   return 2
        case .shelf:        return 3
        case .desk:         return 4
        case .bed:          return 4
        case .sideTable:    return 5
        case .deskChair:    return 6
        case .cozyCorner:   return 6
        case .floorCenter:  return 3
        case .petBed:       return 7
        case .accentItem:   return 7
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
