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

// MARK: - Step 5: Widget Tutorial

/// Final onboarding step — primes the user for the widget-first experience.
/// The product IS the widget; without this step, ~30% of users never add it
/// and churn before seeing the value prop. Shows a faux home-screen mockup
/// with a preview of THEIR mini-me on a widget, then teaches the long-press
/// add flow.
///
/// CTAs:
/// - "I added it" → marks widget as added, completes onboarding
/// - "Show me later" → completes onboarding without marking; YouView can
///   re-prompt later (TODO: surface a "Add widget" row when this flag is set)
struct OnboardingWidgetStep: View {
    let petName: String
    let category: BlockCategory?
    let onFinish: (_ widgetMarkedAdded: Bool) -> Void

    @State private var bounceArrow = false
    @State private var widgetScale: CGFloat = 0.7
    @State private var widgetOpacity: Double = 0

    /// Persistence key for "did the user say they added the widget."
    /// Read by YouView later to decide whether to surface a "Add widget" row.
    static let widgetAddedKey = "onboarding_widget_added"

    private var displayName: String {
        petName.trimmingCharacters(in: .whitespaces).isEmpty ? "Pixel" : petName
    }

    /// Pick a scene to render in the mockup based on the user's seed habit.
    /// Falls back to bedroom + idling if no habit was selected.
    private var mockScene: RoomType {
        category?.sceneRoomType ?? .bedroom
    }
    private var mockActivity: PetActivity {
        category?.sceneActivity ?? .idling
    }

