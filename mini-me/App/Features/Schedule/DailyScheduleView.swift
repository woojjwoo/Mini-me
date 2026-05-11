import SwiftUI
import SwiftData
#if canImport(WidgetKit)
import WidgetKit
#endif

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

    @State private var animatingBlockID: UUID?

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

    var body: some View {
        NavigationStack {
            ZStack {
                PixelTheme.background.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 16) {
                        // Header with pet + progress
                        headerCard

                        // Schedule blocks
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
                    .padding(16)
                }
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    // MARK: - Header

    private var headerCard: some View {
        VStack(spacing: 12) {
            HStack {
                // Pet mood placeholder
                VStack {
                    Text("🧑")
                        .font(.system(size: 40))
                    if let pet = pet {
                        Text(pet.name)
                            .font(PixelTheme.captionFont)
                            .foregroundColor(PixelTheme.text.opacity(0.7))
                    }
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 4) {
                    Text(dateString)
                        .font(PixelTheme.headlineFont)
                        .foregroundColor(PixelTheme.text)

                    // Coins
                    HStack(spacing: 4) {
                        Image(systemName: "circle.fill")
                            .font(.caption)
                            .foregroundColor(PixelTheme.coin)
                        Text("\(player?.coins ?? 0)")
                            .font(PixelTheme.coinFont)
                            .foregroundColor(PixelTheme.text)
                    }
                }
            }

            // Progress bar
            if let schedule = todaySchedule {
                let total = schedule.blocks.count
                let completed = todayLog.completedBlockIDs.count

                VStack(spacing: 4) {
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 6)
                                .fill(PixelTheme.pending.opacity(0.3))
                            RoundedRectangle(cornerRadius: 6)
                                .fill(PixelTheme.completed)
                                .frame(width: total > 0 ? geo.size.width * CGFloat(completed) / CGFloat(total) : 0)
                                .animation(.spring(response: 0.4), value: completed)
                        }
                    }
                    .frame(height: 10)

                    HStack {
                        Text("\(completed)/\(total) done")
                            .font(PixelTheme.captionFont)
                            .foregroundColor(PixelTheme.text.opacity(0.6))
                        Spacer()
                        if total > 0 {
                            Text("\(Int(Double(completed) / Double(total) * 100))%")
                                .font(PixelTheme.captionFont)
                                .foregroundColor(PixelTheme.completed)
                        }
                    }
                }
            }
        }
        .padding(16)
        .background(PixelTheme.cardBackground)
        .cornerRadius(16)
        .shadow(color: PixelTheme.shadowColor, radius: 4, y: 2)
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

        // Feedback
        HapticService.success()
        SoundService.playCompleteSound()

        // Check for perfect day celebration
        if todayLog.completedBlockIDs.count == schedule.blocks.count {
            HapticService.heavy()
            SoundService.playCelebrationSound()
        }

        // Trigger animation
        animatingBlockID = block.id
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            animatingBlockID = nil
        }

        // Update widget
        updateWidget()

        // Notify Room for animations
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
        // Ensure WidgetDataService is available
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
        WidgetCenter.shared.reloadAllTimelines()
        #endif
    }

    private var dateString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE, MMM d"
        return formatter.string(from: .now)
    }
}
