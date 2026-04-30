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

    // MARK: - Widget Activity Mapping
    //
    // The widget reads (RoomType, PetActivity) from the App Group and renders
    // the matching pre-baked snapshot. These mappings drive that pipeline.
    // See `docs/WIDGET_SPEC.md` for the full source-of-truth table.

    /// Which scene the widget renders when this category's block is active.
    var sceneRoomType: RoomType {
        switch self {
        case .work, .learning, .creative: return .study
        case .exercise: return .gym
        case .nutrition: return .kitchen
        case .social: return .coffeeShop
        case .wellness, .routine, .rest, .custom: return .bedroom
        }
    }

    /// Which character pose the widget shows when this category's block is active.
    var sceneActivity: PetActivity {
        switch self {
        case .work, .creative: return .working
        case .learning: return .reading
        case .exercise: return .stretching
        case .nutrition: return .eating
        case .social: return .slacking
        case .rest: return .sleeping
        case .wellness, .routine, .custom: return .idling
        }
    }
}

// MARK: - Default scene fallback

extension BlockCategory? {
    /// Scene + pose to render when no block is active (or input is nil).
    /// After-hours / pre-wake also routes through here in `WidgetDataService`.
    static var widgetDefaultScene: RoomType { .bedroom }
    static var widgetDefaultActivity: PetActivity { .idling }
}
