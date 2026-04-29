import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var players: [Player]

    var body: some View {
        if let player = players.first, player.hasCompletedOnboarding {
            MainTabView()
        } else {
            OnboardingView()
        }
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
