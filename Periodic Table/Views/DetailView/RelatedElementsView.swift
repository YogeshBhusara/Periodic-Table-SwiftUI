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
                                DottedDisplay(text: AtomicDisplay.padded(related.atomicNumber), size: 22)
                                Text(related.symbol)
                                    .font(AppFont.heading(size: 22, weight: .bold))
                                    .foregroundStyle(.white)
                                Text(related.name)
                                    .font(AppFont.eyebrow(size: 11))
                                    .foregroundStyle(.white.opacity(0.75))
                                    .lineLimit(2)
                            }
                            .padding(12)
                            .frame(width: 120, height: 128, alignment: .topLeading)
                            .background(CategoryMeshFill(category: related.category))
                            .widgetChrome(
                                cornerRadius: 20,
                                glow: ColorManager.shared.color(for: related.category)
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
