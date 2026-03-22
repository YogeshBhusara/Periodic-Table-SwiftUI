import SwiftUI

struct ElementDetailView: View {
    let element: ElementCard
    var namespace: Namespace.ID?

    @EnvironmentObject private var dataStore: ElementDataStore
    @EnvironmentObject private var uiState: UIStateManager
    @EnvironmentObject private var quizManager: QuizManager
    @Environment(\.colorScheme) private var colorScheme
    @StateObject private var speechManager = SpeechManager.shared
    @State private var contentAppeared = false
    @Namespace private var glassNamespace

    var body: some View {
        GeometryReader { proxy in
            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .leading, spacing: Spacing.xxxl) {
                    headerSection
                        .padding(.top, proxy.safeAreaInsets.top + Spacing.md)

                    overviewSection

                    PropertySection(element: element)

                    historySection

                    funFactsSection

                    RelatedElementsView(element: element)
                        .environmentObject(dataStore)
                        .environmentObject(uiState)
                        .padding(.bottom, proxy.safeAreaInsets.bottom + Spacing.xl)
                }
                .padding(.horizontal, LayoutConstants.sectionPadding)
                .opacity(contentAppeared ? 1 : 0)
                .offset(y: contentAppeared ? 0 : 8)
            }
            .ignoresSafeArea(edges: .top)
            .animation(AnimationConstants.sheetContentAppear, value: contentAppeared)
            .onAppear {
                contentAppeared = true
            }
            .background(
                LinearGradient(
                    colors: [
                        ColorManager.shared.color(for: element.category, colorScheme: colorScheme).opacity(0.25),
                        Color(.systemBackground)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
            )
        }
        .interactiveDismissDisabled(false)
    }

    private var categoryColor: Color {
        ColorManager.shared.color(for: element.category, colorScheme: colorScheme)
    }

    private var headerSection: some View {
        VStack(spacing: Spacing.md) {
            // Simple header mirroring card data (without card shell or orbital)
            VStack(alignment: .leading, spacing: Spacing.sm) {
                HStack(alignment: .top, spacing: Spacing.md) {
                    VStack(alignment: .leading, spacing: Spacing.xxs) {
                        Text(element.symbol)
                            .font(AppFont.heading(size: 40, weight: .heavy))

                        Text(element.name)
                            .font(AppFont.semibold(size: 22))

                        Text("#\(element.atomicNumber)")
                            .font(AppFont.body(size: 15))
                            .foregroundStyle(.secondary)
                    }

                    Spacer()

                    actionButtons
                }

                Text(element.category.categoryName)
                    .font(AppFont.semibold(size: 15))
                    .foregroundStyle(.primary)

                HStack(spacing: Spacing.lg) {
                    VStack(alignment: .leading, spacing: Spacing.xxs) {
                        Text("MELTING POINT")
                            .font(AppFont.mono(size: 10))
                            .foregroundStyle(.secondary)
                        Text(formattedTemperature(element.meltingPoint))
                            .font(AppFont.mono(size: 12))
                            .foregroundStyle(.primary)
                    }

                    VStack(alignment: .leading, spacing: Spacing.xxs) {
                        Text("BOILING POINT")
                            .font(AppFont.mono(size: 10))
                            .foregroundStyle(.secondary)
                        Text(formattedTemperature(element.boilingPoint))
                            .font(AppFont.mono(size: 12))
                            .foregroundStyle(.primary)
                    }

                    Spacer()
                }
            }
            .padding(Spacing.md)
            .frame(maxWidth: .infinity, alignment: .leading)
            .glassEffect(
                .regular
                    .tint(categoryColor)
                    .interactive(),
                in: .rect(cornerRadius: 20)
            )
            .designCodeShadow(.subtle, colorScheme: colorScheme)
            .designCodeInnerGlow(colorScheme: colorScheme, cornerRadius: 20)
        }
    }

    private func formattedTemperature(_ value: Double?) -> String {
        guard let value else { return "—" }
        return String(format: "%.0f K", value)
    }

    private var overviewSection: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            Text(element.description)
                .font(AppFont.body(size: 17))
                .foregroundStyle(.primary)

            VStack(alignment: .leading, spacing: Spacing.sm) {
                Text("Electron Configuration")
                    .font(AppFont.semibold(size: 17))
                Text(element.electronConfiguration)
                    .font(AppFont.mono(size: 20))
                    .padding()
                    .glassEffect(.regular.interactive(), in: .rect(cornerRadius: 16))
                    .designCodeShadow(.subtle, colorScheme: colorScheme)
            }

