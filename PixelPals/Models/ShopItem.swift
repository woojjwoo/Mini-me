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
    case outfits

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .furniture: "Furniture"
        case .decor: "Decor"
        case .electronics: "Electronics"
        case .cozy: "Cozy"
        case .fun: "Fun"
        case .wallFloor: "Walls & Floors"
        case .outfits: "Outfits"
        }
    }
}

// MARK: - Outfit System

struct OutfitItem: Identifiable, Codable {
    let id: String           // e.g. "outfit_headphones", "outfit_cap"
    let name: String
    let outfitSlot: OutfitSlot
    let price: Int
    let spriteName: String
    let isPremium: Bool
    let scheduleTrigger: String? // auto-equip when doing this category (e.g. "exercise")
}

enum OutfitSlot: String, Codable, CaseIterable, Identifiable {
    case head       // hats, caps, headbands
    case face       // glasses, masks
    case neck       // scarves, headphones (around neck)
    case top        // jackets, hoodies, shirts
    case hand       // phone, book, coffee cup
    case shoes      // sneakers, slippers

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .head: "Head"
        case .face: "Face"
        case .neck: "Neck"
        case .top: "Top"
        case .hand: "Hand"
        case .shoes: "Shoes"
        }
    }

    var icon: String {
        switch self {
        case .head: "crown.fill"
        case .face: "eyeglasses"
        case .neck: "headphones"
        case .top: "tshirt.fill"
        case .hand: "hand.raised.fill"
        case .shoes: "shoeprints.fill"
        }
    }
}

enum OutfitCatalog {
    static let allOutfits: [OutfitItem] = [
        // Head
        OutfitItem(id: "outfit_cap", name: "Baseball Cap", outfitSlot: .head, price: 80, spriteName: "outfit_cap", isPremium: false, scheduleTrigger: nil),
        OutfitItem(id: "outfit_beanie", name: "Cozy Beanie", outfitSlot: .head, price: 100, spriteName: "outfit_beanie", isPremium: false, scheduleTrigger: nil),
        OutfitItem(id: "outfit_headband", name: "Workout Headband", outfitSlot: .head, price: 60, spriteName: "outfit_headband", isPremium: false, scheduleTrigger: "exercise"),
        OutfitItem(id: "outfit_partyhat", name: "Party Hat", outfitSlot: .head, price: 150, spriteName: "outfit_partyhat", isPremium: true, scheduleTrigger: nil),

        // Face
        OutfitItem(id: "outfit_glasses", name: "Round Glasses", outfitSlot: .face, price: 100, spriteName: "outfit_glasses", isPremium: false, scheduleTrigger: "learning"),
        OutfitItem(id: "outfit_sunglasses", name: "Cool Shades", outfitSlot: .face, price: 120, spriteName: "outfit_sunglasses", isPremium: false, scheduleTrigger: nil),
        OutfitItem(id: "outfit_pixelglasses", name: "Pixel Shades", outfitSlot: .face, price: 200, spriteName: "outfit_pixelglasses", isPremium: true, scheduleTrigger: nil),

        // Neck
        OutfitItem(id: "outfit_headphones", name: "Headphones", outfitSlot: .neck, price: 150, spriteName: "outfit_headphones", isPremium: false, scheduleTrigger: "creative"),
        OutfitItem(id: "outfit_scarf", name: "Warm Scarf", outfitSlot: .neck, price: 80, spriteName: "outfit_scarf", isPremium: false, scheduleTrigger: nil),
        OutfitItem(id: "outfit_bowtie", name: "Pixel Bow Tie", outfitSlot: .neck, price: 100, spriteName: "outfit_bowtie", isPremium: true, scheduleTrigger: "work"),

        // Top
        OutfitItem(id: "outfit_hoodie", name: "Cozy Hoodie", outfitSlot: .top, price: 200, spriteName: "outfit_hoodie", isPremium: false, scheduleTrigger: nil),
        OutfitItem(id: "outfit_gymtank", name: "Gym Tank", outfitSlot: .top, price: 120, spriteName: "outfit_gymtank", isPremium: false, scheduleTrigger: "exercise"),
        OutfitItem(id: "outfit_blazer", name: "Smart Blazer", outfitSlot: .top, price: 250, spriteName: "outfit_blazer", isPremium: false, scheduleTrigger: "work"),
        OutfitItem(id: "outfit_pajamas", name: "Cozy Pajamas", outfitSlot: .top, price: 150, spriteName: "outfit_pajamas", isPremium: false, scheduleTrigger: "rest"),

        // Hand
        OutfitItem(id: "outfit_coffee", name: "Coffee Cup", outfitSlot: .hand, price: 60, spriteName: "outfit_coffee", isPremium: false, scheduleTrigger: "routine"),
        OutfitItem(id: "outfit_phone", name: "Pixel Phone", outfitSlot: .hand, price: 100, spriteName: "outfit_phone", isPremium: false, scheduleTrigger: nil),
        OutfitItem(id: "outfit_book", name: "Open Book", outfitSlot: .hand, price: 80, spriteName: "outfit_book", isPremium: false, scheduleTrigger: "learning"),
        OutfitItem(id: "outfit_paintbrush", name: "Paintbrush", outfitSlot: .hand, price: 100, spriteName: "outfit_paintbrush", isPremium: true, scheduleTrigger: "creative"),

        // Shoes
        OutfitItem(id: "outfit_sneakers", name: "Fresh Sneakers", outfitSlot: .shoes, price: 150, spriteName: "outfit_sneakers", isPremium: false, scheduleTrigger: "exercise"),
        OutfitItem(id: "outfit_slippers", name: "Fuzzy Slippers", outfitSlot: .shoes, price: 100, spriteName: "outfit_slippers", isPremium: false, scheduleTrigger: "rest"),
    ]

