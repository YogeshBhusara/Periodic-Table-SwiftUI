//
//  ColorManager.swift
//  Periodic Table
//
//  Created by Cursor AI on 11/12/25.
//

import SwiftUI

final class ColorManager {
    static let shared = ColorManager()

    private init() {}

    private let lightPalette: [ElementCategory: Color] = [
        .alkaliMetals: Color(hex: "#4A90E2"),
        .alkalineEarthMetals: Color(hex: "#5DADE2"),
        .transitionMetals: Color(hex: "#2E86C1"),
        .postTransitionMetals: Color(hex: "#2874A6"),
        .lanthanides: Color(hex: "#27AE60"),
        .actinides: Color(hex: "#F39C12"),
        .metalloids: Color(hex: "#16A085"),
        .nonmetals: Color(hex: "#FF6B6B"),
        .halogens: Color(hex: "#F4D03F"),
        .nobleGases: Color(hex: "#9B59B6"),
        .unknown: Color(hex: "#95A5A6")
    ]

    private let darkPalette: [ElementCategory: Color] = [
        .alkaliMetals: Color(hex: "#1F4D78"),
        .alkalineEarthMetals: Color(hex: "#1F618D"),
        .transitionMetals: Color(hex: "#154360"),
        .postTransitionMetals: Color(hex: "#0B3C5D"),
        .lanthanides: Color(hex: "#145A32"),
        .actinides: Color(hex: "#7E5109"),
        .metalloids: Color(hex: "#0E6251"),
        .nonmetals: Color(hex: "#C0392B"),
        .halogens: Color(hex: "#B7950B"),
        .nobleGases: Color(hex: "#5B2C6F"),
        .unknown: Color(hex: "#566573")
    ]

    func color(for category: ElementCategory, colorScheme: ColorScheme = .light) -> Color {
        switch colorScheme {
        case .dark:
            return darkPalette[category] ?? Color(hex: "#7F8C8D")
        default:
            return lightPalette[category] ?? Color(hex: "#7F8C8D")
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

