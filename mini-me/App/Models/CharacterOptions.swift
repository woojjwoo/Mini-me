import SwiftUI

enum HairStyle: String, CaseIterable, Identifiable {
    case short, medium, long, spiky, bun, pixie
    var id: String { rawValue }
    var displayName: String {
        switch self {
        case .long: "Long"
        default: rawValue.capitalized
        }
    }
    var icon: String {
        switch self {
        case .short: "scissors"
        case .medium: "arrow.up.and.down"
        case .long: "arrow.down.to.line"
        case .spiky: "bolt.fill"
        case .bun: "circle.fill"
        case .pixie: "leaf.fill"
        }
    }
}

enum HairColor: String, CaseIterable, Identifiable {
    case black, brown, blonde, auburn, blue, pink, purple, silver
    var id: String { rawValue }
    var displayName: String {
        switch self {
        case .auburn: "Auburn"
        case .silver: "Silver"
        default: rawValue.capitalized
        }
    }
    var color: Color {
        switch self {
        case .black:  Color(hex: "1C1C1E")
        case .brown:  Color(hex: "6B3A2A")
        case .blonde: Color(hex: "E8C060")
        case .auburn: Color(hex: "A0401A")
        case .blue:   Color(hex: "2255AA")
        case .pink:   Color(hex: "DD3388")
        case .purple: Color(hex: "7733BB")
        case .silver: Color(hex: "AAAAAA")
        }
    }
}

enum SkinTone: String, CaseIterable, Identifiable {
    case light, fair, medium, tan, dark
    var id: String { rawValue }
    var displayName: String { rawValue.capitalized }
    var color: Color {
        switch self {
        case .light:  Color(hex: "FDDBB4")
        case .fair:   Color(hex: "EAAA80")
        case .medium: Color(hex: "C68642")
        case .tan:    Color(hex: "9B5E2E")
        case .dark:   Color(hex: "5C3317")
        }
    }
    var shadowColor: Color {
        switch self {
        case .light:  Color(hex: "DCAA88")
        case .fair:   Color(hex: "C07A50")
        case .medium: Color(hex: "A06030")
        case .tan:    Color(hex: "7A3E1A")
        case .dark:   Color(hex: "3C1E08")
        }
    }
}

enum EyeSize: String, CaseIterable, Identifiable {
    case small, medium, large
    var id: String { rawValue }
    var displayName: String { rawValue.capitalized }
}

enum FaceShape: String, CaseIterable, Identifiable {
    case round, angular, soft
    var id: String { rawValue }
    var displayName: String { rawValue.capitalized }
}

enum OutfitStyle: String, CaseIterable, Identifiable {
    case casual, sporty, formal, cozy, street
    var id: String { rawValue }
    var displayName: String {
        switch self {
        case .street: "Street"
        default: rawValue.capitalized
        }
    }
    var icon: String {
        switch self {
        case .casual: "tshirt"
        case .sporty: "figure.run"
        case .formal: "briefcase"
        case .cozy:   "bed.double.fill"
        case .street: "star.fill"
        }
    }
    var shirtColor: Color {
        switch self {
        case .casual:  Color(hex: "5B8C5A")
        case .sporty:  Color(hex: "E8985E")
        case .formal:  Color(hex: "3D5A80")
        case .cozy:    Color(hex: "C4956A")
        case .street:  Color(hex: "1A1A2E")
        }
    }
    var pantsColor: Color {
        switch self {
        case .casual:  Color(hex: "4A6FA5")
        case .sporty:  Color(hex: "2D3561")
        case .formal:  Color(hex: "2A3A50")
        case .cozy:    Color(hex: "8B6F5E")
        case .street:  Color(hex: "3D3D3D")
        }
    }
    var shoeColor: Color {
        switch self {
        case .casual:  Color(hex: "F0F0F0")
        case .sporty:  Color(hex: "FFFFFF")
        case .formal:  Color(hex: "1A1A1A")
        case .cozy:    Color(hex: "9B7B5A")
        case .street:  Color(hex: "E8985E")
        }
    }
    var accentColor: Color? {
        switch self {
        case .sporty:  Color(hex: "FFFFFF")
        case .formal:  Color(hex: "F0C060")
        case .street:  Color(hex: "E8985E")
        default: nil
        }
    }
}
