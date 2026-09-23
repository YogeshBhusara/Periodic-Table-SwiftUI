import SwiftUI

struct LearnView: View {
    enum LearningMode: String, CaseIterable, Identifiable {
        case comparator
        case quiz

        var id: String { rawValue }

        var title: String {
            switch self {
            case .comparator:
                return String(localized: "Property Comparator", comment: "Learning mode title")
            case .quiz:
                return String(localized: "Quiz Mode", comment: "Learning mode title")
            }
        }

        var systemImage: String {
            switch self {
            case .comparator:
                return "chart.bar.xaxis"
            case .quiz:
                return "gamecontroller"
            }
        }
    }

    @State private var selectedMode: LearningMode = .comparator

    @EnvironmentObject private var uiState: UIStateManager
    @Environment(\.colorScheme) private var colorScheme

    /// Uses the element currently shown on the Elements tab (carousel) so Learn background matches when switching tabs.
    private var accentColor: Color {
        let category = uiState.carouselElement?.category ?? uiState.selectedCategory ?? .unknown
        return ColorManager.shared.color(for: category, colorScheme: colorScheme)
    }

    var body: some View {
        NavigationStack {
            ZStack {
                VibeCanvas(accent: accentColor)

                VStack(spacing: Spacing.xl) {
                    Picker("Learning Mode", selection: $selectedMode) {
                        ForEach(LearningMode.allCases) { mode in
                            Label(mode.title, systemImage: mode.systemImage)
                                .tag(mode)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal, LayoutConstants.sectionPadding)
                    .padding(.top, Spacing.xl)

                    TabView(selection: $selectedMode) {
                        ScrollView(.vertical, showsIndicators: true) {
                            PropertyComparator()
                                .padding(.horizontal, LayoutConstants.sectionPadding)
                                .padding(.bottom, Spacing.xxl)
                        }
                        .tag(LearningMode.comparator)

                        ScrollView(.vertical, showsIndicators: true) {
                            QuizModeView()
                                .padding(.horizontal, LayoutConstants.sectionPadding)
                                .padding(.bottom, Spacing.xxl)
                        }
                        .tag(LearningMode.quiz)
                    }
                    .tabViewStyle(.page(indexDisplayMode: .never))
                }
            }
            .navigationTitle("Learn")
            .navigationBarTitleDisplayMode(.large)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbarBackground(.hidden, for: .navigationBar)
            .tint(AppTheme.signal)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    AppMenu(isMenuPresented: $uiState.isMenuPresented)
                }
            }
        }
    }
}

#if DEBUG
#Preview {
    LearnView()
        .environmentObject(ElementDataStore(previewElements: ElementCard.sampleElements))
        .environmentObject(UIStateManager())
        .environmentObject(QuizManager())
}
#endif
