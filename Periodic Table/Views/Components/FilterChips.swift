import SwiftUI

struct FilterChips: View {
    let categories: [ElementCategory]
    let selectedCategory: ElementCategory?
    var onSelection: (ElementCategory?) -> Void

    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                Button(action: {
                    onSelection(nil)
                }) {
                    Label("All", systemImage: "circle.grid.3x3")
                        .labelStyle(.titleAndIcon)
                        .font(AppFont.semibold(size: 15))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .foregroundStyle(foreground(for: nil))
                        .background { chipBackground(for: nil) }
                }
                .buttonStyle(.plain)

                ForEach(categories) { category in
                    Button {
                        onSelection(category)
                    } label: {
                        Label(category.categoryName, systemImage: symbol(for: category))
                            .labelStyle(.titleAndIcon)
                            .font(AppFont.body(size: 15))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .foregroundStyle(foreground(for: category))
                            .background { chipBackground(for: category) }
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel(category.categoryName)
                }
            }
            .padding(.vertical, 4)
        }
    }

    @ViewBuilder
    private func chipBackground(for category: ElementCategory?) -> some View {
        let isSelected = selectedCategory == category
        let fill = isSelected
            ? ColorManager.shared.color(for: category ?? .unknown, colorScheme: colorScheme).opacity(0.28)
            : AppTheme.elevated

        Capsule()
            .fill(fill)
            .glassEffect(.regular.interactive(), in: .capsule)
            .designCodeShadow(.subtle, colorScheme: colorScheme)
    }

    private func foreground(for category: ElementCategory?) -> some ShapeStyle {
        if selectedCategory == category {
            return ColorManager.shared.color(for: category ?? .unknown, colorScheme: colorScheme)
        } else {
            return Color.primary
        }
    }

    private func symbol(for category: ElementCategory) -> String {
        switch category {
        case .alkaliMetals:
            return "flame"
        case .alkalineEarthMetals:
            return "leaf"
        case .transitionMetals:
            return "atom"
        case .postTransitionMetals:
            return "cube"
        case .lanthanides:
            return "sparkles"
        case .actinides:
            return "radiowaves.left"
        case .metalloids:
            return "triangle"
        case .nonmetals:
            return "drop"
        case .halogens:
            return "aqi.medium"
        case .nobleGases:
            return "wind"
        case .unknown:
            return "questionmark.diamond"
        }
    }
}

#if DEBUG
#Preview {
    FilterChips(categories: ElementCategory.allCases, selectedCategory: nil) { _ in }
        .padding()
}
#endif
