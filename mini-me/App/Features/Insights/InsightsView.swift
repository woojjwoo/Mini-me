import SwiftUI
import SwiftData

struct InsightsView: View {
    @Query(sort: \DayLog.date, order: .reverse) private var dayLogs: [DayLog]
    @Query private var schedules: [DailySchedule]
    @Query private var players: [Player]

    private var player: Player? { players.first }

    private var allBlocks: [TimeBlock] {
        schedules.flatMap { $0.blocks }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                PixelTheme.background.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 16) {
                        // Completion rate over time
                        completionTrendCard

                        // Category breakdown
                        categoryBreakdownCard

                        // Best & worst times
                        timeOfDayCard

                        // Streak history
                        streakInsightsCard

                        // Fun stats
                        funStatsCard
                    }
                    .padding(16)
                }
            }
            .navigationTitle("Insights")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    // MARK: - Completion Trend

    private var completionTrendCard: some View {
        let last14Days = (0..<14).compactMap { offset in
            Calendar.current.date(byAdding: .day, value: -offset, to: .now)
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
                            Circle()
                                .fill(PixelTheme.primary)
                                .frame(width: 4, height: 4)
                        } else {
                            Spacer().frame(height: 4)
                        }
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .frame(height: 90)

            HStack {
                legendDot(color: PixelTheme.completed, label: "> 70%")
                legendDot(color: PixelTheme.accent, label: "30-70%")
                legendDot(color: PixelTheme.pending.opacity(0.5), label: "< 30%")
            }
            .font(.system(size: 10))
        }
        .padding(16)
        .background(PixelTheme.cardBackground)
        .cornerRadius(16)
        .shadow(color: PixelTheme.shadowColor, radius: 4, y: 2)
    }

    private func legendDot(color: Color, label: String) -> some View {
        HStack(spacing: 4) {
            Circle().fill(color).frame(width: 8, height: 8)
            Text(label).foregroundColor(PixelTheme.text.opacity(0.5))
        }
    }

    // MARK: - Category Breakdown

    private var categoryBreakdownCard: some View {
        let stats = categoryStats()

        return VStack(alignment: .leading, spacing: 12) {
            Text("Category Completion")
                .font(PixelTheme.headlineFont)
                .foregroundColor(PixelTheme.text)

            if stats.isEmpty {
                Text("Complete some blocks to see insights")
                    .font(PixelTheme.captionFont)
                    .foregroundColor(PixelTheme.text.opacity(0.4))
            } else {
                ForEach(stats, id: \.category) { stat in
                    HStack(spacing: 10) {
                        Image(systemName: stat.category.icon)
                            .foregroundColor(stat.category.color)
                            .frame(width: 24)

                        Text(stat.category.displayName)
                            .font(PixelTheme.captionFont)
                            .foregroundColor(PixelTheme.text)
                            .frame(width: 70, alignment: .leading)

                        GeometryReader { geo in
                            ZStack(alignment: .leading) {
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(PixelTheme.pending.opacity(0.2))
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(stat.category.color.opacity(0.7))
                                    .frame(width: geo.size.width * stat.rate)
                            }
                        }
                        .frame(height: 12)

                        Text("\(Int(stat.rate * 100))%")
                            .font(.system(size: 11, weight: .bold, design: .monospaced))
                            .foregroundColor(PixelTheme.text.opacity(0.6))
                            .frame(width: 36, alignment: .trailing)
                    }
                }
            }
        }
        .padding(16)
        .background(PixelTheme.cardBackground)
        .cornerRadius(16)
        .shadow(color: PixelTheme.shadowColor, radius: 4, y: 2)
    }

    // MARK: - Time of Day Card

    private var timeOfDayCard: some View {
        let sections = timeOfDayStats()

        return VStack(alignment: .leading, spacing: 12) {
            Text("Best Time of Day")
                .font(PixelTheme.headlineFont)
                .foregroundColor(PixelTheme.text)

            HStack(spacing: 12) {
                timeSection("Morning", icon: "sunrise.fill", rate: sections.morning, color: Color(hex: "FFD180"))
                timeSection("Afternoon", icon: "sun.max.fill", rate: sections.afternoon, color: Color(hex: "E8985E"))
                timeSection("Evening", icon: "moon.fill", rate: sections.evening, color: Color(hex: "B388FF"))
            }
        }
        .padding(16)
        .background(PixelTheme.cardBackground)
        .cornerRadius(16)
        .shadow(color: PixelTheme.shadowColor, radius: 4, y: 2)
    }

    private func timeSection(_ label: String, icon: String, rate: Double, color: Color) -> some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(color)
            Text("\(Int(rate * 100))%")
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .foregroundColor(PixelTheme.text)
            Text(label)
                .font(.system(size: 10, weight: .medium))
                .foregroundColor(PixelTheme.text.opacity(0.5))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(color.opacity(0.1))
        .cornerRadius(12)
    }

    // MARK: - Streak Insights

    private var streakInsightsCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Streak History")
                .font(PixelTheme.headlineFont)
                .foregroundColor(PixelTheme.text)

            HStack(spacing: 20) {
                VStack(spacing: 4) {
                    Text("\(player?.currentStreak ?? 0)")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundColor(PixelTheme.accent)
                    Text("Current")
                        .font(PixelTheme.captionFont)
                        .foregroundColor(PixelTheme.text.opacity(0.5))
                }
                .frame(maxWidth: .infinity)

                VStack(spacing: 4) {
                    Text("\(player?.longestStreak ?? 0)")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundColor(PixelTheme.primary)
                    Text("Longest")
                        .font(PixelTheme.captionFont)
                        .foregroundColor(PixelTheme.text.opacity(0.5))
                }
                .frame(maxWidth: .infinity)

                VStack(spacing: 4) {
                    Text("\(player?.totalDaysCompleted ?? 0)")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundColor(PixelTheme.coin)
                    Text("Total Days")
                        .font(PixelTheme.captionFont)
                        .foregroundColor(PixelTheme.text.opacity(0.5))
                }
                .frame(maxWidth: .infinity)
            }

            // Next milestone
            if let streak = player?.currentStreak, streak > 0 {
                let nextMilestone = nextStreakMilestone(streak)
                let daysToGo = nextMilestone - streak
                HStack {
                    Image(systemName: "flame.fill")
                        .foregroundColor(PixelTheme.accent)
                    Text("\(daysToGo) days to \(nextMilestone)-day streak bonus!")
                        .font(PixelTheme.captionFont)
                        .foregroundColor(PixelTheme.text.opacity(0.7))
                }
                .padding(10)
                .background(PixelTheme.accent.opacity(0.1))
                .cornerRadius(10)
            }
        }
        .padding(16)
        .background(PixelTheme.cardBackground)
        .cornerRadius(16)
        .shadow(color: PixelTheme.shadowColor, radius: 4, y: 2)
    }

    // MARK: - Fun Stats

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
                funStatItem(value: "\(activeDays)", label: "Active Days", icon: "calendar", color: PixelTheme.primary)
                funStatItem(value: "\(perfectDays)", label: "Perfect Days", icon: "star.fill", color: PixelTheme.accent)
            }
        }
        .padding(16)
        .background(PixelTheme.cardBackground)
        .cornerRadius(16)
        .shadow(color: PixelTheme.shadowColor, radius: 4, y: 2)
    }

    private func funStatItem(value: String, label: String, icon: String, color: Color) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .foregroundColor(color)
                .frame(width: 20)
            VStack(alignment: .leading, spacing: 1) {
                Text(value)
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundColor(PixelTheme.text)
                Text(label)
                    .font(.system(size: 10))
                    .foregroundColor(PixelTheme.text.opacity(0.5))
            }
            Spacer()
        }
        .padding(10)
        .background(color.opacity(0.08))
        .cornerRadius(10)
    }

    // MARK: - Helpers

    private func completionRate(for date: Date) -> Double {
        guard let log = dayLogs.first(where: { Calendar.current.isDate($0.date, inSameDayAs: date) }) else {
            return 0
        }
        guard let schedule = schedules.first, schedule.blocks.count > 0 else { return 0 }
        return Double(log.completedBlockIDs.count) / Double(schedule.blocks.count)
    }

    private func barColor(_ rate: Double) -> Color {
        if rate >= 0.7 { return PixelTheme.completed }
        if rate >= 0.3 { return PixelTheme.accent }
        return PixelTheme.pending.opacity(0.5)
    }

    private struct CategoryStat {
        let category: BlockCategory
        let rate: Double
    }

    private func categoryStats() -> [CategoryStat] {
        let last7Logs = Array(dayLogs.prefix(7))
        guard !last7Logs.isEmpty else { return [] }

        var results: [CategoryStat] = []
        for category in BlockCategory.allCases {
            let blocksInCategory = allBlocks.filter { $0.blockCategory == category }
            guard !blocksInCategory.isEmpty else { continue }

            let blockIDs = Set(blocksInCategory.map(\.id))
            var completed = 0
            var total = 0
            for log in last7Logs {
                for id in blockIDs {
                    total += 1
                    if log.completedBlockIDs.contains(id) {
                        completed += 1
                    }
                }
            }
            if total > 0 {
                results.append(CategoryStat(category: category, rate: Double(completed) / Double(total)))
            }
        }
        return results.sorted { $0.rate > $1.rate }
    }

    private struct TimeOfDayStats {
        let morning: Double
        let afternoon: Double
        let evening: Double
    }

    private func timeOfDayStats() -> TimeOfDayStats {
        let last7Logs = Array(dayLogs.prefix(7))
        guard !last7Logs.isEmpty else { return TimeOfDayStats(morning: 0, afternoon: 0, evening: 0) }

        let morningBlocks = allBlocks.filter { $0.startHour < 12 }
        let afternoonBlocks = allBlocks.filter { $0.startHour >= 12 && $0.startHour < 17 }
        let eveningBlocks = allBlocks.filter { $0.startHour >= 17 }

        func rate(for blocks: [TimeBlock]) -> Double {
            guard !blocks.isEmpty else { return 0 }
            let blockIDs = Set(blocks.map(\.id))
            var completed = 0
            var total = 0
            for log in last7Logs {
                for id in blockIDs {
                    total += 1
                    if log.completedBlockIDs.contains(id) { completed += 1 }
                }
            }
            return total > 0 ? Double(completed) / Double(total) : 0
        }

        return TimeOfDayStats(
            morning: rate(for: morningBlocks),
            afternoon: rate(for: afternoonBlocks),
            evening: rate(for: eveningBlocks)
        )
    }

    private func nextStreakMilestone(_ current: Int) -> Int {
        if current < 3 { return 3 }
        if current < 7 { return 7 }
        if current < 30 { return 30 }
        return ((current / 30) + 1) * 30
    }
}
