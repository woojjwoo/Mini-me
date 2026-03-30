import SwiftUI

struct TimeBlockRow: View {
    let block: TimeBlock
    let isCompleted: Bool
    let isCurrentBlock: Bool
    let isAnimating: Bool
    let onComplete: () -> Void

    var body: some View {
        Button(action: {
            if !isCompleted {
                onComplete()
            }
        }) {
            HStack(spacing: 12) {
                // Time
                VStack(alignment: .trailing, spacing: 2) {
                    Text(block.startTimeString)
                        .font(PixelTheme.captionFont)
                        .foregroundColor(isCompleted ? PixelTheme.completed : PixelTheme.text.opacity(0.5))
                    Text("\(block.durationMinutes)m")
                        .font(.system(size: 10, weight: .medium, design: .rounded))
                        .foregroundColor(PixelTheme.text.opacity(0.3))
                }
                .frame(width: 60, alignment: .trailing)

                // Status icon
                ZStack {
                    if isCompleted {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.title2)
                            .foregroundColor(PixelTheme.completed)
                            .scaleEffect(isAnimating ? 1.3 : 1.0)
                            .animation(.spring(response: 0.3, dampingFraction: 0.5), value: isAnimating)
                    } else if isCurrentBlock {
                        Circle()
                            .fill(block.blockCategory.color)
                            .frame(width: 28, height: 28)
                            .overlay {
                                Image(systemName: "play.fill")
                                    .font(.caption)
                                    .foregroundColor(.white)
                            }
                    } else {
                        Circle()
                            .stroke(PixelTheme.pending, lineWidth: 2)
                            .frame(width: 28, height: 28)
                    }
                }
                .frame(width: 32)

                // Block info
                VStack(alignment: .leading, spacing: 4) {
                    Text(block.label)
                        .font(PixelTheme.bodyFont)
                        .foregroundColor(isCompleted ? PixelTheme.text.opacity(0.5) : PixelTheme.text)
                        .strikethrough(isCompleted)

                    HStack(spacing: 4) {
                        Image(systemName: block.blockCategory.icon)
                            .font(.caption2)
                        Text(block.blockCategory.displayName)
                            .font(.system(size: 11, weight: .medium, design: .rounded))
                    }
                    .foregroundColor(block.blockCategory.color)
                }

                Spacer()

                // Coin reward indicator
                if !isCompleted {
                    HStack(spacing: 2) {
                        Text("+\(CoinService.coinsPerBlock)")
                            .font(PixelTheme.captionFont)
                        Image(systemName: "circle.fill")
                            .font(.system(size: 6))
                            .foregroundColor(PixelTheme.coin)
                    }
                    .foregroundColor(PixelTheme.text.opacity(0.4))
                } else if isAnimating {
                    Text("+\(CoinService.coinsPerBlock)")
                        .font(PixelTheme.coinFont)
                        .foregroundColor(PixelTheme.coin)
                        .transition(.scale.combined(with: .opacity))
                }
            }
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isCurrentBlock ? block.blockCategory.color.opacity(0.08) : PixelTheme.cardBackground)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isCurrentBlock ? block.blockCategory.color.opacity(0.3) : Color.clear, lineWidth: 1.5)
            )
            .shadow(color: PixelTheme.shadowColor, radius: isCurrentBlock ? 4 : 2, y: 1)
        }
        .buttonStyle(.plain)
        .disabled(isCompleted)
    }
}
