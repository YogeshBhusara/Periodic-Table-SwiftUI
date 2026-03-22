//
//  AppFont.swift
//  Periodic Table
//
//  Typography: SF Pro Rounded (headings/symbol), SF Pro Text (body), SF Mono (data).
//  Vibe: Bold, Clear, Vibrant.
//

import SwiftUI

enum AppFont {
    // MARK: - Symbol / Hero (Flashcards)

    /// SF Pro Rounded, Black, 80pt – element symbol on cards
    static let atomicSymbol = Font.system(size: 80, weight: .black, design: .rounded)

    // MARK: - Headings

    /// SF Pro Rounded, Bold, 34pt – page titles
    static let heading1 = Font.system(size: 34, weight: .bold, design: .rounded)

    /// SF Pro Rounded, Semibold, 20pt – element names, section headers
    static let heading2 = Font.system(size: 20, weight: .semibold, design: .rounded)

    /// Convenience: heading with custom size/weight (rounded)
    static func heading(size: CGFloat = 40, weight: Font.Weight = .heavy) -> Font {
        Font.system(size: size, weight: weight, design: .rounded)
    }

    // MARK: - Body

    /// SF Pro Text, Regular, 17pt – body copy
    static let fontBody = Font.system(size: 17, weight: .regular, design: .default)

    static func body(size: CGFloat = 17) -> Font {
        Font.system(size: size, weight: .regular, design: .default)
    }

    static func semibold(size: CGFloat = 17) -> Font {
        Font.system(size: size, weight: .semibold, design: .default)
    }

    static func bold(size: CGFloat = 17) -> Font {
        Font.system(size: size, weight: .bold, design: .default)
    }

    // MARK: - Data / Mono (configurations, numbers)

    /// SF Mono, Medium, 12pt – electron config, numeric data
    static let fontDataMono = Font.system(size: 12, weight: .medium, design: .monospaced)

    static func mono(size: CGFloat, weight: Font.Weight = .regular) -> Font {
        Font.system(size: size, weight: weight, design: .monospaced)
    }

    /// Large display (e.g. big atomic number in background)
    static func displayMono(size: CGFloat = 200) -> Font {
        Font.system(size: size, weight: .medium, design: .monospaced)
    }
}
