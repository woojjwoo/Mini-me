import WidgetKit
import SwiftUI
import UIKit

// MARK: - Small Widget — full-bleed scene, no chrome

struct SmallWidgetView: View {
    let entry: MiniMeEntry

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .bottom) {
                // Scene fills every pixel
                SceneImageView(scene: entry.scene, activity: entry.activity)

                // Subtle gradient so the label is legible without a card
                LinearGradient(
                    colors: [.clear, .black.opacity(0.55)],
                    startPoint: .center,
                    endPoint: .bottom
                )

                // Status pill — bottom left, minimal
                HStack {
                    VStack(alignment: .leading, spacing: 1) {
                        Text(entry.taskName ?? entry.activityLabel)
                            .font(.system(size: 11, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                        if entry.totalBlocks > 0 {
                            Text("\(entry.completedBlocks)/\(entry.totalBlocks) done")
                                .font(.system(size: 8, weight: .medium, design: .rounded))
                                .foregroundColor(.white.opacity(0.75))
                        }
                    }
                    Spacer()
                }
                .padding(.horizontal, 10)
                .padding(.bottom, 10)
            }
        }
        .containerBackground(.clear, for: .widget)
    }
}

// MARK: - Medium Widget — full-bleed scene + right-side stats card

struct MediumWidgetView: View {
    let entry: MiniMeEntry

    var body: some View {
        GeometryReader { geo in
            ZStack {
                // Scene covers entire widget
                SceneImageView(scene: entry.scene, activity: entry.activity)

                // Right-side frosted stats panel — floats over scene
                HStack {
                    Spacer()
                    VStack(alignment: .leading, spacing: 7) {
                        // Task name
                        Text(entry.taskName ?? "Free time")
                            .font(.system(size: 13, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .lineLimit(1)

                        // Category
                        if let cat = entry.categoryName {
                            Text(cat.uppercased())
                                .font(.system(size: 9, weight: .heavy, design: .rounded))
                                .foregroundColor(.white.opacity(0.6))
                                .kerning(0.5)
                        }

                        Spacer()

                        // Progress ring + fraction
                        HStack(alignment: .bottom, spacing: 6) {
                            MiniProgressRing(value: entry.completionRate, size: 32)
                            VStack(alignment: .leading, spacing: 1) {
                                Text("\(Int(entry.completionRate * 100))%")
                                    .font(.system(size: 15, weight: .black, design: .rounded))
                                    .foregroundColor(.white)
                                Text("\(entry.completedBlocks)/\(entry.totalBlocks)")
                                    .font(.system(size: 9))
                                    .foregroundColor(.white.opacity(0.65))
                            }
                        }

                        // Coins
                        if entry.coinsToday > 0 {
                            HStack(spacing: 3) {
                                Image(systemName: "star.fill")
                                    .font(.system(size: 8))
                                    .foregroundColor(Color(hex: "FFD54F"))
                                Text("\(entry.coinsToday)")
                                    .font(.system(size: 10, weight: .bold, design: .rounded))
                                    .foregroundColor(.white)
                            }
                        }
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 14)
                    .frame(width: geo.size.width * 0.42)
                    .background(
                        // Dark translucent panel that blends with the scene
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(Color.black.opacity(0.45))
                            .background(
                                RoundedRectangle(cornerRadius: 16, style: .continuous)
                                    .fill(.ultraThinMaterial)
                                    .opacity(0.4)
                            )
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    .padding(10)
                }
            }
        }
        .containerBackground(.clear, for: .widget)
    }
}

// MARK: - Scene image (full-bleed, pixel-perfect)

struct SceneImageView: View {
    let scene: RoomType
    let activity: PetActivity

    var body: some View {
        if let image = loadSceneSnapshot(scene: scene, activity: activity) {
            Image(uiImage: image)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .clipped()
        } else {
            // Fallback gradient while snapshots bake
            ZStack {
                LinearGradient(
                    colors: [
                        Color(hex: "2D2040"),
                        Color(hex: "4A3060")
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                VStack(spacing: 4) {
                    Text("🏠")
                        .font(.system(size: 28))
                    Text(scene.displayName)
                        .font(.system(size: 10, weight: .bold, design: .rounded))
                        .foregroundColor(.white.opacity(0.6))
                }
            }
        }
    }
}

// MARK: - Mini progress ring

struct MiniProgressRing: View {
    let value: Double
    let size: CGFloat

    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.white.opacity(0.2), lineWidth: 3)
            Circle()
                .trim(from: 0, to: value)
                .stroke(
                    Color(hex: "E8985E"),
                    style: StrokeStyle(lineWidth: 3, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .animation(.easeOut(duration: 0.5), value: value)
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
