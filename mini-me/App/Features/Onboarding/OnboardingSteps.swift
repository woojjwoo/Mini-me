import SwiftUI

// MARK: - Step 1: Welcome

struct WelcomeStep: View {
    let onNext: () -> Void

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            ZStack {
                RoundedRectangle(cornerRadius: 24)
                    .fill(PixelTheme.primary.opacity(0.12))
                    .frame(width: 180, height: 220)
                    .shadow(color: PixelTheme.shadowColor, radius: 8, y: 4)

                MiniMeAvatarView(
                    hairStyle: .medium,
                    hairColor: .brown,
                    skinTone: .fair,
                    eyeSize: .large,
                    outfitStyle: .casual
                )
                .scaleEffect(1.2)
            }

            Text("Let's design your ideal day.")
                .font(PixelTheme.titleFont)
                .foregroundColor(PixelTheme.text)
                .multilineTextAlignment(.center)

            Text("Build the routine you actually want to follow — your Mini Me lives in a pixel room that grows as you stick to it.")
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

    var body: some View {
        VStack(spacing: 16) {
            Text(title)
                .font(PixelTheme.titleFont)
                .foregroundColor(PixelTheme.text)
                .multilineTextAlignment(.center)

            Text(subtitle)
                .font(PixelTheme.captionFont)
                .foregroundColor(PixelTheme.text.opacity(0.6))

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

            ScrollView {
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
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
            Image(systemName: block.category.icon).font(.caption)
            Text(block.label).font(PixelTheme.captionFont)
            Button(action: onRemove) {
                Image(systemName: "xmark.circle.fill").font(.caption2)
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

// MARK: - Step 6: Character Creator (MapleStory-style)

enum CharacterCreatorTab: CaseIterable {
    case hairStyle, hairColor, skinTone, eyeSize, faceShape, outfit

    var label: String {
        switch self {
        case .hairStyle:  "Hair"
        case .hairColor:  "Color"
        case .skinTone:   "Skin"
        case .eyeSize:    "Eyes"
        case .faceShape:  "Face"
        case .outfit:     "Outfit"
        }
    }

    var icon: String {
        switch self {
        case .hairStyle:  "scissors"
        case .hairColor:  "paintpalette.fill"
        case .skinTone:   "person.fill"
        case .eyeSize:    "eye.fill"
        case .faceShape:  "person.crop.circle"
        case .outfit:     "bag.fill"
        }
    }
}

struct PetSetupStep: View {
    @Binding var petName: String
    @Binding var hairStyle: HairStyle
    @Binding var hairColor: HairColor
    @Binding var skinTone: SkinTone
    @Binding var eyeSize: EyeSize
    @Binding var faceShape: FaceShape
    @Binding var outfitStyle: OutfitStyle
    let onFinish: () -> Void

    @State private var activeTab: CharacterCreatorTab = .hairStyle
    @State private var previewBounce = false
    @FocusState private var nameFieldFocused: Bool

    var body: some View {
        VStack(spacing: 0) {
            Text("Create your Mini Me!")
                .font(PixelTheme.titleFont)
                .foregroundColor(PixelTheme.text)
                .padding(.top, 4)
                .padding(.bottom, 12)

            // ── Character Preview ──────────────────────────────────────
            ZStack {
                RoundedRectangle(cornerRadius: 20)
                    .fill(PixelTheme.primary.opacity(0.10))
                    .frame(width: 180, height: 210)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .strokeBorder(PixelTheme.primary.opacity(0.25), lineWidth: 2)
                    )

                MiniMeAvatarView(
                    hairStyle: hairStyle,
                    hairColor: hairColor,
                    skinTone: skinTone,
                    eyeSize: eyeSize,
                    outfitStyle: outfitStyle,
                    faceShape: faceShape
                )
                .scaleEffect(previewBounce ? 1.06 : 1.0)
                .animation(.spring(response: 0.3, dampingFraction: 0.55), value: previewBounce)
            }
            .padding(.bottom, 16)

            // ── Tab Strip ─────────────────────────────────────────────
            HStack(spacing: 4) {
                ForEach(CharacterCreatorTab.allCases, id: \.self) { tab in
                    Button {
                        withAnimation(.easeInOut(duration: 0.2)) { activeTab = tab }
                    } label: {
                        VStack(spacing: 3) {
                            Image(systemName: tab.icon)
                                .font(.system(size: 14))
                            Text(tab.label)
                                .font(.system(size: 10, weight: .semibold, design: .rounded))
                        }
                        .foregroundColor(activeTab == tab ? .white : PixelTheme.text.opacity(0.6))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 7)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(activeTab == tab ? PixelTheme.primary : Color.clear)
                        )
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 10)

            // ── Option Selector ───────────────────────────────────────
            Group {
                switch activeTab {
                case .hairStyle:
                    HairStylePicker(selected: $hairStyle, onChange: bounce)
                case .hairColor:
                    ColorDotPicker(
                        options: HairColor.allCases.map { ($0.displayName, $0.color, $0.rawValue) },
                        selectedID: hairColor.rawValue
                    ) { id in
                        if let c = HairColor(rawValue: id) { hairColor = c; bounce() }
                    }
                case .skinTone:
                    ColorDotPicker(
                        options: SkinTone.allCases.map { ($0.displayName, $0.color, $0.rawValue) },
                        selectedID: skinTone.rawValue
                    ) { id in
                        if let s = SkinTone(rawValue: id) { skinTone = s; bounce() }
                    }
                case .eyeSize:
                    EyeSizePicker(selected: $eyeSize, onChange: bounce)
                case .faceShape:
                    FaceShapePicker(selected: $faceShape, onChange: bounce)
                case .outfit:
                    OutfitPicker(selected: $outfitStyle, onChange: bounce)
                }
            }
            .frame(height: 80)
            .padding(.horizontal, 16)

            // ── Name Field ────────────────────────────────────────────
            TextField("Name your Mini Me...", text: $petName)
                .font(PixelTheme.bodyFont)
                .multilineTextAlignment(.center)
                .padding(12)
                .background(PixelTheme.cardBackground)
                .cornerRadius(12)
                .padding(.horizontal, 32)
                .padding(.top, 12)
                .focused($nameFieldFocused)

            Spacer(minLength: 12)

            OnboardingButton(title: "Start My Ideal Day!", action: onFinish)
                .padding(.bottom, 32)
        }
        .contentShape(Rectangle())
        .onTapGesture { nameFieldFocused = false }
    }

    private func bounce() {
        previewBounce = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) { previewBounce = false }
    }
}

// MARK: - Hair Style Picker

struct HairStylePicker: View {
    @Binding var selected: HairStyle
    let onChange: () -> Void

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(HairStyle.allCases) { style in
                    Button {
                        selected = style
                        HapticService.light()
                        onChange()
                    } label: {
                        VStack(spacing: 5) {
                            Image(systemName: style.icon)
                                .font(.system(size: 18))
                                .foregroundColor(selected == style ? .white : PixelTheme.text)
                                .frame(width: 44, height: 44)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(selected == style ? PixelTheme.primary : PixelTheme.cardBackground)
                                        .shadow(color: PixelTheme.shadowColor, radius: 2, y: 1)
                                )
                            Text(style.displayName)
                                .font(.system(size: 10, weight: .medium, design: .rounded))
                                .foregroundColor(selected == style ? PixelTheme.primary : PixelTheme.text.opacity(0.6))
                        }
                    }
                }
            }
            .padding(.horizontal, 4)
            .padding(.vertical, 8)
        }
    }
}

