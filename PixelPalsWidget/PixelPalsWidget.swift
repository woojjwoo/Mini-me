import WidgetKit
import SwiftUI

// MARK: - Timeline Provider

struct PixelPalsProvider: TimelineProvider {
    func placeholder(in context: Context) -> PixelPalsEntry {
        PixelPalsEntry.placeholder
    }

    func getSnapshot(in context: Context, completion: @escaping (PixelPalsEntry) -> Void) {
        completion(currentEntry())
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<PixelPalsEntry>) -> Void) {
        let entry = currentEntry()
        // Refresh every 15 minutes
        let nextUpdate = Calendar.current.date(byAdding: .minute, value: 15, to: .now)!
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        completion(timeline)
    }

    private func currentEntry() -> PixelPalsEntry {
        let widgetService = WidgetDataService.shared
        let pet = widgetService.readPetData()
        let progress = widgetService.readDayProgress()

        return PixelPalsEntry(
            date: .now,
            petName: pet?.name ?? "Pixel",
            petMood: pet?.mood ?? PetMood.neutral.rawValue,
            petColor: pet?.color ?? PetColor.orangeTabby.rawValue,
            completedBlocks: progress?.completedBlocks ?? 0,
            totalBlocks: progress?.totalBlocks ?? 0,
            coinsToday: progress?.coinsToday ?? 0,
            nextBlockLabel: progress?.nextBlockLabel
        )
    }
}

// MARK: - Entry

struct PixelPalsEntry: TimelineEntry {
    let date: Date
    let petName: String
    let petMood: String
    let petColor: String
    let completedBlocks: Int
    let totalBlocks: Int
    let coinsToday: Int
    let nextBlockLabel: String?

    var mood: PetMood { PetMood(rawValue: petMood) ?? .neutral }
    var completionRate: Double {
        guard totalBlocks > 0 else { return 0 }
        return Double(completedBlocks) / Double(totalBlocks)
    }

    static let placeholder = PixelPalsEntry(
        date: .now,
        petName: "Pixel",
        petMood: "happy",
        petColor: "orangeTabby",
        completedBlocks: 5,
        totalBlocks: 10,
        coinsToday: 80,
        nextBlockLabel: "Study"
    )
}

// MARK: - Small Widget

struct SmallWidgetView: View {
    let entry: PixelPalsEntry

    var body: some View {
        VStack(spacing: 6) {
            // Pet
            Text("🧑")
                .font(.system(size: 36))

            // Progress
            HStack(spacing: 4) {
                Text("\(entry.completedBlocks)/\(entry.totalBlocks)")
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundColor(Color(hex: "3D3D3D"))
            }

            // Coins
            HStack(spacing: 2) {
                Circle()
                    .fill(Color(hex: "FFD54F"))
                    .frame(width: 8, height: 8)
                Text("\(entry.coinsToday)")
                    .font(.system(size: 11, weight: .semibold, design: .monospaced))
                    .foregroundColor(Color(hex: "3D3D3D").opacity(0.7))
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .containerBackground(Color(hex: "F5E6D3"), for: .widget)
    }
}

// MARK: - Medium Widget

struct MediumWidgetView: View {
    let entry: PixelPalsEntry

    var body: some View {
        HStack(spacing: 16) {
            // Pet side
            VStack(spacing: 4) {
                Text("🧑")
                    .font(.system(size: 40))
                Text(entry.petName)
                    .font(.system(size: 11, weight: .medium, design: .rounded))
                    .foregroundColor(Color(hex: "3D3D3D").opacity(0.7))
                Text(entry.mood.displayEmoji)
                    .font(.system(size: 14))
            }
            .frame(width: 80)

            // Info side
            VStack(alignment: .leading, spacing: 6) {
                Text(dateString)
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                    .foregroundColor(Color(hex: "3D3D3D"))

                // Progress bar
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color(hex: "BDBDBD").opacity(0.3))
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color(hex: "7CB342"))
                            .frame(width: geo.size.width * entry.completionRate)
                    }
                }
                .frame(height: 8)

                Text("\(entry.completedBlocks)/\(entry.totalBlocks) done")
                    .font(.system(size: 11, weight: .medium, design: .rounded))
                    .foregroundColor(Color(hex: "3D3D3D").opacity(0.6))

                if let next = entry.nextBlockLabel {
                    Text("Next: \(next)")
                        .font(.system(size: 11, weight: .medium, design: .rounded))
                        .foregroundColor(Color(hex: "5B8C5A"))
                }

                HStack(spacing: 3) {
                    Circle()
                        .fill(Color(hex: "FFD54F"))
                        .frame(width: 8, height: 8)
                    Text("\(entry.coinsToday) today")
                        .font(.system(size: 11, weight: .semibold, design: .monospaced))
                        .foregroundColor(Color(hex: "3D3D3D").opacity(0.7))
                }
            }
        }
        .padding(.horizontal, 4)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .containerBackground(Color(hex: "F5E6D3"), for: .widget)
    }

    private var dateString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE, MMM d"
        return formatter.string(from: entry.date)
    }
}

// MARK: - Widget Configuration

struct PixelPalsWidget: Widget {
    let kind: String = "PixelPalsWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: PixelPalsProvider()) { entry in
            PixelPalsWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Mini Me")
        .description("See your Mini Me and daily progress")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

struct PixelPalsWidgetEntryView: View {
    @Environment(\.widgetFamily) var family
    let entry: PixelPalsEntry

    var body: some View {
        switch family {
        case .systemSmall:
            SmallWidgetView(entry: entry)
        case .systemMedium:
            MediumWidgetView(entry: entry)
        default:
            SmallWidgetView(entry: entry)
        }
    }
}
