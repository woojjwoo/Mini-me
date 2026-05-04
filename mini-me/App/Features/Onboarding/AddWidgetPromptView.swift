import SwiftUI

/// Full-screen sheet shown once after onboarding to prompt the user to add
/// the Pixie Me widget to their home screen.
/// Shown at most once — gated by @AppStorage("hasSeenWidgetPrompt").
struct AddWidgetPromptView: View {
    let onDone: () -> Void

    @State private var step = 0

    var body: some View {
        ZStack {
            PixelTheme.background.ignoresSafeArea()

            VStack(spacing: 0) {
                // Top handle
                RoundedRectangle(cornerRadius: 3)
                    .fill(Color.white.opacity(0.2))
                    .frame(width: 36, height: 4)
                    .padding(.top, 14)

                Spacer()

                // Widget mockup
                widgetMockup
                    .padding(.horizontal, 40)

                Spacer().frame(height: 32)

                // Instruction text
                VStack(spacing: 10) {
                    Text("Add Pixie Me to your home screen")
                        .font(.system(size: 22, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)

                    Text("Your mini-me lives there — working when you work, resting when you rest.")
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundColor(.white.opacity(0.6))
                        .multilineTextAlignment(.center)
                }
                .padding(.horizontal, 32)

                Spacer().frame(height: 32)

                // Steps
                VStack(alignment: .leading, spacing: 14) {
                    stepRow(number: "1", text: "Long-press your home screen until it jiggles")
                    stepRow(number: "2", text: "Tap the  +  button in the top corner")
                    stepRow(number: "3", text: "Search for \"Pixie Me\"")
                    stepRow(number: "4", text: "Choose small or medium — add widget")
                }
                .padding(.horizontal, 32)

                Spacer()

                // Done button
                Button(action: onDone) {
                    Text("Got it!")
                        .font(.system(size: 17, weight: .bold, design: .rounded))
                        .foregroundColor(PixelTheme.background)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color(hex: "E8985E"))
                        .cornerRadius(14)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
            }
        }
    }

    // MARK: - Widget Mockup

    private var widgetMockup: some View {
        ZStack(alignment: .bottomLeading) {
            // Scene background — bedroom ambient
            RoundedRectangle(cornerRadius: 20)
                .fill(
                    LinearGradient(
                        colors: [Color(hex: "1A1030"), Color(hex: "2D1A50")],
                        startPoint: .topLeading, endPoint: .bottomTrailing
                    )
                )
                .frame(height: 160)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.white.opacity(0.08), lineWidth: 1)
                )

            // Pixel scene dots (decorative suggestion of pixel art)
            pixelSceneDecoration

            // Gradient overlay
            LinearGradient(
                colors: [.clear, .black.opacity(0.55)],
                startPoint: UnitPoint(x: 0.5, y: 0.3),
                endPoint: .bottom
            )
            .clipShape(RoundedRectangle(cornerRadius: 20))

            // Label
            VStack(alignment: .leading, spacing: 2) {
                Text("Working")
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                Text("3/8 blocks")
                    .font(.system(size: 9, weight: .medium, design: .rounded))
                    .foregroundColor(.white.opacity(0.7))
            }
            .padding(.horizontal, 12)
            .padding(.bottom, 12)
        }
        .shadow(color: .black.opacity(0.4), radius: 16, x: 0, y: 8)
    }

    // Decorative pixel art suggestion without needing actual sprites
    private var pixelSceneDecoration: some View {
        Canvas { context, size in
            let pixel: CGFloat = 4
            let palette: [Color] = [
                Color(hex: "5B3A8A"), Color(hex: "7B5CAA"), Color(hex: "8B6CBB"),
                Color(hex: "4A6741"), Color(hex: "5B8C5A"), Color(hex: "E8985E"),
                Color(hex: "F5C484"), Color(hex: "3D2860")
            ]
            // Scatter warm pixels to suggest a cozy room
            let positions: [(CGFloat, CGFloat, Int)] = [
                (0.15, 0.6, 2), (0.18, 0.62, 1), (0.2, 0.58, 2),
                (0.3, 0.55, 0), (0.32, 0.57, 3), (0.28, 0.6, 4),
                (0.5, 0.5, 5), (0.52, 0.52, 6), (0.48, 0.54, 5),
                (0.55, 0.48, 4), (0.7, 0.6, 2), (0.72, 0.58, 1),
                (0.75, 0.62, 3), (0.8, 0.55, 0), (0.85, 0.6, 7),
                (0.4, 0.7, 6), (0.45, 0.72, 5), (0.6, 0.68, 2),
                (0.65, 0.65, 1), (0.35, 0.65, 3)
            ]
            for (rx, ry, ci) in positions {
                let rect = CGRect(
                    x: rx * size.width,
                    y: ry * size.height,
                    width: pixel * 2, height: pixel * 2
                )
                context.fill(Path(rect), with: .color(palette[ci % palette.count].opacity(0.6)))
            }
            // Character silhouette (simple chibi blob)
            let cx = size.width * 0.5
            let cy = size.height * 0.45
            let body = CGRect(x: cx - 10, y: cy, width: 20, height: 28)
            let head = CGRect(x: cx - 9, y: cy - 18, width: 18, height: 18)
            context.fill(Path(ellipseIn: head), with: .color(Color(hex: "F5C484").opacity(0.9)))
            context.fill(Path(body), with: .color(Color(hex: "4A3080").opacity(0.9)))
        }
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }

    // MARK: - Step Row

    private func stepRow(number: String, text: String) -> some View {
        HStack(alignment: .top, spacing: 14) {
            ZStack {
                Circle()
                    .fill(Color(hex: "E8985E").opacity(0.2))
                    .frame(width: 28, height: 28)
                Text(number)
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                    .foregroundColor(Color(hex: "E8985E"))
            }
            Text(text)
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundColor(.white.opacity(0.85))
                .fixedSize(horizontal: false, vertical: true)
            Spacer()
        }
    }
}

#Preview {
    AddWidgetPromptView(onDone: {})
}
