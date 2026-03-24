import Foundation
import EventKit

/// Optional calendar sync — imports calendar events as temporary schedule blocks
@Observable
final class CalendarSyncService {
    private let eventStore = EKEventStore()
    private(set) var isAuthorized = false

    // MARK: - Permission

    func requestAccess() async -> Bool {
        do {
            let granted = try await eventStore.requestFullAccessToEvents()
            isAuthorized = granted
            return granted
        } catch {
            isAuthorized = false
            return false
        }
    }

    func checkAuthorizationStatus() -> EKAuthorizationStatus {
        EKEventStore.authorizationStatus(for: .event)
    }

    // MARK: - Fetch Today's Events

    func fetchTodayEvents() -> [CalendarEvent] {
        guard checkAuthorizationStatus() == .fullAccess else { return [] }

        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: .now)
        guard let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay) else {
            return []
        }

        let predicate = eventStore.predicateForEvents(
            withStart: startOfDay,
            end: endOfDay,
            calendars: nil
        )
        let events = eventStore.events(matching: predicate)

        return events.compactMap { event -> CalendarEvent? in
            guard !event.isAllDay else { return nil }
            let startHour = calendar.component(.hour, from: event.startDate)
            let startMinute = calendar.component(.minute, from: event.startDate)
            let durationMinutes = Int(event.endDate.timeIntervalSince(event.startDate) / 60)

            return CalendarEvent(
                id: event.eventIdentifier,
                title: event.title ?? "Event",
                startHour: startHour,
                startMinute: startMinute,
                durationMinutes: max(durationMinutes, 15),
                calendarColor: event.calendar.cgColor
            )
        }
        .sorted { ($0.startHour * 60 + $0.startMinute) < ($1.startHour * 60 + $1.startMinute) }
    }

    // MARK: - Convert to TimeBlocks

    func calendarEventsAsBlocks() -> [(category: BlockCategory, label: String, startHour: Int, startMinute: Int, duration: Int)] {
        let events = fetchTodayEvents()
        return events.map { event in
            let category = guessCategory(from: event.title)
            return (
                category: category,
                label: event.title,
                startHour: event.startHour,
                startMinute: event.startMinute,
                duration: min(event.durationMinutes, 120)
            )
        }
    }

    /// Best-effort category guess from event title
    private func guessCategory(from title: String) -> BlockCategory {
        let lower = title.lowercased()
        if lower.contains("gym") || lower.contains("workout") || lower.contains("run") || lower.contains("yoga") {
            return .exercise
        }
        if lower.contains("study") || lower.contains("class") || lower.contains("lecture") || lower.contains("exam") {
            return .learning
        }
        if lower.contains("meeting") || lower.contains("standup") || lower.contains("work") || lower.contains("office") {
            return .work
        }
        if lower.contains("lunch") || lower.contains("dinner") || lower.contains("breakfast") || lower.contains("eat") {
            return .nutrition
        }
        if lower.contains("doctor") || lower.contains("dentist") || lower.contains("therapy") || lower.contains("appointment") {
            return .wellness
        }
        if lower.contains("friend") || lower.contains("party") || lower.contains("hangout") || lower.contains("date") {
            return .social
        }
        if lower.contains("paint") || lower.contains("music") || lower.contains("art") || lower.contains("write") {
            return .creative
        }
        return .custom
    }
}

struct CalendarEvent: Identifiable {
    let id: String
    let title: String
    let startHour: Int
    let startMinute: Int
    let durationMinutes: Int
    let calendarColor: CGColor?

    var startTimeString: String {
        let hour = startHour % 12 == 0 ? 12 : startHour % 12
        let period = startHour < 12 ? "AM" : "PM"
        return "\(hour):\(String(format: "%02d", startMinute)) \(period)"
    }
}
