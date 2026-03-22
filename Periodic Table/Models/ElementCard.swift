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
    /// Electron shell counts from CSV (e.g. [2, 8, 1] for sodium). Used for orbital visualization.
    let shells: [Int]?
    /// URL to GLB 3D Bohr model from Bowserinator/Periodic-Table-JSON (bohr_model_3d).
    let bohrModel3DURL: String?
    /// Discoverer name from CSV (discovered_by).
    let discoveredBy: String?

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

    var approximateValenceElectrons: Int {
        guard let group = layout.group, (1...18).contains(group) else { return 0 }

        switch group {
        case 1, 13:
            return 1
        case 2, 14:
            return 2
        case 15:
            return 5
        case 16:
            return 6
        case 17:
            return 7
        case 18:
            return 8
        default:
            return max(0, min(group % 8, 8))
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
    /// Curated fun / interesting facts keyed by atomic number.
    static let predefinedFunFacts: [Int: [String]] = [
        1: [
            "Most abundant element in the universe powering stars through fusion.",
            "The lightest element and extremely flammable.",
            "Used in fuel cells that produce electricity and water."
        ],
        2: [
            "Second most abundant element in the universe.",
            "So light that it slowly escapes Earth's gravity into space.",
            "Liquid helium cools MRI magnets and superconductors."
        ],
        3: [
            "The lightest metal and can float on water.",
            "One of the few elements created during the Big Bang.",
            "Key component of rechargeable lithium-ion batteries."
        ],
        4: [
            "Extremely stiff and lightweight metal.",
            "Found in gemstones like emerald and aquamarine.",
            "Used in aerospace structures and satellite mirrors."
        ],
        5: [
            "Produces bright green flames in fireworks.",
            "Used to make heat-resistant borosilicate glass.",
            "Important in detergents and fiberglass."
        ],
        6: [
            "Foundation of all known life on Earth.",
            "Exists as diamond, graphite, and graphene.",
            "Essential for fuels, plastics, and steel production."
        ],
        7: [
            "Makes up about 78% of Earth's atmosphere.",
            "Essential component of DNA and proteins.",
            "Used to produce fertilizers that feed global agriculture."
        ],
        8: [
            "Supports respiration for most living organisms.",
            "Third most abundant element in the universe.",
            "Used in medical oxygen therapy and steelmaking."
        ],
        9: [
            "The most electronegative and reactive element.",
            "Never found free in nature due to its reactivity.",
            "Fluoride compounds help prevent tooth decay."
        ],
        10: [
            "Glows reddish-orange when electrified.",
            "More common in stars than on Earth.",
            "Used in neon signs and lighting."
        ],
        11: [
            "Reacts violently with water.",
            "Found naturally as sodium chloride (table salt).",
            "Important for nerve signals in the human body."
        ],
        12: [
            "Burns with an intense white flame.",
            "Central atom in chlorophyll for photosynthesis.",
            "Used in lightweight alloys for aircraft."
        ],
        13: [
            "Most abundant metal in Earth's crust.",
            "Lightweight and corrosion resistant.",
            "Used in aircraft, packaging, and construction."
        ],
        14: [
            "Main component of sand and quartz.",
            "Foundation of modern semiconductor electronics.",
            "Used in solar panels and computer chips."
        ],
        15: [
            "Essential for DNA and ATP energy molecules.",
            "White phosphorus glows faintly in the dark.",
            "Used in fertilizers and matches."
        ],
        16: [
            "Known historically as brimstone.",
            "Associated with volcanic activity.",
            "Used to make sulfuric acid for industry."
        ],
        17: [
            "A greenish toxic gas.",
            "Used widely to disinfect drinking water.",
            "Important in producing PVC plastic."
        ],
        18: [
            "Inert noble gas making up about 1% of Earth's atmosphere.",
            "Does not react easily with other elements.",
            "Used in welding and light bulbs."
        ],
        19: [
            "Explodes when dropped in water.",
            "Essential nutrient for plants and humans.",
            "Used in fertilizers."
        ],
        20: [
            "Major component of bones and teeth.",
            "Most abundant mineral in the human body.",
            "Used in cement and construction materials."
        ],
        21: [
            "A rare metal found in small amounts in minerals.",
            "Improves strength of aluminum alloys.",
            "Used in high intensity stadium lights."
        ],
        22: [
            "Strong as steel but much lighter.",
            "Highly resistant to corrosion.",
            "Used in aircraft, spacecraft, and medical implants."
        ],
        23: [
            "Strengthens steel alloys.",
            "Trace nutrient for some organisms.",
            "Used in high strength tools and jet engines."
        ],
        24: [
            "Gives stainless steel corrosion resistance.",
            "Responsible for shiny chrome plating.",
            "Used in pigments and metal alloys."
        ],
        25: [
            "Important element in steel manufacturing.",
            "Essential trace nutrient in humans.",
            "Used in batteries and metal alloys."
        ],
        26: [
            "Main component of steel.",
            "Essential in hemoglobin for oxygen transport.",
            "Earth's core is mostly iron."
        ],
        27: [
            "Produces deep blue pigments in glass.",
            "Used in rechargeable batteries.",
            "Important in superalloys for jet engines."
        ],
        28: [
            "Highly corrosion resistant metal.",
            "Commonly used in stainless steel.",
            "Used in coins and rechargeable batteries."
        ],
        29: [
            "Excellent conductor of electricity.",
            "Used by humans for over 10,000 years.",
            "Essential in electrical wiring and electronics."
        ],
        30: [
            "Important for immune system health.",
            "Used to galvanize steel to prevent rust.",
            "Common in dietary supplements."
        ],
        31: [
            "Melts in your hand at about 30°C.",
            "Used in semiconductors and LEDs.",
            "Important in high speed electronics."
        ],
        32: [
            "Important in early transistor technology.",
            "Used in fiber optics and infrared optics.",
            "Semiconductor material."
        ],
        33: [
            "Well known toxic element.",
            "Historically used in poisons.",
            "Also used in semiconductor electronics."
        ],
        34: [
            "Essential trace nutrient.",
            "Used in glass manufacturing.",
            "Important in solar cells."
        ],
        35: [
            "Only non-metal liquid at room temperature.",
            "Has a reddish brown color.",
            "Used in flame retardants."
        ],
        36: [
            "Noble gas used in lighting.",
            "Used in photographic flash lamps.",
            "Name comes from Greek word meaning hidden."
        ],
        37: [
            "Highly reactive alkali metal.",
            "Can ignite spontaneously in air.",
            "Used in atomic clocks."
        ],
        38: [
            "Produces bright red color in fireworks.",
            "Used in signal flares.",
            "Also used in some ceramics."
        ],
        39: [
            "Used in LED and display technology.",
            "Important in superconductors.",
            "Used in cancer radiation therapy."
        ],
        40: [
            "Highly corrosion resistant.",
            "Used in nuclear reactor components.",
            "Found in zircon gemstones."
        ],
        41: [
            "Improves strength of steel alloys.",
            "Used in superconducting magnets.",
            "Common in jet engine components."
        ],
        42: [
            "Has extremely high melting point.",
            "Strengthens steel alloys.",
            "Used in high temperature industrial equipment."
        ],
        43: [
            "First element artificially produced.",
            "Radioactive element.",
            "Used in medical imaging scans."
        ],
        44: [
            "Rare platinum group metal.",
            "Improves corrosion resistance in alloys.",
            "Used in electronics and catalysts."
        ],
        45: [
            "One of the rarest metals on Earth.",
            "Extremely reflective and corrosion resistant.",
            "Used in catalytic converters."
        ],
        46: [
            "Can absorb large amounts of hydrogen.",
            "Used in catalytic converters.",
            "Important in electronics and jewelry."
        ],
        47: [
            "Best electrical conductor among metals.",
            "Used in jewelry and electronics.",
            "Has antimicrobial properties."
        ],
        48: [
            "Toxic heavy metal.",
            "Used in rechargeable batteries.",
            "Used in pigments and coatings."
        ],
        49: [
            "Very soft metal.",
            "Used in touchscreens and LCD displays.",
            "Component of indium tin oxide coatings."
        ],
        50: [
            "Used historically to make bronze.",
            "Resists corrosion.",
            "Used in solder for electronics."
        ],
        51: [
            "Used in flame retardants.",
            "Strengthens lead alloys.",
            "Known since ancient times."
        ],
        52: [
            "Rare metalloid element.",
            "Used in solar panels.",
            "Improves machinability of metals."
        ],
        53: [
            "Essential for thyroid hormones.",
            "Purple colored vapor when heated.",
            "Added to table salt to prevent deficiency."
        ],
        54: [
            "Noble gas used in powerful flash lamps.",
            "Used in spacecraft ion propulsion.",
            "Produces bright white light."
        ],
        55: [
            "Extremely reactive alkali metal.",
            "Used in the most accurate atomic clocks.",
            "Melts slightly above room temperature."
        ],
        56: [
            "Produces green colors in fireworks.",
            "Used in X-ray contrast imaging.",
            "Heavy alkaline earth metal."
        ],
        57: [
            "First element in the lanthanide series.",
            "Used in camera lenses.",
            "Important in hybrid car batteries."
        ],
        58: [
            "Used in lighter flints.",
            "Important catalyst in petroleum refining.",
            "Common rare earth element."
        ],
        59: [
            "Used in strong magnets.",
            "Produces yellow green glass coloring.",
            "Important in aircraft engines."
        ],
        60: [
            "Creates the strongest permanent magnets.",
            "Used in headphones and wind turbines.",
            "Important rare earth element."
        ],
        61: [
            "Extremely rare radioactive element.",
            "Not found naturally in large quantities.",
            "Used in scientific research."
        ],
        62: [
            "Used in powerful magnets.",
            "Important in nuclear reactors.",
            "Also used in cancer treatments."
        ],
        63: [
            "Used in red phosphors in TV screens.",
            "Highly reactive rare earth element.",
            "Important in anti counterfeit banknotes."
        ],
        64: [
            "Used as MRI contrast agent.",
            "Strong neutron absorber.",
            "Important rare earth metal."
        ],
        65: [
            "Produces green phosphors in displays.",
            "Used in solid state devices.",
            "Rare earth metal."
        ],
        66: [
            "Improves magnet resistance to heat.",
            "Used in electric vehicle motors.",
            "Rare earth metal."
        ],
        67: [
            "Strongest magnetic element.",
            "Used in nuclear reactors.",
            "Rare earth metal."
        ],
        68: [
            "Used in fiber optic communication.",
            "Produces pink colored glass.",
            "Rare earth element."
        ],
        69: [
            "One of the rarest rare earth elements.",
            "Used in portable X-ray machines.",
            "Silvery gray metal."
        ],
        70: [
            "Used in atomic clocks.",
            "Important in laser technology.",
            "Rare earth metal."
        ],
        71: [
            "One of the densest rare earth metals.",
            "Used in PET scan detectors.",
            "Important catalyst in petroleum refining."
        ],
        72: [
            "Used in nuclear control rods.",
            "Absorbs neutrons effectively.",
            "Important in high temperature alloys."
        ],
        73: [
            "Highly corrosion resistant metal.",
            "Used in electronic capacitors.",
            "Used in surgical implants."
        ],
        74: [
            "Highest melting point of any metal.",
            "Used in light bulb filaments.",
            "Important in rocket engines."
        ],
        75: [
            "Extremely rare element.",
            "Improves jet engine alloys.",
            "High melting point metal."
        ],
        76: [
            "Densest naturally occurring element.",
            "Hard and brittle metal.",
            "Used in specialized alloys."
        ],
        77: [
            "Highly corrosion resistant.",
            "Rare platinum group metal.",
            "Used in spark plugs."
        ],
        78: [
            "Precious corrosion resistant metal.",
            "Used in catalytic converters.",
            "Common in jewelry."
        ],
        79: [
            "Highly conductive and corrosion resistant.",
            "Used as currency and jewelry for thousands of years.",
            "Important in electronics."
        ],
        80: [
            "Only metal liquid at room temperature.",
            "Historically used in thermometers.",
            "Toxic heavy metal."
        ],
        81: [
            "Highly toxic metal.",
            "Used historically in poisons.",
            "Also used in electronics."
        ],
        82: [
            "Dense and soft metal.",
            "Used in radiation shielding.",
            "Toxic to humans."
        ],
        83: [
            "Forms beautiful rainbow crystals.",
            "Used in stomach medicines.",
            "Low toxicity metal."
        ],
        84: [
            "Extremely radioactive element.",
            "Discovered by Marie Curie.",
            "Very rare in nature."
        ],
        85: [
            "One of the rarest elements on Earth.",
            "Highly radioactive.",
            "Exists only in tiny quantities."
        ],
        86: [
            "Radioactive noble gas.",
            "Can accumulate in buildings.",
            "Health hazard in poorly ventilated homes."
        ],
        87: [
            "Extremely rare alkali metal.",
            "Highly radioactive.",
            "Only tiny amounts exist naturally."
        ],
        88: [
            "Radioactive alkaline earth metal.",
            "Glows faintly due to radioactivity.",
            "Historically used in luminous paint."
        ],
        89: [
            "Radioactive rare metal.",
            "Discovered in 1899.",
            "Used in experimental cancer treatments."
        ],
        90: [
            "Potential nuclear fuel.",
            "More abundant than uranium.",
            "Used in high temperature ceramics."
        ],
        91: [
            "Rare radioactive metal.",
            "Occurs naturally in uranium ores.",
            "Mainly used for research."
        ],
        92: [
            "Heavy radioactive element.",
            "Used as fuel in nuclear reactors.",
            "Key material in nuclear weapons."
        ],
        93: [
            "Synthetic radioactive element.",
            "Produced in nuclear reactors.",
            "Named after planet Neptune."
        ],
        94: [
            "Used in nuclear weapons.",
            "Used as power source in space probes.",
            "Highly radioactive."
        ],
        95: [
            "Used in household smoke detectors.",
            "Synthetic radioactive element.",
            "Named after the Americas."
        ],
        96: [
            "Named after Marie and Pierre Curie.",
            "Used in space missions.",
            "Radioactive actinide."
        ],
        97: [
            "Synthetic element.",
            "Discovered in Berkeley California.",
            "Used only in scientific research."
        ],
        98: [
            "Powerful neutron emitter.",
            "Used to start nuclear reactors.",
            "Extremely rare synthetic element."
        ],
        99: [
            "Discovered in nuclear explosion debris.",
            "Named after Albert Einstein.",
            "Synthetic radioactive element."
        ],
        100: [
            "Named after Enrico Fermi.",
            "Synthetic radioactive element.",
            "Produced in nuclear reactions."
        ],
        101: [
            "Named after Dmitri Mendeleev.",
            "Synthetic actinide element.",
            "Produced in particle accelerators."
        ],
        102: [
            "Named after Alfred Nobel.",
            "Synthetic radioactive element.",
            "Studied mainly in research labs."
        ],
        103: [
            "Named after cyclotron inventor Ernest Lawrence.",
            "Synthetic element.",
            "Produced in particle accelerators."
        ],
        104: [
            "Named after Ernest Rutherford.",
            "Synthetic transactinide element.",
            "Extremely short half life."
        ],
        105: [
            "Named after Dubna research center.",
            "Synthetic heavy element.",
            "Created in particle accelerators."
        ],
        106: [
            "Named after Glenn Seaborg.",
            "Synthetic element.",
            "Exists only for fractions of a second."
        ],
        107: [
            "Named after Niels Bohr.",
            "Synthetic element.",
            "Produced in particle accelerators."
        ],
        108: [
            "Named after the German state Hesse.",
            "Synthetic element.",
            "Extremely unstable."
        ],
        109: [
            "Named after physicist Lise Meitner.",
            "Synthetic element.",
            "Highly unstable."
        ],
        110: [
            "Discovered in Darmstadt Germany.",
            "Synthetic heavy element.",
            "Short half life."
        ],
        111: [
            "Named after Wilhelm Roentgen.",
            "Synthetic element.",
            "Highly unstable."
        ],
        112: [
            "Named after Nicolaus Copernicus.",
            "Synthetic element.",
            "Very short lived."
        ],
        113: [
            "Named after Japan.",
            "Synthetic superheavy element.",
            "Extremely unstable."
        ],
        114: [
            "Named after Flerov Laboratory.",
            "Synthetic heavy element.",
            "Very short half life."
        ],
        115: [
            "Named after Moscow region.",
            "Synthetic element.",
            "Extremely unstable."
        ],
        116: [
            "Named after Lawrence Livermore Laboratory.",
            "Synthetic element.",
            "Short lived superheavy element."
        ],
        117: [
            "Named after Tennessee USA.",
            "Synthetic element.",
            "Extremely unstable."
        ],
        118: [
            "Named after physicist Yuri Oganessian.",
            "One of the heaviest known elements.",
            "Synthetic noble gas."
        ]
    ]

    /// Returns curated facts when available, otherwise a simple generic sentence.
    var funFacts: [String] {
        ElementCard.predefinedFunFacts[atomicNumber]
        ?? ["Scientists are still discovering new uses and stories for \(name)."]
    }

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
        layout: ElementLayout(row: 1, column: 1, period: 1, group: 1, block: "s", isLanthanide: false, isActinide: false),
        shells: [1],
        bohrModel3DURL: "https://storage.googleapis.com/search-ar-edu/periodic-table/element_001_hydrogen/element_001_hydrogen.glb",
        discoveredBy: "Henry Cavendish"
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
        layout: ElementLayout(row: 1, column: 18, period: 1, group: 18, block: "s", isLanthanide: false, isActinide: false),
        shells: [2],
        bohrModel3DURL: "https://storage.googleapis.com/search-ar-edu/periodic-table/element_002_helium/element_002_helium.glb",
        discoveredBy: "Pierre Janssen"
    )

    static let sampleElements: [ElementCard] = [hydrogen, helium]
}
