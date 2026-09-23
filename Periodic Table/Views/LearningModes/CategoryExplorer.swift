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
                        .font(AppFont.semibold(size: 16))
                        .foregroundStyle(.white)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                    Spacer()
                    Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                        .foregroundStyle(isSelected ? AppTheme.signal : Color.white.opacity(0.7))
                        .font(.title3)
                }

                Text("\(count) elements")
                    .font(AppFont.eyebrow(size: 12))
                    .tracking(0.6)
                    .foregroundStyle(.white.opacity(0.75))
            }
            .padding(18)
            .frame(maxWidth: .infinity, minHeight: 120, alignment: .leading)
            .background(CategoryMeshFill(category: category))
            .widgetChrome(
                cornerRadius: AppTheme.cornerRadiusLarge,
                glow: isSelected ? ColorManager.shared.color(for: category, colorScheme: colorScheme) : .clear
            )
            .overlay(
                RoundedRectangle(cornerRadius: AppTheme.cornerRadiusLarge, style: .continuous)
                    .strokeBorder(AppTheme.signal.opacity(isSelected ? 0.9 : 0), lineWidth: 2)
            )
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
