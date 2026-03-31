import Foundation
import UIKit

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

    func saveRoomSnapshot(_ image: UIImage) {
        guard let data = image.pngData(),
              let container = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: Self.appGroupID) else {
            return
        }
        
        let fileURL = container.appendingPathComponent("room_diorama.png")
        try? data.write(to: fileURL)
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
