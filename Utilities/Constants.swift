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

/// DesignCode UI–style spacing scale (4pt grid). Use for padding, margins, and gaps.
enum Spacing {
    /// 2pt – fine-tuning
    static let xxxs: CGFloat = 2
    /// 4pt – smallest unit
    static let xxs: CGFloat = 4
    /// 8pt – small elements (buttons, chips)
    static let xs: CGFloat = 8
    /// 12pt – small-to-medium gaps
    static let sm: CGFloat = 12
    /// 16pt – default section padding
    static let md: CGFloat = 16
    /// 20pt – medium-large
    static let lg: CGFloat = 20
    /// 24pt – large (section tops)
    static let xl: CGFloat = 24
    /// 32pt – large elements (cards, modals)
    static let xxl: CGFloat = 32
    /// 40pt – section spacing
    static let xxxl: CGFloat = 40
}

enum LayoutConstants {
    static let cardWidth: CGFloat = 60
    static let cardHeight: CGFloat = 70
    static let cardCornerRadius: CGFloat = 18
    static let gridSpacing: CGFloat = Spacing.xs
    static let sectionPadding: CGFloat = Spacing.md
    static let cardPadding: CGFloat = Spacing.sm
    static let minimumTapSize: CGSize = .init(width: 44, height: 44)
}

enum AnimationConstants {
    static let cardSpring: Animation = .interpolatingSpring(
        mass: 1,
        stiffness: 170,
        damping: 26,
        initialVelocity: 0
    )

    static let peekSpring: Animation = .spring(response: 0.6, dampingFraction: 0.7, blendDuration: 0.2)
    static let filterEase: Animation = .easeInOut(duration: 0.35)
    static let shimmerDuration: Double = 1.6
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

