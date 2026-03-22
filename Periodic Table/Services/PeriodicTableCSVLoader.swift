//
//  PeriodicTableCSVLoader.swift
//  Periodic Table
//
//  Loads element data from Bowserinator/Periodic-Table-JSON CSV.
//  https://github.com/Bowserinator/Periodic-Table-JSON/blob/master/PeriodicTableCSV.csv
//

import Foundation

enum PeriodicTableCSVLoader {
    static let csvURL = URL(string: "https://raw.githubusercontent.com/Bowserinator/Periodic-Table-JSON/master/PeriodicTableCSV.csv")!

    /// Fetches and parses the CSV, returns array of ElementCard (or nil on failure).
    static func loadElements() async throws -> [ElementCard] {
        let (data, _) = try await URLSession.shared.data(from: csvURL)
        guard let csv = String(data: data, encoding: .utf8) else {
            throw LoaderError.invalidEncoding
        }
        return try parseCSV(csv)
    }

    private static func parseCSV(_ csv: String) throws -> [ElementCard] {
        let rows = parseCSVRows(csv)
        guard let headerRow = rows.first else { throw LoaderError.emptyCSV }
        let headers = headerRow
        var elements: [ElementCard] = []
        for (index, row) in rows.dropFirst().enumerated() {
            guard row.count >= 28 else { continue }
            guard let element = makeElement(headers: headers, values: row, rowIndex: index + 2) else {
                continue
            }
            elements.append(element)
        }
        return elements.sorted { $0.atomicNumber < $1.atomicNumber }
    }

    /// Parse CSV into rows, respecting quoted fields.
    private static func parseCSVRows(_ csv: String) -> [[String]] {
        var rows: [[String]] = []
        var currentRow: [String] = []
        var current = ""
        var inQuotes = false
        for char in csv {
            switch char {
            case "\"":
                inQuotes.toggle()
            case "," where !inQuotes:
                currentRow.append(current.trimmingCharacters(in: .whitespaces))
                current = ""
            case "\n", "\r":
                if !inQuotes {
                    if char == "\n" || (char == "\r" && current.isEmpty) {
                        currentRow.append(current.trimmingCharacters(in: .whitespaces))
                        if !currentRow.isEmpty { rows.append(currentRow) }
                        currentRow = []
                        current = ""
                    }
                } else {
                    current.append(char)
                }
            default:
                current.append(char)
            }
        }
        if !current.isEmpty || !currentRow.isEmpty {
            currentRow.append(current.trimmingCharacters(in: .whitespaces))
            if !currentRow.isEmpty { rows.append(currentRow) }
        }
        return rows
    }

    private static func value(_ values: [String], index: Int) -> String? {
        guard index < values.count else { return nil }
        let s = values[index].trimmingCharacters(in: .whitespaces)
        return s.isEmpty ? nil : s
    }

    private static func makeElement(headers: [String], values: [String], rowIndex: Int) -> ElementCard? {
        func v(_ name: String) -> String? { value(values, index: headers.firstIndex(of: name) ?? -1) }

        guard let numberStr = v("number"), let num = Int(numberStr), num >= 1, num <= 118 else { return nil }
        let symbol = v("symbol") ?? ""
        let name = v("name") ?? "Element \(num)"
        let atomicMass = Double(v("atomic_mass") ?? "0") ?? 0
        let category = mapCategory(v("category"), group: Int(v("group") ?? ""))
        let electronConfig = v("electron_configuration") ?? v("electron_configuration_semantic") ?? ""
        let melt = Double(v("melt") ?? "")
        let boil = Double(v("boil") ?? "")
        let density = Double(v("density") ?? "")
        let summary = v("summary") ?? ""
        let discoveredBy = v("discovered_by")
        let electronegativity = Double(v("electronegativity_pauling") ?? "")
        let shells = parseShells(v("shells"))
        let bohrModel3D = v("bohr_model_3d")
        let period = Int(v("period") ?? "1") ?? 1
        let group = Int(v("group") ?? "")
        let block = v("block") ?? "s"
        let xpos = Int(v("xpos") ?? "0") ?? 0
        let ypos = Int(v("ypos") ?? "0") ?? 0

        let isLanthanide = (period == 6 && (group == nil || group == 3) && num >= 57 && num <= 71) || ypos == 9
        let isActinide = (period == 7 && (group == nil || group == 3) && num >= 89) || ypos == 10

        let layout = ElementLayout(
            row: ypos,
            column: xpos,
            period: period,
            group: group,
            block: block,
            isLanthanide: isLanthanide,
            isActinide: isActinide
        )

        return ElementCard(
            atomicNumber: num,
            symbol: symbol,
            name: name,
            atomicMass: atomicMass,
            category: category,
            electronConfiguration: electronConfig,
            oxidationStates: [], // CSV does not provide
            electronegativity: electronegativity,
            meltingPoint: melt,
            boilingPoint: boil,
            density: density,
            description: summary,
            uses: [],
            historicalFacts: discoveredBy.map { "Discovered by \($0)." } ?? summary,
            discoveryYear: nil,
            layout: layout,
            shells: shells,
            bohrModel3DURL: bohrModel3D,
            discoveredBy: discoveredBy
        )
    }

    private static func parseShells(_ s: String?) -> [Int]? {
        guard let s = s?.trimmingCharacters(in: .whitespaces), s.hasPrefix("["), s.hasSuffix("]") else {
            return nil
        }
        let inner = s.dropFirst().dropLast()
        let parts = inner.split(separator: ",").compactMap { Int($0.trimmingCharacters(in: .whitespaces)) }
        return parts.isEmpty ? nil : parts
    }

    private static func mapCategory(_ category: String?, group: Int?) -> ElementCategory {
        let c = (category ?? "").lowercased()
        switch c {
        case "alkali metal": return .alkaliMetals
        case "alkaline earth metal": return .alkalineEarthMetals
        case "noble gas": return .nobleGases
        case "transition metal": return .transitionMetals
        case "post-transition metal": return .postTransitionMetals
        case "metalloid": return .metalloids
        case "lanthanide": return .lanthanides
        case "actinide": return .actinides
        case "polyatomic nonmetal": return .nonmetals
        case "diatomic nonmetal":
            return (group == 17) ? .halogens : .nonmetals
        default:
            if c.contains("transition") { return .transitionMetals }
            if c.contains("post-transition") { return .postTransitionMetals }
            if c.contains("metalloid") { return .metalloids }
            if c.contains("noble") { return .nobleGases }
            if c.contains("alkali") { return .alkaliMetals }
            if c.contains("alkaline") { return .alkalineEarthMetals }
            if c.contains("lanthanide") { return .lanthanides }
            if c.contains("actinide") { return .actinides }
            if c.contains("halogen") { return .halogens }
            return .unknown
        }
    }
}

enum LoaderError: LocalizedError {
    case invalidEncoding
    case emptyCSV

    var errorDescription: String? {
        switch self {
        case .invalidEncoding: return "Invalid CSV encoding."
        case .emptyCSV: return "CSV has no data."
        }
    }
}
