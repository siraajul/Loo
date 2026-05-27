import SwiftUI

// MARK: - Brand Colors

extension Color {
    static let brand          = Color(hex: 0x00A86B)
    static let brandDark      = Color(hex: 0x007A4D)
    static let accent         = Color(hex: 0xFFB627)
    static let success        = Color(hex: 0x34C759)
    static let warning        = Color(hex: 0xFF9500)
    static let danger         = Color(hex: 0xFF3B30)
    // Gender marker colors
    static let womenPink      = Color(hex: 0xFF2D78)   // safety pink — female washrooms
    static let menBlue        = Color(hex: 0x007AFF)   // iOS blue — male washrooms
    static let surface        = Color(.systemBackground)
    static let surfaceElev    = Color(.secondarySystemBackground)
    static let textPrimary    = Color(.label)
    static let textSecondary  = Color(.secondaryLabel)

    init(hex: UInt32) {
        self.init(
            red:   Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >>  8) & 0xFF) / 255,
            blue:  Double( hex        & 0xFF) / 255
        )
    }
}

// MARK: - Typography

extension Font {
    static let looTitle    = Font.system(size: 28, weight: .bold)
    static let looHeadline = Font.system(size: 20, weight: .semibold)
    static let looBody     = Font.system(size: 17, weight: .regular)
    static let looCaption  = Font.system(size: 13, weight: .medium)
}

// MARK: - Spacing

enum Spacing {
    static let xs: CGFloat =  4
    static let sm: CGFloat =  8
    static let md: CGFloat = 16
    static let lg: CGFloat = 24
    static let xl: CGFloat = 32
}

// MARK: - Corner Radii

enum Radius {
    static let card:   CGFloat = 16
    static let sheet:  CGFloat = 24
    static let button: CGFloat = 28
}
