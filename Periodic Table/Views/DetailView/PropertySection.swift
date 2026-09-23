import SwiftUI

struct PropertySection: View {
    let element: ElementCard

    private struct PropertyItem: Identifiable {
        let id = UUID()
        let title: LocalizedStringKey
        let value: String
        let icon: String
        let color: Color
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Physical Properties")
                .font(AppFont.semibold(size: 20))

            propertyGrid

            Divider()

            Text("Electron Details")
                .font(AppFont.semibold(size: 20))

            VStack(spacing: 12) {
                PropertyBar(label: "Electronegativity", value: element.electronegativity ?? 0, maxValue: 4.0, color: AppTheme.signal)
                PropertyBar(label: "Melting Point", value: element.meltingPoint ?? 0, maxValue: 5800, color: Color(hex: "#FF4D8A"))
                PropertyBar(label: "Boiling Point", value: element.boilingPoint ?? 0, maxValue: 6000, color: Color(hex: "#3DFFF0"))
            }
        }
    }

    private var propertyGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
            ForEach(propertyItems) { item in
                HStack(alignment: .center, spacing: 12) {
                    Image(systemName: item.icon)
                        .font(.title2)
                        .foregroundStyle(item.color)
                        .frame(width: 40, height: 40)
                        .background(item.color.opacity(0.12), in: RoundedRectangle(cornerRadius: 12, style: .continuous))

                    VStack(alignment: .leading, spacing: 4) {
                        Text(item.title)
                            .font(AppFont.mono(size: 12))
                            .foregroundStyle(.secondary)
                        Text(item.value)
                            .font(AppFont.semibold(size: 17))
                    }
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .glassEffect(.regular.interactive(), in: .rect(cornerRadius: 20))
            }
        }
    }

    private var propertyItems: [PropertyItem] {
        [
            PropertyItem(title: "Atomic Number", value: "\(element.atomicNumber)", icon: "number", color: .mint),
            PropertyItem(title: "Atomic Mass", value: element.formattedAtomicMass, icon: "scalemass", color: .purple),
            PropertyItem(title: "Density", value: formattedDensity, icon: "cube", color: .teal),
            PropertyItem(title: "Category", value: element.category.categoryName, icon: "tag", color: .orange)
        ]
    }

    private var formattedDensity: String {
        guard let density = element.density else { return "—" }
        return String(format: "%.2f g/cm³", density)
    }
}

private struct PropertyBar: View {
    let label: String
    let value: Double
    let maxValue: Double
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(label)
                    .font(AppFont.body(size: 15))
                Spacer()
                Text(formattedValue)
                    .font(AppFont.semibold(size: 15))
                    .foregroundStyle(color)
            }

            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.white.opacity(0.12))
                    Capsule()
                        .fill(color.gradient)
                        .frame(width: min(CGFloat(progress) * geometry.size.width, geometry.size.width))
                        .animation(.easeInOut(duration: 0.6), value: value)
                }
            }
            .frame(height: 12)
        }
    }

    private var progress: Double {
        guard maxValue > 0 else { return 0 }
        let ratio = value / maxValue
        return min(max(ratio, 0), 1)
    }

    private var formattedValue: String {
        if value == 0 { return "—" }
        if label.contains("Point") {
            return String(format: "%.0f K", value)
        }
        if label == "Electronegativity" {
            return String(format: "%.2f", value)
        }
        return String(format: "%.2f", value)
    }
}

#if DEBUG
#Preview {
    PropertySection(element: .hydrogen)
        .padding()
}
#endif
