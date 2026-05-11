import SwiftUI
import SwiftData
import EventKit

struct SettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query private var players: [Player]
    @Query private var pets: [Pet]
    @Query private var schedules: [DailySchedule]
    @Query private var rooms: [Room]

    @State private var showingResetAlert = false
    @State private var showingScheduleEditor = false
    @State private var showingWeekendScheduleEditor = false
    @State private var showingCharacterEditor = false
    @State private var showingCharacterCard = false
    @State private var showingOutfitView = false
    @State private var showingStatusPicker = false
    @State private var showingCalendarSync = false
    @State private var notificationsEnabled = false

    private var player: Player? { players.first }
    private var pet: Pet? { pets.first }
    private var weekdaySchedule: DailySchedule? { schedules.first { $0.isWeekday } ?? schedules.first }
    private var weekendSchedule: DailySchedule? { schedules.first { !$0.isWeekday } }

    var body: some View {
        ZStack {
            PixelTheme.background.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 16) {
                    // Mini Me section
                    settingsSection(title: "Your Mini Me") {
                        if let pet = pet {
                            petRow(pet)
                            Divider()
                            outfitRow(pet)
                            Divider()
                            characterCardRow(pet)
                        }
                    }

                    // Status section (v2: Sick Day)
                    settingsSection(title: "Status") {
                        statusRow
                    }

                    // Schedule section
                    settingsSection(title: "Daily Schedule") {
                        weekdayScheduleRow
                        Divider()
                        weekendScheduleRow
                    }

                    // Notifications section
                    settingsSection(title: "Notifications") {
                        notificationToggleRow
                    }

                    // Calendar section
                    settingsSection(title: "Calendar Sync") {
                        calendarSyncRow
                    }

                    // Pro section
                    if !(player?.isPremium ?? false) {
                        settingsSection(title: "Mini Me Pro") {
                            proUpgradeRow
                        }
                    }

                    // App section
                    settingsSection(title: "App") {
                        infoRow(icon: "info.circle", label: "Version", value: "2.0.0")
                        Divider()
                        infoRow(icon: "house.fill", label: "Rooms", value: "\(rooms.count)")
                        Divider()
                        dangerRow
                    }
                }
                .padding(16)
            }
        }
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showingCharacterEditor) {
            if let pet = pet {
                CharacterEditorView(pet: pet)
            }
        }
        .sheet(isPresented: $showingCharacterCard) {
            if let pet = pet {
                CharacterCardView(pet: pet, player: player)
                    .presentationDetents([.medium, .large])
            }
        }
        .sheet(isPresented: $showingOutfitView) {
            OutfitView()
        }
        .sheet(isPresented: $showingScheduleEditor) {
            if let schedule = weekdaySchedule {
                ScheduleEditorSheet(schedule: schedule)
                    .presentationDetents([.large])
            }
        }
        .sheet(isPresented: $showingWeekendScheduleEditor) {
            if let schedule = weekendSchedule {
                ScheduleEditorSheet(schedule: schedule)
                    .presentationDetents([.large])
            } else {
                WeekendScheduleSetupSheet { newSchedule in
                    modelContext.insert(newSchedule)
                    try? modelContext.save()
                }
                .presentationDetents([.medium])
            }
        }
        .sheet(isPresented: $showingStatusPicker) {
            StatusPickerSheet(player: player)
                .presentationDetents([.medium])
        }
        .sheet(isPresented: $showingCalendarSync) {
            CalendarSyncSheet()
                .presentationDetents([.large])
        }
        .alert("Reset All Data?", isPresented: $showingResetAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Reset", role: .destructive) {
                resetAllData()
            }
        } message: {
            Text("This will delete your Mini Me, schedule, coins, and all progress. This cannot be undone.")
        }
    }

    // MARK: - Section Builder

    private func settingsSection(title: String, @ViewBuilder content: () -> some View) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(PixelTheme.headlineFont)
                .foregroundColor(PixelTheme.text)

            VStack(spacing: 0) {
                content()
            }
            .background(PixelTheme.cardBackground)
            .cornerRadius(14)
            .shadow(color: PixelTheme.shadowColor, radius: 4, y: 2)
        }
    }

    // MARK: - Pet Row

    private func petRow(_ pet: Pet) -> some View {
        Button {
            HapticService.light()
            showingCharacterEditor = true
        } label: {
            HStack(spacing: 12) {
                // Live pixel art preview instead of emoji
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(PixelTheme.primary.opacity(0.1))
                        .frame(width: 52, height: 52)
                    MiniMeAvatarView(
                        hairStyle:   pet.hairStyle,
                        hairColor:   pet.hairColor,
                        skinTone:    pet.skinTone,
                        eyeSize:     pet.eyeSize,
                        outfitStyle: pet.characterOutfitStyle,
                        faceShape:   pet.faceShape,
                        pixelSize:   3
                    )
                    .allowsHitTesting(false)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(pet.name)
                        .font(PixelTheme.bodyFont)
                        .foregroundColor(PixelTheme.text)
                    Text("Edit Appearance")
                        .font(PixelTheme.captionFont)
                        .foregroundColor(PixelTheme.text.opacity(0.5))
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(PixelTheme.text.opacity(0.3))
            }
            .padding(14)
        }
        .buttonStyle(.plain)
    }

    // MARK: - Character Card Row

    private func characterCardRow(_ pet: Pet) -> some View {
        Button {
            HapticService.light()
            showingCharacterCard = true
        } label: {
            HStack(spacing: 12) {
                Image(systemName: "square.and.arrow.up")
                    .font(.title3)
                    .foregroundColor(PixelTheme.primary)
                    .frame(width: 44, height: 44)
                VStack(alignment: .leading, spacing: 2) {
                    Text("Share Character Card")
                        .font(PixelTheme.bodyFont)
                        .foregroundColor(PixelTheme.text)
                    Text("Export your Mini Me as an image")
                        .font(PixelTheme.captionFont)
                        .foregroundColor(PixelTheme.text.opacity(0.5))
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(PixelTheme.text.opacity(0.3))
            }
            .padding(14)
        }
        .buttonStyle(.plain)
    }

    // MARK: - Outfit Row

    private func outfitRow(_ pet: Pet) -> some View {
        Button {
            HapticService.light()
            showingOutfitView = true
        } label: {
            HStack(spacing: 12) {
                Image(systemName: "tshirt.fill")
                    .font(.title3)
                    .foregroundColor(PixelTheme.accent)
                    .frame(width: 44, height: 44)

                VStack(alignment: .leading, spacing: 2) {
                    Text("Outfits")
                        .font(PixelTheme.bodyFont)
                        .foregroundColor(PixelTheme.text)
                    Text("\(pet.equippedOutfitIDs.count) equipped")
                        .font(PixelTheme.captionFont)
                        .foregroundColor(PixelTheme.text.opacity(0.5))
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(PixelTheme.text.opacity(0.3))
            }
            .padding(14)
        }
        .buttonStyle(.plain)
    }

    // MARK: - Status Row (v2: Sick Day)

    private var statusRow: some View {
        Button {
            HapticService.light()
            showingStatusPicker = true
        } label: {
            HStack(spacing: 12) {
                if let status = player?.manualStatus {
                    Text(status.emoji)
                        .font(.title3)
                        .frame(width: 44, height: 44)
                } else {
                    Image(systemName: "face.smiling")
                        .font(.title3)
                        .foregroundColor(PixelTheme.primary)
                        .frame(width: 44, height: 44)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(player?.manualStatus?.displayName ?? "Normal")
                        .font(PixelTheme.bodyFont)
                        .foregroundColor(PixelTheme.text)
                    Text(player?.manualStatus?.avatarDescription ?? "Avatar follows your schedule mood")
                        .font(PixelTheme.captionFont)
                        .foregroundColor(PixelTheme.text.opacity(0.5))
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(PixelTheme.text.opacity(0.3))
            }
            .padding(14)
        }
        .buttonStyle(.plain)
    }

    // MARK: - Schedule Rows

    private var weekdayScheduleRow: some View {
        Button {
            HapticService.light()
            showingScheduleEditor = true
        } label: {
            HStack(spacing: 12) {
                Image(systemName: "calendar.badge.clock")
                    .font(.title3)
                    .foregroundColor(PixelTheme.primary)
                    .frame(width: 44, height: 44)

                VStack(alignment: .leading, spacing: 2) {
                    Text("Weekday Schedule")
                        .font(PixelTheme.bodyFont)
                        .foregroundColor(PixelTheme.text)
                    if let schedule = weekdaySchedule {
                        Text("\(schedule.blocks.count) blocks")
                            .font(PixelTheme.captionFont)
                            .foregroundColor(PixelTheme.text.opacity(0.5))
                    }
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(PixelTheme.text.opacity(0.3))
            }
            .padding(14)
        }
        .buttonStyle(.plain)
    }

    private var weekendScheduleRow: some View {
        Button {
            HapticService.light()
            showingWeekendScheduleEditor = true
        } label: {
            HStack(spacing: 12) {
                Image(systemName: "sun.max.fill")
                    .font(.title3)
                    .foregroundColor(PixelTheme.accent)
                    .frame(width: 44, height: 44)

                VStack(alignment: .leading, spacing: 2) {
                    Text("Weekend Schedule")
                        .font(PixelTheme.bodyFont)
                        .foregroundColor(PixelTheme.text)
                    if let schedule = weekendSchedule {
                        Text("\(schedule.blocks.count) blocks")
                            .font(PixelTheme.captionFont)
                            .foregroundColor(PixelTheme.text.opacity(0.5))
                    } else {
                        Text("Not set up yet")
                            .font(PixelTheme.captionFont)
                            .foregroundColor(PixelTheme.accent.opacity(0.7))
                    }
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(PixelTheme.text.opacity(0.3))
            }
            .padding(14)
        }
        .buttonStyle(.plain)
    }

    // MARK: - Notification Toggle

    private var notificationToggleRow: some View {
        HStack(spacing: 12) {
            Image(systemName: "bell.fill")
                .font(.title3)
                .foregroundColor(PixelTheme.primary)
                .frame(width: 44, height: 44)

            VStack(alignment: .leading, spacing: 2) {
                Text("Block Reminders")
                    .font(PixelTheme.bodyFont)
                    .foregroundColor(PixelTheme.text)
                Text("Get reminded 5 min before each block")
                    .font(PixelTheme.captionFont)
                    .foregroundColor(PixelTheme.text.opacity(0.5))
            }

            Spacer()

            Toggle("", isOn: $notificationsEnabled)
                .tint(PixelTheme.primary)
                .onChange(of: notificationsEnabled) { _, enabled in
                    if enabled {
                        Task {
                            let granted = await NotificationService.shared.requestPermission()
                            if granted, let schedule = weekdaySchedule, let pet = pet {
                                let blocks = schedule.sortedBlocks.map { TimeBlockDTO(from: $0) }
                                NotificationService.shared.scheduleBlockReminders(blocks: blocks, petName: pet.name)
                                NotificationService.shared.scheduleMorningGreeting(
                                    wakeUpHour: schedule.sortedBlocks.first?.startHour ?? 7,
                                    petName: pet.name
                                )
                                NotificationService.shared.scheduleMidDayNudge(
                                    completedCount: 0,
                                    totalCount: schedule.blocks.count,
                                    petName: pet.name
                                )
                                if let streak = player?.currentStreak, streak > 0 {
                                    NotificationService.shared.scheduleStreakWarning(
                                        currentStreak: streak,
                                        petName: pet.name
                                    )
                                }
                            } else {
                                notificationsEnabled = false
                            }
                        }
                    } else {
                        NotificationService.shared.cancelAllNotifications()
                    }
                }
        }
        .padding(14)
    }

    // MARK: - Calendar Sync

    private var calendarSyncRow: some View {
        Button {
            HapticService.light()
            showingCalendarSync = true
        } label: {
            HStack(spacing: 12) {
                Image(systemName: "calendar")
                    .font(.title3)
                    .foregroundColor(PixelTheme.primary)
                    .frame(width: 44, height: 44)

                VStack(alignment: .leading, spacing: 2) {
                    Text("Import from Calendar")
                        .font(PixelTheme.bodyFont)
                        .foregroundColor(PixelTheme.text)
                    Text("Add calendar events as schedule blocks")
                        .font(PixelTheme.captionFont)
                        .foregroundColor(PixelTheme.text.opacity(0.5))
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(PixelTheme.text.opacity(0.3))
            }
            .padding(14)
        }
        .buttonStyle(.plain)
    }

    // MARK: - Pro Upgrade

    private var proUpgradeRow: some View {
        Button {
            HapticService.medium()
            // In production: trigger StoreKit purchase flow
            player?.isPremium = true
            try? modelContext.save()
        } label: {
            HStack(spacing: 12) {
                Image(systemName: "crown.fill")
                    .font(.title3)
                    .foregroundColor(PixelTheme.coin)
                    .frame(width: 44, height: 44)

                VStack(alignment: .leading, spacing: 2) {
                    Text("Upgrade to Pro")
                        .font(PixelTheme.bodyFont)
                        .foregroundColor(PixelTheme.text)
                    Text("$1.99/mo — Exclusive items, lock screen widget, weekend schedule")
                        .font(PixelTheme.captionFont)
                        .foregroundColor(PixelTheme.text.opacity(0.5))
                }

                Spacer()

                Text("$1.99")
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(PixelTheme.accent)
                    .cornerRadius(10)
            }
            .padding(14)
        }
        .buttonStyle(.plain)
    }

    // MARK: - Info Row

    private func infoRow(icon: String, label: String, value: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(PixelTheme.primary)
                .frame(width: 44, height: 44)

            Text(label)
                .font(PixelTheme.bodyFont)
                .foregroundColor(PixelTheme.text)

            Spacer()

            Text(value)
                .font(PixelTheme.captionFont)
                .foregroundColor(PixelTheme.text.opacity(0.5))
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 8)
    }

    // MARK: - Danger Zone

    private var dangerRow: some View {
        Button {
            HapticService.warning()
            showingResetAlert = true
        } label: {
            HStack(spacing: 12) {
                Image(systemName: "exclamationmark.triangle")
                    .font(.title3)
                    .foregroundColor(.red.opacity(0.7))
                    .frame(width: 44, height: 44)

                Text("Reset All Data")
                    .font(PixelTheme.bodyFont)
                    .foregroundColor(.red.opacity(0.8))

                Spacer()
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
        }
        .buttonStyle(.plain)
    }

    // MARK: - Actions

    private func resetAllData() {
        NotificationService.shared.cancelAllNotifications()
        do {
            try modelContext.delete(model: Player.self)
            try modelContext.delete(model: Pet.self)
            try modelContext.delete(model: Room.self)
            try modelContext.delete(model: RoomSlotAssignment.self)
            try modelContext.delete(model: DailySchedule.self)
            try modelContext.delete(model: TimeBlock.self)
            try modelContext.delete(model: DayLog.self)
            try modelContext.save()
        } catch {
            // Silently handle
        }
    }

}

// MARK: - Schedule Editor Sheet

struct ScheduleEditorSheet: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    let schedule: DailySchedule
    @State private var blocks: [TimeBlock] = []
    @State private var showingAddBlock = false

    var body: some View {
        NavigationStack {
            ZStack {
                PixelTheme.background.ignoresSafeArea()

                if blocks.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "calendar.badge.plus")
                            .font(.system(size: 40))
                            .foregroundColor(PixelTheme.pending)
                        Text("No blocks yet")
                            .font(PixelTheme.bodyFont)
                            .foregroundColor(PixelTheme.text.opacity(0.5))
                        Text("Tap + to add a time block")
                            .font(PixelTheme.captionFont)
                            .foregroundColor(PixelTheme.text.opacity(0.3))
                    }
                } else {
                    List {
                        ForEach(blocks) { block in
                            HStack(spacing: 12) {
                                Image(systemName: block.blockCategory.icon)
                                    .font(.title3)
                                    .foregroundColor(block.blockCategory.color)
                                    .frame(width: 32)

                                VStack(alignment: .leading, spacing: 2) {
                                    Text(block.label)
                                        .font(PixelTheme.bodyFont)
                                        .foregroundColor(PixelTheme.text)
                                    Text("\(block.startTimeString) · \(block.durationMinutes)min")
                                        .font(PixelTheme.captionFont)
                                        .foregroundColor(PixelTheme.text.opacity(0.5))
                                }

                                Spacer()

                                Text(block.blockCategory.displayName)
                                    .font(.system(size: 10, weight: .medium, design: .rounded))
                                    .foregroundColor(block.blockCategory.color)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(block.blockCategory.color.opacity(0.12))
                                    .cornerRadius(8)
                            }
                            .listRowBackground(PixelTheme.cardBackground)
                        }
                        .onDelete { offsets in deleteBlocks(at: offsets) }
                    }
                    .listStyle(.plain)
                    .scrollContentBackground(.hidden)
                }
            }
            .navigationTitle("Edit \(schedule.name) Schedule")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Done") { dismiss() } }
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        HapticService.light()
                        showingAddBlock = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddBlock) {
                AddBlockSheet(schedule: schedule) { refreshBlocks() }
                    .presentationDetents([.medium])
            }
            .onAppear { refreshBlocks() }
        }
    }

    private func refreshBlocks() { blocks = schedule.sortedBlocks }

    private func deleteBlocks(at offsets: IndexSet) {
        for index in offsets {
            let block = blocks[index]
            schedule.blocks.removeAll { $0.id == block.id }
            modelContext.delete(block)
        }
        try? modelContext.save()
        HapticService.medium()
        refreshBlocks()
    }
}

