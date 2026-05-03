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
    }

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
    /// snapshot the user will encounter today, BUT only if the pair set
    /// has changed since the last bake. Cheap to call from anywhere.
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
        guard hash != lastHash else { return }

        WidgetSnapshotBakery.shared.bakeRequiredSnapshots(
            for: schedule,
            pet: pet,
            room: room
        )
        defaults?.set(hash, forKey: Keys.lastBakedPairsHash)
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
