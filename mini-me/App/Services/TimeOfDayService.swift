import Foundation
import SwiftUI
import Observation

/// Determines the current time of day for lighting and ambient effects in the Diorama.
enum TimeOfDay {
    case morning
    case day
    case sunset
    case night
    
    var overlayColor: Color {
        switch self {
        case .morning: return Color.orange.opacity(0.1)
        case .day: return Color.clear
        case .sunset: return Color.red.opacity(0.15)
        case .night: return Color.indigo.opacity(0.3)
        }
    }
}

@Observable
final class TimeOfDayService {
    
    var currentTimeOfDay: TimeOfDay = .day
    private var timer: Timer?
    
    init() {
        updateTimeOfDay()
        startTimer()
    }
    
    deinit {
        timer?.invalidate()
    }
    
    private func startTimer() {
        // Check every minute if the time of day phase has changed
        timer = Timer.scheduledTimer(withTimeInterval: 60.0, repeats: true) { [weak self] _ in
            self?.updateTimeOfDay()
        }
    }
    
    func updateTimeOfDay() {
        let hour = Calendar.current.component(.hour, from: .now)
        let newPhase = TimeOfDayService.phase(forHour: hour)
        if newPhase != currentTimeOfDay {
            currentTimeOfDay = newPhase
        }
    }

    static func phase(forHour hour: Int) -> TimeOfDay {
        switch hour {
        case 6..<10: return .morning
        case 10..<17: return .day
        case 17..<19: return .sunset
        default:      return .night
        }
    }
}
