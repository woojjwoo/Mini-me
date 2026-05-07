import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.scenePhase) private var scenePhase
    @Query private var players: [Player]
    @Query private var schedules: [DailySchedule]
    @Query private var pets: [Pet]
    @Query private var rooms: [Room]
    @Query(sort: \DayLog.date, order: .reverse) private var dayLogs: [DayLog]

    /// Shown once after onboarding to prompt the user to add the home-screen widget.
    @AppStorage("hasSeenWidgetPrompt") private var hasSeenWidgetPrompt = false
    @State private var showWidgetPrompt = false

    var body: some View {
        Group {
            if let player = players.first, player.hasCompletedOnboarding {
                MainTabView()
                    .onAppear {
                        // Delay slightly so the tab view settles before sheet appears
                        guard !hasSeenWidgetPrompt else { return }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                            showWidgetPrompt = true
                        }
                    }
            } else {
                OnboardingView()
            }
        }
        .sheet(isPresented: $showWidgetPrompt) {
            AddWidgetPromptView {
                hasSeenWidgetPrompt = true
                showWidgetPrompt = false
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
            syncLiveActivityIfPossible()
            pushScheduleToWidgetIfPossible()
            // Resume lo-fi music if enabled — the service paused on background.
            if UserDefaults.standard.bool(forKey: AmbientAudioService.userDefaultsKey) {
                AmbientAudioService.shared.startPlayback()
            }
            // Refresh friend presence list on foreground. Own presence is
            // republished by pushScheduleToWidgetIfPossible() above (it calls
            // updateWidgetData which now also calls publishPresence).
            FriendPresenceService.shared.refreshFriends()
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

    /// Sync the Live Activity to the current active block when foregrounding.
    @MainActor
    private func syncLiveActivityIfPossible() {
        let isWeekday = !Calendar.current.isDateInWeekend(.now)
        guard
            let pet = pets.first,
            let schedule = schedules.first(where: { $0.isWeekday == isWeekday }) ?? schedules.first
        else { return }

        // Look up today's actual completed block count from the DayLog store
        let today = Calendar.current.startOfDay(for: .now)
        let completedCount = dayLogs
            .first(where: { Calendar.current.isDate($0.date, inSameDayAs: today) })?
            .completedBlockIDs.count ?? 0

        LiveActivityService.shared.sync(
            petName:         pet.name,
            schedule:        schedule,
            completedBlocks: completedCount,
            totalBlocks:     schedule.blocks.count
        )
    }

    /// Push the current schedule blocks + active scene to the App Group on
    /// every foreground so the widget always reflects the right day's blocks
    /// even when the user hasn't touched the Today tab yet.
    @MainActor
    private func pushScheduleToWidgetIfPossible() {
        let isWeekday = !Calendar.current.isDateInWeekend(.now)
        guard
            let pet = pets.first,
            let schedule = schedules.first(where: { $0.isWeekday == isWeekday }) ?? schedules.first
        else { return }

        let today = Calendar.current.startOfDay(for: .now)
        let completedCount = dayLogs
            .first(where: { Calendar.current.isDate($0.date, inSameDayAs: today) })?
            .completedBlockIDs.count ?? 0

        let now = Date()
        let currentMinutes = Calendar.current.component(.hour, from: now) * 60
            + Calendar.current.component(.minute, from: now)
        let currentBlock = schedule.sortedBlocks.first { block in
            let start = block.startHour * 60 + block.startMinute
            let end   = start + block.durationMinutes
            return currentMinutes >= start && currentMinutes < end
        }

        let moodService = PetMoodService()
        let mood = moodService.currentMood(
            completedBlocks: completedCount,
            totalBlocks: schedule.blocks.count,
            wakeUpHour: schedule.sortedBlocks.first?.startHour ?? 7,
            lastCompletionDate: .now,
            manualStatus: nil,
            currentActivity: currentBlock?.category
        )

        WidgetDataService.shared.updateWidgetData(
            pet: pet,
            mood: mood,
            completedBlocks: completedCount,
            totalBlocks: schedule.blocks.count,
            coinsToday: dayLogs.first(where: {
                Calendar.current.isDate($0.date, inSameDayAs: today)
            })?.totalCoins ?? 0,
            nextBlockLabel: nil,
            currentTaskName: currentBlock?.label,
            currentCategory: currentBlock?.category,
            scheduleBlocks: schedule.sortedBlocks.map { TimeBlockDTO(from: $0) }
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

            MemoriesView()
                .tabItem {
                    Image(systemName: "sparkles")
                    Text("Memories")
                }
                .tag(3)

            YouView()
                .tabItem {
                    Image(systemName: "person.crop.circle")
                    Text("You")
                }
                .tag(4)
        }
        .tint(PixelTheme.primary)
        // Handle deep links from widget taps (e.g. pixieme://today, pixieme://room)
        .onOpenURL { url in
            guard url.scheme == "pixieme" else { return }
            switch url.host {
            case "today": selectedTab = 0
            case "room":  selectedTab = 1
            case "shop":  selectedTab = 2
            case "you":   selectedTab = 3
            default:      selectedTab = 0
            }
        }
    }
}
