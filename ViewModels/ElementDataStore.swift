//
//  ElementDataStore.swift
//  Periodic Table
//
//  Created by Cursor AI on 11/12/25.
//

import Foundation
import SwiftUI

@MainActor
final class ElementDataStore: ObservableObject {
    enum DataError: LocalizedError {
        case missingFile
        case decodingFailed

        var errorDescription: String? {
            switch self {
            case .missingFile:
                return String(localized: "Unable to locate elements data file.", comment: "Missing data file error")
            case .decodingFailed:
                return String(localized: "Failed to decode the periodic table dataset.", comment: "Decoding error")
            }
        }
    }

    @Published private(set) var elements: [ElementCard] = []
    @Published private(set) var filteredElements: [ElementCard] = []
    @Published private(set) var isLoading = false
    @Published var favorites: Set<Int> = []
    @Published private(set) var dataError: DataError?

    private let favoritesKey = "favoriteElements"
    private(set) var lastUpdated: Date?

    init() {
        loadFavorites()
    }

    func loadElements() async {
        guard !isLoading else { return }
        isLoading = true
        defer { isLoading = false }

        do {
            elements = try await loadElementsFromBundle()
            filteredElements = elements
            lastUpdated = Date()
            dataError = nil
        } catch let error as DataError {
            dataError = error
        } catch {
            dataError = .decodingFailed
        }
    }

    func refreshFilters(using uiState: UIStateManager) {
        filteredElements = elements
            .filter { element in
                guard let category = uiState.selectedCategory else { return true }
                return element.category == category
            }
            .filter { element in
                guard let massRange = uiState.massRangeFilter else { return true }
                return massRange.contains(element.atomicMass)
            }
            .filter { element in
                guard let electronegativityRange = uiState.electronegativityRangeFilter else { return true }
                guard let electronegativity = element.electronegativity else { return false }
                return electronegativityRange.contains(electronegativity)
            }
            .filter { element in
                guard !uiState.searchQuery.isEmpty else { return true }
                return matchesSearch(element, query: uiState.searchQuery)
            }
    }

    func searchElements(_ query: String) -> [ElementCard] {
        guard !query.isEmpty else { return elements }
        return elements.filter { matchesSearch($0, query: query) }
    }

    func elements(in category: ElementCategory?) -> [ElementCard] {
        guard let category else { return elements }
        return elements.filter { $0.category == category }
    }

    func element(for atomicNumber: Int) -> ElementCard? {
        elements.first { $0.atomicNumber == atomicNumber }
    }

    func toggleFavorite(_ atomicNumber: Int) {
        if favorites.contains(atomicNumber) {
            favorites.remove(atomicNumber)
        } else {
            favorites.insert(atomicNumber)
        }
        saveFavorites()
    }

    func clearFilters() {
        filteredElements = elements
    }

    private func matchesSearch(_ element: ElementCard, query: String) -> Bool {
        let normalizedQuery = query.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard !normalizedQuery.isEmpty else { return true }

        let atomicNumberMatch = String(element.atomicNumber) == normalizedQuery
        let symbolMatch = element.symbol.lowercased().contains(normalizedQuery)
        let nameMatch = element.name.lowercased().contains(normalizedQuery)
        return atomicNumberMatch || symbolMatch || nameMatch
    }

    private func loadElementsFromBundle() async throws -> [ElementCard] {
        guard let url = Bundle.main.url(forResource: "elements", withExtension: "json") else {
            throw DataError.missingFile
        }
        let data = try Data(contentsOf: url)
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let response = try decoder.decode(ElementResponse.self, from: data)
        return response.elements.sorted { $0.atomicNumber < $1.atomicNumber }
    }

    private func loadFavorites() {
        guard let stored = UserDefaults.standard.array(forKey: favoritesKey) as? [Int] else {
            favorites = []
            return
        }
        favorites = Set(stored)
    }

    private func saveFavorites() {
        UserDefaults.standard.set(Array(favorites), forKey: favoritesKey)
    }
}

private struct ElementResponse: Codable {
    let elements: [ElementCard]
}

#if DEBUG
extension ElementDataStore {
    convenience init(previewElements: [ElementCard]) {
        self.init()
        elements = previewElements
        filteredElements = previewElements
        isLoading = false
    }
}
#endif

