//
//  MainTabView.swift
//  Periodic Table
//
//  Created by Cursor AI on 11/12/25.
//

import SwiftUI

struct MainTabView: View {
    @EnvironmentObject private var dataStore: ElementDataStore
    @EnvironmentObject private var uiState: UIStateManager
    @EnvironmentObject private var quizManager: QuizManager
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        TabView(selection: $uiState.selectedTab) {
            GridView()
                .tag(UIStateManager.AppTab.grid)
                .tabItem {
                    Label(UIStateManager.AppTab.grid.title, systemImage: UIStateManager.AppTab.grid.systemImage)
                }

            LearnView()
                .tag(UIStateManager.AppTab.learn)
                .tabItem {
                    Label(UIStateManager.AppTab.learn.title, systemImage: UIStateManager.AppTab.learn.systemImage)
                }

            FavoritesView()
                .tag(UIStateManager.AppTab.favorites)
                .tabItem {
                    Label(UIStateManager.AppTab.favorites.title, systemImage: UIStateManager.AppTab.favorites.systemImage)
                }

            SettingsView()
                .tag(UIStateManager.AppTab.settings)
                .tabItem {
                    Label(UIStateManager.AppTab.settings.title, systemImage: UIStateManager.AppTab.settings.systemImage)
                }
        }
        .tint(ColorManager.shared.color(for: uiState.selectedCategory ?? .unknown, colorScheme: colorScheme))
        .sheet(item: $uiState.selectedElement) { element in
            ElementDetailView(element: element)
                .environmentObject(dataStore)
                .environmentObject(uiState)
                .environmentObject(quizManager)
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
        }
    }
}

#if DEBUG
#Preview {
    MainTabView()
        .environmentObject(ElementDataStore(previewElements: ElementCard.sampleElements))
        .environmentObject(UIStateManager())
        .environmentObject(QuizManager())
}
#endif

