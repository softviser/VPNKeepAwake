import SwiftUI

// MARK: - App Theme
enum AppTheme {
    // MARK: - Brand Colors
    static let primaryGradient = LinearGradient(
        colors: [Color(hex: "6366F1"), Color(hex: "8B5CF6")],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let connectedGradient = LinearGradient(
        colors: [Color(hex: "10B981"), Color(hex: "34D399")],
        startPoint: .top,
        endPoint: .bottom
    )
    
    static let disconnectedGradient = LinearGradient(
        colors: [Color(hex: "EF4444"), Color(hex: "F97316")],
        startPoint: .top,
        endPoint: .bottom
    )
    
    // MARK: - Status Colors
    static let connected = Color(hex: "10B981")
    static let disconnected = Color(hex: "EF4444")
    static let warning = Color(hex: "F59E0B")
    static let info = Color(hex: "6366F1")
    
    // MARK: - Neutral Colors
    static let background = Color(hex: "0F172A")
    static let cardBackground = Color(hex: "1E293B")
    static let cardBorder = Color(hex: "334155")
    static let textPrimary = Color(hex: "F8FAFC")
    static let textSecondary = Color(hex: "94A3B8")
    static let textTertiary = Color(hex: "64748B")
}

// MARK: - Color Extension
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int >> 0 & 0xF) * 17)
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

// MARK: - StatusBadge Color Mapping
extension StatusBadge {
    static func color(for status: ConnectionStatus) -> Color {
        switch status {
        case .connected: return AppTheme.connected
        case .disconnected: return AppTheme.disconnected
        case .warning: return AppTheme.warning
        }
    }
}

enum ConnectionStatus {
    case connected, disconnected, warning
}