    static func outfit(byID id: String) -> OutfitItem? {
        allOutfits.first { $0.id == id }
    }

    static func outfits(for slot: OutfitSlot) -> [OutfitItem] {
        allOutfits.filter { $0.outfitSlot == slot }
    }

    static func outfits(triggeredBy category: String) -> [OutfitItem] {
        allOutfits.filter { $0.scheduleTrigger == category }
    }
}

// MARK: - Seasonal Items (v2)

struct SeasonalItem: Identifiable, Codable {
    let id: String
    let name: String
    let category: ItemCategory
    let slotType: String
    let price: Int
    let spriteName: String
    let season: Season
    let availableMonth: Int  // 1-12, 0 = always during season
}

enum Season: String, Codable, CaseIterable, Identifiable {
    case spring
    case summer
    case fall
    case winter
    case holiday

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .spring: "Spring"
        case .summer: "Summer"
        case .fall: "Fall"
        case .winter: "Winter"
        case .holiday: "Holiday"
        }
    }

    var icon: String {
        switch self {
        case .spring: "leaf.fill"
        case .summer: "sun.max.fill"
        case .fall: "leaf.arrow.triangle.circlepath"
        case .winter: "snowflake"
        case .holiday: "gift.fill"
        }
    }

    var isCurrentlyAvailable: Bool {
        let month = Calendar.current.component(.month, from: .now)
        switch self {
        case .spring: return (3...5).contains(month)
        case .summer: return (6...8).contains(month)
        case .fall: return (9...11).contains(month)
        case .winter: return month == 12 || month <= 2
        case .holiday: return month == 12
        }
    }
}

enum SeasonalCatalog {
    static let allItems: [SeasonalItem] = [
        // Spring
        SeasonalItem(id: "seasonal_cherry_blossom", name: "Cherry Blossom Branch", category: .decor, slotType: "cozyCorner", price: 200, spriteName: "seasonal_cherry_blossom", season: .spring, availableMonth: 0),
        SeasonalItem(id: "seasonal_flower_pot", name: "Spring Flowers", category: .cozy, slotType: "sideTable", price: 120, spriteName: "seasonal_flower_pot", season: .spring, availableMonth: 0),

        // Summer
        SeasonalItem(id: "seasonal_fan", name: "Desk Fan", category: .electronics, slotType: "desk", price: 150, spriteName: "seasonal_fan", season: .summer, availableMonth: 0),
        SeasonalItem(id: "seasonal_surfboard", name: "Mini Surfboard", category: .fun, slotType: "accentItem", price: 250, spriteName: "seasonal_surfboard", season: .summer, availableMonth: 0),

        // Fall
        SeasonalItem(id: "seasonal_pumpkin", name: "Pixel Pumpkin", category: .decor, slotType: "floorCenter", price: 100, spriteName: "seasonal_pumpkin", season: .fall, availableMonth: 10),
        SeasonalItem(id: "seasonal_candle_fall", name: "Autumn Candle", category: .cozy, slotType: "sideTable", price: 80, spriteName: "seasonal_candle_fall", season: .fall, availableMonth: 0),
        SeasonalItem(id: "seasonal_bat_poster", name: "Bat Poster", category: .decor, slotType: "wallDecor2", price: 100, spriteName: "seasonal_bat_poster", season: .fall, availableMonth: 10),

        // Winter
        SeasonalItem(id: "seasonal_snowglobe", name: "Snow Globe", category: .cozy, slotType: "sideTable", price: 180, spriteName: "seasonal_snowglobe", season: .winter, availableMonth: 0),
        SeasonalItem(id: "seasonal_hot_cocoa", name: "Hot Cocoa Mug", category: .cozy, slotType: "desk", price: 60, spriteName: "seasonal_hot_cocoa", season: .winter, availableMonth: 0),

        // Holiday
        SeasonalItem(id: "seasonal_mini_tree", name: "Mini Holiday Tree", category: .decor, slotType: "cozyCorner", price: 300, spriteName: "seasonal_mini_tree", season: .holiday, availableMonth: 12),
        SeasonalItem(id: "seasonal_gift_box", name: "Gift Box Stack", category: .fun, slotType: "accentItem", price: 150, spriteName: "seasonal_gift_box", season: .holiday, availableMonth: 12),
        SeasonalItem(id: "seasonal_lights", name: "String Lights", category: .decor, slotType: "windowArea", price: 120, spriteName: "seasonal_lights", season: .holiday, availableMonth: 12),
    ]

    static var currentlyAvailable: [SeasonalItem] {
        allItems.filter { $0.season.isCurrentlyAvailable }
    }

    static func item(byID id: String) -> SeasonalItem? {
        allItems.first { $0.id == id }
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
        ShopItem(id: "poster_cat", name: "Selfie Poster", category: .decor, slotType: "wallDecor2", price: 80, spriteName: "poster_cat", isPremium: false),
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
        ShopItem(id: "petbed_cushion", name: "Floor Cushion", category: .cozy, slotType: "petBed", price: 80, spriteName: "petbed_cushion", isPremium: false),
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
