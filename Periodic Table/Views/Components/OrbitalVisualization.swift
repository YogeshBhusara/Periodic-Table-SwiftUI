import SwiftUI

struct OrbitalVisualization: View {
    let element: ElementCard

    var body: some View {
        TimelineView(.animation) { timeline in
            Canvas { context, size in
                drawOrbits(context: &context, size: size, date: timeline.date)
            }
            .drawingGroup()
        }
        .frame(height: 180)
    }

    private func drawOrbits(context: inout GraphicsContext, size: CGSize, date: Date) {
        let center = CGPoint(x: size.width / 2, y: size.height / 2)
        let maxRadius = min(size.width, size.height) / 2 - 12
        let shells = shellElectronCounts(for: element.atomicNumber)
        let orbitalCount = shells.count

        for (index, electronsInShell) in shells.enumerated() {
            let progress = CGFloat(index + 1) / CGFloat(orbitalCount)
            let radius = maxRadius * progress

            var orbitPath = Path()
            orbitPath.addEllipse(in: CGRect(x: center.x - radius, y: center.y - radius, width: radius * 2, height: radius * 2))

            context.stroke(
                orbitPath,
                with: .color(Color.white.opacity(0.2)),
                lineWidth: 1.2
            )

            let electronCount = max(1, electronsInShell)
            let baseAngle = CGFloat(date.timeIntervalSinceReferenceDate).truncatingRemainder(dividingBy: CGFloat.pi * 2)

            for electron in 0..<electronCount {
                let offsetAngle = baseAngle
                + CGFloat(electron) * (CGFloat.pi * 2 / CGFloat(electronCount))

                let electronPosition = CGPoint(
                    x: center.x + CoreGraphics.cos(offsetAngle) * radius,
                    y: center.y + CoreGraphics.sin(offsetAngle) * radius
                )
                let electronRect = CGRect(x: electronPosition.x - 5, y: electronPosition.y - 5, width: 10, height: 10)
                let electronCircle = Path(ellipseIn: electronRect)

                context.fill(electronCircle, with: .color(Color.white))

                let glowCircle = Path(ellipseIn: electronRect.insetBy(dx: -4, dy: -4))
                context.fill(glowCircle, with: .color(Color.blue.opacity(0.45)))
            }
        }

        let nucleusRect = CGRect(x: center.x - 13, y: center.y - 13, width: 26, height: 26)
        let nucleus = Path(ellipseIn: nucleusRect)
        let nucleusColor = ColorManager.shared.color(for: element.category)

        let nucleusGlow = Path(ellipseIn: nucleusRect.insetBy(dx: -6, dy: -6))
        context.fill(nucleusGlow, with: .color(nucleusColor.opacity(0.55)))
        context.fill(nucleus, with: .color(.white.opacity(0.95)))
    }

    /// Uses element.shells from CSV when available (Bowserinator data), else computed Bohr-style shells.
    private func shellElectronCounts(for atomicNumber: Int) -> [Int] {
        if let shells = element.shells, !shells.isEmpty {
            return shells
        }
        // Fallback: simple Bohr-model style distribution using 2n² capacities
        let shellCapacities = [2, 8, 18, 32, 32, 18, 8]
        var remaining = max(1, atomicNumber)
        var shells: [Int] = []
        for capacity in shellCapacities {
            guard remaining > 0 else { break }
            shells.append(min(remaining, capacity))
            remaining -= shells.last!
        }
        return shells
    }
}

#if DEBUG
#Preview {
    OrbitalVisualization(element: .hydrogen)
        .padding()
        .background(Color.black)
}
#endif
