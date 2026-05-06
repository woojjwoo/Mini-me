import WidgetKit
import SwiftUI
import UIKit

// MARK: - Small Widget

struct SmallWidgetView: View {
    let entry: MiniMeEntry

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            SceneImageView(scene: entry.scene, activity: entry.activity, frame: entry.animationFrame)

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
        .widgetURL(URL(string: "pixieme://today"))
        .containerBackground(.clear, for: .widget)
    }
}

// MARK: - Medium Widget

struct MediumWidgetView: View {
    let entry: MiniMeEntry

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            // Full-bleed scene
            SceneImageView(scene: entry.scene, activity: entry.activity, frame: entry.animationFrame)

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
        .widgetURL(URL(string: "pixieme://today"))
        .containerBackground(.clear, for: .widget)
    }
}

// MARK: - Lock Screen: Circular

struct CircularWidgetView: View {
    let entry: MiniMeEntry

    var body: some View {
        ZStack {
            MiniProgressRing(value: entry.completionRate, size: 44)
            Text(entry.activityEmoji)
                .font(.system(size: 18))
        }
        .widgetURL(URL(string: "pixieme://today"))
    }
}

// MARK: - Lock Screen: Rectangular

struct RectangularWidgetView: View {
    let entry: MiniMeEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(entry.taskName ?? entry.activityLabel)
                .font(.system(size: 13, weight: .bold, design: .rounded))
                .foregroundColor(.primary)
                .lineLimit(1)

            ProgressView(value: entry.completionRate)
                .tint(Color(hex: "E8985E"))

            Text(entry.totalBlocks > 0
                 ? "\(entry.completedBlocks) of \(entry.totalBlocks) blocks done"
                 : "Free time")
                .font(.system(size: 10, weight: .medium, design: .rounded))
                .foregroundColor(.secondary)
        }
        .widgetURL(URL(string: "pixieme://today"))
    }
}

// MARK: - Lock Screen: Inline

struct InlineWidgetView: View {
    let entry: MiniMeEntry

    var body: some View {
        // Inline lock screen widgets: text + optional image.
        // Keep it extremely short — space is ~20 characters.
        Label {
            Text(entry.taskName ?? entry.activityLabel)
        } icon: {
            Text(entry.activityEmoji)
        }
        .widgetURL(URL(string: "pixieme://today"))
    }
}

// MARK: - Scene image (bottom-anchored so floor/character shows)

struct SceneImageView: View {
    let scene: RoomType
    let activity: PetActivity
    /// Optional animation frame (1...widgetFrameCount). When nil the loader
    /// uses the unsuffixed base snapshot — same as pre-animation behavior.
    let frame: Int?

    init(scene: RoomType, activity: PetActivity, frame: Int? = nil) {
        self.scene = scene
        self.activity = activity
        self.frame = frame
    }

