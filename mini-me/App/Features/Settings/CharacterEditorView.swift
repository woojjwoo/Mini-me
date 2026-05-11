import SwiftUI
import SwiftData

struct CharacterEditorView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    let pet: Pet

    @State private var petName: String
    @State private var hairStyle: HairStyle
    @State private var hairColor: HairColor
    @State private var skinTone: SkinTone
    @State private var eyeSize: EyeSize
    @State private var faceShape: FaceShape
    @State private var outfitStyle: OutfitStyle
    @State private var previewBounce = false
    @State private var activeTab: CharacterCreatorTab = .hairStyle
    @FocusState private var nameFieldFocused: Bool

    init(pet: Pet) {
        self.pet = pet
        _petName    = State(initialValue: pet.name)
        _hairStyle  = State(initialValue: pet.hairStyle)
        _hairColor  = State(initialValue: pet.hairColor)
        _skinTone   = State(initialValue: pet.skinTone)
        _eyeSize    = State(initialValue: pet.eyeSize)
        _faceShape  = State(initialValue: pet.faceShape)
        _outfitStyle = State(initialValue: pet.characterOutfitStyle)
    }

    var body: some View {
        NavigationStack {
            ZStack {
                PixelTheme.background.ignoresSafeArea()

                VStack(spacing: 0) {
                    // Preview
                    ZStack {
                        RoundedRectangle(cornerRadius: 20)
                            .fill(PixelTheme.primary.opacity(0.10))
                            .frame(width: 180, height: 210)
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .strokeBorder(PixelTheme.primary.opacity(0.25), lineWidth: 2)
                            )
                        MiniMeAvatarView(
                            hairStyle:   hairStyle,
                            hairColor:   hairColor,
                            skinTone:    skinTone,
                            eyeSize:     eyeSize,
                            outfitStyle: outfitStyle,
                            faceShape:   faceShape
                        )
                        .scaleEffect(previewBounce ? 1.06 : 1.0)
                        .animation(.spring(response: 0.3, dampingFraction: 0.55), value: previewBounce)
                    }
                    .padding(.top, 8)
                    .padding(.bottom, 16)

                    // Tab strip
                    HStack(spacing: 4) {
                        ForEach(CharacterCreatorTab.allCases, id: \.self) { tab in
                            Button {
                                withAnimation(.easeInOut(duration: 0.2)) { activeTab = tab }
                            } label: {
                                VStack(spacing: 3) {
                                    Image(systemName: tab.icon).font(.system(size: 14))
                                    Text(tab.label).font(.system(size: 10, weight: .semibold, design: .rounded))
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

                    // Options
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

                    // Name
                    TextField("Name", text: $petName)
                        .font(PixelTheme.bodyFont)
                        .multilineTextAlignment(.center)
                        .padding(12)
                        .background(PixelTheme.cardBackground)
                        .cornerRadius(12)
                        .padding(.horizontal, 32)
                        .padding(.top, 12)
                        .focused($nameFieldFocused)

                    Spacer()
                }
            }
            .navigationTitle("Edit Appearance")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveCharacter()
                        HapticService.success()
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
            .contentShape(Rectangle())
            .onTapGesture { nameFieldFocused = false }
        }
    }

    private func bounce() {
        previewBounce = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) { previewBounce = false }
    }

    private func saveCharacter() {
        pet.name                  = petName.trimmingCharacters(in: .whitespaces).isEmpty ? "Pixel" : petName.trimmingCharacters(in: .whitespaces)
        pet.hairStyle             = hairStyle
        pet.hairColor             = hairColor
        pet.skinTone              = skinTone
        pet.eyeSize               = eyeSize
        pet.faceShape             = faceShape
        pet.characterOutfitStyle  = outfitStyle
        try? modelContext.save()
    }
}
