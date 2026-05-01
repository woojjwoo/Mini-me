import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.scenePhase) private var scenePhase
    @Query private var players: [Player]
    @Query private var schedules: [DailySchedule]
    @Query private var pets: [Pet]
    @Query private var rooms: [Room]

    var body: some View {
        Group {
            if let player = players.first, player.hasCompletedOnboarding {
                MainTabView()
            } else {
                OnboardingView()
            }
        }
        .onChange(of: scenePhase) { _, newPhase in
            // Re-bake widget snapshots when the app comes back to foreground.
            // Cases this catches:
            //   - User opens app after a day rollover (schedule's "today" may
            //     differ from "yesterday" if weekday/weekend differs)
            //   - User edited their schedule via Shortcuts/widget config
            //   - User force-quit the app and reopened
            //   - First open of the day where pre-bake hash is stale
            // The bakery's hash dedup makes this near-free when nothing has
            // structurally changed.
            guard newPhase == .active else { return }
            triggerBakeIfPossible()
        }
    }

    /// Resolve the active (schedule, pet, room) trio and fire a hash-deduped
    /// pre-bake. Silently no-ops if any piece is missing (e.g. user is mid-
    /// onboarding and not yet ready for widgets).
    @MainActor
    private func triggerBakeIfPossible() {
        let isWeekday = !Calendar.current.isDateInWeekend(.now)
        guard
            let pet = pets.first,
            let room = rooms.first(where: { $0.isActive }) ?? rooms.first,
            let schedule = schedules.first(where: { $0.isWeekday == isWeekday })
                ?? schedules.first
        else { return }

        WidgetDataService.shared.triggerBakeIfScheduleChanged(
            schedule: schedule,
            pet: pet,
            room: room
        )
    }
}

struct MainTabView: View {
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            DailyScheduleView()
                .tabItem {
                    Image(systemName: "calendar.badge.checkmark")
                    Text("Today")
                }
                .tag(0)

            IsometricRoomView()
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Room")
                }
                .tag(1)

            ShopView()
                .tabItem {
                    Image(systemName: "bag.fill")
                    Text("Shop")
                }
                .tag(2)

            YouView()
                .tabItem {
                    Image(systemName: "person.crop.circle")
                    Text("You")
                }
                .tag(3)
        }
        .tint(PixelTheme.primary)
    }
}