    var body: some View {
        VStack(spacing: 0) {
            Spacer().frame(height: 28)

            // Headline
            VStack(spacing: 10) {
                Text("Add me to your\nhome screen")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(PixelTheme.text)
                    .multilineTextAlignment(.center)

                Text("Mini Me lives best as a widget — that's the whole point.")
                    .font(PixelTheme.captionFont)
                    .foregroundColor(PixelTheme.text.opacity(0.55))
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal, 32)

            Spacer().frame(height: 28)

            // Faux home-screen mockup with the preview widget
            ZStack {
                fauxPhone
            }
            .frame(height: 280)
            .scaleEffect(widgetScale)
            .opacity(widgetOpacity)
            .onAppear {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                    widgetScale = 1.0
                    widgetOpacity = 1.0
                }
                // Subtle bounce on the long-press indicator
                withAnimation(.easeInOut(duration: 0.9).repeatForever(autoreverses: true)) {
                    bounceArrow = true
                }
            }

            Spacer().frame(height: 18)

            // Three-step instruction strip
            HStack(spacing: 10) {
                instructionPill(num: 1, text: "Long-press home")
                instructionPill(num: 2, text: "Tap +")
                instructionPill(num: 3, text: "Search “Mini Me”")
            }
            .padding(.horizontal, 16)

            Spacer()

            // Primary + secondary CTAs
            VStack(spacing: 8) {
                OnboardingButton(title: "I added it ✓") {
                    HapticService.medium()
                    UserDefaults.standard.set(true, forKey: Self.widgetAddedKey)
                    onFinish(true)
                }

                Button {
                    HapticService.light()
                    UserDefaults.standard.set(false, forKey: Self.widgetAddedKey)
                    onFinish(false)
                } label: {
                    Text("Show me later")
                        .font(PixelTheme.captionFont)
                        .foregroundColor(PixelTheme.text.opacity(0.5))
                        .underline()
                }
                .padding(.bottom, 8)
            }
            .padding(.bottom, 36)
        }
    }

    // MARK: - Faux phone + widget mockup

    /// A tiny phone silhouette with a stylized lock-screen-style background
    /// and the preview widget pinned in the center. Not pixel-perfect —
    /// it's a teaching mockup, not a screenshot. Goal: make the user
    /// recognize "oh, that's a widget."
    private var fauxPhone: some View {
        ZStack {
            // Phone body
            RoundedRectangle(cornerRadius: 32)
                .fill(
                    LinearGradient(
                        colors: [Color(hex: "#FFD9A8"), Color(hex: "#E8985E")],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 180, height: 280)
                .overlay(
                    RoundedRectangle(cornerRadius: 32)
                        .stroke(PixelTheme.text.opacity(0.18), lineWidth: 2)
                )
                .shadow(color: PixelTheme.shadowColor, radius: 8, y: 4)

            // Soft dimmed top status bar to suggest "iPhone"
            VStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(PixelTheme.text.opacity(0.18))
                    .frame(width: 80, height: 6)
                    .padding(.top, 14)
                Spacer()
            }
            .frame(width: 180, height: 280)

            // The widget preview — medium size proportional
            previewWidget
                .frame(width: 138, height: 80)
                .offset(y: -8)

            // Long-press cue arrow (tap target indicator)
            VStack {
                Spacer()
                Image(systemName: "hand.point.up.fill")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(PixelTheme.text.opacity(0.85))
                    .offset(y: bounceArrow ? -6 : 0)
                    .padding(.bottom, 60)
            }
            .frame(width: 180, height: 280)
        }
    }

    /// Mini medium-widget mockup using actual pixel assets so the user sees
    /// a believable preview of THEIR mini-me on a widget — not a generic
    /// stock screenshot.
    private var previewWidget: some View {
        ZStack(alignment: .bottomLeading) {
            // Scene background or fallback color
            sceneBackgroundColor
                .frame(maxWidth: .infinity, maxHeight: .infinity)

            // Mini-me sprite scaled small, anchored bottom-center
            HStack {
                Spacer()
                Image(uiImage:
                    UIImage(named: mockSpriteName())
                    ?? UIImage(named: "minime_idle")
                    ?? UIImage(named: "minime_idle_1774711350053")
                    ?? UIImage()
                )
                    .interpolation(.none)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 64)
                Spacer()
            }
            .padding(.bottom, 4)

            // Status caption (bottom-left like the real widget)
            VStack(alignment: .leading, spacing: 1) {
                Text(displayName)
                    .font(.system(size: 9, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                Text(activityLabel())
                    .font(.system(size: 8, weight: .medium, design: .rounded))
                    .foregroundColor(.white.opacity(0.7))
            }
            .padding(8)
        }
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(.white.opacity(0.6), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.25), radius: 4, y: 2)
    }

    private var sceneBackgroundColor: Color {
        // Mirror WidgetSnapshotBakery.ambientColor(for:) so the preview tints
        // match what they'll see on the real widget once art is baked.
        switch mockScene {
        case .bedroom:    return Color(hex: "1A1030")
        case .study:      return Color(hex: "1C1810")
        case .gym:        return Color(hex: "0D1A0D")
        case .kitchen:    return Color(hex: "1A1208")
        case .coffeeShop: return Color(hex: "1A0D0D")
        case .rooftop:    return Color(hex: "0A0D1A")
        }
    }

    private func mockSpriteName() -> String {
        switch mockActivity {
        case .working:    return "minime_working"
        case .reading:    return "minime_reading"
        case .eating:     return "minime_eating"
        case .stretching: return "minime_exercising"
        case .slacking:   return "minime_socializing"
        case .sleeping:   return "minime_sleeping"
        case .walking, .idling: return "minime_idle"
        }
    }

    private func activityLabel() -> String {
        switch mockActivity {
        case .working:    return "Working"
        case .reading:    return "Reading"
        case .eating:     return "Eating"
        case .stretching: return "Exercising"
        case .slacking:   return "Hanging out"
        case .sleeping:   return "Sleeping"
        case .walking, .idling: return "At home"
        }
    }

    private func instructionPill(num: Int, text: String) -> some View {
        HStack(spacing: 6) {
            Text("\(num)")
                .font(.system(size: 11, weight: .bold, design: .rounded))
                .foregroundColor(PixelTheme.background)
                .frame(width: 18, height: 18)
                .background(PixelTheme.primary)
                .clipShape(Circle())
            Text(text)
                .font(.system(size: 10, weight: .medium, design: .rounded))
                .foregroundColor(PixelTheme.text.opacity(0.7))
                .lineLimit(1)
                .fixedSize(horizontal: true, vertical: false)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 6)
        .background(PixelTheme.cardBackground)
        .cornerRadius(10)
        .overlay(RoundedRectangle(cornerRadius: 10).stroke(PixelTheme.cardBorder, lineWidth: 1))
    }
}
