import SwiftUI

struct FavoritesView: View {
    @EnvironmentObject private var dataStore: ElementDataStore
    @EnvironmentObject private var uiState: UIStateManager

    private let columns = [GridItem(.adaptive(minimum: 120, maximum: 160), spacing: 16)]

    var body: some View {
        NavigationStack {
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
            .navigationTitle("Favorites")
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
                Text("#\(element.atomicNumber)")
                    .font(AppFont.mono(size: 12, weight: .bold))
                Spacer()
                Button(role: .destructive) {
                    dataStore.toggleFavorite(element.atomicNumber)
                } label: {
                    Image(systemName: "heart.slash")
                }
                .labelStyle(.iconOnly)
                .buttonStyle(.borderless)
                .accessibilityLabel("Remove from favorites")
            }

            Text(element.symbol)
                .font(AppFont.heading(size: 48, weight: .bold))
            Text(element.name)
                .font(AppFont.semibold(size: 17))
                .foregroundStyle(.secondary)

            Spacer()

            Button(action: {
                withAnimation(AnimationConstants.spotifyOpen) {
                    uiState.selectElement(element)
                }
            }) {
                Label("View Details", systemImage: "arrow.up.right")
                    .font(AppFont.semibold(size: 13))
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
        .frame(maxWidth: .infinity, minHeight: 180, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(ColorManager.shared.color(for: element.category, colorScheme: colorScheme).opacity(0.15))
        )
        .designCodeShadow(.normal, colorScheme: colorScheme)
        .designCodeInnerGlow(colorScheme: colorScheme, cornerRadius: 24)
    }
}

#if DEBUG
#Preview {
    FavoritesView()
        .environmentObject(ElementDataStore(previewElements: ElementCard.sampleElements))
        .environmentObject(UIStateManager())
}
#endif
