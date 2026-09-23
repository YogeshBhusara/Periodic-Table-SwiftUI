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
    @Namespace private var cardNamespace

    var body: some View {
        TabView(selection: $uiState.selectedTab) {
            GridView(namespace: cardNamespace)
                .tag(UIStateManager.AppTab.cards)
                .tabItem {
                    Label(UIStateManager.AppTab.cards.title, systemImage: UIStateManager.AppTab.cards.systemImage)
                }

            LearnView()
                .tag(UIStateManager.AppTab.learn)
                .tabItem {
                    Label(UIStateManager.AppTab.learn.title, systemImage: UIStateManager.AppTab.learn.systemImage)
                }
        }
        .tint(AppTheme.signal)
        .preferredColorScheme(.dark)
        .toolbarColorScheme(.dark, for: .tabBar)
        .sheet(isPresented: $uiState.isMenuPresented) {
            MenuFlyoutView()
                .environmentObject(dataStore)
                .environmentObject(uiState)
                .environmentObject(quizManager)
        }
        .sheet(item: $uiState.selectedElement) { element in
            ElementDetailView(element: element, namespace: cardNamespace)
                .environmentObject(dataStore)
                .environmentObject(uiState)
                .environmentObject(quizManager)
                .animation(AnimationConstants.sheetTransition, value: element.id)
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
                .presentationCornerRadius(LayoutConstants.elementCardCornerRadius)
        }
    }
}

// MARK: - Menu flyout (Favorites, Settings)

private struct MenuFlyoutView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var dataStore: ElementDataStore
    @EnvironmentObject private var uiState: UIStateManager
    @EnvironmentObject private var quizManager: QuizManager

    var body: some View {
        NavigationStack {
            ZStack {
                VibeCanvas(accent: AppTheme.signal)
                List {
                    Section {
                        NavigationLink {
                            FavoritesView()
                                .environmentObject(dataStore)
                                .environmentObject(uiState)
                        } label: {
                            Label(UIStateManager.AppTab.favorites.title, systemImage: UIStateManager.AppTab.favorites.systemImage)
                        }

                        NavigationLink {
                            SettingsView()
                                .environmentObject(uiState)
                        } label: {
                            Label(UIStateManager.AppTab.settings.title, systemImage: UIStateManager.AppTab.settings.systemImage)
                        }
                    }
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Menu")
            .navigationBarTitleDisplayMode(.large)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundStyle(AppTheme.signal)
                }
            }
        }
    }
}

// MARK: - Hamburger button (opens flyout)

struct AppMenu: View {
    @Binding var isMenuPresented: Bool

    var body: some View {
        Button {
            isMenuPresented = true
        } label: {
            Image(systemName: "line.3.horizontal")
        }
        .accessibilityLabel("Menu")
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

