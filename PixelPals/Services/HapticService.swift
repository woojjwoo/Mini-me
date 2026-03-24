import SwiftUI

#if canImport(UIKit)
import UIKit
#endif

/// Centralized haptic feedback for the app
enum HapticService {

    /// Light tap — used for toggling, selecting items
    static func light() {
        #if os(iOS)
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        #endif
    }

    /// Medium tap — used for completing a block, purchasing an item
    static func medium() {
        #if os(iOS)
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        #endif
    }

    /// Heavy tap — used for major milestones (perfect day, streak bonus)
    static func heavy() {
        #if os(iOS)
        UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
        #endif
    }

    /// Success notification — block completed, purchase confirmed
    static func success() {
        #if os(iOS)
        UINotificationFeedbackGenerator().notificationOccurred(.success)
        #endif
    }

    /// Warning notification — streak at risk
    static func warning() {
        #if os(iOS)
        UINotificationFeedbackGenerator().notificationOccurred(.warning)
        #endif
    }

    /// Error notification — can't afford, invalid action
    static func error() {
        #if os(iOS)
        UINotificationFeedbackGenerator().notificationOccurred(.error)
        #endif
    }

    /// Selection changed — picker wheels, tab switching
    static func selection() {
        #if os(iOS)
        UISelectionFeedbackGenerator().selectionChanged()
        #endif
    }
}
