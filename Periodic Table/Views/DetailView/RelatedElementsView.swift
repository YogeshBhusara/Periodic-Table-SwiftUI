import SwiftUI

struct RelatedElementsView: View {
    let element: ElementCard

    @EnvironmentObject private var dataStore: ElementDataStore
    @EnvironmentObject private var uiState: UIStateManager
    @Namespace private var namespace

    private var relatedElements: [ElementCard] {
        let neighbors = [element.atomicNumber - 1, element.atomicNumber + 1]
            .compactMap { dataStore.element(for: $0) }
        let sameCategory = dataStore.elements(in: element.category)
            .filter { $0.atomicNumber != element.atomicNumber }
            .prefix(6)
        return Array(neighbors + sameCategory)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Related Elements")
                    .font(.title3.weight(.semibold))
                Spacer()
                if !relatedElements.isEmpty {
                    Text("Swipe to explore")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }

            if relatedElements.isEmpty {
                ContentUnavailableView("No related elements", systemImage: "sparkles", description: Text("Explore the table to discover more connections."))
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 16) {
                        ForEach(relatedElements) { related in
                            VStack(alignment: .leading, spacing: 6) {
                                Text("\(related.atomicNumber)")
                                    .font(.caption.bold())
                                    .foregroundStyle(.secondary)
                                Text(related.symbol)
                                    .font(.headline)
                                Text(related.name)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            .padding(12)
                            .frame(width: 110, height: 120, alignment: .topLeading)
                            .background(
                                RoundedRectangle(cornerRadius: 18, style: .continuous)
                                    .fill(Color(.secondarySystemBackground))
                            )
                            .onTapGesture {
                                HapticManager.shared.playSelectionChange()
                                withAnimation(AnimationConstants.spotifyOpen) {
                                    uiState.selectElement(related)
                                }
                            }
                        }
                    }
                    .padding(.vertical, 8)
                }
            }
        }
    }
}

#if DEBUG
#Preview {
    RelatedElementsView(element: .hydrogen)
        .environmentObject(ElementDataStore(previewElements: ElementCard.sampleElements))
        .environmentObject(UIStateManager())
        .padding()
}
#endif
