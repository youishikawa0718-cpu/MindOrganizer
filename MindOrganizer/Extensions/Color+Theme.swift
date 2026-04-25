import SwiftUI

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
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

extension Color {
    static let tagColors: [String] = [
        "FF6B6B", "4ECDC4", "45B7D1", "96CEB4",
        "FFEAA7", "DDA0DD", "98D8C8", "F7DC6F",
    ]
}

// MARK: - Calm Paper Design Tokens

extension Color {
    static let moBg          = Color("MoBg")
    static let moBgElev      = Color("MoBgElev")
    static let moBgElev2     = Color("MoBgElev2")
    static let moInk         = Color("MoInk")
    static let moHair        = Color("MoHair")
    static let moHairStrong  = Color("MoHairStrong")
    static let moDanger      = Color("MoDanger")
    static let moPin         = Color("MoPin")

    static var moInkMuted: Color { Color("MoInk").opacity(0.58) }
    static var moInkFaint: Color { Color("MoInk").opacity(0.36) }
    static var moInkUltra: Color { Color("MoInk").opacity(0.14) }

    static func moAccent(_ key: String) -> Color {
        (AccentPreset(rawValue: key) ?? .indigo).color
    }
}

// MARK: - Accent Preset

enum AccentPreset: String, CaseIterable, Sendable, Identifiable {
    case indigo
    case sumi
    case sabi
    case matcha
    case enji
    case konjou

    var id: String { rawValue }

    var color: Color {
        switch self {
        case .indigo: Color(hex: "1F3A5F")
        case .sumi:   Color(hex: "2B2B33")
        case .sabi:   Color(hex: "8A4B3A")
        case .matcha: Color(hex: "4A6B4E")
        case .enji:   Color(hex: "7A2E3B")
        case .konjou: Color(hex: "2E4C7E")
        }
    }

    var displayName: String {
        switch self {
        case .indigo: "藍"
        case .sumi:   "墨"
        case .sabi:   "錆"
        case .matcha: "抹茶"
        case .enji:   "臙脂"
        case .konjou: "紺青"
        }
    }
}
