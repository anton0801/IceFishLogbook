import Foundation
import SwiftUI

extension Color {
    // Primary Colors
    static let iceBackground = Color(hex: "E8F4F8")
    static let frostBlue = Color(hex: "4A90E2")
    static let deepIce = Color(hex: "2C5F8D")
    static let glacierGreen = Color(hex: "7FB3A3")
    static let winterGray = Color(hex: "8B9DAF")
    static let snowWhite = Color(hex: "FAFCFD")
    
    // Gradient Colors
    static let iceGradientStart = Color(hex: "D4E9F7")
    static let iceGradientEnd = Color(hex: "F0F8FF")
    
    // Result Colors
    static let resultPoor = Color(hex: "B8C5D0")
    static let resultNormal = Color(hex: "8B9DAF")
    static let resultGood = Color(hex: "7FB3A3")
    
    // Weather Colors
    static let weatherCold = Color(hex: "A8D8EA")
    static let weatherWindy = Color(hex: "8B9DAF")
    static let weatherSnow = Color(hex: "E8F4F8")
    static let weatherClear = Color(hex: "87CEEB")
    
    // Helper initializer for hex colors
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - Gradient Definitions
extension LinearGradient {
    static let iceBackground = LinearGradient(
        colors: [Color.iceGradientStart, Color.iceGradientEnd],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let frostOverlay = LinearGradient(
        colors: [Color.frostBlue.opacity(0.3), Color.clear],
        startPoint: .top,
        endPoint: .bottom
    )
    
    static let deepIceGradient = LinearGradient(
        colors: [Color.deepIce, Color.frostBlue],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}
