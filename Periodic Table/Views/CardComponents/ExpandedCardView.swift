import SwiftUI

struct ExpandedCardView: View {
    let element: ElementCard
    var namespace: Namespace.ID?
    @Environment(\.colorScheme) private var colorScheme

    private var categoryColor: Color {
        ColorManager.shared.color(for: element.category, colorScheme: colorScheme)
    }

    var body: some View {
        ZStack {
            CategoryMeshFill(category: element.category)

            ElementOrbitalView(element: element, height: 188)
                .opacity(0.92)
                .mask(
                    LinearGradient(
                        colors: [.white, .white.opacity(0.8), .clear],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                .padding(.top, Spacing.xs)
        }
        .overlay(alignment: .bottom) {
            VStack(alignment: .leading, spacing: Spacing.sm) {
                Text(element.category.categoryName)
                    .font(AppFont.eyebrow(size: 12))
                    .tracking(1.4)
                    .textCase(.uppercase)
                    .foregroundStyle(.white.opacity(0.72))

                HStack(alignment: .firstTextBaseline, spacing: Spacing.sm) {
                    DottedDisplay(
                        text: AtomicDisplay.padded(element.atomicNumber),
                        size: 84
                    )
                    Spacer(minLength: Spacing.xs)
                    Text(element.symbol)
                        .font(AppFont.heading(size: 44, weight: .bold))
                        .foregroundStyle(.white)
                }

                Text(element.name)
                    .font(AppFont.heading(size: 22, weight: .semibold))
                    .foregroundStyle(.white.opacity(0.92))

                SignalWave()
                    .frame(height: 28)
                    .padding(.top, Spacing.xxs)

                HStack(spacing: Spacing.md) {
                    metric(title: "Melting", value: formattedTemperature(element.meltingPoint))
                    metric(title: "Boiling", value: formattedTemperature(element.boilingPoint))
                    Spacer(minLength: 0)
                    Text(element.formattedAtomicMass)
                        .font(AppFont.mono(size: 12, weight: .medium))
                        .foregroundStyle(.white.opacity(0.7))
                }
            }
            .padding(Spacing.xl)
            .allowsHitTesting(false)
        }
        .widgetChrome(cornerRadius: LayoutConstants.elementCardCornerRadius, glow: categoryColor)
        .modifier(MatchedCardModifier(id: "element-card-\(element.atomicNumber)", namespace: namespace))
        .accessibilityElement(children: .combine)
        .accessibilityLabel(AccessibilityLabels.elementCard(element))
    }

    private func metric(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: Spacing.xxs) {
            Text(title.uppercased())
                .font(AppFont.eyebrow(size: 10))
                .tracking(1.1)
                .foregroundStyle(.white.opacity(0.62))
            Text(value)
                .font(AppFont.mono(size: 13, weight: .medium))
                .foregroundStyle(.white)
        }
    }

    private func formattedTemperature(_ value: Double?) -> String {
        guard let value else { return "—" }
        return String(format: "%.0f K", value)
    }
}

#if DEBUG
#Preview {
    ExpandedCardView(element: .hydrogen, namespace: nil)
        .padding()
        .frame(height: 520)
        .background(AppTheme.canvas)
}
#endif

private struct MatchedCardModifier: ViewModifier {
    let id: String
    let namespace: Namespace.ID?

    func body(content: Content) -> some View {
        if let namespace {
            content.matchedGeometryEffect(id: id, in: namespace)
        } else {
            content
        }
    }
}