// MARK: - Add Block Sheet

struct AddBlockSheet: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    let schedule: DailySchedule
    let onAdded: () -> Void

    @State private var selectedCategory: BlockCategory = .routine
    @State private var label: String = ""
    @State private var startHour: Int = 8
    @State private var startMinute: Int = 0
    @State private var duration: Int = 60

    var body: some View {
        NavigationStack {
            ZStack {
                PixelTheme.background.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 20) {
                        // Category picker
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Category")
                                .font(PixelTheme.captionFont)
                                .foregroundColor(PixelTheme.text.opacity(0.6))

                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 8) {
                                    ForEach(BlockCategory.allCases) { category in
                                        Button {
                                            HapticService.selection()
                                            selectedCategory = category
                                            if label.isEmpty || BlockCategory.allCases.map(\.displayName).contains(label) {
                                                label = category.displayName
                                            }
                                        } label: {
                                            HStack(spacing: 4) {
                                                Image(systemName: category.icon).font(.caption)
                                                Text(category.displayName).font(PixelTheme.captionFont)
                                            }
                                            .padding(.horizontal, 10)
                                            .padding(.vertical, 8)
                                            .background(selectedCategory == category ? category.color.opacity(0.25) : PixelTheme.cardBackground)
                                            .foregroundColor(selectedCategory == category ? PixelTheme.text : PixelTheme.text.opacity(0.6))
                                            .cornerRadius(10)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 10)
                                                    .stroke(selectedCategory == category ? category.color : Color.clear, lineWidth: 1.5)
                                            )
                                        }
                                        .buttonStyle(.plain)
                                    }
                                }
                            }
                        }

                        VStack(alignment: .leading, spacing: 8) {
                            Text("Label").font(PixelTheme.captionFont).foregroundColor(PixelTheme.text.opacity(0.6))
                            TextField("Block name", text: $label)
                                .font(PixelTheme.bodyFont)
                                .padding(12)
                                .background(PixelTheme.cardBackground)
                                .cornerRadius(10)
                        }

                        VStack(alignment: .leading, spacing: 8) {
                            Text("Start Time").font(PixelTheme.captionFont).foregroundColor(PixelTheme.text.opacity(0.6))
                            HStack(spacing: 4) {
                                Picker("Hour", selection: $startHour) {
                                    ForEach(0..<24, id: \.self) { h in Text(formatHour(h)).tag(h) }
                                }.pickerStyle(.wheel).frame(width: 100, height: 100)
                                Text(":").font(.title2).foregroundColor(PixelTheme.text)
                                Picker("Minute", selection: $startMinute) {
                                    Text("00").tag(0); Text("15").tag(15); Text("30").tag(30); Text("45").tag(45)
                                }.pickerStyle(.wheel).frame(width: 80, height: 100)
                            }.frame(maxWidth: .infinity)
                        }

                        VStack(alignment: .leading, spacing: 8) {
                            Text("Duration").font(PixelTheme.captionFont).foregroundColor(PixelTheme.text.opacity(0.6))
                            HStack(spacing: 12) {
                                durationButton(30); durationButton(60); durationButton(90)
                            }
                        }
                    }
                    .padding(20)
                }
            }
            .navigationTitle("Add Block")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        addBlock()
                        HapticService.success()
                        dismiss()
                    }
                    .disabled(label.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
    }

    private func durationButton(_ mins: Int) -> some View {
        Button {
            HapticService.selection()
            duration = mins
        } label: {
            Text("\(mins) min")
                .font(PixelTheme.captionFont)
                .foregroundColor(duration == mins ? .white : PixelTheme.text)
                .padding(.horizontal, 16).padding(.vertical, 10)
                .frame(maxWidth: .infinity)
                .background(duration == mins ? PixelTheme.primary : PixelTheme.cardBackground)
                .cornerRadius(10)
        }.buttonStyle(.plain)
    }

    private func formatHour(_ h: Int) -> String {
        let hour = h % 12 == 0 ? 12 : h % 12
        return "\(hour) \(h < 12 ? "AM" : "PM")"
    }

    private func addBlock() {
        let trimmed = label.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }
        let block = TimeBlock(
            category: selectedCategory,
            label: trimmed,
            startHour: startHour,
            startMinute: startMinute,
            durationMinutes: duration,
            sortOrder: schedule.blocks.count
        )
        schedule.blocks.append(block)
        try? modelContext.save()
        onAdded()
    }
}

