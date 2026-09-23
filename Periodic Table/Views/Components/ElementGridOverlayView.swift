//
//  ElementGridOverlayView.swift
//  Periodic Table
//
//  Full-screen element picker. Cells use the same atmospheric mesh as the carousel cards.
//

import SwiftUI

struct ElementGridOverlayView: View {
    let elements: [ElementCard]
    var namespace: Namespace.ID?
    let onSelect: (ElementCard) -> Void
    let onDismiss: () -> Void

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 12), count: 5)

    var body: some View {
        ZStack {
            AppTheme.canvas.opacity(0.55)
                .ignoresSafeArea()
                .onTapGesture(perform: onDismiss)

            VStack(spacing: 0) {
                HStack {
                    Text("Elements")
                        .font(AppFont.heading(size: 28, weight: .bold))
                        .foregroundStyle(.white)
                    Spacer()
                    Button(action: onDismiss) {
                        Image(systemName: "xmark")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(AppTheme.canvas)
                            .frame(width: 36, height: 36)
                            .background(.white, in: Circle())
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Close")
                }
                .padding(.horizontal, Spacing.lg)
                .padding(.top, Spacing.xl)
                .padding(.bottom, Spacing.md)

                ScrollView(.vertical, showsIndicators: false) {
                    LazyVGrid(columns: columns, spacing: 12) {
                        ForEach(elements) { element in
                            ElementGridCell(element: element, namespace: namespace)
                                .onTapGesture {
                                    HapticManager.shared.playSelectionChange()
                                    onSelect(element)
                                }
                        }
                    }
                    .padding(.horizontal, Spacing.md)
                    .padding(.bottom, Spacing.xxl)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(VibeCanvas(accent: AppTheme.signal))
            .ignoresSafeArea(edges: .bottom)
        }
    }
}

private struct ElementGridCell: View {
    let element: ElementCard
    var namespace: Namespace.ID?
    @Environment(\.colorScheme) private var colorScheme

    private var categoryColor: Color {
        ColorManager.shared.color(for: element.category, colorScheme: colorScheme)
    }

    private var cellContent: some View {
        VStack(spacing: 4) {
            DottedDisplay(text: AtomicDisplay.padded(element.atomicNumber), size: 18)
            Text(element.symbol)
                .font(AppFont.heading(size: 16, weight: .bold))
                .foregroundStyle(.white)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(CategoryMeshFill(category: element.category))
        .widgetChrome(cornerRadius: 16, glow: categoryColor.opacity(0.8))
    }

    var body: some View {
        Group {
            if let namespace {
                cellContent
                    .matchedGeometryEffect(id: "element-card-\(element.atomicNumber)", in: namespace)
            } else {
                cellContent
            }
        }
        .contentShape(Rectangle())
    }
}

#if DEBUG
#Preview {
    ElementGridOverlayView(
        elements: ElementCard.sampleElements,
        namespace: nil,
        onSelect: { _ in },
        onDismiss: {}
    )
}
#endif
