//
//  ElementCategory.swift
//  Periodic Table
//
//  Created by Cursor AI on 11/12/25.
//

import SwiftUI

enum ElementCategory: String, Codable, CaseIterable, Identifiable {
    case alkaliMetals
    case alkalineEarthMetals
    case lanthanides
    case actinides
    case transitionMetals
    case postTransitionMetals
    case metalloids
    case nonmetals
    case halogens
    case nobleGases
    case unknown

    var id: String { rawValue }

    var color: Color {
        ColorManager.shared.color(for: self)
    }

    var gradient: LinearGradient {
        ColorManager.shared.gradient(for: self)
    }

    var categoryName: String {
        switch self {
        case .alkaliMetals:
            String(localized: "Alkali Metals", comment: "Element category")
        case .alkalineEarthMetals:
            String(localized: "Alkaline Earth Metals", comment: "Element category")
        case .lanthanides:
            String(localized: "Lanthanides", comment: "Element category")
        case .actinides:
            String(localized: "Actinides", comment: "Element category")
        case .transitionMetals:
            String(localized: "Transition Metals", comment: "Element category")
        case .postTransitionMetals:
            String(localized: "Post-Transition Metals", comment: "Element category")
        case .metalloids:
            String(localized: "Metalloids", comment: "Element category")
        case .nonmetals:
            String(localized: "Non-metals", comment: "Element category")
        case .halogens:
            String(localized: "Halogens", comment: "Element category")
        case .nobleGases:
            String(localized: "Noble Gases", comment: "Element category")
        case .unknown:
            String(localized: "Unknown", comment: "Element category")
        }
    }
}

