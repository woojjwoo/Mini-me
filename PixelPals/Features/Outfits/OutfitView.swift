import SwiftUI
import SwiftData

struct OutfitView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var players: [Player]
    @Query private var pets: [Pet]

    @State private var selectedSlot: OutfitSlot?

    private var player: Player? { players.first }
    private var pet: Pet? { pets.first }

    private var ownedOutfits: [OutfitItem] {
        guard let player = player else { return [] }
        return OutfitCatalog.allOutfits.filter { player.ownsItem($0.id) }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                PixelTheme.background.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 16) {
                        // Avatar preview with current outfit
                        avatarPreview

                        // Outfit slots
                        outfitSlotsGrid

                        // Selected slot items
                        if let slot = selectedSlot {
                            slotItemsList(slot)
                        }
                    }
                    .padding(16)
                }
            }
            .navigationTitle("Outfits")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    // MARK: - Avatar Preview

    private var avatarPreview: some View {
        VStack(spacing: 8) {
            ZStack {
                RoundedRectangle(cornerRadius: 20)
                    .fill(PixelTheme.primary.opacity(0.1))
                    .frame(width: 140, height: 140)

                VStack(spacing: 4) {
                    Text("🧑")
                        .font(.system(size: 60))

                    // Show equipped items as small icons below
                    if let pet = pet {
                        HStack(spacing: 4) {
                            ForEach(pet.equippedOutfitIDs, id: \.self) { outfitID in
                                if let outfit = OutfitCatalog.outfit(byID: outfitID) {
                                    Image(systemName: outfit.outfitSlot.icon)
                                        .font(.system(size: 10))
                                        .foregroundColor(PixelTheme.accent)
                                }
                            }
                        }
                    }
                }
            }

            if let pet = pet {
                Text(pet.name)
                    .font(PixelTheme.headlineFont)
                    .foregroundColor(PixelTheme.text)
                Text("\(pet.equippedOutfitIDs.count) items equipped")
                    .font(PixelTheme.captionFont)
                    .foregroundColor(PixelTheme.text.opacity(0.5))
            }
        }
        .padding(16)
        .background(PixelTheme.cardBackground)
        .cornerRadius(16)
        .shadow(color: PixelTheme.shadowColor, radius: 4, y: 2)
    }

    // MARK: - Outfit Slots Grid

    private var outfitSlotsGrid: some View {
        LazyVGrid(columns: [
            GridItem(.flexible()),
            GridItem(.flexible()),
            GridItem(.flexible()),
        ], spacing: 12) {
            ForEach(OutfitSlot.allCases) { slot in
                outfitSlotButton(slot)
            }
        }
    }

    private func outfitSlotButton(_ slot: OutfitSlot) -> some View {
        let equipped = pet?.equippedOutfit(for: slot)
        let isSelected = selectedSlot == slot

        return Button {
            HapticService.selection()
            withAnimation(.spring(response: 0.3)) {
                selectedSlot = selectedSlot == slot ? nil : slot
            }
        } label: {
            VStack(spacing: 6) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(isSelected ? PixelTheme.primary.opacity(0.15) : PixelTheme.cardBackground)
                        .frame(height: 60)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(isSelected ? PixelTheme.primary : Color.clear, lineWidth: 2)
                        )

                    if let equipped = equipped {
                        VStack(spacing: 2) {
                            Image(systemName: slot.icon)
                                .font(.title3)
                                .foregroundColor(PixelTheme.primary)
                            Text(equipped.name)
                                .font(.system(size: 8, weight: .medium))
                                .foregroundColor(PixelTheme.text.opacity(0.6))
                                .lineLimit(1)
                        }
                    } else {
                        Image(systemName: slot.icon)
                            .font(.title3)
                            .foregroundColor(PixelTheme.pending)
                    }
                }

                Text(slot.displayName)
                    .font(PixelTheme.captionFont)
                    .foregroundColor(PixelTheme.text.opacity(0.7))
            }
        }
        .buttonStyle(.plain)
    }

    // MARK: - Slot Items List

    private func slotItemsList(_ slot: OutfitSlot) -> some View {
        let slotOutfits = ownedOutfits.filter { $0.outfitSlot == slot }

        return VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(slot.displayName)
                    .font(PixelTheme.headlineFont)
                    .foregroundColor(PixelTheme.text)
                Spacer()
                if pet?.equippedOutfit(for: slot) != nil {
                    Button("Remove") {
                        unequipSlot(slot)
                    }
                    .font(PixelTheme.captionFont)
                    .foregroundColor(.red.opacity(0.7))
                }
            }

            if slotOutfits.isEmpty {
                HStack {
                    Spacer()
                    VStack(spacing: 6) {
                        Image(systemName: "bag")
                            .font(.title2)
                            .foregroundColor(PixelTheme.pending)
                        Text("No \(slot.displayName.lowercased()) items owned")
                            .font(PixelTheme.captionFont)
                            .foregroundColor(PixelTheme.text.opacity(0.4))
                        Text("Buy from the Shop tab")
                            .font(PixelTheme.captionFont)
                            .foregroundColor(PixelTheme.text.opacity(0.3))
                    }
                    Spacer()
                }
                .padding(.vertical, 20)
            } else {
                ForEach(slotOutfits) { outfit in
                    outfitRow(outfit)
                }
            }
        }
        .padding(16)
        .background(PixelTheme.cardBackground)
        .cornerRadius(16)
        .shadow(color: PixelTheme.shadowColor, radius: 4, y: 2)
    }

    private func outfitRow(_ outfit: OutfitItem) -> some View {
        let isEquipped = pet?.isWearing(outfit.id) ?? false

        return Button {
            toggleOutfit(outfit)
        } label: {
            HStack(spacing: 12) {
                RoundedRectangle(cornerRadius: 8)
                    .fill(isEquipped ? PixelTheme.primary.opacity(0.15) : Color.gray.opacity(0.1))
                    .frame(width: 44, height: 44)
                    .overlay {
                        Image(systemName: outfit.outfitSlot.icon)
                            .foregroundColor(isEquipped ? PixelTheme.primary : PixelTheme.text.opacity(0.4))
                    }

                VStack(alignment: .leading, spacing: 2) {
                    Text(outfit.name)
                        .font(PixelTheme.bodyFont)
                        .foregroundColor(PixelTheme.text)

                    if let trigger = outfit.scheduleTrigger {
                        Text("Auto-equips during \(trigger)")
                            .font(.system(size: 10))
                            .foregroundColor(PixelTheme.accent.opacity(0.8))
                    }
                }

                Spacer()

                if isEquipped {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(PixelTheme.primary)
                } else {
                    Text("Equip")
                        .font(PixelTheme.captionFont)
                        .foregroundColor(PixelTheme.primary)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(PixelTheme.primary.opacity(0.1))
                        .cornerRadius(8)
                }
            }
            .padding(.vertical, 4)
        }
        .buttonStyle(.plain)
    }

    // MARK: - Actions

    private func toggleOutfit(_ outfit: OutfitItem) {
        guard let pet = pet else { return }
        if pet.isWearing(outfit.id) {
            pet.unequip(outfit.id)
            HapticService.light()
        } else {
            pet.equip(outfit.id)
            HapticService.success()
        }
        try? modelContext.save()
    }

    private func unequipSlot(_ slot: OutfitSlot) {
        guard let pet = pet else { return }
        if let equipped = pet.equippedOutfit(for: slot) {
            pet.unequip(equipped.id)
            HapticService.light()
            try? modelContext.save()
        }
    }
}