// MARK: - Weekend Schedule Setup Sheet (v2)

struct WeekendScheduleSetupSheet: View {
    @Environment(\.dismiss) private var dismiss
    let onCreated: (DailySchedule) -> Void

    var body: some View {
        NavigationStack {
            ZStack {
                PixelTheme.background.ignoresSafeArea()

                VStack(spacing: 20) {
                    Image(systemName: "sun.max.fill")
                        .font(.system(size: 50))
                        .foregroundColor(PixelTheme.accent)

                    Text("Create Weekend Schedule")
                        .font(PixelTheme.headlineFont)
                        .foregroundColor(PixelTheme.text)

                    Text("Your weekend can have a different routine than weekdays. Create a relaxed schedule for Saturdays and Sundays.")
                        .font(PixelTheme.captionFont)
                        .foregroundColor(PixelTheme.text.opacity(0.6))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)

                    Spacer()

                    Button {
                        let schedule = DailySchedule(isWeekday: false, name: "Weekend")
                        onCreated(schedule)
                        HapticService.success()
                        dismiss()
                    } label: {
                        Text("Create Weekend Schedule")
                            .font(PixelTheme.bodyFont)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(14)
                            .background(PixelTheme.primary)
                            .cornerRadius(14)
                    }
                    .padding(.horizontal, 30)
                    .padding(.bottom, 20)
                }
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
            }
        }
    }
}

