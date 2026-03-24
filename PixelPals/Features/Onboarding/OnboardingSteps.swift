import SwiftUI

// MARK: - Step 1: Welcome

struct WelcomeStep: View {
    let onNext: () -> Void

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            // Placeholder for pixel art logo/cat
            RoundedRectangle(cornerRadius: 20)
                .fill(PixelTheme.primary.opacity(0.15))
                .frame(width: 160, height: 160)
                .overlay {
                    Text("🐱")
                        .font(.system(size: 80))
                }

            Text("Let's design your ideal day.")
                .font(PixelTheme.titleFont)
                .foregroundColor(PixelTheme.text)
                .multilineTextAlignment(.center)

            Text("Build the daily routine you actually want to follow — then watch your pixel room grow as you stick to it.")
                .font(PixelTheme.bodyFont)
                .foregroundColor(PixelTheme.text.opacity(0.7))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)

            Spacer()

            OnboardingButton(title: "Let's Go", action: onNext)
                .padding(.bottom, 40)
        }
        .padding(.horizontal, 24)
    }
}

// MARK: - Step 2: Wake Up Time

struct WakeUpStep: View {
    @Binding var hour: Int
    @Binding var minute: Int
    let onNext: () -> Void

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            Text("What time do you wake up?")
                .font(PixelTheme.titleFont)
                .foregroundColor(PixelTheme.text)

            Text("This is your ideal wake-up time — not your alarm, your goal.")
                .font(PixelTheme.bodyFont)
                .foregroundColor(PixelTheme.text.opacity(0.7))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)

            HStack(spacing: 4) {
                Picker("Hour", selection: $hour) {
                    ForEach(4..<13, id: \.self) { h in
                        Text("\(h == 0 ? 12 : h)").tag(h)
                    }
                }
                .pickerStyle(.wheel)
                .frame(width: 80)

                Text(":")
                    .font(.title)
                    .foregroundColor(PixelTheme.text)

                Picker("Minute", selection: $minute) {
                    Text("00").tag(0)
                    Text("15").tag(15)
                    Text("30").tag(30)
                    Text("45").tag(45)
                }
                .pickerStyle(.wheel)
                .frame(width: 80)

                Text("AM")
                    .font(PixelTheme.headlineFont)
                    .foregroundColor(PixelTheme.primary)
            }
            .padding(.vertical, 20)

            Spacer()

            OnboardingButton(title: "Next", action: onNext)
                .padding(.bottom, 40)
        }
        .padding(.horizontal, 24)
    }
}

// MARK: - Step 3/4/5: Block Picker

struct BlockPickerStep: View {
    let title: String
    let subtitle: String
    @Binding var selectedBlocks: [OnboardingBlock]
    let suggestedCategories: [BlockCategory]
    let onNext: () -> Void

    @State private var showingCustomSheet = false

    var body: some View {
        VStack(spacing: 16) {
            Text(title)
                .font(PixelTheme.titleFont)
                .foregroundColor(PixelTheme.text)
                .multilineTextAlignment(.center)

            Text(subtitle)
                .font(PixelTheme.captionFont)
                .foregroundColor(PixelTheme.text.opacity(0.6))

            // Selected blocks preview
            if !selectedBlocks.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(selectedBlocks) { block in
                            SelectedBlockChip(block: block) {
                                selectedBlocks.removeAll { $0.id == block.id }
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                }
                .frame(height: 44)
            }

            // Category grid
            ScrollView {
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible()),
                ], spacing: 12) {
                    ForEach(suggestedCategories) { category in
                        CategoryBlockButton(category: category) {
                            let block = OnboardingBlock(
                                category: category,
                                label: category.displayName,
                                duration: 60
                            )
                            selectedBlocks.append(block)
                        }
                    }
                }
                .padding(.horizontal, 16)
            }

            Spacer()

            OnboardingButton(
                title: selectedBlocks.isEmpty ? "Skip" : "Next",
                action: onNext
            )
            .padding(.bottom, 40)
        }
        .padding(.horizontal, 8)
    }
}

struct SelectedBlockChip: View {
    let block: OnboardingBlock
    let onRemove: () -> Void

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: block.category.icon)
                .font(.caption)
            Text(block.label)
                .font(PixelTheme.captionFont)
            Button(action: onRemove) {
                Image(systemName: "xmark.circle.fill")
                    .font(.caption2)
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(block.category.color.opacity(0.2))
        .foregroundColor(PixelTheme.text)
        .cornerRadius(16)
    }
}

struct CategoryBlockButton: View {
    let category: BlockCategory
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 8) {
                Image(systemName: category.icon)
                    .font(.title3)
                    .foregroundColor(category.color)
                Text(category.displayName)
                    .font(PixelTheme.bodyFont)
                    .foregroundColor(PixelTheme.text)
                Spacer()
                Image(systemName: "plus.circle.fill")
                    .foregroundColor(PixelTheme.primary.opacity(0.6))
            }
            .padding(14)
            .background(PixelTheme.cardBackground)
            .cornerRadius(12)
            .shadow(color: PixelTheme.shadowColor, radius: 2, y: 1)
        }
    }
}

// MARK: - Step 6: Pet Setup

struct PetSetupStep: View {
    @Binding var petName: String
    @Binding var petColor: PetColor
    let onFinish: () -> Void

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            Text("Meet your pixel pal!")
                .font(PixelTheme.titleFont)
                .foregroundColor(PixelTheme.text)

            // Placeholder for pixel cat preview
            RoundedRectangle(cornerRadius: 20)
                .fill(petColor == .orangeTabby ? Color(hex: "FFD180") :
                      petColor == .black ? Color(hex: "4A4A4A") :
                      Color(hex: "F5F5F5"))
                .frame(width: 120, height: 120)
                .overlay {
                    Text("🐱")
                        .font(.system(size: 60))
                }

            // Color picker
            HStack(spacing: 16) {
                ForEach(PetColor.allCases) { color in
                    VStack(spacing: 4) {
                        Circle()
                            .fill(color == .orangeTabby ? Color(hex: "FFB74D") :
                                  color == .black ? Color(hex: "4A4A4A") :
                                  Color(hex: "FAFAFA"))
                            .frame(width: 48, height: 48)
                            .overlay {
                                Circle()
                                    .stroke(petColor == color ? PixelTheme.primary : Color.clear, lineWidth: 3)
                            }
                            .shadow(color: PixelTheme.shadowColor, radius: 2)

                        Text(color.displayName)
                            .font(PixelTheme.captionFont)
                            .foregroundColor(PixelTheme.text.opacity(0.7))
                    }
                    .onTapGesture { petColor = color }
                }
            }

            // Name field
            TextField("Name your cat...", text: $petName)
                .font(PixelTheme.bodyFont)
                .padding(14)
                .background(PixelTheme.cardBackground)
                .cornerRadius(12)
                .padding(.horizontal, 40)
                .multilineTextAlignment(.center)

            Spacer()

            OnboardingButton(title: "Start My Ideal Day!", action: onFinish)
                .padding(.bottom, 40)
        }
        .padding(.horizontal, 24)
    }
}

// MARK: - Shared Button

struct OnboardingButton: View {
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(PixelTheme.headlineFont)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(PixelTheme.primary)
                .cornerRadius(16)
                .shadow(color: PixelTheme.primary.opacity(0.3), radius: 8, y: 4)
        }
        .padding(.horizontal, 24)
    }
}
