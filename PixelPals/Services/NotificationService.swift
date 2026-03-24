import Foundation
import UserNotifications

final class NotificationService {
    static let shared = NotificationService()

    private init() {}

    // MARK: - Permission

    func requestPermission() async -> Bool {
        do {
            return try await UNUserNotificationCenter.current()
                .requestAuthorization(options: [.alert, .badge, .sound])
        } catch {
            return false
        }
    }

    func isAuthorized() async -> Bool {
        let settings = await UNUserNotificationCenter.current().notificationSettings()
        return settings.authorizationStatus == .authorized
    }

    // MARK: - Schedule Block Reminders

    func scheduleBlockReminders(blocks: [TimeBlockDTO], petName: String) {
        // Remove old block reminders
        UNUserNotificationCenter.current().removePendingNotificationRequests(
            withIdentifiers: blocks.map { "block_\($0.id.uuidString)" }
        )

        for block in blocks {
            let content = UNMutableNotificationContent()
            content.title = "Time for \(block.label)!"
            content.body = "\(petName) is ready. Let's do this!"
            content.sound = .default
            content.categoryIdentifier = "BLOCK_REMINDER"

            // Schedule 5 minutes before block start
            var dateComponents = DateComponents()
            var reminderMinute = block.startMinute - 5
            var reminderHour = block.startHour
            if reminderMinute < 0 {
                reminderMinute += 60
                reminderHour -= 1
            }
            dateComponents.hour = reminderHour
            dateComponents.minute = reminderMinute

            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
            let request = UNNotificationRequest(
                identifier: "block_\(block.id.uuidString)",
                content: content,
                trigger: trigger
            )
            UNUserNotificationCenter.current().add(request)
        }
    }

    // MARK: - Streak Warning

    func scheduleStreakWarning(currentStreak: Int, petName: String) {
        guard currentStreak > 0 else { return }

        UNUserNotificationCenter.current().removePendingNotificationRequests(
            withIdentifiers: ["streak_warning"]
        )

        let content = UNMutableNotificationContent()
        content.title = "Don't break your \(currentStreak)-day streak!"
        content.body = "\(petName) believes in you. Complete one more block today."
        content.sound = .default
        content.categoryIdentifier = "STREAK_WARNING"

        // Fire at 8pm if no completion today
        var dateComponents = DateComponents()
        dateComponents.hour = 20
        dateComponents.minute = 0

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        let request = UNNotificationRequest(
            identifier: "streak_warning",
            content: content,
            trigger: trigger
        )
        UNUserNotificationCenter.current().add(request)
    }

    // MARK: - Mid-Day Nudge

    func scheduleMidDayNudge(completedCount: Int, totalCount: Int, petName: String) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(
            withIdentifiers: ["midday_nudge"]
        )

        let content = UNMutableNotificationContent()
        content.title = "Halfway check-in"
        content.body = "You've completed \(completedCount)/\(totalCount) blocks today. \(petName) is rooting for you!"
        content.sound = .default

        var dateComponents = DateComponents()
        dateComponents.hour = 14
        dateComponents.minute = 0

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        let request = UNNotificationRequest(
            identifier: "midday_nudge",
            content: content,
            trigger: trigger
        )
        UNUserNotificationCenter.current().add(request)
    }

    // MARK: - Morning Greeting

    func scheduleMorningGreeting(wakeUpHour: Int, petName: String) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(
            withIdentifiers: ["morning_greeting"]
        )

        let content = UNMutableNotificationContent()
        content.title = "Good morning!"
        content.body = "\(petName) is awake and ready to start the day with you."
        content.sound = .default

        var dateComponents = DateComponents()
        dateComponents.hour = wakeUpHour
        dateComponents.minute = 0

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(
            identifier: "morning_greeting",
            content: content,
            trigger: trigger
        )
        UNUserNotificationCenter.current().add(request)
    }

    // MARK: - Cancel All

    func cancelAllNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
}