// MARK: - Color Dot Picker (hair color + skin tone)

struct ColorDotPicker: View {
    let options: [(name: String, color: Color, id: String)]
    let selectedID: String
    let onSelect: (String) -> Void

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(options, id: \.id) { opt in
                    Button { onSelect(opt.id); HapticService.light() } label: {
                        VStack(spacing: 5) {
                            Circle()
                                .fill(opt.color)
                                .frame(width: 40, height: 40)
                                .overlay(
                                    Circle()
                                        .strokeBorder(
                                            selectedID == opt.id ? PixelTheme.primary : Color.clear,
                                            lineWidth: 3
                                        )
                                )
                                .shadow(color: PixelTheme.shadowColor, radius: 2, y: 1)
                            Text(opt.name)
                                .font(.system(size: 9, weight: .medium, design: .rounded))
                                .foregroundColor(PixelTheme.text.opacity(0.6))
                        }
                    }
                }
            }
            .padding(.horizontal, 4)
            .padding(.vertical, 8)
        }
    }
}

// MARK: - Eye Size Picker

struct EyeSizePicker: View {
    @Binding var selected: EyeSize
    let onChange: () -> Void

    private let eyeIcons = [EyeSize.small: "eye", .medium: "eye.fill", .large: "eye.trianglebadge.exclamationmark"]

