import SwiftUI
import SwiftData

struct ShopView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var players: [Player]
    @Query private var rooms: [Room]

    @State private var selectedCategory: ShopTab = .furniture
    @State private var purchaseAnimation: String?

    private var player: Player? { players.first }
    private var room: Room? { rooms.first }

    enum ShopTab: String, CaseIterable, Identifiable {
        case furniture
        case outfits
        case seasonal
        case rooms

        var id: String { rawValue }

        var displayName: String {
            switch self {
            case .furniture: "Furniture"
            case .outfits: "Drip"
            case .seasonal: "Limited"
            case .rooms: "Rooms"
            }
        }

        var icon: String {
            switch self {
            case .furniture: "square.grid.2x2.fill"
            case .outfits: "tshirt.fill"
            case .seasonal: "leaf.fill"
            case .rooms: "house.fill"
            }
        }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                PixelTheme.background.ignoresSafeArea()

                VStack(spacing: 0) {
                    // Coin balance
                    HStack {
                        Spacer()
                        HStack(spacing: 6) {
                            Image(systemName: "circle.fill")
                                .foregroundColor(PixelTheme.coin)
                            Text("\(player?.coins ?? 0)")
                                .font(PixelTheme.coinFont)
                                .foregroundColor(PixelTheme.text)
                        }
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .background(PixelTheme.cardBackground)
                        .cornerRadius(20)
                        .shadow(color: PixelTheme.shadowColor, radius: 2)
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 8)

                    // Tab selector
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(ShopTab.allCases) { tab in
                                CategoryPill(name: tab.displayName, isSelected: selectedCategory == tab) {
                                    selectedCategory = tab
                                }
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                    }

                    // Content
                    ScrollView {
                        switch selectedCategory {
                        case .furniture:
                            furnitureGrid
                        case .outfits:
                            outfitGrid
                        case .seasonal:
                            seasonalGrid
                        case .rooms:
                            roomShop
                        }
                    }
                }
            }
            .navigationTitle("Shop")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    // MARK: - Furniture Grid

    @State private var furnitureFilter: ItemCategory?

    private var filteredItems: [ShopItem] {
        let base = furnitureFilter != nil ? ItemCatalog.items(in: furnitureFilter!) : ItemCatalog.allItems
        return base.filter { $0.price > 0 }  // hide free starter items (mattress_floor)
    }

    private var furnitureGrid: some View {
        VStack(spacing: 0) {
            // Sub-category filter
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 6) {
                    categoryFilterPill("All", isSelected: furnitureFilter == nil) {
                        furnitureFilter = nil
                    }
                    ForEach(ItemCategory.allCases.filter { $0 != .outfits }) { category in
                        categoryFilterPill(category.displayName, isSelected: furnitureFilter == category) {
                            furnitureFilter = category
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 8)
            }

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                ForEach(filteredItems) { item in
                    ShopItemCard(
                        item: item,
                        isOwned: player?.ownsItem(item.id) ?? false,
                        canAfford: player?.canAfford(item.price) ?? false,
                        isPurchasing: purchaseAnimation == item.id,
                        onPurchase: { purchaseItem(item.id, item.price) }
                    )
                }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 20)
        }
    }

    // MARK: - Outfit Grid

    private var outfitGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
            ForEach(OutfitCatalog.allOutfits) { outfit in
                outfitCard(outfit)
            }
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 20)
    }

    private func outfitCard(_ outfit: OutfitItem) -> some View {
        let isOwned = player?.ownsItem(outfit.id) ?? false
        let canAfford = player?.canAfford(outfit.price) ?? false

        let slotColor = outfitSlotColor(outfit.outfitSlot)

        return VStack(spacing: 8) {
            RoundedRectangle(cornerRadius: 10)
                .fill(isOwned ? PixelTheme.completed.opacity(0.12) : slotColor.opacity(0.12))
                .frame(height: 150)
                .overlay {
                    VStack(spacing: 8) {
                        Image(systemName: outfit.outfitSlot.icon)
                            .font(.system(size: 32))
                            .foregroundColor(isOwned ? PixelTheme.accent : slotColor.opacity(0.7))
                        Text(outfit.outfitSlot.displayName)
                            .font(.system(size: 11, weight: .semibold, design: .rounded))
                            .foregroundColor(isOwned ? PixelTheme.accent : slotColor)
                    }
                }
                .overlay(alignment: .topLeading) {
                    if outfit.scheduleTrigger != nil {
                        Image(systemName: "bolt.fill")
                            .font(.system(size: 8))
                            .foregroundColor(.white)
                            .padding(4)
                            .background(PixelTheme.primary)
                            .clipShape(Circle())
                            .padding(6)
                    }
                }
                .scaleEffect(purchaseAnimation == outfit.id ? 1.05 : 1.0)
                .animation(.spring(response: 0.3), value: purchaseAnimation)

            Text(outfit.name)
                .font(PixelTheme.captionFont)
                .foregroundColor(PixelTheme.text)
                .lineLimit(1)

            if isOwned {
                Text("Owned")
                    .font(.system(size: 11, weight: .semibold, design: .rounded))
                    .foregroundColor(PixelTheme.completed)
            } else {
                Button { purchaseItem(outfit.id, outfit.price) } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "circle.fill")
                            .font(.system(size: 8))
                            .foregroundColor(PixelTheme.coin)
                        Text("\(outfit.price)")
                            .font(PixelTheme.captionFont)
                    }
                    .foregroundColor(canAfford ? PixelTheme.text : PixelTheme.pending)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(canAfford ? PixelTheme.coin.opacity(0.2) : PixelTheme.pending.opacity(0.1))
                    .cornerRadius(10)
                }
                .disabled(!canAfford)
            }
        }
        .padding(10)
        .background(PixelTheme.cardBackground)
        .cornerRadius(14)
        .shadow(color: PixelTheme.shadowColor, radius: 2, y: 1)
    }

    // MARK: - Seasonal Grid

    private var seasonalGrid: some View {
        let available = SeasonalCatalog.currentlyAvailable

        return VStack(spacing: 12) {
            if available.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "clock.fill")
                        .font(.system(size: 40))
                        .foregroundColor(PixelTheme.pending)
                    Text("No seasonal items right now")
                        .font(PixelTheme.bodyFont)
                        .foregroundColor(PixelTheme.text.opacity(0.5))
                    Text("Check back next season!")
                        .font(PixelTheme.captionFont)
                        .foregroundColor(PixelTheme.text.opacity(0.3))
                }
                .padding(.top, 60)
            } else {
                // Season header
                if let season = available.first?.season {
                    HStack {
                        Image(systemName: season.icon)
                            .foregroundColor(PixelTheme.accent)
                        Text("\(season.displayName) Collection")
                            .font(PixelTheme.headlineFont)
                            .foregroundColor(PixelTheme.text)
                        Spacer()
                        Text("Limited Time")
                            .font(PixelTheme.captionFont)
                            .foregroundColor(PixelTheme.accent)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(PixelTheme.accent.opacity(0.1))
                            .cornerRadius(8)
                    }
                    .padding(.horizontal, 16)
                }

                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                    ForEach(available) { item in
                        seasonalCard(item)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 20)
            }
        }
    }

    private func seasonalCard(_ item: SeasonalItem) -> some View {
        let isOwned = player?.ownsItem(item.id) ?? false
        let canAfford = player?.canAfford(item.price) ?? false

        return VStack(spacing: 8) {
            RoundedRectangle(cornerRadius: 10)
                .fill(isOwned ? PixelTheme.completed.opacity(0.15) : PixelTheme.accent.opacity(0.08))
                .frame(height: 150)
                .overlay {
                    Image(systemName: item.season.icon)
                        .font(.system(size: 36))
                        .foregroundColor(PixelTheme.accent.opacity(0.4))
                }

            Text(item.name)
                .font(PixelTheme.captionFont)
                .foregroundColor(PixelTheme.text)
                .lineLimit(1)

            if isOwned {
                Text("Owned")
                    .font(.system(size: 11, weight: .semibold, design: .rounded))
                    .foregroundColor(PixelTheme.completed)
            } else {
                Button { purchaseItem(item.id, item.price) } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "circle.fill")
                            .font(.system(size: 8))
                            .foregroundColor(PixelTheme.coin)
                        Text("\(item.price)")
                            .font(PixelTheme.captionFont)
                    }
                    .foregroundColor(canAfford ? PixelTheme.text : PixelTheme.pending)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(canAfford ? PixelTheme.coin.opacity(0.2) : PixelTheme.pending.opacity(0.1))
                    .cornerRadius(10)
                }
                .disabled(!canAfford)
            }
        }
        .padding(10)
        .background(PixelTheme.cardBackground)
        .cornerRadius(14)
        .shadow(color: PixelTheme.shadowColor, radius: 2, y: 1)
    }

    // MARK: - Room Shop

    private var ownedRoomTypes: Set<String> {
        Set(rooms.map { $0.roomTypeRaw })
    }

    private var roomShop: some View {
        VStack(spacing: 12) {
            ForEach(RoomType.allCases) { roomType in
                let isOwned = ownedRoomTypes.contains(roomType.rawValue)
                let canAfford = player?.canAfford(roomType.unlockPrice) ?? false

                HStack(spacing: 14) {
                    Image(systemName: roomType.icon)
                        .font(.title2)
                        .foregroundColor(isOwned ? PixelTheme.primary : PixelTheme.text.opacity(0.4))
                        .frame(width: 44, height: 44)
                        .background(isOwned ? PixelTheme.primary.opacity(0.1) : Color.gray.opacity(0.08))
                        .cornerRadius(12)

                    VStack(alignment: .leading, spacing: 2) {
                        Text(roomType.displayName)
                            .font(PixelTheme.bodyFont)
                            .foregroundColor(PixelTheme.text)
                        Text(roomType.description)
                            .font(PixelTheme.captionFont)
                            .foregroundColor(PixelTheme.text.opacity(0.5))
                    }

                    Spacer()

                    if isOwned {
                        Text("Owned")
                            .font(.system(size: 11, weight: .semibold, design: .rounded))
                            .foregroundColor(PixelTheme.completed)
                    } else if roomType.unlockPrice == 0 {
                        Text("Free")
                            .font(.system(size: 11, weight: .semibold, design: .rounded))
                            .foregroundColor(PixelTheme.primary)
                    } else {
                        Button {
                            purchaseRoom(roomType)
                        } label: {
                            HStack(spacing: 4) {
                                Image(systemName: "circle.fill")
                                    .font(.system(size: 8))
                                    .foregroundColor(PixelTheme.coin)
                                Text("\(roomType.unlockPrice)")
                                    .font(PixelTheme.captionFont)
                            }
                            .foregroundColor(canAfford ? PixelTheme.text : PixelTheme.pending)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(canAfford ? PixelTheme.coin.opacity(0.2) : PixelTheme.pending.opacity(0.1))
                            .cornerRadius(10)
                        }
                        .disabled(!canAfford)
                    }
                }
                .padding(14)
                .background(PixelTheme.cardBackground)
                .cornerRadius(14)
                .shadow(color: PixelTheme.shadowColor, radius: 2, y: 1)
            }
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 20)
    }

    // MARK: - Slot color helpers

    private func outfitSlotColor(_ slot: OutfitSlot) -> Color {
        switch slot {
        case .head: return Color(hex: "E8985E")
        case .face: return Color(hex: "FFD180")
        case .neck: return Color(hex: "B388FF")
        case .top: return Color(hex: "5B8C5A")
        case .hand: return Color(hex: "4FC3F7")
        case .shoes: return Color(hex: "E8985E").opacity(0.8)
        }
    }

    // MARK: - Purchase Actions

    private func purchaseItem(_ itemID: String, _ price: Int) {
        guard let player = player else { return }
        let coinService = CoinService(modelContext: modelContext)
        if coinService.purchaseItem(itemID: itemID, player: player) {
            HapticService.success()
            SoundService.playPurchaseSound()
            purchaseAnimation = itemID
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                purchaseAnimation = nil
            }
            try? modelContext.save()
        } else {
            HapticService.error()
            SoundService.playErrorSound()
        }
    }

    private func purchaseRoom(_ roomType: RoomType) {
        guard let player = player else { return }
        let coinService = CoinService(modelContext: modelContext)
        if coinService.purchaseRoom(roomType: roomType, player: player) {
            let newRoom = Room(roomType: roomType, isActive: false)
            modelContext.insert(newRoom)
            HapticService.success()
            SoundService.playPurchaseSound()
            try? modelContext.save()
        } else {
            HapticService.error()
            SoundService.playErrorSound()
        }
    }

    // MARK: - Sub-filter pill

    private func categoryFilterPill(_ name: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(name)
                .font(.system(size: 11, weight: .medium, design: .rounded))
                .foregroundColor(isSelected ? .white : PixelTheme.text.opacity(0.6))
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(isSelected ? PixelTheme.primary.opacity(0.8) : PixelTheme.cardBackground.opacity(0.6))
                .cornerRadius(12)
        }
    }
}

