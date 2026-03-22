import SwiftUI

struct ExpandedCardView: View {
    let element: ElementCard
    var namespace: Namespace.ID?
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        let cardShape = RoundedRectangle(cornerRadius: LayoutConstants.elementCardCornerRadius, style: .continuous)

        ZStack {
            // Main glass card
            cardSurface
                .overlay(cardContent)
                .designCodeShadow(.strong, colorScheme: colorScheme)
                .designCodeInnerGlow(colorScheme: colorScheme, cornerRadius: LayoutConstants.elementCardCornerRadius)
                .modifier(MatchedCardModifier(id: "element-card-\(element.atomicNumber)", namespace: namespace))
        }
        .compositingGroup()
        .clipShape(cardShape)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(AccessibilityLabels.elementCard(element))
    }

    @ViewBuilder
    private var cardSurface: some View {
        let shape = RoundedRectangle(cornerRadius: LayoutConstants.elementCardCornerRadius, style: .continuous)

        shape
            .fill(Color.clear)
            .glassEffect(
                .regular
                    .interactive(),
                in: .rect(cornerRadius: LayoutConstants.elementCardCornerRadius)
            )
    }

    private func formattedTemperature(_ value: Double?) -> String {
        guard let value else { return "—" }
        return String(format: "%.0f K", value)
    }

    private var cardContent: some View {
        VStack(spacing: 0) {
            // Top: 3D Bohr model (from CSV bohr_model_3d) or 2D orbital visualization; 3D allows rotation
            ElementOrbitalView(element: element, height: 216)
                .opacity(0.75)
                .blendMode(.plusLighter)

            Divider()
                .background(Color.white.opacity(0.5))

            // Bottom: element info + stats
            VStack(alignment: .leading, spacing: Spacing.sm) {
                VStack(alignment: .leading, spacing: Spacing.xs) {
                    Text("\(element.atomicNumber)")
                        .font(AppFont.mono(size: 12, weight: .bold))
                        .foregroundStyle(.secondary)

                    Text(element.symbol)
                        .font(AppFont.heading(size: 40, weight: .heavy))

                    Text(element.name)
                        .font(AppFont.semibold(size: 17))
                        .foregroundStyle(.primary)

                    Text(element.formattedAtomicMass)
                        .font(AppFont.mono(size: 12))
                        .foregroundStyle(.secondary)
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

                    Spacer()

                    VStack(alignment: .leading, spacing: Spacing.xxs) {
                        Text("BOILING POINT")
                            .font(AppFont.mono(size: 10))
                            .foregroundStyle(.secondary)
                        Text(formattedTemperature(element.boilingPoint))
                            .font(AppFont.mono(size: 12))
                            .foregroundStyle(.primary)
                    }
                }
            }
            .padding(Spacing.lg)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

}

#if DEBUG
#Preview {
    ExpandedCardView(element: .hydrogen, namespace: nil)
        .padding()
        .background(Color(.systemGroupedBackground))
}
#endif

private struct MatchedCardModifier: ViewModifier {
    let id: String
    let namespace: Namespace.ID?

    func body(content: Content) -> some View {
        if let namespace {
            content
                .matchedGeometryEffect(id: id, in: namespace)
                .glassEffectID(id, in: namespace)
        } else {
            content
        }
    }
}
