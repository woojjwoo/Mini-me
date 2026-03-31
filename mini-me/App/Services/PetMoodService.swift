import Foundation

@Observable
final class PetMoodService {
    private let calendar = Calendar.current

    /// Determine exact activity based on current block category
    func currentActivity(for category: String?) -> PetActivity {
        guard let category = category?.lowercased() else { return .idling }
        
        if category.contains("work") || category.contains("study") || category.contains("learn") {
            return .working
        }
        if category.contains("sleep") || category.contains("rest") || category.contains("nap") {
            return .sleeping
        }
        if category.contains("read") || category.contains("wellness") || category.contains("book") {
            return .reading
        }
        if category.contains("eat") || category.contains("meal") || category.contains("cooking") {
            return .eating
        }
        
        return .idling
    }

    /// Determine pet mood, respecting manual status overrides
    func currentMood(
        completedBlocks: Int,
        totalBlocks: Int,
        wakeUpHour: Int,
        lastCompletionDate: Date?,
        manualStatus: ManualStatus? = nil,
        currentActivity: String? = nil
    ) -> PetMood {
        // Manual status overrides all mood logic
        if let status = manualStatus {
            return status.moodOverride
        }

        let now = Date.now
        let hour = calendar.component(.hour, from: now)

        // Activity-based overrides
        if let activity = currentActivity?.lowercased() {
            if activity.contains("work") || activity.contains("study") || activity.contains("learning") {
                return .focused
            }
            if activity.contains("eat") || activity.contains("meal") || activity.contains("breakfast") || activity.contains("lunch") || activity.contains("dinner") {
                return .eating
            }
            if activity.contains("sleep") || activity.contains("nap") {
                return .sleeping
            }
        }

        // Sleeping: before wake-up time or after 11pm
        if hour < wakeUpHour || hour >= 23 {
            return .sleeping
        }

        let completionRate = totalBlocks > 0 ? Double(completedBlocks) / Double(totalBlocks) : 0

        // Celebrating: perfect day
        if completedBlocks == totalBlocks && totalBlocks > 0 {
            return .celebrating
        }

        // Sad: evening + low completion
        if hour >= 18 && completionRate < 0.3 {
            return .sad
        }

        // Bored: no blocks completed in 3+ hours
        if let lastCompletion = lastCompletionDate {
            let hoursSince = calendar.dateComponents([.hour], from: lastCompletion, to: now).hour ?? 0
            if hoursSince >= 3 {
                return .bored
            }
        } else if hour >= wakeUpHour + 3 && completedBlocks == 0 {
            // No completions at all and it's been 3+ hours since wake up
            return .bored
        }

        // Happy: recently completed something
        if completionRate >= 0.5 {
            return .happy
        }

        return .neutral
    }
}
