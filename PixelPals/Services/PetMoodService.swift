import Foundation

@Observable
final class PetMoodService {
    private let calendar = Calendar.current

    /// Determine pet mood based on current state
    func currentMood(
        completedBlocks: Int,
        totalBlocks: Int,
        wakeUpHour: Int,
        lastCompletionDate: Date?
    ) -> PetMood {
        let now = Date.now
        let hour = calendar.component(.hour, from: now)

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