    var body: some View {
        ZStack {
            // Ambient fill — matches the scene's baked background color.
            // Fills transparent PNG edges AND acts as the fallback background.
            sceneAmbientColor
                .frame(maxWidth: .infinity, maxHeight: .infinity)

            if let image = loadSceneSnapshot(scene: scene, activity: activity, frame: frame) {
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
    /// Animation frame index (1...widgetFrameCount). Cycles 1→2→3→1... within
    /// each block window so the widget appears to animate. nil = no animation
    /// (e.g. idle/sleep states), in which case the base snapshot is used.
    let animationFrame: Int?

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

    /// Single emoji for compact lock-screen slots
    var activityEmoji: String {
        switch activity {
        case .working:    "💻"
        case .reading:    "📖"
        case .eating:     "🍳"
        case .stretching: "🏃"
        case .sleeping:   "😴"
        case .slacking:   "☕"
        case .walking:    "🚶"
        case .idling:     "✨"
        }
    }

    static let placeholder = MiniMeEntry(
        date: .now, petName: "Pixie", petMood: "focused",
        completedBlocks: 3, totalBlocks: 8, coinsToday: 40,
        taskName: "Deep Work", categoryName: "Work",
        scene: .study, activity: .working,
        animationFrame: nil)
}

struct MiniMeProvider: TimelineProvider {
    func placeholder(in context: Context) -> MiniMeEntry { .placeholder }

    func getSnapshot(in context: Context, completion: @escaping (MiniMeEntry) -> Void) {
        completion(context.isPreview ? .placeholder : currentEntry())
    }

    /// Time between animation frames within an active block. 3 frames × 1.5s
    /// = 4.5s per loop cycle, which reads as continuous motion to the eye.
    private let frameInterval: TimeInterval = 1.5

    /// How far into the future we plan animated entries. iOS will request a
    /// fresh timeline at the end of this window. Trade-off: longer window =
    /// fewer reloads but more entries; shorter = more reloads but tighter
    /// memory. 3 minutes ≈ 120 entries, well within WidgetKit's comfort zone.
    private let animationWindow: TimeInterval = 180

    func getTimeline(in context: Context, completion: @escaping (Timeline<MiniMeEntry>) -> Void) {
        let svc      = WidgetDataService.shared
        let pet      = svc.readPetData()
        let progress = svc.readDayProgress()
        let blocks   = svc.readScheduleBlocks()

        let calendar = Calendar.current
        let now      = Date.now
        let today    = calendar.startOfDay(for: now)

        // Helper: build one MiniMeEntry for a (date, block?, frame?) tuple.
        func makeEntry(date: Date, block: WidgetTimeBlock?, frame: Int?) -> MiniMeEntry {
            let scene    = block.flatMap { RoomType(rawValue: $0.scene) }    ?? .bedroom
            let activity = block.flatMap { PetActivity(rawValue: $0.activity) } ?? .idling
            return MiniMeEntry(
                date: date,
                petName:         pet?.name ?? "Pixie",
                petMood:         pet?.mood ?? "neutral",
                completedBlocks: progress?.completedBlocks ?? 0,
                totalBlocks:     progress?.totalBlocks ?? 0,
                coinsToday:      progress?.coinsToday ?? 0,
                taskName:        block?.label,
                categoryName:    block?.category,
                scene:           scene,
                activity:        activity,
                animationFrame:  frame)
        }

        // Find which block (if any) covers a given moment in time.
        // Returns nil for "between blocks" / idle gaps.
        func block(at date: Date) -> WidgetTimeBlock? {
            let minutes = calendar.component(.hour, from: date) * 60
                + calendar.component(.minute, from: date)
            return blocks.first { b in
                minutes >= b.startMinuteOfDay && minutes < b.endMinuteOfDay
            }
        }

        // Should this activity get frame cycling? Idle/sleeping don't animate
        // — they're meant to be quiet states, and saving widget cycles for
        // active poses keeps the motion meaningful.
        func shouldAnimate(_ block: WidgetTimeBlock?) -> Bool {
            guard let b = block else { return false }
            guard let activity = PetActivity(rawValue: b.activity) else { return false }
            switch activity {
            case .idling, .sleeping: return false
            default:                  return true
            }
        }

        guard !blocks.isEmpty else {
            // No schedule — idle entry, refresh in 15 min
            let entry = makeEntry(date: now, block: nil, frame: nil)
            let next  = calendar.date(byAdding: .minute, value: 15, to: now)!
            completion(Timeline(entries: [entry], policy: .after(next)))
            return
        }

        // Strategy: walk forward in `frameInterval` ticks across the
        // animationWindow. At each tick figure out which block (if any)
        // is active, and assign a cycling frame index when animation applies.
        // This naturally handles block boundaries — when we tick past one,
        // the active block changes and so does the (scene, activity) pair.
        var entries: [MiniMeEntry] = []
        let windowEnd = now.addingTimeInterval(animationWindow)

        // Always add a "right now" entry so the widget has something to show
        // even if the first natural tick is a moment in the future.
        let nowBlock = block(at: now)
        entries.append(makeEntry(
            date: now,
            block: nowBlock,
            frame: shouldAnimate(nowBlock) ? 1 : nil))

        var tick = now.addingTimeInterval(frameInterval)
        var frameCounter = 1
        while tick < windowEnd {
            let activeBlock = block(at: tick)
            let frame: Int?
            if shouldAnimate(activeBlock) {
                frameCounter = (frameCounter % widgetFrameCount) + 1
                frame = frameCounter
            } else {
                frame = nil
                frameCounter = 1   // reset cycle for next active block
            }
            // Skip emitting a duplicate-state entry that doesn't change scene,
            // activity, OR frame from the previous one — keeps the entry list
            // tight when we're idle for a long stretch.
            if let last = entries.last,
               last.scene == (activeBlock.flatMap { RoomType(rawValue: $0.scene) } ?? .bedroom),
               last.activity == (activeBlock.flatMap { PetActivity(rawValue: $0.activity) } ?? .idling),
               last.animationFrame == frame {
                tick = tick.addingTimeInterval(frameInterval)
                continue
            }
            entries.append(makeEntry(date: tick, block: activeBlock, frame: frame))
            tick = tick.addingTimeInterval(frameInterval)
        }

        // Reload policy: ask iOS to refresh at the end of the animation
        // window so we can compute the next window's entries. Capped at
        // midnight so we always pick up tomorrow's schedule.
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: today)!
        let reloadAt = min(windowEnd, tomorrow)

        completion(Timeline(entries: entries, policy: .after(reloadAt)))
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
            activity:        active.activity,
            animationFrame:  nil)
    }
}

// MARK: - Entry view + configuration

struct MiniMeWidgetEntryView: View {
    @Environment(\.widgetFamily) var family
    let entry: MiniMeEntry

    var body: some View {
        switch family {
        case .systemSmall:          SmallWidgetView(entry: entry)
        case .systemMedium:         MediumWidgetView(entry: entry)
        case .accessoryCircular:    CircularWidgetView(entry: entry)
        case .accessoryRectangular: RectangularWidgetView(entry: entry)
        case .accessoryInline:      InlineWidgetView(entry: entry)
        default:                    SmallWidgetView(entry: entry)
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
        .supportedFamilies([
            .systemSmall,
            .systemMedium,
            .accessoryCircular,
            .accessoryRectangular,
            .accessoryInline,
        ])
    }
}
