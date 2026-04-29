import SwiftUI

struct TimeBlockRow: View {
    let block: TimeBlock
    let isCompleted: Bool
    let isCurrentBlock: Bool
    let isAnimating: Bool
    let onComplete: () -> Void

    @State private var checkScale: CGFloat = 1.0

    var body: some View {
        Button(action: {
            if !isCompleted {
                withAnimation(.spring(response: 0.25, dampingFraction: 0.5)) { checkScale = 1.2 }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                    withAnimation(.spring(response: 0.2)) { checkScale = 1.0 }
                }
                onComplete()
            }
        }) {
            HStack(spacing: 0) {
                // Left category color stripe
                Rectangle()
                    .fill(isCompleted ? PixelTheme.pending.opacity(0.4) : block.blockCategory.color)
                    .frame(width: 4)

                // Content
                HStack(spacing: 12) {
                    // Label + time
                    VStack(alignment: .leading, spacing: 3) {
                        Text(block.label)
                            .font(.system(size: 16, weight: .semibold, design: .rounded))
                            .foregroundColor(PixelTheme.text)

                        Text(timeRangeString)
                            .font(.system(size: 11, weight: .medium, design: .rounded))
                            .foregroundColor(PixelTheme.text.opacity(0.45))
                    }

                    Spacer()

                    // Checkmark circle — 32pt
                    ZStack {
                        if isCompleted {
                            Circle()
                                .fill(PixelTheme.accent)
                                .frame(width: 32, height: 32)
                            Image(systemName: "checkmark")
                                .font(.system(size: 13, weight: .bold))
                                .foregroundColor(.white)
                        } else if isCurrentBlock {
                            Circle()
                                .fill(block.blockCategory.color)
                                .frame(width: 32, height: 32)
                            Image(systemName: "play.fill")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(.white)
                        } else {
                            Circle()
                                .stroke(PixelTheme.pending.opacity(0.5), lineWidth: 2)
                                .frame(width: 32, height: 32)
                        }
                    }
                    .scaleEffect(isAnimating ? checkScale : 1.0)
                }
                .padding(.vertical, 14)
                .padding(.leading, 14)
                .padding(.trailing, 16)
            }
            .background(
                isCurrentBlock
                    ? block.blockCategory.color.opacity(0.08)
                    : PixelTheme.cardBackground
            )
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(
                        isCurrentBlock ? block.blockCategory.color.opacity(0.25) : PixelTheme.cardBorder,
                        lineWidth: isCurrentBlock ? 1.5 : 1
                    )
            )
            .shadow(
                color: isCurrentBlock ? block.blockCategory.color.opacity(0.15) : PixelTheme.shadowColor,
                radius: isCurrentBlock ? 6 : 2,
                y: 1
            )
            .opacity(isCompleted ? 0.55 : 1.0)
        }
        .buttonStyle(.plain)
        .disabled(isCompleted)
    }

    private var timeRangeString: String {
        let startH = block.startHour % 12 == 0 ? 12 : block.startHour % 12
        let endH = block.endHour % 12 == 0 ? 12 : block.endHour % 12
        let startPeriod = block.startHour < 12 ? "am" : "pm"
        let endPeriod = block.endHour < 12 ? "am" : "pm"

        let startStr = block.startMinute == 0
            ? "\(startH)\(startPeriod)"
            : "\(startH):\(String(format: "%02d", block.startMinute))\(startPeriod)"

        let endStr = block.endMinute == 0
            ? "\(endH)\(endPeriod)"
            : "\(endH):\(String(format: "%02d", block.endMinute))\(endPeriod)"

        return "\(startStr) – \(endStr) · \(block.durationMinutes)min"
    }
}
