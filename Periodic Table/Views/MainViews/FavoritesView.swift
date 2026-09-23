import SwiftUI

struct FavoritesView: View {
    @EnvironmentObject private var dataStore: ElementDataStore
    @EnvironmentObject private var uiState: UIStateManager

    private let columns = [GridItem(.adaptive(minimum: 120, maximum: 160), spacing: 16)]

    var body: some View {
        NavigationStack {
            ZStack {
                VibeCanvas(accent: AppTheme.signal)
                Group {
                    if favorites.isEmpty {
                        ContentUnavailableView("No favorites yet", systemImage: "heart", description: Text("Tap the heart on an element to add it to your favorites."))
                            .padding()
                    } else {
                        ScrollView {
                            LazyVGrid(columns: columns, spacing: 16) {
                                ForEach(favorites) { element in
                                    FavoriteElementCard(element: element)
                                }
                            }
                            .padding(LayoutConstants.sectionPadding)
                        }
                    }
                }
            }
            .navigationTitle("Favorites")
            .navigationBarTitleDisplayMode(.large)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbarBackground(.hidden, for: .navigationBar)
        }
    }

    private var favorites: [ElementCard] {
        dataStore.elements.filter { dataStore.favorites.contains($0.atomicNumber) }
    }
}

private struct FavoriteElementCard: View {
    let element: ElementCard
    @EnvironmentObject private var dataStore: ElementDataStore
    @EnvironmentObject private var uiState: UIStateManager
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                DottedDisplay(text: AtomicDisplay.padded(element.atomicNumber), size: 22)
                Spacer()
                Button(role: .destructive) {
                    dataStore.toggleFavorite(element.atomicNumber)
                } label: {
                    Image(systemName: "heart.slash")
                        .foregroundStyle(.white.opacity(0.85))
                }
                .labelStyle(.iconOnly)
                .buttonStyle(.borderless)
                .accessibilityLabel("Remove from favorites")
            }

            Text(element.symbol)
                .font(AppFont.heading(size: 44, weight: .bold))
                .foregroundStyle(.white)
            Text(element.name)
                .font(AppFont.semibold(size: 15))
                .foregroundStyle(.white.opacity(0.75))

            Spacer()

            Button(action: {
                withAnimation(AnimationConstants.spotifyOpen) {
                    uiState.selectElement(element)
                }
            }) {
                Label("View Details", systemImage: "arrow.up.right")
                    .font(AppFont.semibold(size: 13))
                    .foregroundStyle(AppTheme.canvas)
                    .padding(.horizontal, Spacing.sm)
                    .padding(.vertical, Spacing.xs)
                    .background(AppTheme.signal, in: Capsule())
            }
            .buttonStyle(.plain)
        }
        .padding()
        .frame(maxWidth: .infinity, minHeight: 190, alignment: .leading)
        .background(CategoryMeshFill(category: element.category))
        .widgetChrome(cornerRadius: AppTheme.cornerRadiusLarge, glow: ColorManager.shared.color(for: element.category, colorScheme: colorScheme))
    }
}

#if DEBUG
#Preview {
    FavoritesView()
        .environmentObject(ElementDataStore(previewElements: ElementCard.sampleElements))
        .environmentObject(UIStateManager())
}
#endif