            VStack(alignment: .leading, spacing: Spacing.sm) {
                Text("Oxidation States")
                    .font(AppFont.semibold(size: 17))
                if element.oxidationStates.isEmpty {
                    Text("No common states recorded")
                        .font(AppFont.body(size: 15))
                        .foregroundStyle(.secondary)
                } else {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 56), spacing: Spacing.xs)], spacing: Spacing.xs) {
                        ForEach(element.oxidationStates, id: \.self) { state in
                            Text("\(state)")
                                .font(AppFont.body(size: 15))
                                .padding(.horizontal, Spacing.sm)
                                .padding(.vertical, Spacing.xxs + Spacing.xxxs)
                                .glassEffect(.regular.interactive(), in: .capsule)
                                .designCodeShadow(.subtle, colorScheme: colorScheme)
                        }
                    }
                }
            }
        }
    }

    private var historySection: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            if let discoveryYear = element.discoveryYear {
                Label("Discovered in \(discoveryYear)", systemImage: "clock")
                    .font(AppFont.semibold(size: 17))
            }

            Text(element.historicalFacts)
                .font(AppFont.body(size: 17))
                .foregroundStyle(.primary)

            if !element.uses.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Notable Uses")
                        .font(AppFont.semibold(size: 17))
                    ForEach(element.uses, id: \.self) { use in
                        Label(use, systemImage: "sparkle")
                            .font(AppFont.body(size: 15))
                    }
                }
            }
        }
    }

    private var funFactsSection: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            Text("Fun & Interesting Facts")
                .font(AppFont.semibold(size: 17))

            VStack(alignment: .leading, spacing: Spacing.sm) {
                ForEach(Array(element.funFacts.enumerated()), id: \.offset) { _, fact in
                    HStack(alignment: .top, spacing: Spacing.xs) {
                        Image(systemName: "sparkles")
                            .font(AppFont.body(size: 15))
                            .foregroundStyle(.secondary)

                        Text(fact)
                            .font(AppFont.body(size: 15))
                            .foregroundStyle(.primary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }
            .padding(Spacing.md)
            .frame(maxWidth: .infinity, alignment: .leading)
            .glassEffect(.regular.interactive(), in: .rect(cornerRadius: 18))
            .designCodeShadow(.subtle, colorScheme: colorScheme)
        }
    }

    private func pronounceElement() {
        HapticManager.shared.playSelectionChange()
        if speechManager.isSpeaking {
            speechManager.stop()
        } else {
            speechManager.speak(element.name)
        }
    }

    private var elementShareText: String {
        "\(element.name) (\(element.symbol)) - Atomic Number \(element.atomicNumber)"
    }

    @ViewBuilder
    private var actionButtons: some View {
        LiquidGlassContainer(spacing: Spacing.sm) {
            actionButtonsContent
        }
    }

    private var actionButtonIconColor: Color {
        colorScheme == .dark ? .white : .primary
    }

    private var actionButtonsContent: some View {
        HStack(spacing: Spacing.sm) {
            Button(action: pronounceElement) {
                Image(systemName: speechManager.isSpeaking ? "waveform" : "speaker.wave.2")
                    .actionIcon()
            }
            .buttonStyle(.plain)
            .glassCircleButton(diameter: 40, tint: .primary.opacity(0.35), iconColor: actionButtonIconColor)
            .glassEffectIDIfAvailable("detail-pronounce", in: glassNamespace)
            .accessibilityLabel(speechManager.isSpeaking ? "Stop" : "Pronounce")

            ShareLink(item: elementShareText) {
                Image(systemName: "square.and.arrow.up")
                    .actionIcon()
            }
            .glassCircleButton(diameter: 40, tint: .primary.opacity(0.35), iconColor: actionButtonIconColor)
            .glassEffectIDIfAvailable("detail-share", in: glassNamespace)
            .accessibilityLabel("Share")

            Button {
                dataStore.toggleFavorite(element.atomicNumber)
                HapticManager.shared.playMediumImpact()
            } label: {
                Image(systemName: "heart")
                    .actionIcon()
            }
            .buttonStyle(.plain)
            .glassCircleButton(
                diameter: 40,
                tint: dataStore.favorites.contains(element.atomicNumber) ? .pink.opacity(0.5) : .primary.opacity(0.35),
                iconColor: actionButtonIconColor
            )
            .glassEffectIDIfAvailable("detail-favorite", in: glassNamespace)
            .accessibilityLabel(
                dataStore.favorites.contains(element.atomicNumber)
                ? "Remove from favorites"
                : "Add to favorites"
            )
        }
    }
}

#if DEBUG
#Preview {
    ElementDetailView(element: .hydrogen)
        .environmentObject(ElementDataStore(previewElements: ElementCard.sampleElements))
        .environmentObject(UIStateManager())
        .environmentObject(QuizManager())
}
#endif
