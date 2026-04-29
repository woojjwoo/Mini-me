import SwiftUI
import SwiftData

struct OnboardingView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var currentStep = 0
    @State private var petName = ""
    @State private var wakeUpHour = 7
    @State private var selectedCategory: BlockCategory? = nil

    private let totalSteps = 4

    var body: some View {
        ZStack {
            PixelTheme.background.ignoresSafeArea()

            switch currentStep {
            case 0:
                OnboardingWelcomeStep(onNext: { withAnimation(.easeInOut(duration: 0.35)) { currentStep = 1 } })
                    .transition(.asymmetric(insertion: .opacity, removal: .move(edge: .leading).combined(with: .opacity)))
            case 1:
                OnboardingNameStep(petName: $petName, onNext: { withAnimation(.easeInOut(duration: 0.35)) { currentStep = 2 } })
                    .transition(.asymmetric(insertion: .move(edge: .trailing).combined(with: .opacity), removal: .move(edge: .leading).combined(with: .opacity)))
            case 2:
                OnboardingWakeStep(wakeUpHour: $wakeUpHour, onNext: { withAnimation(.easeInOut(duration: 0.35)) { currentStep = 3 } })
                    .transition(.asymmetric(insertion: .move(edge: .trailing).combined(with: .opacity), removal: .move(edge: .leading).combined(with: .opacity)))
            case 3:
                OnboardingHabitStep(selectedCategory: $selectedCategory, petName: petName, onFinish: completeOnboarding)
                    .transition(.asymmetric(insertion: .move(edge: .trailing).combined(with: .opacity), removal: .opacity))
            default:
                EmptyView()
            }
        }
    }

    private func completeOnboarding() {
        let schedule = DailySchedule(isWeekday: true, name: "Weekday")

        if let category = selectedCategory {
            let block = TimeBlock(
                category: category,
                label: category.displayName,
                startHour: wakeUpHour,
                startMinute: 0,
                durationMinutes: 60,
                sortOrder: 0
            )
            schedule.blocks.append(block)
        }

        let player = Player(coins: 0, hasCompletedOnboarding: true)
        let pet = Pet(name: petName.trimmingCharacters(in: .whitespaces).isEmpty ? "Pixel" : petName)
        let room = Room()

        player.ownedItemIDs.append("mattress_floor")
        room.placeItem("mattress_floor", in: .bed)

        let dayLog = DayLog()

        modelContext.insert(schedule)
        modelContext.insert(player)
        modelContext.insert(pet)
        modelContext.insert(room)
        modelContext.insert(dayLog)

        do {
            try modelContext.save()
        } catch {
            print("❌ Onboarding save failed: \(error)")
        }
    }
}

// MARK: - Onboarding Block (temporary, not persisted)

struct OnboardingBlock: Identifiable, Equatable {
    let id = UUID()
    let category: BlockCategory
    let label: String
    let duration: Int

    static func == (lhs: OnboardingBlock, rhs: OnboardingBlock) -> Bool { lhs.id == rhs.id }
}
