import SwiftUI

// MARK: - Color Tokens

extension Color {
    static let ds = DSColors()

    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet(charactersIn: "#"))
        let scanner = Scanner(string: hex)
        var rgbValue: UInt64 = 0
        scanner.scanHexInt64(&rgbValue)
        self.init(
            red: Double((rgbValue & 0xFF0000) >> 16) / 255,
            green: Double((rgbValue & 0x00FF00) >> 8) / 255,
            blue: Double(rgbValue & 0x0000FF) / 255
        )
    }
}

struct DSColors {
    let bg = Color(hex: "0f172a")
    let card = Color(hex: "1e293b")
    let cardHover = Color(hex: "263548")
    let textPrimary = Color(hex: "f1f5f9")
    let muted = Color(hex: "94a3b8")
    let border = Color(hex: "334155")
    let accentBlue = Color(hex: "38bdf8")
    let accentTeal = Color(hex: "14b8a6")
    let accentOrange = Color(hex: "f97316")
    let accentPurple = Color(hex: "a78bfa")
    let accentRed = Color(hex: "ef4444")
}

// MARK: - Typography

extension Font {
    static let dsTitle = Font.system(size: 24, weight: .bold)
    static let dsHeadline = Font.system(size: 18, weight: .semibold)
    static let dsBody = Font.system(size: 15, weight: .regular)
    static let dsCaption = Font.system(size: 12, weight: .regular)
}

// MARK: - Spacing

enum Spacing {
    static let xs: CGFloat = 4
    static let sm: CGFloat = 8
    static let md: CGFloat = 16
    static let lg: CGFloat = 24
    static let xl: CGFloat = 32
}
