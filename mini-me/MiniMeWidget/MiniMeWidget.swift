import WidgetKit
import SwiftUI
import UIKit

// MARK: - Snapshot loader

private func loadSceneSnapshot(scene: RoomType, activity: PetActivity) -> UIImage? {
    let groupID = "group.com.woojjwoo.pixieme.shared"
    guard let container = FileManager.default.containerURL(
        forSecurityApplicationGroupIdentifier: groupID) else { return nil }
    let specific = container.appendingPathComponent(
        "room_diorama_\(scene.rawValue)_\(activity.rawValue).png")
    if let img = UIImage(contentsOfFile: specific.path) { return img }
    let fallback = container.appendingPathComponent("room_diorama.png")
    return UIImage(contentsOfFile: fallback.path)
}

// MARK: - Shared diorama view

struct RoomDioramaView: View {
    let taskName: String?
    let scene: RoomType
    let activity: PetActivity

    var body: some View {
        ZStack {
            if let image = loadSceneSnapshot(scene: scene, activity: activity) {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } else {
                LinearGradient(
                    colors: [Color(red: 0.96, green: 0.90, blue: 0.83),
                             Color(red: 0.91, green: 0.60, blue: 0.37).opacity(0.4)],
                    startPoint: .topLeading, endPoint: .bottomTrailing)
                Text(scene.displayName)
                    .font(.system(size: 11, weight: .bold, design: .rounded))
                    .foregroundColor(Color(red: 0.18, green: 0.13, blue: 0.25))
            }

            VStack {
                Spacer()
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(taskName ?? activityLabel)
                            .font(.system(size: 10, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                        Text(activity == .idling ? "Free time" : "Active now")
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

    private var activityLabel: String {
        switch activity {
        case .working:    "Working"
        case .reading:    "Reading"
        case .eating:     "Eating"
        case .stretching: "Exercising"
        case .sleeping:   "Resting"
        case .slacking:   "Hanging out"
        case .walking:    "Walking"
        case .idling:     "Free time"
        }
    }
}

// MARK: - Widget views

struct SmallWidgetView: View {
    let entry: MiniMeEntry
    var body: some View {
        RoomDioramaView(taskName: entry.taskName, scene: entry.scene, activity: entry.activity)
            .containerBackground(.clear, for: .widget)
    }
}

struct MediumWidgetView: View {
    let entry: MiniMeEntry
    var body: some View {
        HStack(spacing: 0) {
            RoomDioramaView(taskName: entry.taskName, scene: entry.scene, activity: entry.activity)
                .frame(width: 150)
            VStack(alignment: .leading, spacing: 8) {
                Text(entry.taskName ?? "Relaxing")
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .lineLimit(1)
                Text(entry.categoryName ?? "No Task")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(.secondary)
                Divider()
                HStack {
                    ProgressView(value: entry.completionRate)
                        .tint(.green)
                    Text("\(Int(entry.completionRate * 100))%")
                        .font(.system(size: 10, weight: .bold))
                }
                Text("\(entry.completedBlocks)/\(entry.totalBlocks) blocks done")
                    .font(.system(size: 9))
                    .foregroundStyle(.secondary)
            }
            .padding()
        }
        .containerBackground(.clear, for: .widget)
    }
}

// MARK: - Entry & Provider

struct MiniMeEntry: TimelineEntry {
    let date: Date
    let petName: String
    let petMood: String
    let completedBlocks: Int
    let totalBlocks: Int
    let coinsToday: Int
    let taskName: String?
    let categoryName: String?
    let scene: RoomType
    let activity: PetActivity

    var completionRate: Double {
        guard totalBlocks > 0 else { return 0 }
        return Double(completedBlocks) / Double(totalBlocks)
    }

    static let placeholder = MiniMeEntry(
        date: .now, petName: "Pixie", petMood: "focused",
        completedBlocks: 3, totalBlocks: 8, coinsToday: 40,
        taskName: "Deep Work", categoryName: "Work",
        scene: .study, activity: .working)
}

struct MiniMeProvider: TimelineProvider {
    func placeholder(in context: Context) -> MiniMeEntry { .placeholder }

    func getSnapshot(in context: Context, completion: @escaping (MiniMeEntry) -> Void) {
        completion(context.isPreview ? .placeholder : currentEntry())
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<MiniMeEntry>) -> Void) {
        let entry = currentEntry()
        let next  = Calendar.current.date(byAdding: .minute, value: 15, to: .now)!
        completion(Timeline(entries: [entry], policy: .after(next)))
    }

    private func currentEntry() -> MiniMeEntry {
        let svc      = WidgetDataService.shared
        let pet      = svc.readPetData()
        let progress = svc.readDayProgress()
        let active   = svc.readActiveScene()
        return MiniMeEntry(
            date: .now,
            petName:        pet?.name ?? "Pixie",
            petMood:        pet?.mood ?? "neutral",
            completedBlocks: progress?.completedBlocks ?? 0,
            totalBlocks:    progress?.totalBlocks ?? 0,
            coinsToday:     progress?.coinsToday ?? 0,
            taskName:       progress?.currentTaskName,
            categoryName:   progress?.currentCategory,
            scene:          active.scene,
            activity:       active.activity)
    }
}

// MARK: - Widget configuration

struct MiniMeWidgetEntryView: View {
    @Environment(\.widgetFamily) var family
    let entry: MiniMeEntry
    var body: some View {
        switch family {
        case .systemSmall:  SmallWidgetView(entry: entry)
        case .systemMedium: MediumWidgetView(entry: entry)
        default:            SmallWidgetView(entry: entry)
        }
    }
}

struct MiniMeWidget: Widget {
    let kind: String = "MiniMeWidget"
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: MiniMeProvider()) { entry in
            MiniMeWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Pixie Me")
        .description("Your day, on your home screen.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}
