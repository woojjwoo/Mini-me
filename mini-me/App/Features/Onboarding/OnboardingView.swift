import SwiftUI
import SwiftData

struct OnboardingView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var currentStep = 0
    @State private var wakeUpHour = 7
    @State private var wakeUpMinute = 0
    @State private var morningBlocks: [OnboardingBlock] = []
    @State private var afternoonBlocks: [OnboardingBlock] = []
    @State private var eveningBlocks: [OnboardingBlock] = []
    @State private var petName = ""
    @State private var petColor: PetColor = .orangeTabby

    private let totalSteps = 6

    var body: some View {
        ZStack {
            PixelTheme.background.ignoresSafeArea()

            VStack(spacing: 0) {
                // Progress dots
                HStack(spacing: 8) {
                    ForEach(0..<totalSteps, id: \.self) { step in
                        Circle()
                            .fill(step <= currentStep ? PixelTheme.primary : PixelTheme.pending)
                            .frame(width: 8, height: 8)
                    }
                }
                .padding(.top, 20)
                .padding(.bottom, 30)

                // Step content
                TabView(selection: $currentStep) {
                    WelcomeStep(onNext: nextStep)
                        .tag(0)

                    WakeUpStep(hour: $wakeUpHour, minute: $wakeUpMinute, onNext: nextStep)
                        .tag(1)

                    BlockPickerStep(
                        title: "What does your morning look like?",
                        subtitle: "Pick the blocks that fit your ideal morning",
                        selectedBlocks: $morningBlocks,
                        suggestedCategories: [.routine, .exercise, .wellness, .nutrition, .learning],
                        onNext: nextStep
                    )
                    .tag(2)

                    BlockPickerStep(
                        title: "What about your afternoon?",
                        subtitle: "Fill in your productive hours",
                        selectedBlocks: $afternoonBlocks,
                        suggestedCategories: [.work, .learning, .creative, .nutrition, .social],
                        onNext: nextStep
                    )
                    .tag(3)

                    BlockPickerStep(
                        title: "And your evening?",
                        subtitle: "Wind down your ideal day",
                        selectedBlocks: $eveningBlocks,
                        suggestedCategories: [.nutrition, .social, .creative, .rest, .routine],
                        onNext: nextStep
                    )
                    .tag(4)

                    PetSetupStep(
                        petName: $petName,
                        petColor: $petColor,
                        onFinish: completeOnboarding
                    )
                    .tag(5)
                }
                #if os(iOS)
                .tabViewStyle(.page(indexDisplayMode: .never))
                #endif
                .animation(.easeInOut(duration: 0.3), value: currentStep)
            }
        }
    }

    private func nextStep() {
        if currentStep < totalSteps - 1 {
            currentStep += 1
        }
    }

    private func completeOnboarding() {
        // Create schedule from selected blocks
        let schedule = DailySchedule(isWeekday: true, name: "Weekday")
        var sortOrder = 0
        var currentHour = wakeUpHour
        var currentMinute = wakeUpMinute

        func addBlocks(_ blocks: [OnboardingBlock]) {
            for block in blocks {
                let timeBlock = TimeBlock(
                    category: block.category,
                    label: block.label,
                    startHour: currentHour,
                    startMinute: currentMinute,
                    durationMinutes: block.duration,
                    sortOrder: sortOrder
                )
                schedule.blocks.append(timeBlock)
                sortOrder += 1
                currentMinute += block.duration
                while currentMinute >= 60 {
                    currentMinute -= 60
                    currentHour += 1
                }
            }
        }

        addBlocks(morningBlocks)
        addBlocks(afternoonBlocks)
        addBlocks(eveningBlocks)

        // Create player, pet, room
        let player = Player(hasCompletedOnboarding: true)
        let pet = Pet(name: petName.isEmpty ? "Pixel" : petName, color: petColor)
        let room = Room()

        // Create today's day log
        let dayLog = DayLog()

        modelContext.insert(schedule)
        modelContext.insert(player)
        modelContext.insert(pet)
        modelContext.insert(room)
        modelContext.insert(dayLog)

        try? modelContext.save()
    }
}

// MARK: - Onboarding Block (temporary, not persisted)

struct OnboardingBlock: Identifiable, Equatable {
    let id = UUID()
    let category: BlockCategory
    let label: String
    let duration: Int // minutes

    static func == (lhs: OnboardingBlock, rhs: OnboardingBlock) -> Bool {
        lhs.id == rhs.id
    }
}
