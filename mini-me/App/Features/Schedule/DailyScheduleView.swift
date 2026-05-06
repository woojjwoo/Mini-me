import SwiftUI
import SwiftData

struct DailyScheduleView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var players: [Player]
    @Query private var schedules: [DailySchedule]
    @Query(
        filter: #Predicate<DayLog> { log in true },
        sort: \DayLog.date,
        order: .reverse
    ) private var dayLogs: [DayLog]
    @Query private var pets: [Pet]
    @Query private var rooms: [Room]

    @State private var animatingBlockID: UUID?
    @State private var characterHopScale: CGFloat = 1.0
    @State private var coinFloatVisible = false
    @State private var coinFloatOffset: CGFloat = 0
    @State private var coinFloatOpacity: Double = 0
    @State private var showingScheduleEditor = false

    private var player: Player? { players.first }
    private var pet: Pet? { pets.first }

    private var todaySchedule: DailySchedule? {
        let isWeekday = !Calendar.current.isDateInWeekend(.now)
        return schedules.first { $0.isWeekday == isWeekday } ?? schedules.first
    }

    private var todayLog: DayLog {
        let today = Calendar.current.startOfDay(for: .now)
        if let existing = dayLogs.first(where: {
            Calendar.current.isDate($0.date, inSameDayAs: today)
        }) {
            return existing
        }
        let newLog = DayLog()
        modelContext.insert(newLog)
        try? modelContext.save()
        return newLog
    }

    private var currentMood: PetMood {
        guard let schedule = todaySchedule, schedule.blocks.count > 0 else { return .neutral }
        let pct = Double(todayLog.completedBlockIDs.count) / Double(schedule.blocks.count)
        if pct >= 1.0 { return .happy }
        if pct >= 0.5 { return .neutral }
        return .bored
    }

    private var hasBlocks: Bool {
        (todaySchedule?.blocks.count ?? 0) > 0
    }

    var body: some View {
        NavigationStack {
            ZStack {
                PixelTheme.background.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 12) {
                        // Hero card — always shows
                        heroCard
                            .zIndex(1)

                        if hasBlocks, let schedule = todaySchedule {
                            ForEach(schedule.sortedBlocks) { block in
                                TimeBlockRow(
                                    block: block,
                                    isCompleted: todayLog.isBlockCompleted(block.id),
                                    isCurrentBlock: isCurrentBlock(block),
                                    isAnimating: animatingBlockID == block.id,
                                    onComplete: { completeBlock(block) }
                                )
                            }
                        } else {
                            emptyStateView
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 16)
                    .padding(.bottom, 24)
                }
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
        }
        .sheet(isPresented: $showingScheduleEditor) {
            if let schedule = todaySchedule {
                NavigationStack {
                    ScheduleEditorSheet(schedule: schedule)
                }
            }
        }
    }

    // MARK: - Hero Card (dark diorama style)

    private var heroCard: some View {
        ZStack(alignment: .bottomLeading) {
            // Dark ambient background — matches bedroom widget aesthetic
            RoundedRectangle(cornerRadius: 24)
                .fill(
                    LinearGradient(
                        colors: [Color(hex: "1A1030"), Color(hex: "2D1A50")],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(Color.white.opacity(0.08), lineWidth: 1)
                )

            // Pixel decoration (same as widget mockup)
            heroPixelDecoration

            // Bottom gradient for text legibility
            LinearGradient(
                colors: [.clear, .black.opacity(0.55)],
                startPoint: UnitPoint(x: 0.5, y: 0.0),
                endPoint: .bottom
            )
            .clipShape(RoundedRectangle(cornerRadius: 24))

            // Character sprite — right side, bottom-anchored, overflows slightly
            ZStack(alignment: .bottom) {
                let spriteName = pet?.spriteName(for: currentMood) ?? "minime_idle"
                if UIImage(named: spriteName) != nil {
                    Image(spriteName)
                        .resizable()
                        .interpolation(.none)
                        .scaledToFit()
                        .frame(width: 80, height: 134)
                } else {
                    Text("🧑")
                        .font(.system(size: 72))
                        .frame(width: 80, height: 134, alignment: .bottom)
                }
            }
            .scaleEffect(characterHopScale, anchor: .bottom)
            .frame(maxWidth: .infinity, alignment: .trailing)
            .offset(x: -20, y: 10)

            // Coin float overlay
            if coinFloatVisible {
                Text("+\(CoinService.coinsPerBlock) 🪙")
                    .font(PixelTheme.coinFont)
                    .foregroundColor(PixelTheme.coin)
                    .offset(x: UIScreen.main.bounds.width - 100, y: coinFloatOffset)
                    .opacity(coinFloatOpacity)
            }

            // Text content — left side
            VStack(alignment: .leading, spacing: 0) {
                // Coin pill
                HStack(spacing: 5) {
                    Image(systemName: "circle.fill")
                        .font(.system(size: 7))
                        .foregroundColor(PixelTheme.coin)
                    Text("\(player?.coins ?? 0)")
                        .font(PixelTheme.coinFont)
                        .foregroundColor(.white)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(PixelTheme.coin.opacity(0.18))
                .cornerRadius(12)

                Spacer().frame(height: 12)

                // Pet name
                Text(pet?.name ?? "Pixel")
                    .font(.system(size: 26, weight: .bold, design: .rounded))
                    .foregroundColor(.white)

                Spacer().frame(height: 5)

                // Mood + streak
                HStack(spacing: 6) {
                    Text(currentMood.displayEmoji)
                        .font(.system(size: 13))
                    Text(moodLabel)
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .foregroundColor(.white.opacity(0.7))

                    if let streak = player?.currentStreak, streak > 0 {
                        Text("·").font(.system(size: 12)).foregroundColor(.white.opacity(0.3))
                        Text("\(streak)🔥")
                            .font(.system(size: 12, weight: .semibold, design: .rounded))
                            .foregroundColor(PixelTheme.coin)
                    }
                }

                Spacer().frame(height: 4)

                // Date
                Text(dateString)
                    .font(.system(size: 11, weight: .medium, design: .rounded))
                    .foregroundColor(.white.opacity(0.4))

                Spacer().frame(height: 16)

                // Progress bar — only when blocks exist
                if let schedule = todaySchedule, schedule.blocks.count > 0 {
                    let total = schedule.blocks.count
                    let completed = todayLog.completedBlockIDs.count

                    VStack(alignment: .leading, spacing: 5) {
                        HStack(spacing: 3) {
                            ForEach(0..<total, id: \.self) { index in
                                let isFilled = index < completed
                                let isLastFilled = index == completed - 1
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(isFilled ? PixelTheme.primary : Color.white.opacity(0.15))
                                    .frame(height: 10)
                                    .shadow(
                                        color: isLastFilled ? PixelTheme.primary.opacity(0.8) : .clear,
                                        radius: isLastFilled ? 4 : 0
                                    )
                                    .animation(.spring(response: 0.4), value: completed)
                            }
                        }

                        HStack {
                            Text("\(completed)/\(total) done")
                                .font(.system(size: 11, weight: .medium, design: .rounded))
                                .foregroundColor(.white.opacity(0.5))
                            Spacer()
                            if total > 0 && completed > 0 {
                                Text("\(Int(Double(completed) / Double(total) * 100))%")
                                    .font(.system(size: 11, weight: .semibold, design: .monospaced))
                                    .foregroundColor(PixelTheme.primary)
                            }
                        }
                    }
                } else {
                    // No blocks yet — subtle hint
                    Text("No blocks yet · tap below to add")
                        .font(.system(size: 11, weight: .medium, design: .rounded))
                        .foregroundColor(.white.opacity(0.4))
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 20)
            .padding(.top, 20)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(height: 220)
        .shadow(color: Color(hex: "1A1030").opacity(0.5), radius: 20, x: 0, y: 8)
        .padding(.bottom, 4)
    }

    // Pixel decoration canvas — same warm scatter as widget mockup
    private var heroPixelDecoration: some View {
        Canvas { context, size in
            let pixel: CGFloat = 3
            let palette: [Color] = [
                Color(hex: "5B3A8A"), Color(hex: "7B5CAA"), Color(hex: "8B6CBB"),
                Color(hex: "4A6741"), Color(hex: "5B8C5A"), Color(hex: "E8985E"),
                Color(hex: "F5C484"), Color(hex: "3D2860")
            ]
            let positions: [(CGFloat, CGFloat, Int)] = [
                (0.08, 0.55, 2), (0.11, 0.57, 1), (0.14, 0.52, 2),
                (0.22, 0.48, 0), (0.25, 0.50, 3), (0.19, 0.53, 4),
                (0.35, 0.42, 5), (0.38, 0.44, 6), (0.32, 0.46, 5),
                (0.42, 0.40, 4), (0.55, 0.52, 2), (0.58, 0.50, 1),
                (0.62, 0.56, 3), (0.68, 0.48, 0), (0.75, 0.53, 7),
                (0.30, 0.62, 6), (0.36, 0.65, 5), (0.48, 0.60, 2),
                (0.52, 0.58, 1), (0.26, 0.58, 3),
                (0.72, 0.35, 1), (0.78, 0.30, 2), (0.82, 0.38, 5),
                (0.88, 0.28, 6), (0.92, 0.42, 3)
            ]
            for (rx, ry, ci) in positions {
                let rect = CGRect(
                    x: rx * size.width, y: ry * size.height,
                    width: pixel * 2, height: pixel * 2
                )
                context.fill(Path(rect), with: .color(palette[ci % palette.count].opacity(0.5)))
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 24))
    }

    // MARK: - Empty State

    private var emptyStateView: some View {
        VStack(spacing: 16) {
            // Diorama-style card
            ZStack {
                RoundedRectangle(cornerRadius: 20)
                    .fill(
                        LinearGradient(
                            colors: [Color(hex: "1E1438"), Color(hex: "261B48")],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.white.opacity(0.06), lineWidth: 1)
                    )

                VStack(spacing: 18) {
                    Spacer().frame(height: 4)

                    // Character
                    ZStack {
                        Circle()
                            .fill(PixelTheme.primary.opacity(0.12))
                            .frame(width: 100, height: 100)

                        let spriteName = pet?.spriteName(for: .neutral) ?? "minime_idle"
                        if UIImage(named: spriteName) != nil {
                            Image(spriteName)
                                .resizable()
                                .interpolation(.none)
                                .scaledToFit()
                                .frame(height: 90)
                        } else {
                            Text("🧑")
                                .font(.system(size: 60))
                        }
                    }

                    // Copy
                    VStack(spacing: 8) {
                        Text("Your mini-me is ready")
                            .font(.system(size: 20, weight: .bold, design: .rounded))
                            .foregroundColor(.white)

                        Text("Build your daily schedule — your mini-me will mirror what you do, live on your home screen.")
                            .font(.system(size: 14, weight: .medium, design: .rounded))
                            .foregroundColor(.white.opacity(0.55))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 8)
                    }

                    Spacer().frame(height: 4)
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 28)
            }
            .shadow(color: Color(hex: "1A1030").opacity(0.4), radius: 16, x: 0, y: 6)

            // CTA button
            Button(action: { showingScheduleEditor = true }) {
                HStack(spacing: 8) {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 17))
                    Text("Build Your Schedule")
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    LinearGradient(
                        colors: [PixelTheme.primary, PixelTheme.primary.opacity(0.85)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .cornerRadius(16)
                .shadow(color: PixelTheme.primary.opacity(0.35), radius: 8, x: 0, y: 4)
            }

            // Widget reminder pill
            HStack(spacing: 6) {
                Image(systemName: "rectangle.on.rectangle")
                    .font(.system(size: 11))
                    .foregroundColor(PixelTheme.primary.opacity(0.7))
                Text("Add the widget to see it live on your home screen")
                    .font(.system(size: 11, weight: .medium, design: .rounded))
                    .foregroundColor(PixelTheme.text.opacity(0.45))
            }
            .padding(.top, 4)
        }
        .padding(.top, 8)
    }

    // MARK: - Actions

    private func completeBlock(_ block: TimeBlock) {
        guard let player = player, let schedule = todaySchedule else { return }

        let coinService = CoinService(modelContext: modelContext)
        let _ = coinService.completeBlock(
            blockID: block.id,
            player: player,
            dayLog: todayLog,
            schedule: schedule
        )

        HapticService.success()
        SoundService.playCompleteSound()

        let milestoneService = MilestoneService(modelContext: modelContext)
        let unlocked = milestoneService.checkMilestones(player: player, dayLogs: Array(dayLogs))
        if !unlocked.isEmpty { HapticService.celebration() }

        if todayLog.completedBlockIDs.count == schedule.blocks.count {
            HapticService.heavy()
            SoundService.playCelebrationSound()
        }

        animatingBlockID = block.id
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) { animatingBlockID = nil }

        // Character hop
        withAnimation(.spring(response: 0.15, dampingFraction: 0.4)) { characterHopScale = 1.12 }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            withAnimation(.spring(response: 0.2)) { characterHopScale = 1.0 }
        }

        // Coin float
        coinFloatOffset = 0
        coinFloatOpacity = 1.0
        coinFloatVisible = true
        withAnimation(.easeOut(duration: 0.65)) {
            coinFloatOffset = -48
            coinFloatOpacity = 0
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.75) { coinFloatVisible = false }

        updateWidget()
        syncLiveActivity()
        NotificationCenter.default.post(name: NSNotification.Name("ShowCoinShower"), object: nil)
        if todayLog.completedBlockIDs.count == schedule.blocks.count {
            NotificationCenter.default.post(name: NSNotification.Name("ShowCelebration"), object: nil)
        }

        try? modelContext.save()
    }

    private func isCurrentBlock(_ block: TimeBlock) -> Bool {
        let now = Date.now
        let hour = Calendar.current.component(.hour, from: now)
        let minute = Calendar.current.component(.minute, from: now)
        let currentMinutes = hour * 60 + minute
        let blockStart = block.startHour * 60 + block.startMinute
        let blockEnd = blockStart + block.durationMinutes
        return currentMinutes >= blockStart && currentMinutes < blockEnd
    }

    private func updateWidget() {
        #if canImport(WidgetKit)
        guard let pet = pet, let schedule = todaySchedule else { return }
        let now = Date.now
        let hour = Calendar.current.component(.hour, from: now)
        let minute = Calendar.current.component(.minute, from: now)
        let currentMinutes = hour * 60 + minute
        let currentBlock = schedule.blocks.first { block in
            let blockStart = block.startHour * 60 + block.startMinute
            let blockEnd = blockStart + block.durationMinutes
            return currentMinutes >= blockStart && currentMinutes < blockEnd
        }
        let moodService = PetMoodService()
        let mood = moodService.currentMood(
            completedBlocks: todayLog.completedBlockIDs.count,
            totalBlocks: schedule.blocks.count,
            wakeUpHour: schedule.sortedBlocks.first?.startHour ?? 7,
            lastCompletionDate: .now,
            manualStatus: player?.manualStatus,
            currentActivity: currentBlock?.category
        )
        WidgetDataService.shared.updateWidgetData(
            pet: pet,
            mood: mood,
            completedBlocks: todayLog.completedBlockIDs.count,
            totalBlocks: schedule.blocks.count,
            coinsToday: todayLog.totalCoins,
            nextBlockLabel: "",
            currentTaskName: currentBlock?.label,
            currentCategory: currentBlock?.category,
            scheduleBlocks: schedule.sortedBlocks.map { TimeBlockDTO(from: $0) }
        )

        if let activeRoom = rooms.first(where: { $0.isActive }) ?? rooms.first {
            WidgetDataService.shared.triggerBakeIfScheduleChanged(
                schedule: schedule,
                pet: pet,
                room: activeRoom
            )
        }
        #endif
    }

    private func syncLiveActivity() {
        guard let pet = pet, let schedule = todaySchedule else { return }
        LiveActivityService.shared.sync(
            petName:         pet.name,
            schedule:        schedule,
            completedBlocks: todayLog.completedBlockIDs.count,
            totalBlocks:     schedule.blocks.count
        )
    }

    private var moodLabel: String {
        switch currentMood {
        case .happy: "Crushing it!"
        case .bored: "Needs motivation"
        default: "Doing well"
        }
    }

    private var dateString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE, MMM d"
        return formatter.string(from: .now)
    }
}
