//
//  Constants.swift
//  Periodic Table
//
//  Created by Cursor AI on 11/12/25.
//
//  Spacing follows DesignCode UI: 4pt grid, multiples of 4.
//  See: https://designcodeui.com/components/spacing
//

import SwiftUI

// MARK: - Core Style & Theme
// Near-black canvas, signal yellow, and large continuous corners.
// Color lives inside widget cards; the canvas stays dark.

enum AppTheme {
    /// Near-black canvas
    static let canvas = Color(hex: "#07070A")
    /// Elevated panels sitting on the canvas
    static let elevated = Color(hex: "#141418")
    /// Primary action, waveforms, and ticks
    static let signal = Color(hex: "#E6FF47")

    static let backgroundColorDark = canvas
    static let cardBackgroundDark = elevated

    static let cornerRadiusHero: CGFloat = 32
    static let cornerRadiusLarge: CGFloat = 28
    static let cornerRadiusMedium: CGFloat = 18
}

/// DesignCode UI–style spacing scale (4pt grid). Use for padding, margins, and gaps.
enum Spacing {
    /// 2pt – fine-tuning (e.g. tight icon padding)
    static let xxxs: CGFloat = 2
    /// 4pt – smallest unit
    static let xxs: CGFloat = 4
    /// 8pt – small elements (buttons, chips, compact controls)
    static let xs: CGFloat = 8
    /// 12pt – small-to-medium gaps
    static let sm: CGFloat = 12
    /// 16pt – default section/block padding, medium spacing
    static let md: CGFloat = 16
    /// 20pt – medium-large
    static let lg: CGFloat = 20
    /// 24pt – large (e.g. section tops)
    static let xl: CGFloat = 24
    /// 32pt – large elements (cards, modals)
    static let xxl: CGFloat = 32
    /// 40pt – section spacing
    static let xxxl: CGFloat = 40
}

enum LayoutConstants {
    static let sectionPadding: CGFloat = Spacing.md
    static let elementCardCornerRadius: CGFloat = AppTheme.cornerRadiusHero
    static let glassCircleButtonDiameter: CGFloat = 60
}

// MARK: - DesignCode UI effects (shadows & blur)
// Use presets for elevation: buttons/chips → subtle, cards/inputs → normal, modals/floating → strong.
// Dark mode: stronger shadow opacity and optional inner glow for depth.

enum ShadowPreset {
    /// Low elevation: buttons, chips, small controls
    case subtle
    /// Medium elevation: cards, list rows, inputs
    case normal
    /// High elevation: modals, sheets, main floating cards
    case strong

    func parameters(colorScheme: ColorScheme) -> (color: Color, radius: CGFloat, x: CGFloat, y: CGFloat) {
        switch self {
        case .subtle:
            let opacity = colorScheme == .dark ? 0.38 : 0.12
            return (.black.opacity(opacity), 6, 0, 2)
        case .normal:
            let opacity = colorScheme == .dark ? 0.45 : 0.18
            return (.black.opacity(opacity), 14, 0, 6)
        case .strong:
            let opacity = colorScheme == .dark ? 0.52 : 0.28
            return (.black.opacity(opacity), 30, 0, 18)
        }
    }
}

enum BlurConstants {
    /// Default radius for background/layer blur (glass panels)
    static let panelBlurRadius: CGFloat = 20
}

extension View {
    /// Applies a DesignCode-style shadow preset. Use for consistent elevation across the app.
    func designCodeShadow(_ preset: ShadowPreset, colorScheme: ColorScheme) -> some View {
        let p = preset.parameters(colorScheme: colorScheme)
        return shadow(color: p.color, radius: p.radius, x: p.x, y: p.y)
    }

    /// Optional inner glow in dark mode for elevated surfaces (use with designCodeShadow).
    func designCodeInnerGlow(colorScheme: ColorScheme, cornerRadius: CGFloat, opacity: Double = 0.12) -> some View {
        overlay {
            if colorScheme == .dark {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .strokeBorder(Color.white.opacity(opacity), lineWidth: 1)
            } else {
                Color.clear
            }
        }
    }
}

enum AnimationConstants {
    static let filterEase: Animation = .easeInOut(duration: 0.35)

    /// Smooth spring for grid overlay open/close and matched-geometry transition.
    static let gridOverlaySpring: Animation = .spring(response: 0.42, dampingFraction: 0.86)

    // MARK: - Spotify-style (UIViewPropertyAnimator–like) transitions
    // See: https://github.com/sgl0v/SpotifyPlayer and https://onswiftwings.com/posts/interactive-animations/
    /// Open transition: ~0.7s, no overshoot (damping 1.0). Use for card→detail and carousel.
    static let spotifyOpen: Animation = .spring(response: 0.55, dampingFraction: 1.0)
    /// Close transition: ~0.7s, slight settle (damping 0.9). Use for dismissing detail.
    static let spotifyClose: Animation = .spring(response: 0.55, dampingFraction: 0.9)

    /// Sheet present/dismiss: slightly longer, smoother so card→detail feels continuous.
    static let sheetTransition: Animation = .spring(response: 0.52, dampingFraction: 0.92)
    /// Content inside sheet: quick fade so it feels part of the sheet motion, not a second pop.
    static let sheetContentAppear: Animation = .easeOut(duration: 0.28)
}

enum AccessibilityLabels {
    static func elementCard(_ element: ElementCard) -> String {
        String(
            localized: "\(element.name), atomic number \(element.atomicNumber), \(element.category.categoryName)",
            comment: "Accessibility label for element card"
        )
    }
}

enum SoundEffects: String {
    case cardTap = "card-tap"
    case cardExpand = "card-expand"
    case quizCorrect = "quiz-correct"
    case quizIncorrect = "quiz-incorrect"
}

