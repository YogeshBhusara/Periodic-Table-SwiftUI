//
//  ElementGridOverlayView.swift
//  Periodic Table
//
//  Full-screen grid of element cards (5 per row) with same glass effect as element cards.
//

import SwiftUI

struct ElementGridOverlayView: View {
    let elements: [ElementCard]
    var namespace: Namespace.ID?
    let onSelect: (ElementCard) -> Void
    let onDismiss: () -> Void
    @Environment(\.colorScheme) private var colorScheme

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 12), count: 5)

    var body: some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .onTapGesture(perform: onDismiss)

            VStack(spacing: 0) {
                HStack {
                    Text("Select element")
                        .font(AppFont.semibold(size: 17))
                    Spacer()
                    Button(action: onDismiss) {
                        Image(systemName: "xmark")
                            .actionIcon(font: .title3.weight(.semibold))
                    }
                    .buttonStyle(.plain)
                    .glassCircleButton(diameter: 40, tint: .secondary)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
                .glassEffect(.regular.interactive(), in: .rect(cornerRadius: 0))

                ScrollView(.vertical, showsIndicators: true) {
                    LazyVGrid(columns: columns, spacing: 12) {
                        ForEach(elements) { element in
                            ElementGridCell(element: element, namespace: namespace)
                                .onTapGesture {
                                    HapticManager.shared.playSelectionChange()
                                    onSelect(element)
                                }
                        }
                    }
                    .padding(16)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(.systemGroupedBackground))
            .designCodeShadow(.strong, colorScheme: colorScheme)
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

    private var categoryGradient: LinearGradient {
        LinearGradient(
            colors: [categoryColor, categoryColor.opacity(0.6)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    private var cellContent: some View {
        let shape = RoundedRectangle(cornerRadius: 16, style: .continuous)

        return VStack(spacing: 6) {
            Text("\(element.atomicNumber)")
                .font(AppFont.mono(size: 13, weight: .bold))
                .foregroundStyle(.secondary)
            Text(element.symbol)
                .font(AppFont.heading(size: 17, weight: .heavy))
                .foregroundStyle(.primary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(
            shape
                .fill(categoryGradient.opacity(colorScheme == .dark ? 0.45 : 0.55))
        )
        .glassEffect(.regular.interactive(), in: .rect(cornerRadius: 16))
        .designCodeShadow(.normal, colorScheme: colorScheme)
        .designCodeInnerGlow(colorScheme: colorScheme, cornerRadius: 16)
    }

    var body: some View {
        Group {
            if let namespace {
                cellContent
                    .matchedGeometryEffect(id: "element-card-\(element.atomicNumber)", in: namespace)
                    .glassEffectID("element-card-\(element.atomicNumber)", in: namespace)
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
