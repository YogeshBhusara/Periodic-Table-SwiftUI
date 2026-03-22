import SwiftUI

struct PropertyComparator: View {
    @EnvironmentObject private var dataStore: ElementDataStore
    @EnvironmentObject private var uiState: UIStateManager

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Compare Element Properties")
                .font(.title2.weight(.bold))

            Text("Select two elements to compare their key properties side-by-side.")
                .font(.callout)
                .foregroundStyle(.secondary)

            HStack(spacing: 16) {
                ComparatorSelectionView(index: 0)
                ComparatorSelectionView(index: 1)
            }

            if uiState.selectedComparatorElements.count == 2 {
                ComparisonBars(elements: uiState.selectedComparatorElements)
            } else {
                ContentUnavailableView("Select two elements", systemImage: "slider.horizontal.3", description: Text("Pick two elements to see their properties compared."))
                    .frame(maxWidth: .infinity)
            }
        }
    }
}

private struct ComparatorSelectionView: View {
    let index: Int
    @EnvironmentObject private var dataStore: ElementDataStore
    @EnvironmentObject private var uiState: UIStateManager
    @Environment(\.colorScheme) private var colorScheme

    private var selectedElement: ElementCard? {
        guard uiState.selectedComparatorElements.indices.contains(index) else { return nil }
        return uiState.selectedComparatorElements[index]
    }

    var body: some View {
        VStack(spacing: 12) {
            ZStack(alignment: .topTrailing) {
                Menu {
                    ForEach(dataStore.filteredElements) { element in
                        Button(action: { select(element) }) {
                            Label("\(element.name) (\(element.symbol))", systemImage: "atom")
                        }
                    }
                } label: {
                    VStack(spacing: 8) {
                        if let element = selectedElement {
                            Text(element.symbol)
                                .font(.system(size: 36, weight: .bold, design: .rounded))
                            Text(element.name)
                                .font(.headline)
                                .foregroundStyle(.secondary)
                        } else {
                            Text("Select")
                                .font(.headline)
                            Text("element")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .frame(maxWidth: .infinity, minHeight: 120)
                    .padding()
                    .contentShape(Rectangle())
                }
                .frame(maxWidth: .infinity, minHeight: 120)
                .glassEffect(.regular.interactive(), in: .rect(cornerRadius: 24))
                .designCodeShadow(.normal, colorScheme: colorScheme)
                .designCodeInnerGlow(colorScheme: colorScheme, cornerRadius: 24)

                if selectedElement != nil {
                    Button {
                        removeSelection()
                    } label: {
                        Image(systemName: "xmark.circle")
                            .font(.title2)
                            .foregroundStyle(.secondary)
                    }
                    .buttonStyle(.plain)
                    .padding(Spacing.xs)
                    .accessibilityLabel("Clear selection")
                }
            }
        }
    }

    private func select(_ element: ElementCard) {
        uiState.selectForComparison(element)
    }

    private func removeSelection() {
        guard uiState.selectedComparatorElements.indices.contains(index) else { return }
        uiState.selectedComparatorElements.remove(at: index)
    }
}

private struct ComparisonBars: View {
    let elements: [ElementCard]
    @Environment(\.colorScheme) private var colorScheme

    private var first: ElementCard { elements[0] }
    private var second: ElementCard { elements[1] }

    private struct Metric: Identifiable {
        let id = UUID()
        let title: String
        let subtitle: String
        let firstValue: Double
        let secondValue: Double
        let firstFormatted: String
        let secondFormatted: String
        let maxValue: Double
    }

    private var metrics: [Metric] {
        [
            Metric(
                title: String(localized: "Atomic Mass", comment: "Comparison metric title"),
                subtitle: String(localized: "u", comment: "Atomic mass unit"),
                firstValue: first.atomicMass,
                secondValue: second.atomicMass,
                firstFormatted: String(format: "%.2f", first.atomicMass),
                secondFormatted: String(format: "%.2f", second.atomicMass),
                maxValue: max(first.atomicMass, second.atomicMass)
            ),
            Metric(
                title: String(localized: "Electronegativity", comment: "Comparison metric title"),
                subtitle: "Pauling",
                firstValue: first.electronegativity ?? 0,
                secondValue: second.electronegativity ?? 0,
                firstFormatted: formattedElectronegativity(first.electronegativity),
                secondFormatted: formattedElectronegativity(second.electronegativity),
                maxValue: max(max(first.electronegativity ?? 0, second.electronegativity ?? 0), 1)
            ),
            Metric(
                title: String(localized: "Melting Point", comment: "Comparison metric title"),
                subtitle: "K",
                firstValue: first.meltingPoint ?? 0,
                secondValue: second.meltingPoint ?? 0,
                firstFormatted: formattedTemperature(first.meltingPoint),
                secondFormatted: formattedTemperature(second.meltingPoint),
                maxValue: max(max(first.meltingPoint ?? 0, second.meltingPoint ?? 0), 1)
            ),
            Metric(
                title: String(localized: "Boiling Point", comment: "Comparison metric title"),
                subtitle: "K",
                firstValue: first.boilingPoint ?? 0,
                secondValue: second.boilingPoint ?? 0,
                firstFormatted: formattedTemperature(first.boilingPoint),
                secondFormatted: formattedTemperature(second.boilingPoint),
                maxValue: max(max(first.boilingPoint ?? 0, second.boilingPoint ?? 0), 1)
            )
        ]
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Property Comparison")
                .font(.headline)

            ForEach(metrics) { metric in
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text(metric.title)
                            .font(.subheadline)
                        Spacer()
                        Text(metric.subtitle)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }

                    HStack(alignment: .bottom, spacing: 18) {
                        bar(for: first.symbol, value: metric.firstValue, maxValue: metric.maxValue, formatted: metric.firstFormatted, color: .teal)
                        bar(for: second.symbol, value: metric.secondValue, maxValue: metric.maxValue, formatted: metric.secondFormatted, color: .orange)
                    }
                }
            }
        }
        .padding()
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 24, style: .continuous))
        .designCodeShadow(.normal, colorScheme: colorScheme)
        .designCodeInnerGlow(colorScheme: colorScheme, cornerRadius: 24)
    }

    private func bar(for symbol: String, value: Double, maxValue: Double, formatted: String, color: Color) -> some View {
        VStack(alignment: .center, spacing: 6) {
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(color.gradient)
                .frame(width: 46, height: barHeight(value: value, maxValue: maxValue))
                .animation(.easeOut(duration: 0.6), value: value)
            Text(symbol)
                .font(.headline)
            Text(formatted)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
    }

    private func barHeight(value: Double, maxValue: Double) -> CGFloat {
        guard maxValue > 0 else { return 12 }
        let normalized = value / maxValue
        return max(12, CGFloat(normalized) * 120)
    }

    private func formattedElectronegativity(_ value: Double?) -> String {
        guard let value, value > 0 else { return "—" }
        return String(format: "%.2f", value)
    }

    private func formattedTemperature(_ value: Double?) -> String {
        guard let value, value > 0 else { return "—" }
        return String(format: "%.0f", value)
    }
}

#if DEBUG
#Preview {
    PropertyComparator()
        .environmentObject(ElementDataStore(previewElements: ElementCard.sampleElements))
        .environmentObject(UIStateManager())
        .padding()
}
#endif
