import ActivityKit
import SwiftUI

// MARK: - Attributes declaration (main app copy)
// Must structurally match MiniMeActivityAttributes in MiniMeWidgetLiveActivity.swift.
// ActivityKit serialises both sides as Codable — identical field names ensure
// the same JSON is produced, so the system can bridge app ↔ widget correctly.

struct MiniMeActivityAttributes: ActivityAttributes {
    let petName: String
    let blockLabel: String
    let category: String

    public struct ContentState: Codable, Hashable {
        var sceneRaw: String
        var activityRaw: String
        var minutesRemaining: Int
        var completedBlocks: Int
        var totalBlocks: Int
    }
}

// MARK: - Service

/// Manages the lifecycle of the Pixie Me Live Activity.
/// One activity at a time: starting when a block becomes active,
/// updating on progress, ending when the block ends or is completed.
@MainActor
final class LiveActivityService {
    static let shared = LiveActivityService()
    private init() {}

    private var currentActivity: Activity<MiniMeActivityAttributes>?

    // MARK: Start

    /// Start a Live Activity for the currently active block.
    /// No-op if Live Activities are disabled by the user or unsupported.
    func startActivity(
        petName: String,
        blockLabel: String,
        category: BlockCategory,
        completedBlocks: Int,
        totalBlocks: Int
    ) {
        guard ActivityAuthorizationInfo().areActivitiesEnabled else { return }
        // End any stale activity first (e.g. previous block's)
        endActivity()

        let now = Date()
        let hour = Calendar.current.component(.hour, from: now)
        let minute = Calendar.current.component(.minute, from: now)

        let attributes = MiniMeActivityAttributes(
            petName: petName,
            blockLabel: blockLabel,
            category: category.rawValue
        )
        let state = MiniMeActivityAttributes.ContentState(
            sceneRaw:         category.sceneRoomType.rawValue,
            activityRaw:      category.sceneActivity.rawValue,
            minutesRemaining: 60,  // default; caller can update immediately
            completedBlocks:  completedBlocks,
            totalBlocks:      totalBlocks
        )
        do {
            currentActivity = try Activity.request(
                attributes: attributes,
                content: .init(state: state, staleDate: nil),
                pushType: nil
            )
        } catch {
            // Activity rejected (e.g. already 5 running, device not supported)
            #if DEBUG
            print("[LiveActivity] start failed: \(error.localizedDescription)")
            #endif
        }
    }

    // MARK: Update

    func updateActivity(
        category: BlockCategory,
        minutesRemaining: Int,
        completedBlocks: Int,
        totalBlocks: Int
    ) {
        guard let activity = currentActivity else { return }
        let state = MiniMeActivityAttributes.ContentState(
            sceneRaw:         category.sceneRoomType.rawValue,
            activityRaw:      category.sceneActivity.rawValue,
            minutesRemaining: max(0, minutesRemaining),
            completedBlocks:  completedBlocks,
            totalBlocks:      totalBlocks
        )
        Task {
            await activity.update(.init(state: state, staleDate: nil))
        }
    }

    // MARK: End

    func endActivity() {
        guard let activity = currentActivity else { return }
        Task {
            await activity.end(nil, dismissalPolicy: .immediate)
        }
        currentActivity = nil
    }

    // MARK: Convenience — call from updateWidget() in DailyScheduleView

    /// Inspects the active block right now and starts/updates/ends accordingly.
    /// Safe to call any time (foreground, block completion, etc.).
    func sync(
        petName: String,
        schedule: DailySchedule,
        completedBlocks: Int,
        totalBlocks: Int
    ) {
        guard ActivityAuthorizationInfo().areActivitiesEnabled else { return }

        let now = Date()
        let hour   = Calendar.current.component(.hour,   from: now)
        let minute = Calendar.current.component(.minute, from: now)
        let currentMinutes = hour * 60 + minute

        // Find the block currently in progress
        let activeBlock = schedule.sortedBlocks.first { block in
            let start = block.startHour * 60 + block.startMinute
            let end   = start + block.durationMinutes
            return currentMinutes >= start && currentMinutes < end
        }

        guard let block = activeBlock else {
            // No block active right now — end any running activity
            endActivity()
            return
        }

        let blockEnd = block.startHour * 60 + block.startMinute + block.durationMinutes
        let remaining = max(0, blockEnd - currentMinutes)

        if currentActivity != nil {
            // Already running — just update the state
            updateActivity(
                category:        block.blockCategory,
                minutesRemaining: remaining,
                completedBlocks:  completedBlocks,
                totalBlocks:      totalBlocks
            )
        } else {
            // Start fresh for this block
            startActivity(
                petName:         petName,
                blockLabel:      block.label,
                category:        block.blockCategory,
                completedBlocks: completedBlocks,
                totalBlocks:     totalBlocks
            )
            // Immediately push the real minutesRemaining
            updateActivity(
                category:        block.blockCategory,
                minutesRemaining: remaining,
                completedBlocks:  completedBlocks,
                totalBlocks:      totalBlocks
            )
        }
    }
}
