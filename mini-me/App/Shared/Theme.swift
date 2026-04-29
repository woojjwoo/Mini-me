import SwiftUI

enum PixelTheme {
    // Core palette
    static let background = Color(hex: "F5E6D3")    // warm cream
    static let primary = Color(hex: "E8985E")        // warm orange — main CTA, hoodie color
    static let accent = Color(hex: "5B8C5A")         // sage green — secondary, wellness
    static let text = Color(hex: "2D2040")           // warm dark purple — matches sprite outline
    static let completed = Color(hex: "7CB342")      // fresh green
    static let pending = Color(hex: "BDBDBD")        // light grey
    static let coin = Color(hex: "FFD54F")           // gold

    // Extended
    static let cardBackground = Color(hex: "FFFAF4") // warm white, not cold
    static let cardBorder = Color(hex: "2D2040").opacity(0.12)
    static let shadowColor = Color(hex: "2D2040").opacity(0.10)

    // Typography
    static let titleFont: Font = .system(size: 24, weight: .bold, design: .rounded)
    static let headlineFont: Font = .system(size: 18, weight: .semibold, design: .rounded)
    static let bodyFont: Font = .system(size: 16, weight: .regular, design: .rounded)
    static let captionFont: Font = .system(size: 12, weight: .medium, design: .rounded)
    static let coinFont: Font = .system(size: 14, weight: .bold, design: .monospaced)
}

// MARK: - Color hex initializer

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 6:
            (a, r, g, b) = (255, (int >> 16) & 0xFF, (int >> 8) & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = ((int >> 24) & 0xFF, (int >> 16) & 0xFF, (int >> 8) & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
