//
//  ColorManager.swift
//  Periodic Table
//
//  Created by Cursor AI on 11/12/25.
//
//  Design: Bold, Clear, Vibrant – categorical (Vibrant Science) + functional colors.
//

import SwiftUI

final class ColorManager {
    static let shared = ColorManager()

    private init() {}

    // MARK: - Categorical (Vibrant Science)

    private let lightPalette: [ElementCategory: Color] = [
        .alkaliMetals: Color(hex: "#FF8C00"),           // Solar Orange
        .alkalineEarthMetals: Color(hex: "#FFB347"),   // Lighter orange
        .transitionMetals: Color(hex: "#007AFF"),      // Electric Blue
        .postTransitionMetals: Color(hex: "#5AC8FA"), // Sky Blue
        .lanthanides: Color(hex: "#30D158"),           // Green
        .actinides: Color(hex: "#FF9F0A"),           // Amber
        .metalloids: Color(hex: "#66D4CF"),           // Teal
        .nonmetals: Color(hex: "#34C759"),            // Vivid Green
        .halogens: Color(hex: "#FF2D55"),             // Hot Pink
        .nobleGases: Color(hex: "#AF52DE"),            // Atomic Purple
        .unknown: Color(hex: "#8E8E93")               // Gray
    ]

    private let darkPalette: [ElementCategory: Color] = [
        .alkaliMetals: Color(hex: "#FF8C00"),
        .alkalineEarthMetals: Color(hex: "#FFB347"),
        .transitionMetals: Color(hex: "#007AFF"),
        .postTransitionMetals: Color(hex: "#5AC8FA"),
        .lanthanides: Color(hex: "#30D158"),
        .actinides: Color(hex: "#FF9F0A"),
        .metalloids: Color(hex: "#66D4CF"),
        .nonmetals: Color(hex: "#34C759"),
        .halogens: Color(hex: "#FF2D55"),
        .nobleGases: Color(hex: "#AF52DE"),
        .unknown: Color(hex: "#8E8E93")
    ]

    // MARK: - Functional

    /// Quiz correct / success state
    static let quizSuccess = Color(hex: "#28CD41")
    /// Quiz incorrect / error state
    static let quizError = Color(hex: "#FF3B30")

    func color(for category: ElementCategory, colorScheme: ColorScheme = .light) -> Color {
        switch colorScheme {
        case .dark:
            return darkPalette[category] ?? Color(hex: "#8E8E93")
        default:
            return lightPalette[category] ?? Color(hex: "#8E8E93")
        }
    }

    func gradient(for category: ElementCategory, colorScheme: ColorScheme = .light) -> LinearGradient {
        let base = color(for: category, colorScheme: colorScheme)
        let lighter = base.opacity(0.7)
        let darker = base.opacity(1)
        return LinearGradient(
            colors: [lighter, darker],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}

extension Color {
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
            (a, r, g, b) = (255, 127, 127, 127)
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

