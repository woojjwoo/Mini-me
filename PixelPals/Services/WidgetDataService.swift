import Foundation

/// Shares data between main app and widget via App Groups
final class WidgetDataService {
    static let shared = WidgetDataService()

    // App Group identifier — must match Xcode entitlements
    static let appGroupID = "group.com.pixelpals.shared"

    private let defaults: UserDefaults?

    private init() {
        defaults = UserDefaults(suiteName: Self.appGroupID)
    }

    // MARK: - Keys

    private enum Keys {
        static let petData = "widget_pet_data"
        static let dayProgress = "widget_day_progress"
        static let lastUpdate = "widget_last_update"
    }

    // MARK: - Write (from main app)

    func updateWidgetData(
        pet: Pet,
        mood: PetMood,
        completedBlocks: Int,
        totalBlocks: Int,
        coinsToday: Int,
        nextBlockLabel: String?,
        scheduleBlocks: [TimeBlockDTO]
    ) {
        let petDTO = PetDTO(
            name: pet.name,
            color: pet.colorRaw,
            mood: mood.rawValue,
            accessoryIDs: pet.accessoryIDs
        )

        let dayProgress = WidgetDayProgress(
            completedBlocks: completedBlocks,
            totalBlocks: totalBlocks,
            coinsToday: coinsToday,
            nextBlockLabel: nextBlockLabel,
            date: Date.now
        )

        if let petJSON = try? JSONEncoder().encode(petDTO) {
            defaults?.set(petJSON, forKey: Keys.petData)
        }
        if let progressJSON = try? JSONEncoder().encode(dayProgress) {
            defaults?.set(progressJSON, forKey: Keys.dayProgress)
        }
        defaults?.set(Date.now, forKey: Keys.lastUpdate)
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
}

struct WidgetDayProgress: Codable {
    let completedBlocks: Int
    let totalBlocks: Int
    let coinsToday: Int
    let nextBlockLabel: String?
    let date: Date

    var completionFraction: String {
        "\(completedBlocks)/\(totalBlocks)"
    }

    var completionRate: Double {
        guard totalBlocks > 0 else { return 0 }
        return Double(completedBlocks) / Double(totalBlocks)
    }
}
