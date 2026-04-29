import SwiftUI

// MARK: - Step 1: Welcome

struct OnboardingWelcomeStep: View {
    let onNext: () -> Void
    @State private var spriteScale: CGFloat = 0.7
    @State private var spriteOpacity: Double = 0
    @State private var decorOpacity: Double = 0

    // Fixed decoration positions — scattered around character
    private let decorations: [(String, CGFloat, CGFloat, CGFloat)] = [
        ("⭐", -120, -60, 18),
        ("✨", 110, -40, 14),
        ("🌟", -90, 80, 16),
        ("⭐", 95, 100, 12),
        ("✨", -50, -120, 20),
        ("🌟", 60, -100, 15),
    ]

    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                Spacer()

                ZStack {
                    // Scattered backdrop decorations
                    ForEach(Array(decorations.enumerated()), id: \.offset) { i, d in
                        Text(d.0)
                            .font(.system(size: d.3))
                            .offset(x: d.1, y: d.2)
                            .opacity(decorOpacity * 0.18)
                    }

                    // Character art — large, centered
                    Group {
                        if UIImage(named: "minime_idle") != nil {
                            Image("minime_idle")
                                .resizable()
                                .interpolation(.none)
                                .scaledToFit()
                                .frame(width: 120, height: 200)
                        } else {
                            Text("🧑")
                                .font(.system(size: 100))
                        }
                    }
                    .scaleEffect(spriteScale)
                    .opacity(spriteOpacity)
                }
                .frame(height: 260)
                .onAppear {
                    withAnimation(.spring(response: 0.6, dampingFraction: 0.65)) {
                        spriteScale = 1.0
                        spriteOpacity = 1.0
                    }
                    withAnimation(.easeIn(duration: 0.8).delay(0.3)) {
                        decorOpacity = 1.0
                    }
                }

                Spacer().frame(height: 32)

                VStack(spacing: 12) {
                    Text("Your pixel life\nstarts here.")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundColor(PixelTheme.text)
                        .multilineTextAlignment(.center)

                    Text("Build a routine. Grow your room.\nBecome your best Mini Me.")
                        .font(PixelTheme.bodyFont)
                        .foregroundColor(PixelTheme.text.opacity(0.6))
                        .multilineTextAlignment(.center)
                }
                .padding(.horizontal, 32)

                Spacer()

                OnboardingButton(title: "Let's Go →", action: onNext)
                    .padding(.bottom, 48)
            }
        }
    }
}

// MARK: - Step 2: Name

struct OnboardingNameStep: View {
    @Binding var petName: String
    let onNext: () -> Void
    @FocusState private var focused: Bool
    @State private var bobPhase = false

    private var displayName: String {
        petName.trimmingCharacters(in: .whitespaces).isEmpty ? "Pixel" : petName
    }

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            // Character + speech bubble
            ZStack(alignment: .topTrailing) {
                Group {
                    if UIImage(named: "minime_idle") != nil {
                        Image("minime_idle")
                            .resizable()
                            .interpolation(.none)
                            .scaledToFit()
                            .frame(width: 80, height: 133)
                    } else {
                        Text("🧑").font(.system(size: 70))
                    }
                }
                .offset(y: bobPhase ? -4 : 0)
                .onAppear {
                    withAnimation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true)) {
                        bobPhase = true
                    }
                }

                // Speech bubble
                Text("Hi, I'm \(displayName)!")
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundColor(PixelTheme.text)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(PixelTheme.cardBackground)
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(PixelTheme.cardBorder, lineWidth: 1)
                    )
                    .shadow(color: PixelTheme.shadowColor, radius: 4, y: 2)
                    .offset(x: 100, y: -20)
                    .fixedSize()
            }
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 80)
            .animation(.spring(response: 0.3), value: displayName)

            Spacer().frame(height: 48)

            VStack(spacing: 16) {
                Text("What should I\ncall you?")
                    .font(.system(size: 26, weight: .bold, design: .rounded))
                    .foregroundColor(PixelTheme.text)
                    .multilineTextAlignment(.center)

                TextField("Your name...", text: $petName)
                    .font(.system(size: 22, weight: .medium, design: .rounded))
                    .multilineTextAlignment(.center)
                    .foregroundColor(PixelTheme.text)
                    .padding(.vertical, 16)
                    .background(Color.clear)
                    .overlay(
                        Rectangle()
                            .fill(PixelTheme.primary.opacity(0.4))
                            .frame(height: 2),
                        alignment: .bottom
                    )
                    .padding(.horizontal, 40)
                    .focused($focused)
            }

            Spacer()

            OnboardingButton(title: "Continue", action: onNext)
                .padding(.bottom, 48)
        }
        .padding(.horizontal, 24)
        .onAppear { focused = true }
    }
}

// MARK: - Step 3: Wake Time (horizontal snap scroll)

struct OnboardingWakeStep: View {
    @Binding var wakeUpHour: Int
    let onNext: () -> Void