    var body: some View {
        HStack(spacing: 16) {
            ForEach(EyeSize.allCases) { size in
                Button {
                    selected = size
                    HapticService.light()
                    onChange()
                } label: {
                    VStack(spacing: 6) {
                        // Visual eye size preview
                        ZStack {
                            RoundedRectangle(cornerRadius: 12)
                                .fill(selected == size ? PixelTheme.primary : PixelTheme.cardBackground)
                                .frame(width: 70, height: 50)
                                .shadow(color: PixelTheme.shadowColor, radius: 2, y: 1)

                            let dotSize: CGFloat = size == .small ? 6 : size == .medium ? 10 : 15
                            HStack(spacing: size == .small ? 12 : 8) {
                                Capsule()
                                    .fill(selected == size ? Color.white : PixelTheme.text)
                                    .frame(width: dotSize, height: dotSize)
                                Capsule()
                                    .fill(selected == size ? Color.white : PixelTheme.text)
                                    .frame(width: dotSize, height: dotSize)
                            }
                        }
                        Text(size.displayName)
                            .font(.system(size: 10, weight: .medium, design: .rounded))
                            .foregroundColor(selected == size ? PixelTheme.primary : PixelTheme.text.opacity(0.6))
                    }
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
    }
}

// MARK: - Outfit Picker

struct OutfitPicker: View {
    @Binding var selected: OutfitStyle
    let onChange: () -> Void

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(OutfitStyle.allCases) { style in
                    Button {
                        selected = style
                        HapticService.light()
                        onChange()
                    } label: {
                        VStack(spacing: 5) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(selected == style ? PixelTheme.primary : PixelTheme.cardBackground)
                                    .frame(width: 50, height: 44)
                                    .shadow(color: PixelTheme.shadowColor, radius: 2, y: 1)
                                // Color swatch for the shirt/pants
                                VStack(spacing: 2) {
                                    RoundedRectangle(cornerRadius: 4)
                                        .fill(style.shirtColor)
                                        .frame(width: 28, height: 16)
                                    RoundedRectangle(cornerRadius: 4)
                                        .fill(style.pantsColor)
                                        .frame(width: 28, height: 10)
                                }
                            }
                            Text(style.displayName)
                                .font(.system(size: 10, weight: .medium, design: .rounded))
                                .foregroundColor(selected == style ? PixelTheme.primary : PixelTheme.text.opacity(0.6))
                        }
                    }
                }
            }
            .padding(.horizontal, 4)
            .padding(.vertical, 8)
        }
    }
}

// MARK: - Face Shape Picker

struct FaceShapePicker: View {
    @Binding var selected: FaceShape
    let onChange: () -> Void

    var body: some View {
        HStack(spacing: 16) {
            ForEach(FaceShape.allCases) { shape in
                Button {
                    selected = shape
                    HapticService.light()
                    onChange()
                } label: {
                    VStack(spacing: 6) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 12)
                                .fill(selected == shape ? PixelTheme.primary : PixelTheme.cardBackground)
                                .frame(width: 70, height: 50)
                                .shadow(color: PixelTheme.shadowColor, radius: 2, y: 1)
                            faceShapeIcon(shape, selected: selected == shape)
                        }
                        Text(shape.displayName)
                            .font(.system(size: 10, weight: .medium, design: .rounded))
                            .foregroundColor(selected == shape ? PixelTheme.primary : PixelTheme.text.opacity(0.6))
                    }
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
    }

    @ViewBuilder
    private func faceShapeIcon(_ shape: FaceShape, selected: Bool) -> some View {
        let c: Color = selected ? .white : PixelTheme.text
        switch shape {
        case .round:
            Circle().fill(c).frame(width: 28, height: 28)
        case .angular:
            Rectangle().fill(c).frame(width: 26, height: 28).cornerRadius(3)
        case .soft:
            Ellipse().fill(c).frame(width: 22, height: 32)
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
                .shadow(color: PixelTheme.primary.opacity(0.3), radius: 8, y: 4)
        }
        .padding(.horizontal, 24)
    }
}
