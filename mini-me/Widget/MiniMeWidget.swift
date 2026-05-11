import WidgetKit
import SwiftUI

// MARK: - Snapshot Diorama Renderer for Widget

struct RoomDioramaView: View {
    let taskName: String?

    var body: some View {
        ZStack {
            if let image = loadSnapshot() {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } else {
                Color(red: 0.96, green: 0.90, blue: 0.83)
                VStack(spacing: 8) {
                    Text("🏠")
                        .font(.system(size: 32))
                    Text("Room Loading...")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }

            if let taskName = taskName {
                VStack {
                    Spacer()
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(taskName)
                                .font(.system(size: 10, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                            Text("Active Now")
                                .font(.system(size: 7, weight: .medium))
                                .foregroundColor(.white.opacity(0.8))
                        }
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.black.opacity(0.6))
                        .cornerRadius(6)
                        Spacer()
                    }
                    .padding(8)
                }
            }
        }
    }

    private func loadSnapshot() -> UIImage? {
        let groupID = "group.com.woojjwoo.pixieme.shared"
        guard let container = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: groupID) else {
            return nil
        }
        let fileURL = container.appendingPathComponent("room_diorama.png")
        return UIImage(contentsOfFile: fileURL.path)
    }
}

// MARK: - Widget Views

struct SmallWidgetView: View {
    let entry: MiniMeEntry

    var body: some View {
        RoomDioramaView(taskName: entry.taskName)
            .containerBackground(.clear, for: .widget)
    }
}

struct MediumWidgetView: View {
    let entry: MiniMeEntry

    var body: some View {
        HStack(spacing: 0) {
            RoomDioramaView(taskName: entry.taskName)
                .frame(width: 150)

            VStack(alignment: .leading, spacing: 8) {
                Text(entry.taskName ?? "Relaxing")
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .lineLimit(1)

                Text(entry.categoryName ?? "Free Time")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(.secondary)

                Divider()

                HStack {
                    ProgressView(value: entry.completionRate)
                        .tint(.green)
                    Text("\(Int(entry.completionRate * 100))%")
                        .font(.system(size: 10, weight: .bold))
                }

                Text("\(entry.completedBlocks)/\(entry.totalBlocks) done")
                    .font(.system(size: 9))
                    .foregroundStyle(.secondary)
            }
            .padding()
        }
        .containerBackground(.clear, for: .widget)
    }
}

// MARK: - Provider

struct MiniMeProvider: TimelineProvider {
    func placeholder(in context: Context) -> MiniMeEntry {
        MiniMeEntry.placeholder
    }

    func getSnapshot(in context: Context, completion: @escaping (MiniMeEntry) -> Void) {
        completion(currentEntry())
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<MiniMeEntry>) -> Void) {
        let entry = currentEntry()
        let nextUpdate = Calendar.current.date(byAdding: .minute, value: 15, to: .now)!
        completion(Timeline(entries: [entry], policy: .after(nextUpdate)))
    }

    private func currentEntry() -> MiniMeEntry {
        let service = WidgetDataService.shared
        let pet = service.readPetData()
        let progress = service.readDayProgress()
        return MiniMeEntry(
            date: .now,
            petName: pet?.name ?? "Pixie",
            petMood: pet?.mood ?? "neutral",
            completedBlocks: progress?.completedBlocks ?? 0,
            totalBlocks: progress?.totalBlocks ?? 0,
            coinsToday: progress?.coinsToday ?? 0,
            taskName: progress?.currentTaskName,
            categoryName: progress?.currentCategory
        )
    }
}

// MARK: - Entry

struct MiniMeEntry: TimelineEntry {
    let date: Date
    let petName: String
    let petMood: String
    let completedBlocks: Int
    let totalBlocks: Int
    let coinsToday: Int
    let taskName: String?
    let categoryName: String?

    var completionRate: Double {
        guard totalBlocks > 0 else { return 0 }
        return Double(completedBlocks) / Double(totalBlocks)
    }

    static let placeholder = MiniMeEntry(
        date: .now,
        petName: "Pixie",
        petMood: "focused",
        completedBlocks: 3,
        totalBlocks: 8,
        coinsToday: 40,
        taskName: "Deep Work",
        categoryName: "Work"
    )
}

// MARK: - Widget Entry View

struct MiniMeWidgetEntryView: View {
    @Environment(\.widgetFamily) var family
    let entry: MiniMeEntry

    var body: some View {
        switch family {
        case .systemSmall: SmallWidgetView(entry: entry)
        case .systemMedium: MediumWidgetView(entry: entry)
        default: SmallWidgetView(entry: entry)
        }
    }
}

// MARK: - Widget + Bundle

struct MiniMeWidget: Widget {
    let kind: String = "MiniMeWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: MiniMeProvider()) { entry in
            MiniMeWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Pixie Me")
        .description("Your Mini Me living their best life.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

@main
struct MiniMeWidgetBundle: WidgetBundle {
    var body: some Widget {
        MiniMeWidget()
    }
}