    private let hours = Array(4...11) // 4am–11am

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            VStack(spacing: 16) {
                Text("When do you\nwake up?")
                    .font(.system(size: 26, weight: .bold, design: .rounded))
                    .foregroundColor(PixelTheme.text)
                    .multilineTextAlignment(.center)

                Text("Set your ideal wake-up time.")
                    .font(PixelTheme.bodyFont)
                    .foregroundColor(PixelTheme.text.opacity(0.55))
            }
            .padding(.horizontal, 32)

            Spacer().frame(height: 48)

            // Horizontal hour snap scroll
            ScrollViewReader { proxy in
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 0) {
                        ForEach(hours, id: \.self) { hour in
                            let isSelected = hour == wakeUpHour
                            VStack(spacing: 6) {
                                Text(hourLabel(hour))
                                    .font(.system(size: isSelected ? 28 : 20, weight: isSelected ? .bold : .regular, design: .rounded))
                                    .foregroundColor(isSelected ? PixelTheme.text : PixelTheme.text.opacity(0.3))
                                    .scaleEffect(isSelected ? 1.0 : 0.85)

                                Circle()
                                    .fill(isSelected ? PixelTheme.primary : Color.clear)
                                    .frame(width: 6, height: 6)
                            }
                            .frame(width: 100)
                            .animation(.spring(response: 0.3), value: wakeUpHour)
                            .id(hour)
                            .onTapGesture {
                                HapticService.selection()
                                withAnimation(.spring(response: 0.3)) {
                                    wakeUpHour = hour
                                    proxy.scrollTo(hour, anchor: .center)
                                }
                            }
                        }
                    }
                    .padding(.vertical, 16)
                }
                .scrollTargetBehavior(.viewAligned)
                .onAppear {
                    proxy.scrollTo(wakeUpHour, anchor: .center)
                }
            }
            .frame(height: 80)

            Spacer()

            OnboardingButton(title: "Next", action: onNext)
                .padding(.bottom, 48)
        }
        .padding(.horizontal, 24)
    }

    private func hourLabel(_ hour: Int) -> String {
        let h = hour > 12 ? hour - 12 : hour
        let suffix = hour < 12 ? "am" : "pm"
        return "\(h)\(suffix)"
    }
}

// MARK: - Step 4: First Habit (single pick)

struct OnboardingHabitStep: View {
    @Binding var selectedCategory: BlockCategory?
    let petName: String
    let onFinish: () -> Void

    @State private var bounceCategory: BlockCategory? = nil

    private let displayName: String
    init(selectedCategory: Binding<BlockCategory?>, petName: String, onFinish: @escaping () -> Void) {
        self._selectedCategory = selectedCategory
        self.petName = petName
        self.onFinish = onFinish
        self.displayName = petName.trimmingCharacters(in: .whitespaces).isEmpty ? "Pixel" : petName
    }

    private let categories: [BlockCategory] = [
        .routine, .exercise, .wellness, .nutrition, .work, .learning, .creative, .social, .rest
    ]

    var body: some View {
        VStack(spacing: 0) {
            Spacer().frame(height: 32)

            VStack(spacing: 12) {
                Text("What's your\n#1 morning habit?")
                    .font(.system(size: 26, weight: .bold, design: .rounded))
                    .foregroundColor(PixelTheme.text)
                    .multilineTextAlignment(.center)

                Text("Pick one to start. You can add more later.")
                    .font(PixelTheme.captionFont)
                    .foregroundColor(PixelTheme.text.opacity(0.5))
            }
            .padding(.horizontal, 32)

            Spacer().frame(height: 32)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                ForEach(categories) { category in
                    let isSelected = selectedCategory == category

                    Button {
                        HapticService.selection()
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.55)) {
                            selectedCategory = category
                            bounceCategory = category
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                            bounceCategory = nil
                        }
                    } label: {
                        VStack(spacing: 10) {
                            Image(systemName: category.icon)
                                .font(.system(size: 28))
                                .foregroundColor(isSelected ? .white : category.color)
                            Text(category.displayName)
                                .font(.system(size: 13, weight: .semibold, design: .rounded))
                                .foregroundColor(isSelected ? .white : PixelTheme.text)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 20)
                        .background(isSelected ? category.color : PixelTheme.cardBackground)
                        .cornerRadius(14)
                        .overlay(
                            RoundedRectangle(cornerRadius: 14)
                                .stroke(isSelected ? Color.clear : PixelTheme.cardBorder, lineWidth: 1)
                        )
                        .shadow(color: isSelected ? category.color.opacity(0.5) : PixelTheme.shadowColor, radius: isSelected ? 12 : 2, y: isSelected ? 6 : 1)
                        .scaleEffect(bounceCategory == category ? 1.06 : 1.0)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 16)

            Spacer()

            OnboardingButton(
                title: selectedCategory != nil ? "Start! 🎉" : "Skip",
                action: onFinish
            )
            .padding(.bottom, 48)
        }
    }
}

// MARK: - Shared Button

struct OnboardingButton: View {
    let title: String
    let action: () -> Void

    var body: some View {
        Button {
            HapticService.medium()
            action()
        } label: {
            Text(title)
                .font(PixelTheme.headlineFont)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(PixelTheme.primary)
                .cornerRadius(16)
                .shadow(color: PixelTheme.primary.opacity(0.4), radius: 12, y: 6)
        }
        .padding(.horizontal, 24)
    }
}