// MARK: - Category Pill

struct CategoryPill: View {
    let name: String
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            Text(name)
                .font(PixelTheme.captionFont)
                .foregroundColor(isSelected ? .white : PixelTheme.text)
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(isSelected ? PixelTheme.primary : PixelTheme.cardBackground)
                .cornerRadius(16)
                .shadow(color: PixelTheme.shadowColor, radius: isSelected ? 0 : 2)
        }
    }
}

// MARK: - Shop Item Card

struct ShopItemCard: View {
    let item: ShopItem
    let isOwned: Bool
    let canAfford: Bool
    let isPurchasing: Bool
    let onPurchase: () -> Void

    private func slotIcon(_ slot: SlotType?) -> String {
        switch slot {
        case .bed: return "bed.double.fill"
        case .desk, .deskChair: return "laptopcomputer"
        case .shelf: return "books.vertical.fill"
        case .wallDecor1, .wallDecor2: return "photo.fill"
        case .windowArea: return "window.ceiling.closed"
        case .cozyCorner: return "sofa.fill"
        case .sideTable: return "lamp.table.fill"
        case .petBed: return "pawprint.fill"
        default: return "sparkles"
        }
    }

    private var placeholderColor: Color {
        switch item.slot {
        case .bed, .sideTable: return PixelTheme.primary
        case .desk, .deskChair: return PixelTheme.accent
        case .shelf, .wallDecor1, .wallDecor2: return Color(hex: "B388FF")
        case .windowArea, .cozyCorner: return Color(hex: "FFD180")
        default: return PixelTheme.primary.opacity(0.7)
        }
    }

