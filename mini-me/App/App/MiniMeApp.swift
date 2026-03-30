import SwiftUI
import SwiftData

@main
struct MiniMeApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: [
            Player.self,
            Pet.self,
            Room.self,
            RoomSlotAssignment.self,
            DailySchedule.self,
            TimeBlock.self,
            DayLog.self,
        ])
    }
}
