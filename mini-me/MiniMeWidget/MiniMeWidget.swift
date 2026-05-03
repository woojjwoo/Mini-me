import WidgetKit
import SwiftUI
import UIKit

// MARK: - Small Widget

struct SmallWidgetView: View {
    let entry: MiniMeEntry

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            SceneImageView(scene: entry.scene, activity: entry.activity)

            // Vignette so text is readable
            LinearGradient(
                colors: [.clear, .black.opacity(0.6)],
                startPoint: UnitPoint(x: 0.5, y: 0.35),
                endPoint: .bottom
            )

            // Label
            VStack(alignment: .leading, spacing: 2) {
                Text(entry.taskName ?? entry.activityLabel)
                    .font(.system(size: 11, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                if entry.totalBlocks > 0 {
                    Text("\(entry.completedBlocks)/\(entry.totalBlocks) blocks")
                        .font(.system(size: 8, weight: .medium, design: .rounded))
                        .foregroundColor(.white.opacity(0.8))
                }
            }
            .padding(.horizontal, 10)
            .padding(.bottom, 10)
        }
        .containerBackground(.clear, for: .widget)
    }
}

// MARK: - Medium Widget

struct MediumWidgetView: View {
    let entry: MiniMeEntry

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            // Full-bleed scene
            SceneImageView(scene: entry.scene, activity: entry.activity)

            // Bottom gradient
            LinearGradient(
                colors: [.clear, .black.opacity(0.5)],
                startPoint: UnitPoint(x: 0.5, y: 0.4),
                endPoint: .bottom
            )

            // Stats pill — bottom right
            HStack(spacing: 10) {
                // Progress ring
                MiniProgressRing(value: entry.completionRate, size: 36)

                VStack(alignment: .leading, spacing: 2) {
                    Text(entry.taskName ?? entry.activityLabel)
                        .font(.system(size: 12, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .lineLimit(1)
                    Text(entry.completionRate > 0
                         ? "\(Int(entry.completionRate * 100))%  ·  \(entry.completedBlocks)/\(entry.totalBlocks)"
                         : entry.categoryName?.uppercased() ?? "FREE TIME")
                        .font(.system(size: 9, weight: .semibold, design: .rounded))
                        .foregroundColor(.white.opacity(0.7))
                        .lineLimit(1)
                }

                Spacer()

                if entry.coinsToday > 0 {
                    HStack(spacing: 3) {
                        Image(systemName: "star.fill")
                            .font(.system(size: 9))
                            .foregroundColor(Color(hex: "FFD54F"))
                        Text("\(entry.coinsToday)")
                            .font(.system(size: 11, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                    }
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(
                LinearGradient(
                    colors: [Color.black.opacity(0), Color.black.opacity(0.5)],
                    startPoint: .top, endPoint: .bottom
                )
            )
        }
        .containerBackground(.clear, for: .widget)
    }
}

// MARK: - Scene image (bottom-anchored so floor/character shows)

struct SceneImageView: View {
    let scene: RoomType
    let activity: PetActivity

    var body: some View {
        ZStack {
            // Ambient fill — matches the scene's baked background color.
            // Fills transparent PNG edges AND acts as the fallback background.
            sceneAmbientColor
                .frame(maxWidth: .infinity, maxHeight: .infinity)

            if let image = loadSceneSnapshot(scene: scene, activity: activity) {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
                    .clipped()
            } else {
                // No snapshot yet — show ambient + scene emoji until art is baked
                VStack(spacing: 6) {
                    Text(scene.fallbackEmoji).font(.system(size: 32))
                    Text(scene.displayName)
                        .font(.system(size: 10, weight: .bold, design: .rounded))
                        .foregroundColor(.white.opacity(0.5))
                }
            }
        }
    }

    /// Per-scene ambient color — must match WidgetSnapshotBakery.ambientColor(for:)
    private var sceneAmbientColor: Color {
        switch scene {
        case .bedroom:    Color(hex: "1A1030")  // deep purple-night
        case .study:      Color(hex: "1C1810")  // warm dark wood
        case .gym:        Color(hex: "0D1A0D")  // dark green
        case .kitchen:    Color(hex: "1A1208")  // warm kitchen amber
        case .coffeeShop: Color(hex: "1A0D0D")  // warm brick
        case .rooftop:    Color(hex: "0A0D1A")  // night sky
        }
    }
}

// MARK: - Progress ring

struct MiniProgressRing: View {
    let value: Double
    let size: CGFloat

    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.white.opacity(0.2), lineWidth: 3)
            Circle()
                .trim(from: 0, to: value)
                .stroke(Color(hex: "E8985E"),
                        style: StrokeStyle(lineWidth: 3, lineCap: .round))
                .rotationEffect(.degrees(-90))
        }
        .frame(width: size, height: size)
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

    var activityLabel: String {
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
            petName:         pet?.name ?? "Pixie",
            petMood:         pet?.mood ?? "neutral",
            completedBlocks: progress?.completedBlocks ?? 0,
            totalBlocks:     progress?.totalBlocks ?? 0,
            coinsToday:      progress?.coinsToday ?? 0,
            taskName:        progress?.currentTaskName,
            categoryName:    progress?.currentCategory,
            scene:           active.scene,
            activity:        active.activity)
    }
}

// MARK: - Entry view + configuration

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
