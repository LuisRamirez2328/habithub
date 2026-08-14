import SwiftUI

enum Theme {
    static let background = Color(red: 0.04, green: 0.04, blue: 0.04)
    static let card = Color(red: 0.07, green: 0.07, blue: 0.07)
    static let border = Color(red: 0.15, green: 0.15, blue: 0.15)
    static let accent = Color(red: 0.13, green: 0.77, blue: 0.37)
    static let textPrimary = Color(red: 0.98, green: 0.98, blue: 0.98)
    static let textSecondary = Color(red: 0.45, green: 0.45, blue: 0.45)

    private static let palette: [String: Color] = [
        "mint": Color(red: 0.13, green: 0.77, blue: 0.37),
        "sky": Color(red: 0.22, green: 0.62, blue: 0.98),
        "indigo": Color(red: 0.47, green: 0.44, blue: 0.98),
        "amber": Color(red: 0.98, green: 0.75, blue: 0.24),
        "rose": Color(red: 0.97, green: 0.38, blue: 0.52),
        "teal": Color(red: 0.20, green: 0.75, blue: 0.73),
    ]

    static func color(_ name: String) -> Color {
        palette[name] ?? accent
    }
}
