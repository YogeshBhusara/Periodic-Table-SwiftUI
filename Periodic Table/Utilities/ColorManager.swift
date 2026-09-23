//
//  ColorManager.swift
//  Periodic Table
//
//  Atmospheric category meshes: a deep edge, a saturated mid, and a luminous glow.
//  Inspired by stacked widget cards (soft radial light on a near-black canvas).
//

import SwiftUI

struct CategoryMesh: Equatable {
    let deep: Color
    let mid: Color
    let glow: Color
}

final class ColorManager {
    static let shared = ColorManager()

    private init() {}

    private let meshes: [ElementCategory: CategoryMesh] = [
        .alkaliMetals: CategoryMesh(
            deep: Color(hex: "#3A1604"),
            mid: Color(hex: "#FF7A18"),
            glow: Color(hex: "#FFD27A")
        ),
        .alkalineEarthMetals: CategoryMesh(
            deep: Color(hex: "#3A2410"),
            mid: Color(hex: "#E08A3C"),
            glow: Color(hex: "#FFE0A8")
        ),
        .transitionMetals: CategoryMesh(
            deep: Color(hex: "#07144A"),
            mid: Color(hex: "#2F5BFF"),
            glow: Color(hex: "#9EBEFF")
        ),
        .postTransitionMetals: CategoryMesh(
            deep: Color(hex: "#06283A"),
            mid: Color(hex: "#1C9BE0"),
            glow: Color(hex: "#9AE8FF")
        ),
        .lanthanides: CategoryMesh(
            deep: Color(hex: "#102E14"),
            mid: Color(hex: "#3DDC6A"),
            glow: Color(hex: "#D8FF8A")
        ),
        .actinides: CategoryMesh(
            deep: Color(hex: "#3A100C"),
            mid: Color(hex: "#FF5A3C"),
            glow: Color(hex: "#FFC2A8")
        ),
        .metalloids: CategoryMesh(
            deep: Color(hex: "#042824"),
            mid: Color(hex: "#14C4B4"),
            glow: Color(hex: "#A8FFF0")
        ),
        .nonmetals: CategoryMesh(
            deep: Color(hex: "#0E2A18"),
            mid: Color(hex: "#22C55E"),
            glow: Color(hex: "#B6FF6A")
        ),
        .halogens: CategoryMesh(
            deep: Color(hex: "#4A1030"),
            mid: Color(hex: "#FF3D78"),
            glow: Color(hex: "#FFB0D0")
        ),
        .nobleGases: CategoryMesh(
            deep: Color(hex: "#1A1040"),
            mid: Color(hex: "#8B5CFF"),
            glow: Color(hex: "#E4D0FF")
        ),
        .unknown: CategoryMesh(
            deep: Color(hex: "#121216"),
            mid: Color(hex: "#3A3A44"),
            glow: Color(hex: "#A0A0AA")
        )
    ]

    static let quizSuccess = Color(hex: "#3DFF8A")
    static let quizError = Color(hex: "#FF4D6A")

    func mesh(for category: ElementCategory) -> CategoryMesh {
        meshes[category] ?? CategoryMesh(
            deep: Color(hex: "#121216"),
            mid: Color(hex: "#3A3A44"),
            glow: Color(hex: "#A0A0AA")
        )
    }

    func color(for category: ElementCategory, colorScheme: ColorScheme = .dark) -> Color {
        mesh(for: category).mid
    }

    func gradient(for category: ElementCategory, colorScheme: ColorScheme = .dark) -> LinearGradient {
        let mesh = mesh(for: category)
        return LinearGradient(
            colors: [mesh.glow, mesh.mid, mesh.deep],
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
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
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
