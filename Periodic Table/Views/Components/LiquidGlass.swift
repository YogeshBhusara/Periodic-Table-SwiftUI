import SwiftUI

// Liquid Glass API usage based on:
// https://github.com/mertozseven/LiquidGlassSwiftUI

extension View {
    /// - Parameters:
    ///   - diameter: Circle size.
    ///   - tint: Glass material tint (background).
    ///   - iconColor: Icon color; if nil, uses `tint` (keeps icon visible when tint is dark).
    func glassCircleButton(
        diameter: CGFloat = LayoutConstants.glassCircleButtonDiameter,
        tint: Color = .white,
        iconColor: Color? = nil
    ) -> some View {
        let icon = iconColor ?? tint
        return self
            .foregroundStyle(icon)
            .frame(width: diameter, height: diameter)
            .contentShape(Circle())
            .glassEffect(
                .regular
                    .tint(tint)
                    .interactive()
            )
            .clipShape(Circle())
    }

    func actionIcon(font: Font = .title3.weight(.semibold)) -> some View {
        self
            .font(font)
            .contentTransition(.symbolEffect(.replace))
    }

    func glassEffectIDIfAvailable(_ id: String, in namespace: Namespace.ID?) -> some View {
        Group {
            if let namespace {
                self.glassEffectID(id, in: namespace)
            } else {
                self
            }
        }
    }
}

func LiquidGlassContainer<Content: View>(spacing: CGFloat = Spacing.md, @ViewBuilder content: () -> Content) -> some View {
    GlassEffectContainer(spacing: spacing) {
        content()
    }
}

