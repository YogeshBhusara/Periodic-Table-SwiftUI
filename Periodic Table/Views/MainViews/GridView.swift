import SwiftUI

struct GridView: View {
    @EnvironmentObject private var dataStore: ElementDataStore
    @EnvironmentObject private var uiState: UIStateManager
    @Environment(\.colorScheme) private var colorScheme

    var namespace: Namespace.ID?

    @State private var selectedIndex: Int = 0
    @State private var isElementGridPresented = false

    var body: some View {
        NavigationStack {
            GeometryReader { proxy in
                let size = proxy.size
                let safeArea = proxy.safeAreaInsets
                ZStack {
                    backgroundGradient
                    LiquidBlobBackground(color: accentColor)
                    atomicNumberBackground(in: size)
                    content(for: size, safeArea: safeArea)

                    if !dataStore.isLoading, !dataStore.elements.isEmpty {
                        elementPickerFAB(safeArea: safeArea)
                    }

                    if isElementGridPresented {
                        ElementGridOverlayView(
                            elements: dataStore.elements,
                            namespace: namespace,
                            onSelect: { element in
                                uiState.resetFilters()
                                refreshFilters()
                                if let idx = dataStore.elements.firstIndex(where: { $0.atomicNumber == element.atomicNumber }) {
                                    selectedIndex = idx
                                }
                                withAnimation(AnimationConstants.gridOverlaySpring) {
                                    isElementGridPresented = false
                                }
                            },
                            onDismiss: {
                                withAnimation(AnimationConstants.gridOverlaySpring) {
                                    isElementGridPresented = false
                                }
                            }
                        )
                        .transition(.opacity.combined(with: .scale(scale: 0.96)))
                        .zIndex(1)
                    }
                }
                .frame(width: size.width, height: size.height)
                .animation(AnimationConstants.gridOverlaySpring, value: isElementGridPresented)
                .navigationBarTitleDisplayMode(.inline)
                .tint(accentColor)
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        AppMenu(isMenuPresented: $uiState.isMenuPresented)
                    }
                    ToolbarItem(placement: .topBarTrailing) {
                        categoryFilterMenu
                    }
                }
            }
        }
        .onAppear {
            refreshIfNeeded()
            ensureSelectionBounds()
            uiState.carouselElement = currentElement
        }
        .onChange(of: dataStore.filteredElements) { _, _ in
            ensureSelectionBounds()
            uiState.carouselElement = currentElement
        }
        .onChange(of: selectedIndex) { _, _ in
            uiState.carouselElement = currentElement
        }
        .onChange(of: uiState.selectedCategory) { _, _ in
            applyFiltersMaintainingSelection()
        }
        .onChange(of: uiState.massRangeFilter) { _, _ in
            applyFiltersMaintainingSelection()
        }
        .onChange(of: uiState.electronegativityRangeFilter) { _, _ in
            applyFiltersMaintainingSelection()
        }
        .onChange(of: uiState.searchQuery) { _, _ in
            applyFiltersMaintainingSelection()
        }
        .onChange(of: uiState.showFavoritesOnly) { _, _ in
            ensureSelectionBounds()
        }
    }

    private func elementPickerFAB(safeArea: EdgeInsets) -> some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                Button {
                    HapticManager.shared.playLightTap()
                    withAnimation(AnimationConstants.gridOverlaySpring) {
                        isElementGridPresented = true
                    }
                } label: {
                    Image(systemName: "square.grid.3x3")
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(width: 56, height: 56)
                        .background(accentColor, in: Circle())
                        .designCodeShadow(.subtle, colorScheme: colorScheme)
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Open element grid")
                .padding(.trailing, Spacing.lg)
                .padding(.bottom, Spacing.lg + safeArea.bottom)
            }
        }
        .allowsHitTesting(true)
    }

    private var categoryFilterMenu: some View {
        Menu {
            Button {
                HapticManager.shared.playSelectionChange()
                uiState.selectedCategory = nil
            } label: {
                Label {
                    Text(String(localized: "All Categories", comment: "Category filter menu item"))
                } icon: {
                    Circle()
                        .fill(Color(.tertiaryLabel))
                        .frame(width: 10, height: 10)
                }
                if uiState.selectedCategory == nil {
                    Image(systemName: "checkmark")
                }
            }
            ForEach(ElementCategory.allCases) { category in
                Button {
                    HapticManager.shared.playSelectionChange()
                    uiState.selectedCategory = category
                } label: {
                    Label {
                        Text(category.categoryName)
                    } icon: {
                        Circle()
                            .fill(ColorManager.shared.color(for: category, colorScheme: colorScheme))
                            .frame(width: 10, height: 10)
                    }
                    if uiState.selectedCategory == category {
                        Image(systemName: "checkmark")
                    }
                }
            }
        } label: {
            Label(
                String(localized: "Category filter", comment: "Category filter toolbar button"),
                systemImage: "line.3.horizontal.decrease.circle"
            )
        }
        .accessibilityLabel(uiState.selectedCategory.map { "\($0.categoryName) selected" } ?? "Filter by category")
    }

    // MARK: - Core Views

    @ViewBuilder
    private func content(for size: CGSize, safeArea: EdgeInsets) -> some View {
        if dataStore.isLoading {
            ProgressView(String(localized: "Loading elements…", comment: "Loading state text"))
                .progressViewStyle(.circular)
                .controlSize(.large)
        } else if let element = currentElement {
            let contentStack = VStack(spacing: Spacing.md) {
                cardCarousel(
                    maxWidth: min(size.width - LayoutConstants.sectionPadding * 2, 520),
                    height: min(size.height * 0.7, 520)
                )
                    .frame(maxWidth: .infinity)
                quickActions(for: element)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .frame(maxWidth: .infinity, alignment: .top)
            .padding(.horizontal, LayoutConstants.sectionPadding)
            .padding(.top, LayoutConstants.sectionPadding)
            .padding(.bottom, LayoutConstants.sectionPadding * 2 + safeArea.bottom)

            if size.height < 720 {
                ScrollView(.vertical, showsIndicators: false) {
                    contentStack
                        .padding(.bottom, LayoutConstants.sectionPadding)
                }
            } else {
                contentStack
            }
        } else {
            emptyState
        }
    }

    private func cardCarousel(maxWidth: CGFloat, height: CGFloat) -> some View {
        VStack(spacing: Spacing.md) {
            TabView(selection: $selectedIndex) {
                ForEach(currentElements.indices, id: \.self) { index in
                    let element = currentElements[index]
                    ExpandedCardView(element: element, namespace: namespace)
                        .frame(maxWidth: maxWidth, minHeight: height)
                        .padding(.horizontal, Spacing.xs)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            HapticManager.shared.playSelectionChange()
                            withAnimation(AnimationConstants.sheetTransition) {
                                uiState.selectElement(element)
                            }
                        }
                        .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .frame(height: height)
            .animation(AnimationConstants.spotifyOpen, value: selectedIndex)
        }
        .frame(maxWidth: .infinity)
    }

    private func quickActions(for element: ElementCard) -> some View {
        HStack(spacing: Spacing.md) {
            if uiState.showFavoritesOnly {
                Label(String(localized: "Favorites Only", comment: "Favorites filter indicator"), systemImage: "heart")
                    .font(AppFont.semibold(size: 15))
                    .foregroundStyle(accentColor)
                    .padding(.horizontal, Spacing.sm)
                    .padding(.vertical, Spacing.xxs + Spacing.xxxs)
                    .background(accentColor.opacity(0.15), in: Capsule())
            }

            Spacer()
        }
    }

    private var emptyState: some View {
        VStack(spacing: Spacing.lg) {
            Image(systemName: "sparkles")
                .font(.system(size: 42))
                .foregroundStyle(accentColor)
            Text(String(localized: "No elements match your filters.", comment: "Empty state message"))
                .font(AppFont.semibold(size: 17))
            Button(String(localized: "Reset Filters", comment: "Reset filters button")) {
                    HapticManager.shared.playSelectionChange()
                uiState.resetFilters()
                    refreshFilters()
                ensureSelectionBounds()
            }
            .buttonStyle(.borderedProminent)
            .tint(accentColor)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    /// Large atomic number on top of liquid blobs; parallax offset by selected index so it moves at a different rate than the card.
    private func atomicNumberBackground(in size: CGSize) -> some View {
        let parallaxFactor: CGFloat = 28
        let parallaxOffset = CGFloat(selectedIndex) * parallaxFactor

        return Group {
            if let element = currentElement {
                Text("\(element.atomicNumber)")
                    .font(AppFont.displayMono(size: 200))
                    .foregroundStyle(accentColor.opacity(colorScheme == .dark ? 0.22 : 0.18))
                    .frame(width: size.width, height: size.height, alignment: .trailing)
                    .offset(x: parallaxOffset)
                    .allowsHitTesting(false)
            }
        }
        .animation(AnimationConstants.spotifyOpen, value: selectedIndex)
    }

    private var backgroundGradient: some View {
        let topColor = accentColor.opacity(colorScheme == .dark ? 0.7 : 0.9)
        let bottomColor = accentColor.opacity(colorScheme == .dark ? 0.4 : 0.6)

        return ZStack {
            if colorScheme == .dark {
                AppTheme.backgroundColorDark
                    .ignoresSafeArea()
            }
            LinearGradient(
                colors: [
                    topColor,
                    bottomColor
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .opacity(colorScheme == .dark ? 0.35 : 1)
        }
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
        .animation(AnimationConstants.spotifyOpen, value: accentColor)
    }

    // MARK: - Helpers

    private var currentElements: [ElementCard] {
        var results = dataStore.filteredElements

        if uiState.showFavoritesOnly {
            results = results.filter { dataStore.favorites.contains($0.atomicNumber) }
        }

        if results.isEmpty {
            if uiState.showFavoritesOnly {
                let favorites = dataStore.elements.filter { dataStore.favorites.contains($0.atomicNumber) }
                return favorites.isEmpty ? dataStore.elements : favorites
            }
            return dataStore.filteredElements.isEmpty ? dataStore.elements : dataStore.filteredElements
        }

        return results
    }

    private var currentElement: ElementCard? {
        guard !currentElements.isEmpty, selectedIndex >= 0, selectedIndex < currentElements.count else {
            return nil
        }
        return currentElements[selectedIndex]
    }

    private var accentColor: Color {
        if let element = currentElement {
            return ColorManager.shared.color(for: element.category, colorScheme: colorScheme)
        }

        if let category = uiState.selectedCategory {
            return ColorManager.shared.color(for: category, colorScheme: colorScheme)
        }

        return ColorManager.shared.color(for: .unknown, colorScheme: colorScheme)
    }

    private func refreshFilters() {
        withAnimation(AnimationConstants.filterEase) {
            dataStore.refreshFilters(using: uiState)
        }
    }

    private func applyFiltersMaintainingSelection() {
        let previouslySelected = currentElement
        refreshFilters()
        if let element = previouslySelected, let index = currentElements.firstIndex(of: element) {
            selectedIndex = index
        } else {
            ensureSelectionBounds()
        }
    }

    private func refreshIfNeeded() {
        if dataStore.filteredElements.isEmpty {
            refreshFilters()
        }
    }

    private func ensureSelectionBounds() {
        let count = currentElements.count
        guard count > 0 else {
            selectedIndex = 0
            return
        }
        selectedIndex = min(max(0, selectedIndex), count - 1)
    }

}

#if DEBUG
#Preview {
    GridView(namespace: nil)
        .environmentObject(ElementDataStore(previewElements: ElementCard.sampleElements))
        .environmentObject(UIStateManager())
        .environmentObject(QuizManager())
}
#endif


