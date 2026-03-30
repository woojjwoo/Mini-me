import SwiftUI
import SwiftData

struct StatsView: View {
    @Query private var players: [Player]
    @Query(sort: \DayLog.date, order: .reverse) private var dayLogs: [DayLog]
    @Query private var pets: [Pet]

    private var player: Player? { players.first }
    private var pet: Pet? { pets.first }

    var body: some View {
        NavigationStack {
            ZStack {
                PixelTheme.background.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 16) {
                        // Pet card
                        if let pet = pet {
                            petCard(pet)
                        }

                        // Streak card
                        if let player = player {
                            streakCard(player)
                        }

                        // Weekly overview
                        weeklyCard

                        // Lifetime stats
                        if let player = player {
                            lifetimeCard(player)
                        }
                    }
                    .padding(16)
                }
            }
            .navigationTitle("Stats")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    // MARK: - Pet Card

    private func petCard(_ pet: Pet) -> some View {
        HStack(spacing: 16) {
            // Pet avatar placeholder
            RoundedRectangle(cornerRadius: 16)
                .fill(PixelTheme.primary.opacity(0.15))
                .frame(width: 80, height: 80)
                .overlay {
                    Text("🧑")
                        .font(.system(size: 40))
                }

            VStack(alignment: .leading, spacing: 4) {
                Text(pet.name)
                    .font(PixelTheme.headlineFont)
                    .foregroundColor(PixelTheme.text)
                Text(pet.color.displayName)
                    .font(PixelTheme.captionFont)
                    .foregroundColor(PixelTheme.text.opacity(0.6))
                Text("Outfits: \(pet.accessoryIDs.count)")
                    .font(PixelTheme.captionFont)
                    .foregroundColor(PixelTheme.text.opacity(0.6))
            }

            Spacer()
        }
        .padding(16)
        .background(PixelTheme.cardBackground)
        .cornerRadius(16)
        .shadow(color: PixelTheme.shadowColor, radius: 4, y: 2)
    }

    // MARK: - Streak Card

    private func streakCard(_ player: Player) -> some View {
        HStack(spacing: 20) {
            statBubble(
                value: "\(player.currentStreak)",
                label: "Current\nStreak",
                color: PixelTheme.accent
            )
            statBubble(
                value: "\(player.longestStreak)",
                label: "Longest\nStreak",
                color: PixelTheme.primary
            )
            statBubble(
                value: "\(player.coins)",
                label: "Total\nCoins",
                color: PixelTheme.coin
            )
        }
        .padding(20)
        .frame(maxWidth: .infinity)
        .background(PixelTheme.cardBackground)
        .cornerRadius(16)
        .shadow(color: PixelTheme.shadowColor, radius: 4, y: 2)
    }

    private func statBubble(value: String, label: String, color: Color) -> some View {
        VStack(spacing: 6) {
            Text(value)
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundColor(color)
            Text(label)
                .font(PixelTheme.captionFont)
                .foregroundColor(PixelTheme.text.opacity(0.6))
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Weekly Card

    private var weeklyCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("This Week")
                .font(PixelTheme.headlineFont)
                .foregroundColor(PixelTheme.text)

            HStack(spacing: 6) {
                ForEach(lastSevenDays, id: \.self) { date in
                    let log = dayLog(for: date)
                    VStack(spacing: 4) {
                        Text(dayAbbreviation(date))
                            .font(.system(size: 10, weight: .medium, design: .rounded))
                            .foregroundColor(PixelTheme.text.opacity(0.5))

                        Circle()
                            .fill(colorForCompletion(log?.completedBlockIDs.count ?? 0))
                            .frame(width: 32, height: 32)
                            .overlay {
                                if let log = log, !log.completedBlockIDs.isEmpty {
                                    Text("\(log.completedBlockIDs.count)")
                                        .font(.system(size: 11, weight: .bold, design: .rounded))
                                        .foregroundColor(.white)
                                }
                            }

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
        }
        .padding(16)
        .background(PixelTheme.cardBackground)
        .cornerRadius(16)
        .shadow(color: PixelTheme.shadowColor, radius: 4, y: 2)
    }

    // MARK: - Lifetime Card

    private func lifetimeCard(_ player: Player) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("All Time")
                .font(PixelTheme.headlineFont)
                .foregroundColor(PixelTheme.text)

            HStack {
                Label("\(player.totalDaysCompleted) days", systemImage: "calendar.badge.checkmark")
                Spacer()
                Label("\(player.ownedItemIDs.count) items", systemImage: "bag.fill")
            }
            .font(PixelTheme.bodyFont)
            .foregroundColor(PixelTheme.text.opacity(0.7))
        }
        .padding(16)
        .background(PixelTheme.cardBackground)
        .cornerRadius(16)
        .shadow(color: PixelTheme.shadowColor, radius: 4, y: 2)
    }

    // MARK: - Helpers

    private var lastSevenDays: [Date] {
        (0..<7).compactMap { offset in
            Calendar.current.date(byAdding: .day, value: -offset, to: .now)
        }.reversed()
    }

    private func dayLog(for date: Date) -> DayLog? {
        dayLogs.first { Calendar.current.isDate($0.date, inSameDayAs: date) }
    }

    private func dayAbbreviation(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "E"
        return String(formatter.string(from: date).prefix(2))
    }

    private func colorForCompletion(_ count: Int) -> Color {
        switch count {
        case 0: return PixelTheme.pending.opacity(0.3)
        case 1...3: return PixelTheme.completed.opacity(0.4)
        case 4...7: return PixelTheme.completed.opacity(0.7)
        default: return PixelTheme.completed
        }
    }
}
