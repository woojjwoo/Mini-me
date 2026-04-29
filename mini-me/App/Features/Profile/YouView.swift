import SwiftUI
import SwiftData

struct YouView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \DayLog.date, order: .reverse) private var dayLogs: [DayLog]
    @Query private var schedules: [DailySchedule]
    @Query private var players: [Player]
    @Query private var pets: [Pet]
    @Query private var rooms: [Room]

    @State private var showingPetEditor = false
    @State private var showingOutfitView = false
    @State private var showingScheduleEditor = false
    @State private var showingWeekendScheduleEditor = false
    @State private var showingStatusPicker = false
    @State private var showingCalendarSync = false
    @State private var showingResetAlert = false
    @State private var notificationsEnabled = false

    private var player: Player? { players.first }
    private var pet: Pet? { pets.first }
    private var weekdaySchedule: DailySchedule? { schedules.first { $0.isWeekday } ?? schedules.first }
    private var weekendSchedule: DailySchedule? { schedules.first { !$0.isWeekday } }
    private var allBlocks: [TimeBlock] { schedules.flatMap { $0.blocks } }

    private var currentMood: PetMood {
        guard let schedule = weekdaySchedule else { return .neutral }
        let today = Calendar.current.startOfDay(for: .now)
        let todayLog = dayLogs.first { Calendar.current.isDate($0.date, inSameDayAs: today) }
        let completed = todayLog?.completedBlockIDs.count ?? 0
        let total = schedule.blocks.count
        if total == 0 { return .neutral }
        let pct = Double(completed) / Double(total)
        if pct >= 1.0 { return .happy }
        if pct >= 0.5 { return .neutral }
        return .bored
    }

    var body: some View {
        NavigationStack {
            ZStack {
                PixelTheme.background.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 20) {
                        characterHero
                        statsSection
                        settingsSection
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 32)
                }
            }
            .navigationTitle("You")
            .navigationBarTitleDisplayMode(.inline)
        }
        .sheet(isPresented: $showingPetEditor) {
            if let pet = pet { PetEditorSheet(pet: pet).presentationDetents([.medium]) }
        }
        .sheet(isPresented: $showingOutfitView) { OutfitView() }
        .sheet(isPresented: $showingScheduleEditor) {
            if let schedule = weekdaySchedule {
                ScheduleEditorSheet(schedule: schedule).presentationDetents([.large])
            }
        }
        .sheet(isPresented: $showingWeekendScheduleEditor) {
            if let schedule = weekendSchedule {
                ScheduleEditorSheet(schedule: schedule).presentationDetents([.large])
            } else {
                WeekendScheduleSetupSheet { newSchedule in
                    modelContext.insert(newSchedule)
                    try? modelContext.save()
                }.presentationDetents([.medium])
            }
        }
        .sheet(isPresented: $showingStatusPicker) {
            StatusPickerSheet(player: player).presentationDetents([.medium])
        }
        .sheet(isPresented: $showingCalendarSync) {
            CalendarSyncSheet().presentationDetents([.large])
        }
        .alert("Reset All Data?", isPresented: $showingResetAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Reset", role: .destructive) { resetAllData() }
        } message: {
            Text("This will delete your Mini Me, schedule, coins, and all progress. This cannot be undone.")
        }
    }

    // MARK: - Character Hero

    private var characterHero: some View {
        VStack(spacing: 16) {
            // Sprite — 96×160pt
            let spriteName = pet?.spriteName(for: currentMood) ?? "minime_idle"
            if UIImage(named: spriteName) != nil {
                Image(spriteName)
                    .resizable()
                    .interpolation(.none)
                    .scaledToFit()
                    .frame(width: 96, height: 160)
            } else {
                Text("🧑")
                    .font(.system(size: 80))
                    .frame(width: 96, height: 160, alignment: .bottom)
            }

            // Pet name — large
            Text(pet?.name ?? "Pixel")
                .font(PixelTheme.titleFont)
                .foregroundColor(PixelTheme.text)

            // Mood + streak — single pill
            HStack(spacing: 8) {
                Text(currentMood.displayEmoji)
                Text(moodLabel)
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .foregroundColor(PixelTheme.text.opacity(0.7))

                if let streak = player?.currentStreak, streak > 0 {
                    Text("·").foregroundColor(PixelTheme.text.opacity(0.3))
                        .font(.system(size: 13))
                    Text("\(streak)🔥")
                        .font(.system(size: 13, weight: .semibold, design: .rounded))
                        .foregroundColor(PixelTheme.primary)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(PixelTheme.primary.opacity(0.10))
            .cornerRadius(20)

            // Action pills
            HStack(spacing: 12) {
                pillButton("Edit Mini Me", icon: "pencil") {
                    HapticService.light()
                    showingPetEditor = true
                }
                pillButton("Outfits", icon: "tshirt.fill") {
                    HapticService.light()
                    showingOutfitView = true
                }
            }
        }
        .padding(.vertical, 24)
        .padding(.horizontal, 20)
        .frame(maxWidth: .infinity)
        .background(
            LinearGradient(
                colors: [PixelTheme.cardBackground, PixelTheme.primary.opacity(0.08)],
                startPoint: .top,
                endPoint: .bottom
            )
        )
        .cornerRadius(20)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(PixelTheme.cardBorder, lineWidth: 1)
        )
        .shadow(color: PixelTheme.shadowColor, radius: 8, y: 3)
        .padding(.top, 8)
    }

    private var moodLabel: String {
        switch currentMood {
        case .happy: "Crushing it!"
        case .bored: "Needs motivation"
        case .sleeping: "Rest mode"
        case .focused: "In focus mode"
        case .eating: "Eating"
        default: "Doing well"
        }
    }

    private func pillButton(_ label: String, icon: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 12, weight: .medium))
                Text(label)
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
            }
            .foregroundColor(PixelTheme.primary)
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(PixelTheme.primary.opacity(0.12))
            .cornerRadius(20)
            .shadow(color: PixelTheme.primary.opacity(0.2), radius: 6, y: 3)
        }
    }

    // MARK: - Stats Section

    private var statsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader("Your Stats")
            completionTrendCard
            streakCard
            funStatsCard
        }
    }

    private var completionTrendCard: some View {
        let last14Days = (0..<14).compactMap {
            Calendar.current.date(byAdding: .day, value: -$0, to: .now)
        }.reversed()

        return VStack(alignment: .leading, spacing: 12) {
            Text("2-Week Trend")
                .font(PixelTheme.headlineFont)
                .foregroundColor(PixelTheme.text)

            HStack(alignment: .bottom, spacing: 4) {
                ForEach(Array(last14Days.enumerated()), id: \.offset) { _, date in
                    let rate = completionRate(for: date)
                    VStack(spacing: 2) {
                        RoundedRectangle(cornerRadius: 3)
                            .fill(barColor(rate))
                            .frame(width: 16, height: max(4, CGFloat(rate * 80)))
                        if Calendar.current.isDateInToday(date) {
                            Circle().fill(PixelTheme.primary).frame(width: 4, height: 4)
                        } else {
                            Spacer().frame(height: 4)
                        }
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .frame(height: 90)

            HStack(spacing: 12) {
                legendDot(color: PixelTheme.completed, label: "> 70%")
                legendDot(color: PixelTheme.primary, label: "30–70%")
                legendDot(color: PixelTheme.pending.opacity(0.5), label: "< 30%")
            }
            .font(.system(size: 10))
        }
        .card()
    }

    private var streakCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Streaks")
                .font(PixelTheme.headlineFont)
                .foregroundColor(PixelTheme.text)

            HStack(spacing: 0) {
                streakStat(value: player?.currentStreak ?? 0, label: "Current", color: PixelTheme.primary)
                Divider().frame(height: 40)
                streakStat(value: player?.longestStreak ?? 0, label: "Longest", color: PixelTheme.accent)
                Divider().frame(height: 40)
                streakStat(value: player?.totalDaysCompleted ?? 0, label: "Total Days", color: PixelTheme.coin)
            }

            if let streak = player?.currentStreak, streak > 0 {
                let next = nextStreakMilestone(streak)
                HStack(spacing: 6) {
                    Image(systemName: "flame.fill").foregroundColor(PixelTheme.primary)
                    Text("\(next - streak) days to \(next)-day streak bonus!")
                        .font(PixelTheme.captionFont)
                        .foregroundColor(PixelTheme.text.opacity(0.7))
                }
                .padding(10)
                .background(PixelTheme.primary.opacity(0.1))
                .cornerRadius(10)
            }
        }
        .card()
    }

    private func streakStat(value: Int, label: String, color: Color) -> some View {
        VStack(spacing: 4) {
            Text("\(value)")
                .font(.system(size: 32, weight: .bold, design: .rounded))
                .foregroundColor(color)
            Text(label)
                .font(PixelTheme.captionFont)
                .foregroundColor(PixelTheme.text.opacity(0.5))
        }
        .frame(maxWidth: .infinity)
    }

    private var funStatsCard: some View {
        let totalBlocks = dayLogs.reduce(0) { $0 + $1.completedBlockIDs.count }
        let totalCoins = dayLogs.reduce(0) { $0 + $1.totalCoins }
        let activeDays = dayLogs.filter { !$0.completedBlockIDs.isEmpty }.count
        let perfectDays = dayLogs.filter { log in
            guard let schedule = schedules.first else { return false }
            return log.completedBlockIDs.count >= schedule.blocks.count && schedule.blocks.count > 0
        }.count

        return VStack(alignment: .leading, spacing: 12) {
            Text("All Time")
                .font(PixelTheme.headlineFont)
                .foregroundColor(PixelTheme.text)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                funStatItem(value: "\(totalBlocks)", label: "Blocks Done", icon: "checkmark.circle.fill", color: PixelTheme.completed)
                funStatItem(value: "\(totalCoins)", label: "Coins Earned", icon: "circle.fill", color: PixelTheme.coin)
                funStatItem(value: "\(activeDays)", label: "Active Days", icon: "calendar", color: PixelTheme.accent)
                funStatItem(value: "\(perfectDays)", label: "Perfect Days", icon: "star.fill", color: PixelTheme.primary)
            }
        }
        .card()
    }

    // MARK: - Settings Section

    private var settingsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader("Settings")

            settingsGroup {
                settingsRow(icon: "calendar.badge.clock", iconColor: PixelTheme.accent, label: "Weekday Schedule",
                            detail: weekdaySchedule.map { "\($0.blocks.count) blocks" }) {
                    HapticService.light(); showingScheduleEditor = true
                }
                Divider().padding(.leading, 58)
                settingsRow(icon: "sun.max.fill", iconColor: PixelTheme.primary, label: "Weekend Schedule",
                            detail: weekendSchedule.map { "\($0.blocks.count) blocks" } ?? "Not set") {
                    HapticService.light(); showingWeekendScheduleEditor = true
                }
                Divider().padding(.leading, 58)
                settingsRow(icon: "face.smiling", iconColor: PixelTheme.accent, label: "Status",
                            detail: player?.manualStatus?.displayName ?? "Normal") {
                    HapticService.light(); showingStatusPicker = true
                }
            }

            settingsGroup {
                notificationRow
                Divider().padding(.leading, 58)
                settingsRow(icon: "calendar", iconColor: PixelTheme.accent, label: "Calendar Sync",
                            detail: "Import events as blocks") {
                    HapticService.light(); showingCalendarSync = true
                }
            }

            if !(player?.isPremium ?? false) {
                settingsGroup {
                    Button {
                        HapticService.medium()
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
                                Text("$1.99/mo — Exclusive items, lock screen widget")
                                    .font(PixelTheme.captionFont)
                                    .foregroundColor(PixelTheme.text.opacity(0.5))
                            }
                            Spacer()
                            Text("$1.99")
                                .font(.system(size: 14, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                                .padding(.horizontal, 12).padding(.vertical, 6)
                                .background(PixelTheme.primary)
                                .cornerRadius(10)
                        }
                        .padding(14)
                    }
                    .buttonStyle(.plain)
                }
            }

            settingsGroup {
                HStack(spacing: 12) {
                    Image(systemName: "info.circle")
                        .font(.title3)
                        .foregroundColor(PixelTheme.accent)
                        .frame(width: 44, height: 44)
                    Text("Version")
                        .font(PixelTheme.bodyFont)
                        .foregroundColor(PixelTheme.text)
                    Spacer()
                    Text("2.5.0")
                        .font(PixelTheme.captionFont)
                        .foregroundColor(PixelTheme.text.opacity(0.4))
                }
                .padding(14)

                Divider().padding(.leading, 58)

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
                    .padding(.horizontal, 14).padding(.vertical, 8)
                }
                .buttonStyle(.plain)
            }
        }
    }

    private var notificationRow: some View {
        HStack(spacing: 12) {
            Image(systemName: "bell.fill")
                .font(.title3)
                .foregroundColor(PixelTheme.accent)
                .frame(width: 44, height: 44)
            VStack(alignment: .leading, spacing: 2) {
                Text("Block Reminders")
                    .font(PixelTheme.bodyFont)
                    .foregroundColor(PixelTheme.text)
                Text("5 min before each block")
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

    // MARK: - Helpers

    private func sectionHeader(_ title: String) -> some View {
        Text(title)
            .font(PixelTheme.headlineFont)
            .foregroundColor(PixelTheme.text)
    }

    private func settingsGroup<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        VStack(spacing: 0) {
            content()
        }
        .background(PixelTheme.cardBackground)
        .cornerRadius(14)
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(PixelTheme.cardBorder, lineWidth: 1))
        .shadow(color: PixelTheme.shadowColor, radius: 4, y: 2)
    }

    private func settingsRow(icon: String, iconColor: Color, label: String, detail: String?, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(iconColor)
                    .frame(width: 44, height: 44)
                VStack(alignment: .leading, spacing: 2) {
                    Text(label)
                        .font(PixelTheme.bodyFont)
                        .foregroundColor(PixelTheme.text)
                    if let detail {
                        Text(detail)
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

    private func legendDot(color: Color, label: String) -> some View {
        HStack(spacing: 4) {
            Circle().fill(color).frame(width: 8, height: 8)
            Text(label).foregroundColor(PixelTheme.text.opacity(0.5))
        }
    }

    private func funStatItem(value: String, label: String, icon: String, color: Color) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon).foregroundColor(color).frame(width: 20)
            VStack(alignment: .leading, spacing: 1) {
                Text(value).font(.system(size: 16, weight: .bold, design: .rounded)).foregroundColor(PixelTheme.text)
                Text(label).font(.system(size: 10)).foregroundColor(PixelTheme.text.opacity(0.5))
            }
            Spacer()
        }
        .padding(10)
        .background(color.opacity(0.08))
        .cornerRadius(10)
    }

    private func completionRate(for date: Date) -> Double {
        guard let log = dayLogs.first(where: { Calendar.current.isDate($0.date, inSameDayAs: date) }) else { return 0 }
        guard let schedule = schedules.first, schedule.blocks.count > 0 else { return 0 }
        return Double(log.completedBlockIDs.count) / Double(schedule.blocks.count)
    }

    private func barColor(_ rate: Double) -> Color {
        if rate >= 0.7 { return PixelTheme.completed }
        if rate >= 0.3 { return PixelTheme.primary }
        return PixelTheme.pending.opacity(0.5)
    }

    private func nextStreakMilestone(_ current: Int) -> Int {
        if current < 3 { return 3 }
        if current < 7 { return 7 }
        if current < 30 { return 30 }
        return ((current / 30) + 1) * 30
    }

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
        } catch {}
    }
}

// MARK: - Card modifier

extension View {
    func card() -> some View {
        self
            .padding(16)
            .background(PixelTheme.cardBackground)
            .cornerRadius(16)
            .overlay(RoundedRectangle(cornerRadius: 16).stroke(PixelTheme.cardBorder, lineWidth: 1))
            .shadow(color: PixelTheme.shadowColor, radius: 4, y: 2)
    }
}
