//
//  ElementCard.swift
//  Periodic Table
//
//  Created by Cursor AI on 11/12/25.
//

import Foundation

struct ElementCard: Identifiable, Codable, Equatable, Hashable {
    let atomicNumber: Int
    let symbol: String
    let name: String
    let atomicMass: Double
    let category: ElementCategory
    let electronConfiguration: String
    let oxidationStates: [Int]
    let electronegativity: Double?
    let meltingPoint: Double?
    let boilingPoint: Double?
    let density: Double?
    let description: String
    let uses: [String]
    let historicalFacts: String
    let discoveryYear: String?
    let layout: ElementLayout

    var id: Int { atomicNumber }

    var formattedAtomicMass: String {
        NumberFormatter.atomicMassFormatter.string(from: NSNumber(value: atomicMass)) ?? "\(atomicMass)"
    }

    var primaryOxidationState: Int? {
        oxidationStates.sorted { lhs, rhs in
            abs(lhs) > abs(rhs)
        }.first
    }

    var isMetal: Bool {
        switch category {
        case .alkaliMetals,
             .alkalineEarthMetals,
             .lanthanides,
             .actinides,
             .transitionMetals,
             .postTransitionMetals:
            return true
        default:
            return false
        }
    }
}

struct ElementLayout: Codable, Equatable, Hashable {
    let row: Int
    let column: Int
    let period: Int
    let group: Int?
    let block: String
    let isLanthanide: Bool
    let isActinide: Bool
}

extension NumberFormatter {
    static let atomicMassFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 3
        formatter.locale = .current
        return formatter
    }()
}

extension ElementCard {
    static let hydrogen = ElementCard(
        atomicNumber: 1,
        symbol: "H",
        name: "Hydrogen",
        atomicMass: 1.008,
        category: .nonmetals,
        electronConfiguration: "1s¹",
        oxidationStates: [-1, 1],
        electronegativity: 2.20,
        meltingPoint: 13.99,
        boilingPoint: 20.27,
        density: 0.08988,
        description: String(
            localized: "The simplest and most abundant element in the universe.",
            comment: "Hydrogen description"
        ),
        uses: [
            String(localized: "Fuel cells", comment: "Hydrogen use"),
            String(localized: "Rocket propellant", comment: "Hydrogen use")
        ],
        historicalFacts: String(
            localized: "Identified as a distinct substance by Henry Cavendish in 1766.",
            comment: "Hydrogen historical fact"
        ),
        discoveryYear: "1766",
        layout: ElementLayout(row: 1, column: 1, period: 1, group: 1, block: "s", isLanthanide: false, isActinide: false)
    )

    static let helium = ElementCard(
        atomicNumber: 2,
        symbol: "He",
        name: "Helium",
        atomicMass: 4.0026,
        category: .nobleGases,
        electronConfiguration: "1s²",
        oxidationStates: [],
        electronegativity: nil,
        meltingPoint: 0.95,
        boilingPoint: 4.22,
        density: 0.1786,
        description: String(
            localized: "A lightweight noble gas used in balloons and cryogenics.",
            comment: "Helium description"
        ),
        uses: [
            String(localized: "Cooling superconducting magnets", comment: "Helium use"),
            String(localized: "Lighter-than-air balloons", comment: "Helium use")
        ],
        historicalFacts: String(
            localized: "First detected in 1868 by astronomer Jules Janssen during a solar eclipse.",
            comment: "Helium historical fact"
        ),
        discoveryYear: "1868",
        layout: ElementLayout(row: 1, column: 18, period: 1, group: 18, block: "s", isLanthanide: false, isActinide: false)
    )

    static let sampleElements: [ElementCard] = [hydrogen, helium]
}
    }
}

