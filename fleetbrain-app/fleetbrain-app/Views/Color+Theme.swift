import SwiftUI

extension Color {
    // Background and Cards
    static let bg = Color(hex: "#F4F5F7") // Very light gray background
    static let card = Color.white
    static let cardBorder = Color(white: 0.9)

    // Identity Colors
    static let primary = Color(hex: "#1E293B") // Navy Blue
    static let accent = Color(hex: "#FF6B00")  // Vibrant Orange

    // Status Colors
    static let danger = Color(hex: "#EF4444") // Red
    static let success = Color(hex: "#10B981") // Teal Green

    // Texts
    static let textPrimary = Color(hex: "#0F172A") // Deep slate for high contrast
    static let textSecondary = Color(hex: "#64748B") // Medium cool gray
}

// Clean light-mode card modifier with subtle diffuse shadow
struct CleanCardModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(Color.card)
            .cornerRadius(24)
            .shadow(color: Color.black.opacity(0.04), radius: 10, x: 0, y: 4)
    }
}

extension View {
    func cleanCard() -> some View {
        self.modifier(CleanCardModifier())
    }
}

// HEX SUPPORT
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: .alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)

        let r, g, b: UInt64
        (r, g, b) = ((int >> 16) & 255, (int >> 8) & 255, int & 255)

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255
        )
    }
}
