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

    var body: some View {
        NavigationStack {
            ZStack {
                PixelTheme.background.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 12) {
                        headerCard
                            .zIndex(1)

                        if let schedule = todaySchedule {
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
                            Text("No schedule set up yet")
                                .font(PixelTheme.bodyFont)
                                .foregroundColor(PixelTheme.text.opacity(0.5))
                                .padding(.top, 40)
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
    }

    // MARK: - Header

    private var headerCard: some View {
        ZStack(alignment: .bottom) {
            // Card background — gradient
            RoundedRectangle(cornerRadius: 18)
                .fill(
                    LinearGradient(
                        colors: [PixelTheme.cardBackground, PixelTheme.primary.opacity(0.06)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 18)
                        .stroke(PixelTheme.cardBorder, lineWidth: 1)
                )
                .shadow(color: PixelTheme.shadowColor, radius: 8, y: 3)

            HStack(alignment: .bottom, spacing: 0) {
                // Left: text content
                VStack(alignment: .leading, spacing: 0) {
                    // Coin pill — top
                    HStack(spacing: 4) {
                        Image(systemName: "circle.fill")
                            .font(.system(size: 8))
                            .foregroundColor(PixelTheme.coin)
                        Text("\(player?.coins ?? 0)")
                            .font(PixelTheme.coinFont)
                            .foregroundColor(PixelTheme.text)
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(PixelTheme.coin.opacity(0.15))
                    .cornerRadius(12)

                    Spacer().frame(height: 10)

                    // Pet name
                    Text(pet?.name ?? "Pixel")
                        .font(.system(size: 22, weight: .bold, design: .rounded))
                        .foregroundColor(PixelTheme.text)

                    Spacer().frame(height: 4)

                    // Mood + streak
                    HStack(spacing: 6) {
                        Text(currentMood.displayEmoji)
                            .font(.system(size: 13))
                        Text(moodLabel)
                            .font(.system(size: 12, weight: .medium, design: .rounded))
                            .foregroundColor(PixelTheme.text.opacity(0.6))

                        if let streak = player?.currentStreak, streak > 0 {
                            Text("·").font(.system(size: 12)).foregroundColor(PixelTheme.text.opacity(0.3))
                            Text("\(streak)🔥")
                                .font(.system(size: 12, weight: .semibold, design: .rounded))
                                .foregroundColor(PixelTheme.primary)
                        }
                    }

                    Spacer().frame(height: 4)

                    // Date
                    Text(dateString)
                        .font(.system(size: 11, weight: .medium, design: .rounded))
                        .foregroundColor(PixelTheme.text.opacity(0.35))

                    Spacer().frame(height: 14)

                    // Segmented progress bar — 12pt, with glow on last filled
                    if let schedule = todaySchedule, schedule.blocks.count > 0 {
                        let total = schedule.blocks.count
                        let completed = todayLog.completedBlockIDs.count

                        VStack(spacing: 5) {
                            HStack(spacing: 3) {
                                ForEach(0..<total, id: \.self) { index in
                                    let isFilled = index < completed
                                    let isLastFilled = index == completed - 1
                                    RoundedRectangle(cornerRadius: 4)
                                        .fill(isFilled ? PixelTheme.primary : PixelTheme.pending.opacity(0.2))
                                        .frame(height: 12)
                                        .shadow(
                                            color: isLastFilled ? PixelTheme.primary.opacity(0.5) : .clear,
                                            radius: isLastFilled ? 4 : 0
                                        )
                                        .animation(.spring(response: 0.4), value: completed)
                                }
                            }

                            HStack {
                                Text("\(completed)/\(total) done")
                                    .font(.system(size: 11, weight: .medium, design: .rounded))
                                    .foregroundColor(PixelTheme.text.opacity(0.45))
                                Spacer()
                                if total > 0 && completed > 0 {
                                    Text("\(Int(Double(completed) / Double(total) * 100))%")
                                        .font(.system(size: 11, weight: .semibold, design: .monospaced))
                                        .foregroundColor(PixelTheme.primary)
                                }
                            }
                        }
                    }
                }
                .padding(16)
                .padding(.bottom, 4)

                Spacer()

                // Right: character sprite — anchored to bottom, overflows card
                ZStack(alignment: .bottom) {
                    let spriteName = pet?.spriteName(for: currentMood) ?? "minime_idle"
                    if UIImage(named: spriteName) != nil {
                        Image(spriteName)
                            .resizable()
                            .interpolation(.none)
                            .scaledToFit()
                            .frame(width: 64, height: 107)
                    } else {
                        Text("🧑")
                            .font(.system(size: 64))
                            .frame(width: 64, height: 107, alignment: .bottom)
                    }
                }
                .scaleEffect(characterHopScale, anchor: .bottom)
                .offset(y: 12)
                .padding(.trailing, 16)

                // Coin float overlay (positioned near character)
                if coinFloatVisible {
                    Text("+\(CoinService.coinsPerBlock) 🪙")
                        .font(PixelTheme.coinFont)
                        .foregroundColor(PixelTheme.coin)
                        .offset(y: coinFloatOffset)
                        .opacity(coinFloatOpacity)
                        .padding(.trailing, 8)
                }
            }
            .frame(minHeight: 160)
        }
        .padding(.bottom, 12)
    }

    private var moodLabel: String {
        switch currentMood {
        case .happy: "Crushing it!"
        case .bored: "Needs motivation"
        default: "Doing well"
        }
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

        // Pre-bake all (scene, activity) snapshot variants the widget might
        // need today. Hash-deduped so this is a no-op when the unique pair
        // set hasn't changed since the last bake (i.e. on every block tap
        // inside the same schedule, this short-circuits cheaply).
        if let activeRoom = rooms.first(where: { $0.isActive }) ?? rooms.first {
            WidgetDataService.shared.triggerBakeIfScheduleChanged(
                schedule: schedule,
                pet: pet,
                room: activeRoom
            )
        }
        #endif
    }

    private var dateString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE, MMM d"
        return formatter.string(from: .now)
    }
}
