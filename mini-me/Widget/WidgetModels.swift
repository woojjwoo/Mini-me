import Foundation
import SwiftUI

enum PetMood: String, Codable {
    case sleeping, happy, neutral, bored, sad, celebrating, focused, eating, walking
}

enum PetColor: String, Codable, CaseIterable, Identifiable {
    case orangeTabby, black, white
    var id: String { rawValue }
}

struct PetDTO: Codable {
    let name: String
    let color: String
    let mood: String
    let accessoryIDs: [String]
    let equippedOutfitIDs: [String]
}

struct WidgetDayProgress: Codable {
    let completedBlocks: Int
    let totalBlocks: Int
    let coinsToday: Int
    let nextBlockLabel: String?
    let currentTaskName: String?
    let currentCategory: String?
    let date: Date

    var completionRate: Double {
        guard totalBlocks > 0 else { return 0 }
        return Double(completedBlocks) / Double(totalBlocks)
    }
}

final class WidgetDataService {
    static let shared = WidgetDataService()
    static let appGroupID = "group.com.woojjwoo.pixieme.shared"
    private let defaults: UserDefaults?

    private init() {
        defaults = UserDefaults(suiteName: Self.appGroupID)
    }

    func readPetData() -> PetDTO? {
        guard let data = defaults?.data(forKey: "widget_pet_data") else { return nil }
        return try? JSONDecoder().decode(PetDTO.self, from: data)
    }

    func readDayProgress() -> WidgetDayProgress? {
        guard let data = defaults?.data(forKey: "widget_day_progress") else { return nil }
        return try? JSONDecoder().decode(WidgetDayProgress.self, from: data)
    }
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 6: (a, r, g, b) = (255, (int >> 16) & 0xFF, (int >> 8) & 0xFF, int & 0xFF)
        case 8: (a, r, g, b) = ((int >> 24) & 0xFF, (int >> 16) & 0xFF, (int >> 8) & 0xFF, int & 0xFF)
        default: (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(.sRGB, red: Double(r) / 255, green: Double(g) / 255, blue: Double(b) / 255, opacity: Double(a) / 255)
    }
}
