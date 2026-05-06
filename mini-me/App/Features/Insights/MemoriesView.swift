import SwiftUI
import SwiftData

/// Memories tab — a cozy reframe of the old InsightsView.
/// Same underlying data, completely different framing:
///   - "Where mini-me was today" scene timeline instead of completion stats
///   - Warm-tinted journey heatmap instead of guilt-inducing trend bars
///   - No streak counter, no red "missed" markers, no streak-loss pressure
///   - Aesthetic first, analytic second
struct MemoriesView: View {
    @Query(sort: \DayLog.date, order: .reverse) private var dayLogs: [DayLog]
    @Query private var schedules: [DailySchedule]

    private var todayLog: DayLog? {
        dayLogs.first { Calendar.current.isDateInToday($0.date) }
    }

    private var activeSchedule: DailySchedule? {
        let isWeekday = !Calendar.current.isDateInWeekend(.now)
        return schedules.first { $0.isWeekday == isWeekday } ?? schedules.first
    }

    /// Today's completed blocks in chronological order.
    private var todayScenes: [(block: TimeBlock, scene: RoomType)] {
        guard let log = todayLog, let schedule = activeSchedule else { return [] }
        let completedIDs = Set(log.completedBlockIDs)
        return schedule.blocks
            .filter { completedIDs.contains($0.id) }
            .sorted { ($0.startHour * 60 + $0.startMinute) < ($1.startHour * 60 + $1.startMinute) }
            .map { ($0, $0.blockCategory.sceneRoomType) }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                PixelTheme.background.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 16) {
                        todayTimelineCard
                        journeyHeatmapCard
                        vibesCard
                        timeOfDayCard
                        momentsCard
                    }
                    .padding(16)
                }
            }
            .navigationTitle("Memories")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    // MARK: - Today's Scene Timeline

    private var todayTimelineCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Where mini-me was today")
                    .font(PixelTheme.headlineFont)
                    .foregroundColor(PixelTheme.text)
                Spacer()
                Text(Date.now, style: .date)
                    .font(PixelTheme.captionFont)
                    .foregroundColor(PixelTheme.text.opacity(0.4))
            }

            if todayScenes.isEmpty {
                HStack(spacing: 10) {
                    Text("🛏️")
                        .font(.system(size: 28))
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Still home")
                            .font(PixelTheme.bodyFont)
                            .foregroundColor(PixelTheme.text)
                        Text("Complete a block to start the journey")
                            .font(PixelTheme.captionFont)
                            .foregroundColor(PixelTheme.text.opacity(0.45))
                    }
                }
                .padding(.vertical, 4)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(Array(todayScenes.enumerated()), id: \.offset) { idx, pair in
                            sceneChip(block: pair.block, scene: pair.scene, index: idx)
                        }
                    }
                    .padding(.horizontal, 2)
                }
            }
        }
        .padding(16)
        .background(PixelTheme.cardBackground)
        .cornerRadius(16)
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(PixelTheme.cardBorder, lineWidth: 1))
        .shadow(color: PixelTheme.shadowColor, radius: 4, y: 2)
    }

    private func sceneChip(block: TimeBlock, scene: RoomType, index: Int) -> some View {
        let timeStr = timeString(hour: block.startHour, minute: block.startMinute)
        let emoji = sceneEmoji(for: scene)
        let chipColor = chipAccentColor(for: block.blockCategory)

        return VStack(spacing: 6) {
            // Scene emoji in a warm circle
            ZStack {
                Circle()
                    .fill(chipColor.opacity(0.18))
                    .frame(width: 44, height: 44)
                Text(emoji)
                    .font(.system(size: 22))
            }

            // Block label
            Text(block.label.isEmpty ? block.blockCategory.displayName : block.label)
                .font(.system(size: 10, weight: .semibold, design: .rounded))
                .foregroundColor(PixelTheme.text)
                .lineLimit(1)
                .frame(width: 68)

            // Time
            Text(timeStr)
                .font(.system(size: 9, weight: .medium, design: .rounded))
                .foregroundColor(PixelTheme.text.opacity(0.45))
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 6)
        .background(chipColor.opacity(0.08))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(chipColor.opacity(0.25), lineWidth: 1)
        )
    }

    // MARK: - Journey Heatmap (warm tones, no guilt)

    private var journeyHeatmapCard: some View {
        let last14Days = (0..<14).compactMap {
            Calendar.current.date(byAdding: .day, value: -$0, to: .now)
        }.reversed()

        return VStack(alignment: .leading, spacing: 12) {
            Text("Mini-me's journey")
                .font(PixelTheme.headlineFont)
                .foregroundColor(PixelTheme.text)

            HStack(alignment: .bottom, spacing: 4) {
                ForEach(Array(last14Days.enumerated()), id: \.offset) { _, date in
                    let rate = completionRate(for: date)
                    VStack(spacing: 2) {
                        RoundedRectangle(cornerRadius: 3)
                            .fill(journeyBarColor(rate))
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

            // Warm legend — no guilt language
            HStack(spacing: 12) {
                legendDot(color: Color(hex: "FFD54F"), label: "Stellar")
                legendDot(color: Color(hex: "E8985E"), label: "Active")
                legendDot(color: Color(hex: "C9B89A").opacity(0.6), label: "Cozy")
            }
            .font(.system(size: 10))
        }
        .padding(16)
        .background(PixelTheme.cardBackground)
        .cornerRadius(16)
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(PixelTheme.cardBorder, lineWidth: 1))
        .shadow(color: PixelTheme.shadowColor, radius: 4, y: 2)
    }

    // MARK: - What mini-me was up to (category vibes)

    private var vibesCard: some View {
        let stats = categoryStats()

        return VStack(alignment: .leading, spacing: 12) {
            VStack(alignment: .leading, spacing: 2) {
                Text("What mini-me was up to")
                    .font(PixelTheme.headlineFont)
                    .foregroundColor(PixelTheme.text)
                Text("This week's vibe breakdown")
                    .font(PixelTheme.captionFont)
                    .foregroundColor(PixelTheme.text.opacity(0.45))
            }

            if stats.isEmpty {
                Text("Complete some blocks to see what mini-me's been up to ✨")
                    .font(PixelTheme.captionFont)
                    .foregroundColor(PixelTheme.text.opacity(0.4))
                    .padding(.vertical, 4)
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
                                    .fill(PixelTheme.pending.opacity(0.15))
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(stat.category.color.opacity(0.65))
                                    .frame(width: geo.size.width * stat.rate)
                            }
                        }
                        .frame(height: 10)

                        Text("\(Int(stat.rate * 100))%")
                            .font(.system(size: 10, weight: .bold, design: .monospaced))
                            .foregroundColor(PixelTheme.text.opacity(0.5))
                            .frame(width: 36, alignment: .trailing)
                    }
                }
            }
        }
        .padding(16)
        .background(PixelTheme.cardBackground)
        .cornerRadius(16)
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(PixelTheme.cardBorder, lineWidth: 1))
        .shadow(color: PixelTheme.shadowColor, radius: 4, y: 2)
    }

    // MARK: - Time of Day Vibes

    private var timeOfDayCard: some View {
        let sections = timeOfDayStats()

        return VStack(alignment: .leading, spacing: 12) {
            Text("Time of day vibes")
                .font(PixelTheme.headlineFont)
                .foregroundColor(PixelTheme.text)

            HStack(spacing: 12) {
                timeSection("Morning", emoji: "🌅", rate: sections.morning, color: Color(hex: "FFD180"))
                timeSection("Afternoon", emoji: "☀️", rate: sections.afternoon, color: Color(hex: "E8985E"))
                timeSection("Evening", emoji: "🌙", rate: sections.evening, color: Color(hex: "B388FF"))
            }
        }
        .padding(16)
        .background(PixelTheme.cardBackground)
        .cornerRadius(16)
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(PixelTheme.cardBorder, lineWidth: 1))
        .shadow(color: PixelTheme.shadowColor, radius: 4, y: 2)
    }

    private func timeSection(_ label: String, emoji: String, rate: Double, color: Color) -> some View {
        VStack(spacing: 6) {
            Text(emoji).font(.system(size: 22))
            Text("\(Int(rate * 100))%")
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .foregroundColor(PixelTheme.text)
            Text(label)
                .font(.system(size: 10, weight: .medium))
                .foregroundColor(PixelTheme.text.opacity(0.5))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
        .background(color.opacity(0.10))
        .cornerRadius(12)
    }

    // MARK: - All Time Moments

    private var momentsCard: some View {
        let totalBlocks = dayLogs.reduce(0) { $0 + $1.completedBlockIDs.count }
        let totalCoins  = dayLogs.reduce(0) { $0 + $1.totalCoins }
        let activeDays  = dayLogs.filter { !$0.completedBlockIDs.isEmpty }.count
        let perfectDays = dayLogs.filter { log in
            guard let schedule = schedules.first else { return false }
            return log.completedBlockIDs.count >= schedule.blocks.count && schedule.blocks.count > 0
        }.count

        return VStack(alignment: .leading, spacing: 12) {
            Text("All time moments")
                .font(PixelTheme.headlineFont)
                .foregroundColor(PixelTheme.text)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                momentItem(value: "\(totalBlocks)", label: "Moments lived", emoji: "✨", color: PixelTheme.primary)
                momentItem(value: "\(totalCoins)",  label: "Coins collected", emoji: "⭐", color: PixelTheme.coin)
                momentItem(value: "\(activeDays)",  label: "Days with mini-me", emoji: "📅", color: PixelTheme.accent)
                momentItem(value: "\(perfectDays)", label: "Perfect days", emoji: "🌟", color: Color(hex: "FFD54F"))
            }
        }
        .padding(16)
        .background(PixelTheme.cardBackground)
        .cornerRadius(16)
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(PixelTheme.cardBorder, lineWidth: 1))
        .shadow(color: PixelTheme.shadowColor, radius: 4, y: 2)
    }

    private func momentItem(value: String, label: String, emoji: String, color: Color) -> some View {
        HStack(spacing: 8) {
            Text(emoji).font(.system(size: 18))
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

    private func legendDot(color: Color, label: String) -> some View {
        HStack(spacing: 4) {
            Circle().fill(color).frame(width: 8, height: 8)
            Text(label).foregroundColor(PixelTheme.text.opacity(0.5))
        }
    }

    private func completionRate(for date: Date) -> Double {
        guard let log = dayLogs.first(where: { Calendar.current.isDate($0.date, inSameDayAs: date) }) else { return 0 }
        guard let schedule = schedules.first, schedule.blocks.count > 0 else { return 0 }
        return Double(log.completedBlockIDs.count) / Double(schedule.blocks.count)
    }

    /// Warm palette only — no red, no guilt.
    private func journeyBarColor(_ rate: Double) -> Color {
        if rate >= 0.7 { return Color(hex: "FFD54F") }          // gold — stellar
        if rate >= 0.3 { return Color(hex: "E8985E") }          // warm orange — active
        if rate > 0    { return Color(hex: "C9B89A").opacity(0.8) } // linen — cozy
        return Color(hex: "C9B89A").opacity(0.25)               // barely there — rest day
    }

    private func sceneEmoji(for room: RoomType) -> String {
        switch room {
        case .bedroom:    return "🛏️"
        case .study:      return "💻"
        case .kitchen:    return "🍳"
        case .gym:        return "🏃"
        case .coffeeShop: return "☕"
        case .rooftop:    return "🌆"
        }
    }

    private func chipAccentColor(for category: BlockCategory) -> Color {
        category.color
    }

    private func timeString(hour: Int, minute: Int) -> String {
        let h = hour % 12 == 0 ? 12 : hour % 12
        let m = String(format: "%02d", minute)
        let suffix = hour < 12 ? "am" : "pm"
        return "\(h):\(m)\(suffix)"
    }

    private struct CategoryStat {
        let category: BlockCategory
        let rate: Double
    }

    private func categoryStats() -> [CategoryStat] {
        let last7Logs = Array(dayLogs.prefix(7))
        guard !last7Logs.isEmpty else { return [] }

        let allBlocks = schedules.flatMap { $0.blocks }
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
                    if log.completedBlockIDs.contains(id) { completed += 1 }
                }
            }
            if total > 0 {
                results.append(CategoryStat(category: category, rate: Double(completed) / Double(total)))
            }
        }
        return results.sorted { $0.rate > $1.rate }
    }

    private struct TimeOfDayStats {
        let morning, afternoon, evening: Double
    }

    private func timeOfDayStats() -> TimeOfDayStats {
        let last7Logs = Array(dayLogs.prefix(7))
        guard !last7Logs.isEmpty else { return TimeOfDayStats(morning: 0, afternoon: 0, evening: 0) }

        let allBlocks = schedules.flatMap { $0.blocks }
        let morning   = allBlocks.filter { $0.startHour < 12 }
        let afternoon = allBlocks.filter { $0.startHour >= 12 && $0.startHour < 17 }
        let evening   = allBlocks.filter { $0.startHour >= 17 }

        func rate(for blocks: [TimeBlock]) -> Double {
            guard !blocks.isEmpty else { return 0 }
            let ids = Set(blocks.map(\.id))
            var completed = 0, total = 0
            for log in last7Logs {
                for id in ids { total += 1; if log.completedBlockIDs.contains(id) { completed += 1 } }
            }
            return total > 0 ? Double(completed) / Double(total) : 0
        }

        return TimeOfDayStats(morning: rate(for: morning), afternoon: rate(for: afternoon), evening: rate(for: evening))
    }
}
