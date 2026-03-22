import SwiftUI

@main
struct PeriodicTableApp: App {
    @StateObject private var dataStore = ElementDataStore()
    @StateObject private var uiState = UIStateManager()
    @StateObject private var quizManager = QuizManager()

    var body: some Scene {
        WindowGroup {
            MainTabView()
                .environmentObject(dataStore)
                .environmentObject(uiState)
                .environmentObject(quizManager)
                .task {
                    await dataStore.loadElements()
                }
        }
    }
}
