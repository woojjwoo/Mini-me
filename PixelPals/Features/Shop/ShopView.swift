import SwiftUI
import SwiftData

struct ShopView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var players: [Player]
    @Query private var rooms: [Room]

    @State private var selectedCategory: ItemCategory?
    @State private var purchaseAnimation: String? // itemID being animated

    private var player: Player? { players.first }
    private var room: Room? { rooms.first }

    private var displayedItems: [ShopItem] {
        if let category = selectedCategory {
            return ItemCatalog.items(in: category)
        }
        return ItemCatalog.allItems
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

                    // Category filter
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            CategoryPill(name: "All", isSelected: selectedCategory == nil) {
                                selectedCategory = nil
                            }
                            ForEach(ItemCategory.allCases) { category in
                                CategoryPill(
                                    name: category.displayName,
                                    isSelected: selectedCategory == category
                                ) {
                                    selectedCategory = category
                                }
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                    }

                    // Items grid
                    ScrollView {
                        LazyVGrid(columns: [
                            GridItem(.flexible()),
                            GridItem(.flexible()),
                        ], spacing: 12) {
                            ForEach(displayedItems) { item in
                                ShopItemCard(
                                    item: item,
                                    isOwned: player?.ownsItem(item.id) ?? false,
                                    canAfford: player?.canAfford(item.price) ?? false,
                                    isPurchasing: purchaseAnimation == item.id,
                                    onPurchase: { purchaseItem(item) }
                                )
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.bottom, 20)
                    }
                }
            }
            .navigationTitle("Shop")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private func purchaseItem(_ item: ShopItem) {
        guard let player = player else { return }
        let coinService = CoinService(modelContext: modelContext)
        if coinService.purchaseItem(itemID: item.id, player: player) {
            HapticService.success()
            SoundService.playPurchaseSound()
            purchaseAnimation = item.id
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                purchaseAnimation = nil
            }
            try? modelContext.save()
        } else {
            HapticService.error()
            SoundService.playErrorSound()
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

    var body: some View {
        VStack(spacing: 8) {
            // Item preview (placeholder)
            RoundedRectangle(cornerRadius: 10)
                .fill(isOwned ? PixelTheme.completed.opacity(0.15) : Color.gray.opacity(0.1))
                .frame(height: 100)
                .overlay {
                    VStack {
                        if let slot = item.slot {
                            Image(systemName: "square.dashed")
                                .font(.title)
                                .foregroundColor(PixelTheme.text.opacity(0.3))
                            Text(slot.displayName)
                                .font(.system(size: 9))
                                .foregroundColor(PixelTheme.text.opacity(0.4))
                        }
                    }
                }
                .overlay(alignment: .topTrailing) {
                    if item.isPremium {
                        Text("PRO")
                            .font(.system(size: 8, weight: .bold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(PixelTheme.accent)
                            .cornerRadius(4)
                            .padding(6)
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