// MARK: - Status Picker Sheet (v2: Sick Day / Manual Status)

struct StatusPickerSheet: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    let player: Player?

    var body: some View {
        NavigationStack {
            ZStack {
                PixelTheme.background.ignoresSafeArea()

                VStack(spacing: 16) {
                    Text("How are you today?")
                        .font(PixelTheme.headlineFont)
                        .foregroundColor(PixelTheme.text)
                        .padding(.top, 20)

                    // Normal (clear status)
                    statusOption(emoji: "😊", title: "Normal", subtitle: "Avatar follows schedule mood", isSelected: player?.manualStatus == nil) {
                        player?.manualStatus = nil
                        player?.manualStatusExpiresAt = nil
                        try? modelContext.save()
                        HapticService.selection()
                        dismiss()
                    }

                    // Manual statuses
                    ForEach(ManualStatus.allCases) { status in
                        statusOption(emoji: status.emoji, title: status.displayName, subtitle: status.avatarDescription, isSelected: player?.manualStatus == status) {
                            player?.manualStatus = status
                            // Auto-expire at end of day
                            player?.manualStatusExpiresAt = Calendar.current.startOfDay(
                                for: Calendar.current.date(byAdding: .day, value: 1, to: .now) ?? .now
                            )
                            try? modelContext.save()
                            HapticService.success()
                            dismiss()
                        }
                    }

                    Spacer()
                }
                .padding(.horizontal, 16)
            }
            .navigationTitle("Set Status")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
            }
        }
    }

    private func statusOption(emoji: String, title: String, subtitle: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 14) {
                Text(emoji)
                    .font(.title2)
                    .frame(width: 44)

                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(PixelTheme.bodyFont)
                        .foregroundColor(PixelTheme.text)
                    Text(subtitle)
                        .font(PixelTheme.captionFont)
                        .foregroundColor(PixelTheme.text.opacity(0.5))
                }

                Spacer()

                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(PixelTheme.primary)
                }
            }
            .padding(14)
            .background(isSelected ? PixelTheme.primary.opacity(0.08) : PixelTheme.cardBackground)
            .cornerRadius(14)
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(isSelected ? PixelTheme.primary : Color.clear, lineWidth: 1.5)
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Calendar Sync Sheet (v2)

