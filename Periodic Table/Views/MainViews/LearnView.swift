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

    private var backgroundGradient: some View {
        let topColor = accentColor.opacity(colorScheme == .dark ? 0.7 : 0.9)
        let bottomColor = accentColor.opacity(colorScheme == .dark ? 0.4 : 0.6)
        return LinearGradient(
            colors: [topColor, bottomColor],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
        .overlay(
            RadialGradient(
                colors: [
                    Color.white.opacity(colorScheme == .dark ? 0.08 : 0.32),
                    Color.clear
                ],
                center: .top,
                startRadius: 0,
                endRadius: 420
            )
            .blendMode(.screen)
        )
    }

    var body: some View {
        NavigationStack {
            ZStack {
                backgroundGradient
                LiquidBlobBackground(color: accentColor)

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
            .navigationTitle("Learning Lab")
            .navigationBarTitleDisplayMode(.inline)
            .tint(accentColor)
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
