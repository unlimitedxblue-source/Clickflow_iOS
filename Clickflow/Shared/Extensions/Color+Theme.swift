import SwiftUI

extension Color {
    static let clickflowBackground = Color(hex: 0x000000)
    static let clickflowNeonCyan = Color(hex: 0x00F2FE)
    static let clickflowVividEmerald = Color(hex: 0x00F5A0)
    static let clickflowGlass = Color.white.opacity(0.08)
    static let clickflowGlassBorder = Color.white.opacity(0.14)

    init(hex: UInt32, alpha: Double = 1.0) {
        let red = Double((hex & 0xFF0000) >> 16) / 255.0
        let green = Double((hex & 0x00FF00) >> 8) / 255.0
        let blue = Double(hex & 0x0000FF) / 255.0
        self.init(.sRGB, red: red, green: green, blue: blue, opacity: alpha)
    }
}

extension LinearGradient {
    static let clickflowAccent = LinearGradient(
        colors: [.clickflowNeonCyan, .clickflowVividEmerald],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}
