#if !APP
import WidgetKit
import SwiftUI

// MARK: - Timeline Provider

struct MiniMeProvider: TimelineProvider {
    func placeholder(in context: Context) -> MiniMeEntry {
        MiniMeEntry.placeholder
    }

    func getSnapshot(in context: Context, completion: @escaping (MiniMeEntry) -> Void) {
        completion(currentEntry())
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<MiniMeEntry>) -> Void) {
        let entry = currentEntry()
        // Refresh every 15 minutes
        let nextUpdate = Calendar.current.date(byAdding: .minute, value: 15, to: .now)!
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        completion(timeline)
    }

    private func currentEntry() -> MiniMeEntry {
        let widgetService = WidgetDataService.shared
        let pet = widgetService.readPetData()
        let progress = widgetService.readDayProgress()

        return MiniMeEntry(
            date: .now,
            petName: pet?.name ?? "Pixel",
            petMood: pet?.mood ?? PetMood.neutral.rawValue,
            petColor: pet?.color ?? PetColor.orangeTabby.rawValue,
            completedBlocks: progress?.completedBlocks ?? 0,
            totalBlocks: progress?.totalBlocks ?? 0,
            coinsToday: progress?.coinsToday ?? 0,
            nextBlockLabel: progress?.nextBlockLabel,
            accessoryIDs: pet?.accessoryIDs ?? [],
            equippedOutfitIDs: pet?.equippedOutfitIDs ?? []
        )
    }
}

// MARK: - Entry

struct MiniMeEntry: TimelineEntry {
    let date: Date
    let petName: String
    let petMood: String
    let petColor: String
    let completedBlocks: Int
    let totalBlocks: Int
    let coinsToday: Int
    let nextBlockLabel: String?
    let accessoryIDs: [String]
    let equippedOutfitIDs: [String]

    var mood: PetMood {
        PetMood(rawValue: petMood) ?? .neutral
    }

    var completionRate: Double {
        guard totalBlocks > 0 else { return 0 }
        return Double(completedBlocks) / Double(totalBlocks)
    }

    static let placeholder = MiniMeEntry(
        date: .now,
        petName: "Pixel",
        petMood: "happy",
        petColor: "orangeTabby",
        completedBlocks: 5,
        totalBlocks: 10,
        coinsToday: 50,
        nextBlockLabel: "Study",
        accessoryIDs: [],
        equippedOutfitIDs: []
    )
struct SmallWidgetView: View {
    let entry: MiniMeEntry

    var body: some View {
        VStack(spacing: 6) {
            // Context-aware icon
            Text(activityIcon)
                .font(.system(size: 30))

            Text(entry.petName)
                .font(.caption2.bold())

            // Progress
            ProgressView(value: entry.completionRate)
                .tint(.green)

            Text("\(entry.completedBlocks)/\(entry.totalBlocks)")
                .font(.system(size: 10))
        }
        .containerBackground(.clear, for: .widget)
    }

    private var activityIcon: String {
        switch entry.mood {
        case .sleeping: return "😴"
        case .focused: return "💻"
        case .eating: return "🍎"
        case .happy: return "✨"
        default: return "🧑"
        }
    }
}

// MARK: - Medium Widget

struct MediumWidgetView: View {
    let entry: MiniMeEntry

    var body: some View {
        HStack(spacing: 16) {
            // Pet side
            VStack(spacing: 4) {
                Text(activityIcon)
                    .font(.system(size: 44))
                Text(entry.petName)
                    .font(.caption.bold())
                Text(entry.mood.displayEmoji)
                    .font(.title3)
            }
            .frame(width: 80)

            // Stats side
...
        }
        .containerBackground(.clear, for: .widget)
    }

    private var activityIcon: String {
        switch entry.mood {
        case .sleeping: return "😴"
        case .focused: return "💻"
        case .eating: return "🍎"
        case .happy: return "✨"
        default: return "🧑"
        }
    }
}
                Text("Today's Progress")
                    .font(.caption.bold())
                    .foregroundStyle(.secondary)
                
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(.green)
                    Text("\(entry.completedBlocks)/\(entry.totalBlocks) Blocks")
                        .font(.subheadline)
                }
                
                HStack {
                    Image(systemName: "bitcoinsign.circle.fill")
                        .foregroundStyle(.orange)
                    Text("\(entry.coinsToday) Coins")
                        .font(.subheadline)
                }
                
                if let next = entry.nextBlockLabel {
                    Text("Next: \(next)")
                        .font(.caption)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.accentColor.opacity(0.2))
                        .clipShape(Capsule())
                }
            }
        }
        .containerBackground(.clear, for: .widget)
    }
}

// MARK: - Widget Configuration

// MARK: - Lock Screen Widgets (v2)

struct LockScreenCircularView: View {
    let entry: MiniMeEntry

    var body: some View {
        ZStack {
            AccessoryWidgetBackground()
            VStack(spacing: 1) {
                Text(entry.mood.displayEmoji)
                    .font(.system(size: 20))
                Text("\(entry.completedBlocks)")
                    .font(.system(size: 10, weight: .bold))
            }
        }
    }
}

struct LockScreenRectangularView: View {
    let entry: MiniMeEntry

    var body: some View {
        HStack(spacing: 8) {
            Text(entry.mood.displayEmoji)
                .font(.system(size: 22))
            VStack(alignment: .leading) {
                Text(entry.petName)
                    .font(.headline)
                Text("\(entry.completedBlocks)/\(entry.totalBlocks) blocks done")
                    .font(.caption)
            }
        }
    }
}

struct LockScreenInlineView: View {
    let entry: MiniMeEntry

    var body: some View {
        Text("\(entry.mood.displayEmoji) \(entry.completedBlocks)/\(entry.totalBlocks) blocks · \(entry.coinsToday) coins")
    }
}

// MARK: - Widget Configuration

struct MiniMeWidget: Widget {
    let kind: String = "MiniMeWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: MiniMeProvider()) { entry in
            MiniMeWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Mini Me")
        .description("See your Mini Me and daily progress")
        .supportedFamilies([
            .systemSmall,
            .systemMedium,
            .accessoryCircular,
            .accessoryRectangular,
            .accessoryInline,
        ])
    }
}

struct MiniMeWidgetEntryView: View {
    @Environment(\.widgetFamily) var family
    let entry: MiniMeEntry

    var body: some View {
        switch family {
        case .systemSmall:
            SmallWidgetView(entry: entry)
        case .systemMedium:
            MediumWidgetView(entry: entry)
        case .accessoryCircular:
            LockScreenCircularView(entry: entry)
        case .accessoryRectangular:
            LockScreenRectangularView(entry: entry)
        case .accessoryInline:
            LockScreenInlineView(entry: entry)
        default:
            SmallWidgetView(entry: entry)
        }
    }
}
#endif
