import SwiftUI
import SpriteKit
import SwiftData

struct IsometricRoomView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var rooms: [Room]
    @Query private var players: [Player]
    @Query private var pets: [Pet]

    @State private var selectedSlot: SlotType?
    @State private var showingSlotPicker = false
    @State private var selectedRoomID: UUID?

    private var activeRoom: Room? {
        if let selected = selectedRoomID {
            return rooms.first { $0.id == selected }
        }
        return rooms.first { $0.isActive } ?? rooms.first
    }

    private var player: Player? { players.first }

    var body: some View {
        NavigationStack {
            ZStack {
                PixelTheme.background.ignoresSafeArea()

                VStack(spacing: 0) {
                    // Room Switcher UI
                    if rooms.count > 1 {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(rooms) { r in
                                    Button {
                                        selectedRoomID = r.id
                                    } label: {
                                        Text(r.roomType.displayName)
                                            .font(.system(size: 14, weight: .bold, design: .rounded))
                                            .padding(.horizontal, 16)
                                            .padding(.vertical, 8)
                                            .background(activeRoom?.id == r.id ? PixelTheme.primary : PixelTheme.cardBackground)
                                            .foregroundColor(activeRoom?.id == r.id ? .white : PixelTheme.text)
                                            .cornerRadius(20)
                                            .shadow(color: PixelTheme.shadowColor, radius: 1, y: 1)
                                    }
                                }
                            }
                            .padding(.horizontal, 16)
                            .padding(.bottom, 8)
                        }
                    }

                    // SpriteKit room scene
                    if let room = activeRoom {
                        SpriteView(scene: makeScene(room: room))
                            .frame(maxWidth: .infinity)
                            .frame(height: 400)
                            .cornerRadius(16)
                            .padding(.horizontal, 16)
                            .padding(.top, 8)
                    }

                    // Slot buttons (scrollable grid)
                    ScrollView {
                        VStack(spacing: 8) {
                            Text("Tap a slot to change furniture")
                                .font(PixelTheme.captionFont)
                                .foregroundColor(PixelTheme.text.opacity(0.5))
                                .padding(.top, 12)

                            LazyVGrid(columns: [
                                GridItem(.flexible()),
                                GridItem(.flexible()),
                                GridItem(.flexible()),
                            ], spacing: 10) {
                                ForEach(SlotType.allCases) { slot in
                                    SlotButton(
                                        slot: slot,
                                        currentItemID: activeRoom?.assignment(for: slot)?.itemID,
                                        onTap: {
                                            selectedSlot = slot
                                            showingSlotPicker = true
                                        }
                                    )
                                }
                            }
                            .padding(.horizontal, 16)
                            .padding(.bottom, 30) // Add padding so scroll isn't tight
                        }
                    }
                }
            }
            .navigationTitle("My Room")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showingSlotPicker) {
                if let slot = selectedSlot, let player = player, let room = activeRoom {
                    SlotItemPicker(
                        slot: slot,
                        player: player,
                        room: room,
                        onDismiss: { showingSlotPicker = false }
                    )
                    .presentationDetents([.medium])
                }
            }
        }
    }

    private func makeScene(room: Room) -> RoomScene {
        let scene = RoomScene(room: room, size: CGSize(width: 400, height: 400))
        scene.scaleMode = .aspectFit
        scene.backgroundColor = .clear
        return scene
    }
}

// MARK: - Slot Button

struct SlotButton: View {
    let slot: SlotType
    let currentItemID: String?
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 4) {
                if let itemID = currentItemID, let item = ItemCatalog.item(byID: itemID) {
                    // Show item icon/name
                    Image(systemName: "checkmark.square.fill")
                        .font(.title3)
                        .foregroundColor(PixelTheme.completed)
                    Text(item.name)
                        .font(.system(size: 9, weight: .medium, design: .rounded))
                        .foregroundColor(PixelTheme.text)
                        .lineLimit(1)
                } else {
                    // Empty slot
                    Image(systemName: "plus.square.dashed")
                        .font(.title3)
                        .foregroundColor(PixelTheme.pending)
                    Text(slot.displayName)
                        .font(.system(size: 9, weight: .medium, design: .rounded))
                        .foregroundColor(PixelTheme.text.opacity(0.5))
                        .lineLimit(1)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
            .background(PixelTheme.cardBackground)
            .cornerRadius(10)
            .shadow(color: PixelTheme.shadowColor, radius: 2, y: 1)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Slot Item Picker

struct SlotItemPicker: View {
    let slot: SlotType
    let player: Player
    let room: Room
    let onDismiss: () -> Void

    @Environment(\.modelContext) private var modelContext

    private var availableItems: [ShopItem] {
        ItemCatalog.items(for: slot).filter { player.ownsItem($0.id) }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                Text(slot.displayName)
                    .font(PixelTheme.headlineFont)
                    .foregroundColor(PixelTheme.text)

                if availableItems.isEmpty {
                    VStack(spacing: 8) {
                        Text("No items owned for this slot")
                            .font(PixelTheme.bodyFont)
                            .foregroundColor(PixelTheme.text.opacity(0.5))
                        Text("Visit the Shop to buy furniture!")
                            .font(PixelTheme.captionFont)
                            .foregroundColor(PixelTheme.accent)
                    }
                    .padding(.top, 40)
                } else {
                    List {
                        // Empty option
                        Button("Remove item") {
                            room.removeItem(from: slot)
                            try? modelContext.save()
                            onDismiss()
                        }
                        .foregroundColor(.red)

                        ForEach(availableItems) { item in
                            Button {
                                room.placeItem(item.id, in: slot)
                                try? modelContext.save()
                                onDismiss()
                            } label: {
                                HStack {
                                    Text(item.name)
                                        .foregroundColor(PixelTheme.text)
                                    Spacer()
                                    if room.assignment(for: slot)?.itemID == item.id {
                                        Image(systemName: "checkmark")
                                            .foregroundColor(PixelTheme.completed)
                                    }
                                }
                            }
                        }
                    }
                    .listStyle(.plain)
                }

                Spacer()
            }
            .padding(.top, 20)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close", action: onDismiss)
                }
            }
        }
    }
}
