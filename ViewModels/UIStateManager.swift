//
//  UIStateManager.swift
//  Periodic Table
//
//  Created by Cursor AI on 11/12/25.
//

import Foundation
import SwiftUI

@MainActor
final class UIStateManager: ObservableObject {
    enum AppTab: Hashable {
        case grid
        case learn
        case favorites
        case settings

        var title: LocalizedStringKey {
            switch self {
            case .grid:
                "Table"
            case .learn:
                "Learn"
            case .favorites:
                "Favorites"
            case .settings:
                "Settings"
            }
        }

        var systemImage: String {
            switch self {
            case .grid:
                "tablecells"
            case .learn:
                "graduationcap"
            case .favorites:
                "heart"
            case .settings:
                "gear"
            }
        }
    }

    @Published var selectedTab: AppTab = .grid
    @Published var selectedElement: ElementCard?
    @Published var expandedElementID: Int?
    @Published var isDetailPresented = false
    @Published var selectedCategory: ElementCategory?
    @Published var searchQuery: String = ""
    @Published var searchHistory: [String] = []
    @Published var massRangeFilter: ClosedRange<Double>?
    @Published var electronegativityRangeFilter: ClosedRange<Double>?
    @Published var selectedComparatorElements: [ElementCard] = []
    @Published var isComparatorActive = false
    @Published var showFavoritesOnly = false
    @Published var isParticleEffectsEnabled = true
    @Published var isSoundEnabled = false

    private let maxSearchHistory = 10

    func selectElement(_ element: ElementCard?) {
        selectedElement = element
        expandedElementID = element?.atomicNumber
        isDetailPresented = element != nil
    }

    func toggleCategory(_ category: ElementCategory?) {
        if selectedCategory == category {
            selectedCategory = nil
        } else {
            selectedCategory = category
        }
    }

    func updateSearchQuery(_ query: String) {
        searchQuery = query
        guard !query.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        addToSearchHistory(query)
    }

    func addToSearchHistory(_ query: String) {
        let normalized = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !normalized.isEmpty else { return }
        searchHistory.removeAll { $0.caseInsensitiveCompare(normalized) == .orderedSame }
        searchHistory.insert(normalized, at: 0)
        if searchHistory.count > maxSearchHistory {
            searchHistory = Array(searchHistory.prefix(maxSearchHistory))
        }
    }

    func removeFromSearchHistory(_ query: String) {
        searchHistory.removeAll { $0.caseInsensitiveCompare(query) == .orderedSame }
    }

    func resetFilters() {
        selectedCategory = nil
        massRangeFilter = nil
        electronegativityRangeFilter = nil
        searchQuery = ""
        isComparatorActive = false
        selectedComparatorElements.removeAll()
    }

    func selectForComparison(_ element: ElementCard) {
        if let index = selectedComparatorElements.firstIndex(of: element) {
            selectedComparatorElements.remove(at: index)
        } else if selectedComparatorElements.count < 2 {
            selectedComparatorElements.append(element)
        } else {
            selectedComparatorElements[1] = element
        }
        isComparatorActive = !selectedComparatorElements.isEmpty
    }

    func clearComparator() {
        selectedComparatorElements.removeAll()
        isComparatorActive = false
    }

    func setFavoritesFilter(_ isActive: Bool) {
        showFavoritesOnly = isActive
    }
}