    var body: some View {
        VStack(spacing: 8) {
            RoundedRectangle(cornerRadius: 10)
                .fill(isOwned ? PixelTheme.completed.opacity(0.12) : placeholderColor.opacity(0.12))
                .frame(height: 150)
                .overlay {
                    if UIImage(named: item.spriteName) != nil {
                        Image(item.spriteName)
                            .resizable()
                            .interpolation(.none)
                            .scaledToFit()
                            .padding(16)
                    } else {
                        VStack(spacing: 8) {
                            Image(systemName: slotIcon(item.slot))
                                .font(.system(size: 32))
                                .foregroundColor(placeholderColor.opacity(0.7))
                            Text(item.name)
                                .font(.system(size: 11, weight: .semibold, design: .rounded))
                                .foregroundColor(placeholderColor)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 8)
                        }
                    }
                }
                .scaleEffect(isPurchasing ? 1.05 : 1.0)
                .animation(.spring(response: 0.3), value: isPurchasing)

            Text(item.name)
                .font(PixelTheme.captionFont)
                .foregroundColor(PixelTheme.text)
                .lineLimit(1)

            if isOwned {
                Text("Owned")
                    .font(.system(size: 11, weight: .semibold, design: .rounded))
                    .foregroundColor(PixelTheme.completed)
            } else {
                Button(action: onPurchase) {
                    HStack(spacing: 4) {
                        Image(systemName: "circle.fill")
                            .font(.system(size: 8))
                            .foregroundColor(PixelTheme.coin)
                        Text("\(item.price)")
                            .font(PixelTheme.captionFont)
                    }
                    .foregroundColor(canAfford ? PixelTheme.text : PixelTheme.pending)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(canAfford ? PixelTheme.coin.opacity(0.2) : PixelTheme.pending.opacity(0.1))
                    .cornerRadius(10)
                }
                .disabled(!canAfford)
            }
        }
        .padding(10)
        .background(PixelTheme.cardBackground)
        .cornerRadius(14)
        .shadow(color: PixelTheme.shadowColor, radius: 2, y: 1)
    }
}
