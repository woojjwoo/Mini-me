import Foundation
import SwiftUI

enum BlockCategory: String, Codable, CaseIterable, Identifiable {
    case wellness
    case exercise
    case nutrition
    case learning
    case creative
    case work
    case social
    case rest
    case routine
    case custom

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .wellness: "Wellness"
        case .exercise: "Exercise"
        case .nutrition: "Nutrition"
        case .learning: "Learning"
        case .creative: "Creative"
        case .work: "Work"
        case .social: "Social"
        case .rest: "Rest"
        case .routine: "Routine"
        case .custom: "Custom"
        }
    }

    var icon: String {
        switch self {
        case .wellness: "sparkles"
        case .exercise: "figure.run"
        case .nutrition: "fork.knife"
        case .learning: "book.fill"
        case .creative: "paintbrush.fill"
        case .work: "briefcase.fill"
        case .social: "person.2.fill"
        case .rest: "moon.fill"
        case .routine: "arrow.triangle.2.circlepath"
        case .custom: "star.fill"
        }
    }

    var color: Color {
        switch self {
        case .wellness: Color(hex: "A8D8B9")
        case .exercise: Color(hex: "FF8A80")
        case .nutrition: Color(hex: "FFD180")
        case .learning: Color(hex: "82B1FF")
        case .creative: Color(hex: "EA80FC")
        case .work: Color(hex: "8C9EFF")
        case .social: Color(hex: "FFD740")
        case .rest: Color(hex: "B388FF")
        case .routine: Color(hex: "84FFFF")
        case .custom: Color(hex: "CCFF90")
        }
    }
}