struct CalendarSyncSheet: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query private var schedules: [DailySchedule]

    @State private var calendarService = CalendarSyncService()
    @State private var events: [CalendarEvent] = []
    @State private var selectedEventIDs: Set<String> = []
    @State private var authStatus: String = "Checking..."

    private var weekdaySchedule: DailySchedule? { schedules.first { $0.isWeekday } ?? schedules.first }

    var body: some View {
        NavigationStack {
            ZStack {
                PixelTheme.background.ignoresSafeArea()

                VStack(spacing: 16) {
                    if events.isEmpty {
                        VStack(spacing: 16) {
                            Image(systemName: "calendar")
                                .font(.system(size: 50))
                                .foregroundColor(PixelTheme.pending)

                            Text(authStatus)
                                .font(PixelTheme.bodyFont)
                                .foregroundColor(PixelTheme.text.opacity(0.6))

                            Button("Grant Calendar Access") {
                                Task {
                                    let granted = await calendarService.requestAccess()
                                    if granted {
                                        events = calendarService.fetchTodayEvents()
                                        authStatus = events.isEmpty ? "No events today" : ""
                                    } else {
                                        authStatus = "Calendar access denied. Enable in Settings."
                                    }
                                }
                            }
                            .font(PixelTheme.bodyFont)
                            .foregroundColor(.white)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 12)
                            .background(PixelTheme.primary)
                            .cornerRadius(12)
                        }
                        .padding(.top, 60)
                    } else {
                        Text("Select events to import as blocks:")
                            .font(PixelTheme.captionFont)
                            .foregroundColor(PixelTheme.text.opacity(0.6))
                            .padding(.top, 12)

                        List {
                            ForEach(events) { event in
                                HStack(spacing: 12) {
                                    Image(systemName: selectedEventIDs.contains(event.id) ? "checkmark.circle.fill" : "circle")
                                        .foregroundColor(selectedEventIDs.contains(event.id) ? PixelTheme.primary : PixelTheme.pending)

                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(event.title)
                                            .font(PixelTheme.bodyFont)
                                            .foregroundColor(PixelTheme.text)
                                        Text("\(event.startTimeString) · \(event.durationMinutes)min")
                                            .font(PixelTheme.captionFont)
                                            .foregroundColor(PixelTheme.text.opacity(0.5))
                                    }
                                }
                                .listRowBackground(PixelTheme.cardBackground)
                                .onTapGesture {
                                    if selectedEventIDs.contains(event.id) {
                                        selectedEventIDs.remove(event.id)
                                    } else {
                                        selectedEventIDs.insert(event.id)
                                    }
                                }
                            }
                        }
                        .listStyle(.plain)
                        .scrollContentBackground(.hidden)
                    }

                    Spacer()
                }
            }
            .navigationTitle("Calendar Sync")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    if !selectedEventIDs.isEmpty {
                        Button("Import \(selectedEventIDs.count)") {
                            importSelectedEvents()
                            HapticService.success()
                            dismiss()
                        }
                    }
                }
            }
            .onAppear {
                let status = calendarService.checkAuthorizationStatus()
                switch status {
                case .fullAccess:
                    events = calendarService.fetchTodayEvents()
                    authStatus = events.isEmpty ? "No events today" : ""
                case .notDetermined:
                    authStatus = "Tap below to grant calendar access"
                default:
                    authStatus = "Calendar access not available"
                }
            }
        }
    }

    private func importSelectedEvents() {
        guard let schedule = weekdaySchedule else { return }

        for event in events where selectedEventIDs.contains(event.id) {
            let blocks = calendarService.calendarEventsAsBlocks()
            if let match = blocks.first(where: { $0.startHour == event.startHour && $0.startMinute == event.startMinute }) {
                let block = TimeBlock(
                    category: match.category,
                    label: match.label,
                    startHour: match.startHour,
                    startMinute: match.startMinute,
                    durationMinutes: match.duration,
                    sortOrder: schedule.blocks.count
                )
                schedule.blocks.append(block)
            }
        }
        try? modelContext.save()
    }
}
