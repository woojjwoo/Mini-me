import Foundation
import UIKit
import WidgetKit

/// Shares data between main app and widget via App Groups
final class WidgetDataService {
    static let shared = WidgetDataService()

    // App Group identifier — must match Xcode entitlements
    static let appGroupID = "group.com.woojjwoo.pixieme.shared"

    private let defaults: UserDefaults?

    private init() {
        defaults = UserDefaults(suiteName: Self.appGroupID)
    }

    // MARK: - Snapshot Management

    /// Default snapshot used when no scene-specific snapshot exists yet.
    /// (Backwards compatible with pre-pivot widget code.)
    func saveRoomSnapshot(_ image: UIImage) {
        guard let data = image.pngData(),
              let container = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: Self.appGroupID) else {
            return
        }
        let fileURL = container.appendingPathComponent("room_diorama.png")
        try? data.write(to: fileURL)
    }

    /// Scene-specific snapshot. The widget will try this filename first,
    /// then fall back to `room_diorama.png` if missing.
    /// Filename convention: `room_diorama_<scene>_<activity>.png`
    func saveSceneSnapshot(_ image: UIImage, scene: RoomType, activity: PetActivity) {
        guard let data = image.pngData(),
              let container = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: Self.appGroupID) else {
            return
        }
        let filename = "room_diorama_\(scene.rawValue)_\(activity.rawValue).png"
        let fileURL = container.appendingPathComponent(filename)
        try? data.write(to: fileURL)
    }

    /// Frame-variant snapshot for animated widgets. Saved as
    /// `room_diorama_<scene>_<activity>_f<frame>.png`. The widget reads
    /// these in sequence (cycling f1 → f2 → f3) to produce the appearance
    /// of continuous motion within a block.
    func saveSceneFrameSnapshot(_ image: UIImage, scene: RoomType, activity: PetActivity, frame: Int) {
        guard let data = image.pngData(),
              let container = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: Self.appGroupID) else {
            return
        }
        let filename = "room_diorama_\(scene.rawValue)_\(activity.rawValue)_f\(frame).png"
        let fileURL = container.appendingPathComponent(filename)
        try? data.write(to: fileURL)
    }

    /// Resolve the URL the widget should load for a given (scene, activity) pair.
    /// Returns the scene-specific URL if it exists on disk, else falls back to the
    /// generic `room_diorama.png`. Returns nil if neither exists.
    func sceneSnapshotURL(scene: RoomType, activity: PetActivity) -> URL? {
        guard let container = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: Self.appGroupID) else {
            return nil
        }
        let specific = container.appendingPathComponent("room_diorama_\(scene.rawValue)_\(activity.rawValue).png")
        if FileManager.default.fileExists(atPath: specific.path) { return specific }
        let fallback = container.appendingPathComponent("room_diorama.png")
        return FileManager.default.fileExists(atPath: fallback.path) ? fallback : nil
    }

    // MARK: - Keys

    private enum Keys {
        static let petData = "widget_pet_data"
        static let dayProgress = "widget_day_progress"
        static let lastUpdate = "widget_last_update"
        static let activeScene = "widget_active_scene"
        static let activeActivity = "widget_active_activity"
        /// Hash of the unique (scene, activity) pairs in the most-recently-baked
        /// schedule. Lets `triggerBakeIfScheduleChanged()` skip re-baking when
        /// the structural set of pairs hasn't shifted.
        static let lastBakedPairsHash = "widget_last_baked_pairs_hash"
        /// Version string tracking the BUNDLED sprite art set. Bumped manually
        /// whenever we land new sprite/scene PNGs. If this differs from the
        /// last-baked version, the bakery force-rebakes so existing users see
        /// new art on their widget without needing a schedule change.
        static let lastBakedArtVersion = "widget_last_baked_art_version"
        static let scheduleBlocks = "widget_schedule_blocks"
    }

    /// Version of the bundled sprite art. Bump this manually whenever new
    /// PNGs land in `Assets.xcassets` (new pose, new scene, new frame variant).
    /// Format: `YYYY.MM.DD-<descriptor>` so it sorts and reads at a glance.
    /// History:
    ///   - 2026.05.07-coffeeshop+socializing_f123: coffee shop scene + 3 frames
    static let bundledArtVersion = "2026.05.07-coffeeshop+socializing_f123"

    // MARK: - Write (from main app)

    func updateWidgetData(
        pet: Pet,
        mood: PetMood,
        completedBlocks: Int,
        totalBlocks: Int,
        coinsToday: Int,
        nextBlockLabel: String?,
        currentTaskName: String?,
        currentCategory: String?,
        scheduleBlocks: [TimeBlockDTO]
    ) {
        let petDTO = PetDTO(
            name: pet.name,
            color: pet.color.rawValue,
            mood: mood.rawValue,
            accessoryIDs: pet.accessoryIDs,
            equippedOutfitIDs: pet.equippedOutfitIDs
        )

        let progress = WidgetDayProgress(
            completedBlocks: completedBlocks,
            totalBlocks: totalBlocks,
            coinsToday: coinsToday,
            nextBlockLabel: nextBlockLabel,
            currentTaskName: currentTaskName,
            currentCategory: currentCategory,
            date: .now
        )

        if let petJSON = try? JSONEncoder().encode(petDTO) {
            defaults?.set(petJSON, forKey: Keys.petData)
        }
        if let progressJSON = try? JSONEncoder().encode(progress) {
            defaults?.set(progressJSON, forKey: Keys.dayProgress)
        }
        defaults?.set(Date.now, forKey: Keys.lastUpdate)

        // Derive widget scene + activity from the active category and persist.
        // The widget reads these to pick which pre-baked snapshot to load.
        let resolved = resolveWidgetScene(
            currentCategory: currentCategory,
            mood: mood
        )
        defaults?.set(resolved.scene.rawValue, forKey: Keys.activeScene)
        defaults?.set(resolved.activity.rawValue, forKey: Keys.activeActivity)

        // Publish own presence to CloudKit so friends can see your current
        // scene + activity. Privacy contract honored: only displayName, scene,
        // activity, lastSeen ever leave the device — never schedule details.
        FriendPresenceService.shared.publishPresence(
            displayName: pet.name,
            scene: resolved.scene,
            activity: resolved.activity
        )

        // Persist schedule blocks with pre-resolved scene + activity so the widget
        // can build a per-block timeline without needing the full BlockCategory logic.
        let widgetBlocks = scheduleBlocks.map { dto -> WidgetTimeBlockStorage in
            let cat = BlockCategory(rawValue: dto.category) ?? .custom
            return WidgetTimeBlockStorage(
                id: dto.id,
                category: dto.category,
                label: dto.label,
                startHour: dto.startHour,
                startMinute: dto.startMinute,
                durationMinutes: dto.durationMinutes,
                sortOrder: dto.sortOrder,
                scene: cat.sceneRoomType.rawValue,
                activity: cat.sceneActivity.rawValue
            )
        }
        if let blocksJSON = try? JSONEncoder().encode(widgetBlocks) {
            defaults?.set(blocksJSON, forKey: Keys.scheduleBlocks)
        }

        // Reload widget timeline so scene change reflects immediately on home screen.
        WidgetCenter.shared.reloadAllTimelines()
    }

    /// Translate the current block category (or absence) into a (scene, activity) pair.
    /// Sleep/manual-status moods override the schedule mapping (e.g. user marks "sick"
    /// → bedroom + sleeping regardless of block).
    private func resolveWidgetScene(
        currentCategory: String?,
        mood: PetMood
    ) -> (scene: RoomType, activity: PetActivity) {
        // Mood overrides — these win over schedule-derived mapping
        if mood == .sleeping {
            return (.bedroom, .sleeping)
        }

        // Otherwise derive from the active block category
        if let raw = currentCategory, let cat = BlockCategory(rawValue: raw) {
            return (cat.sceneRoomType, cat.sceneActivity)
        }

        // No active block → idle in bedroom
        return (.bedroom, .idling)
    }

    // MARK: - Read (from widget)

    func readPetData() -> PetDTO? {
        guard let data = defaults?.data(forKey: Keys.petData) else { return nil }
        return try? JSONDecoder().decode(PetDTO.self, from: data)
    }

    func readDayProgress() -> WidgetDayProgress? {
        guard let data = defaults?.data(forKey: Keys.dayProgress) else { return nil }
        return try? JSONDecoder().decode(WidgetDayProgress.self, from: data)
    }

    /// Read the active (scene, activity) pair the widget should render.
    /// Falls back to bedroom + idling if not set.
    func readActiveScene() -> (scene: RoomType, activity: PetActivity) {
        let sceneRaw = defaults?.string(forKey: Keys.activeScene) ?? RoomType.bedroom.rawValue
        let activityRaw = defaults?.string(forKey: Keys.activeActivity) ?? PetActivity.idling.rawValue
        let scene = RoomType(rawValue: sceneRaw) ?? .bedroom
        let activity = PetActivity(rawValue: activityRaw) ?? .idling
        return (scene, activity)
    }

    // MARK: - Pre-bake orchestration

    /// Trigger an off-screen pre-bake of every unique (scene, activity)
    /// snapshot the user will encounter today. Re-bakes when EITHER:
    ///   1. The (scene, activity) pair set has changed (user edited schedule), OR
    ///   2. The bundled sprite art has changed (we shipped new PNGs).
    ///
    /// Cheap to call from anywhere; the bakery itself dedupes per-frame work.
    ///
    /// Call this from:
    /// - DailyScheduleView when blocks are added/edited/removed
    /// - Onboarding completion
    /// - App foreground (once per day check)
    @MainActor
    func triggerBakeIfScheduleChanged(
        schedule: DailySchedule,
        pet: Pet?,
        room: Room
    ) {
        let hash = uniquePairsHash(for: schedule)
        let lastHash = defaults?.string(forKey: Keys.lastBakedPairsHash)
        let lastArtVersion = defaults?.string(forKey: Keys.lastBakedArtVersion)
        let artVersionChanged = lastArtVersion != Self.bundledArtVersion

        // Skip only when BOTH structure AND art version match the last bake.
        guard hash != lastHash || artVersionChanged else { return }

        WidgetSnapshotBakery.shared.bakeRequiredSnapshots(
            for: schedule,
            pet: pet,
            room: room
        )
        defaults?.set(hash, forKey: Keys.lastBakedPairsHash)
        defaults?.set(Self.bundledArtVersion, forKey: Keys.lastBakedArtVersion)
    }

    /// Force a re-bake regardless of hash. Use after the user customizes
    /// their Mini Me (skin tone, outfit) since the same (scene, activity)
    /// pair will produce a different rendered image.
    @MainActor
    func forceBakeAll(
        schedule: DailySchedule,
        pet: Pet?,
        room: Room
    ) {
        WidgetSnapshotBakery.shared.bakeRequiredSnapshots(
            for: schedule,
            pet: pet,
            room: room
        )
        defaults?.set(uniquePairsHash(for: schedule), forKey: Keys.lastBakedPairsHash)
        defaults?.set(Self.bundledArtVersion, forKey: Keys.lastBakedArtVersion)
    }

    /// Stable hash of the unique (scene, activity) pairs derived from a
    /// schedule's blocks, plus the default fallback pair.
    private func uniquePairsHash(for schedule: DailySchedule) -> String {
        var seen = Set<String>(["bedroom_idling"])
        for block in schedule.blocks {
            let cat = block.blockCategory
            seen.insert("\(cat.sceneRoomType.rawValue)_\(cat.sceneActivity.rawValue)")
        }
        return seen.sorted().joined(separator: "|")
    }
}

/// Codable representation of a schedule block written to the App Group
/// by the main app and read by the widget to build its per-block timeline.
/// Must stay in sync with `WidgetTimeBlock` in MiniMeWidget/WidgetModels.swift.
private struct WidgetTimeBlockStorage: Codable {
    let id: UUID
    let category: String
    let label: String
    let startHour: Int
    let startMinute: Int
    let durationMinutes: Int
    let sortOrder: Int
    let scene: String    // RoomType rawValue
    let activity: String // PetActivity rawValue
}

struct WidgetDayProgress: Codable {
    let completedBlocks: Int
    let totalBlocks: Int
    let coinsToday: Int
    let nextBlockLabel: String?
    let currentTaskName: String?
    let currentCategory: String?
    let date: Date

    var completionFraction: String {
        "\(completedBlocks)/\(totalBlocks)"
    }

    var completionRate: Double {
        guard totalBlocks > 0 else { return 0 }
        return Double(completedBlocks) / Double(totalBlocks)
    }
}
