import SwiftUI
import SwiftData

struct CharacterCardView: View {
    let pet: Pet
    let player: Player?

    var cardContent: some View {
        VStack(spacing: 16) {
            MiniMeAvatarView(
                hairStyle:   pet.hairStyle,
                hairColor:   pet.hairColor,
                skinTone:    pet.skinTone,
                eyeSize:     pet.eyeSize,
                outfitStyle: pet.characterOutfitStyle,
                faceShape:   pet.faceShape,
                pixelSize:   10
            )

            Text(pet.name)
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundColor(PixelTheme.text)

            VStack(spacing: 8) {
                statRow(icon: "flame.fill",      color: PixelTheme.accent,   label: "\(player?.currentStreak ?? 0) day streak")
                statRow(icon: "checkmark.circle.fill", color: PixelTheme.completed, label: "\(player?.totalDaysCompleted ?? 0) days completed")
                statRow(icon: "dollarsign.circle.fill", color: PixelTheme.coin,  label: "\(player?.coins ?? 0) coins")
            }
        }
        .padding(28)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(PixelTheme.background)
                .shadow(color: PixelTheme.shadowColor, radius: 12, y: 6)
        )
    }

    var body: some View {
        VStack(spacing: 24) {
            cardContent

            ShareLink(
                item: renderedCardImage,
                preview: SharePreview("\(pet.name)'s Mini Me Card", image: renderedCardImage)
            ) {
                Label("Share Character Card", systemImage: "square.and.arrow.up")
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
        .padding(.vertical, 24)
        .background(PixelTheme.background.ignoresSafeArea())
    }

    private var renderedCardImage: Image {
        let renderer = ImageRenderer(content: cardContent.padding(8))
        renderer.scale = 3.0
        if let ui = renderer.uiImage {
            return Image(uiImage: ui)
        }
        return Image(systemName: "person.fill")
    }

    private func statRow(icon: String, color: Color, label: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .foregroundColor(color)
                .frame(width: 20)
            Text(label)
                .font(PixelTheme.bodyFont)
                .foregroundColor(PixelTheme.text)
            Spacer()
        }
    }
}
