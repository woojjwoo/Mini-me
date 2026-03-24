import Foundation

// Static catalog — not stored in SwiftData, defined in code
struct ShopItem: Identifiable, Codable {
    let id: String           // e.g. "bed_wooden", "poster_sunset"
    let name: String
    let category: ItemCategory
    let slotType: String     // which SlotType this item fits in
    let price: Int
    let spriteName: String   // asset name for SpriteKit
    let isPremium: Bool      // requires Pro subscription

    var slot: SlotType? {
        SlotType(rawValue: slotType)
    }
}

enum ItemCategory: String, Codable, CaseIterable, Identifiable {
    case furniture
    case decor
    case electronics
    case cozy
    case fun
    case wallFloor

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .furniture: "Furniture"
        case .decor: "Decor"
        case .electronics: "Electronics"
        case .cozy: "Cozy"
        case .fun: "Fun"
        case .wallFloor: "Walls & Floors"
        }
    }
}

// MARK: - Item Catalog (v1: 20-25 items)

enum ItemCatalog {
    static let allItems: [ShopItem] = [
        // Bed area
        ShopItem(id: "bed_wooden", name: "Wooden Bed", category: .furniture, slotType: "bed", price: 400, spriteName: "bed_wooden", isPremium: false),
        ShopItem(id: "bed_cozy", name: "Cozy Bed", category: .furniture, slotType: "bed", price: 600, spriteName: "bed_cozy", isPremium: false),
        ShopItem(id: "bed_loft", name: "Loft Bed", category: .furniture, slotType: "bed", price: 800, spriteName: "bed_loft", isPremium: true),

        // Desk area
        ShopItem(id: "desk_simple", name: "Simple Desk", category: .furniture, slotType: "desk", price: 200, spriteName: "desk_simple", isPremium: false),
        ShopItem(id: "desk_gaming", name: "Gaming Desk", category: .furniture, slotType: "desk", price: 500, spriteName: "desk_gaming", isPremium: true),

        // Desk chair
        ShopItem(id: "chair_basic", name: "Basic Chair", category: .furniture, slotType: "deskChair", price: 100, spriteName: "chair_basic", isPremium: false),
        ShopItem(id: "chair_gaming", name: "Gaming Chair", category: .furniture, slotType: "deskChair", price: 350, spriteName: "chair_gaming", isPremium: true),

        // Shelf
        ShopItem(id: "shelf_books", name: "Bookshelf", category: .furniture, slotType: "shelf", price: 300, spriteName: "shelf_books", isPremium: false),

        // Floor center
        ShopItem(id: "rug_round", name: "Round Rug", category: .decor, slotType: "floorCenter", price: 150, spriteName: "rug_round", isPremium: false),
        ShopItem(id: "rug_pixel", name: "Pixel Art Rug", category: .decor, slotType: "floorCenter", price: 250, spriteName: "rug_pixel", isPremium: true),

        // Wall decor
        ShopItem(id: "poster_sunset", name: "Sunset Poster", category: .decor, slotType: "wallDecor1", price: 80, spriteName: "poster_sunset", isPremium: false),
        ShopItem(id: "poster_cat", name: "Cat Poster", category: .decor, slotType: "wallDecor2", price: 80, spriteName: "poster_cat", isPremium: false),
        ShopItem(id: "clock_pixel", name: "Pixel Clock", category: .decor, slotType: "wallDecor1", price: 120, spriteName: "clock_pixel", isPremium: false),

        // Cozy corner
        ShopItem(id: "plant_succulent", name: "Succulent", category: .cozy, slotType: "cozyCorner", price: 50, spriteName: "plant_succulent", isPremium: false),
        ShopItem(id: "lamp_floor", name: "Floor Lamp", category: .cozy, slotType: "cozyCorner", price: 180, spriteName: "lamp_floor", isPremium: false),
        ShopItem(id: "beanbag", name: "Bean Bag", category: .cozy, slotType: "cozyCorner", price: 250, spriteName: "beanbag", isPremium: false),

        // Side table
        ShopItem(id: "table_nightstand", name: "Nightstand", category: .furniture, slotType: "sideTable", price: 120, spriteName: "table_nightstand", isPremium: false),

        // Window
        ShopItem(id: "curtain_white", name: "White Curtains", category: .decor, slotType: "windowArea", price: 100, spriteName: "curtain_white", isPremium: false),

        // Pet bed
        ShopItem(id: "petbed_cushion", name: "Cat Cushion", category: .cozy, slotType: "petBed", price: 80, spriteName: "petbed_cushion", isPremium: false),
        ShopItem(id: "petbed_box", name: "Cardboard Box", category: .fun, slotType: "petBed", price: 30, spriteName: "petbed_box", isPremium: false),

        // Accent items
        ShopItem(id: "guitar_acoustic", name: "Acoustic Guitar", category: .fun, slotType: "accentItem", price: 300, spriteName: "guitar_acoustic", isPremium: false),
        ShopItem(id: "console_retro", name: "Retro Console", category: .electronics, slotType: "accentItem", price: 500, spriteName: "console_retro", isPremium: true),
        ShopItem(id: "laptop_pixel", name: "Pixel Laptop", category: .electronics, slotType: "accentItem", price: 200, spriteName: "laptop_pixel", isPremium: false),
    ]

    static func items(for slotType: SlotType) -> [ShopItem] {
        allItems.filter { $0.slotType == slotType.rawValue }
    }

    static func item(byID id: String) -> ShopItem? {
        allItems.first { $0.id == id }
    }

    static func items(in category: ItemCategory) -> [ShopItem] {
        allItems.filter { $0.category == category }
    }
}
