import SwiftUI

struct CategoryExplorer: View {
    @EnvironmentObject private var dataStore: ElementDataStore
    @EnvironmentObject private var uiState: UIStateManager
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Explore by Category")
                .font(.title2.weight(.bold))

            Text("Tap a category to highlight matching elements in the table.")
                .font(.callout)
                .foregroundStyle(.secondary)

            LazyVGrid(columns: [GridItem(.adaptive(minimum: 150), spacing: 16)], spacing: 16) {
                ForEach(ElementCategory.allCases) { category in
                    CategoryCard(
                        category: category,
                        count: dataStore.elements(in: category).count,
                        isSelected: uiState.selectedCategory == category
                    ) {
                        HapticManager.shared.playSelectionChange()
                        uiState.toggleCategory(category)
                        dataStore.refreshFilters(using: uiState)
                    }
                }
            }

            Spacer(minLength: 24)
        }
    }
}

private struct CategoryCard: View {
    let category: ElementCategory
    let count: Int
    let isSelected: Bool
    var action: () -> Void
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text(category.categoryName)
                        .font(.headline)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                    Spacer()
                    Image(systemName: isSelected ? "checkmark.circle" : "circle")
                        .foregroundStyle(Color.white.opacity(0.9))
                        .font(.title3)
                }

                Text("\(count) elements")
                    .font(.caption)
                    .foregroundStyle(Color.white.opacity(0.8))
            }
            .padding(18)
            .frame(maxWidth: .infinity, minHeight: 120, alignment: .leading)
            .background(
                LinearGradient(
                    colors: [
                        ColorManager.shared.color(for: category, colorScheme: colorScheme).opacity(0.85),
                        ColorManager.shared.color(for: category, colorScheme: colorScheme)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .stroke(Color.white.opacity(isSelected ? 0.6 : 0.2), lineWidth: isSelected ? 3 : 1)
            )
            .shadow(color: ColorManager.shared.color(for: category, colorScheme: colorScheme).opacity(0.35), radius: 12, x: 0, y: 10)
        }
        .buttonStyle(.plain)
    }
}

#if DEBUG
#Preview {
    CategoryExplorer()
        .environmentObject(ElementDataStore(previewElements: ElementCard.sampleElements))
        .environmentObject(UIStateManager())
        .padding()
}
#endif
