import SwiftUI

struct LiquidBlobBackground: View {
    let color: Color

    @State private var animate = false
    /// Tracks whether we've started the infinite animation to avoid re-attaching it
    /// every time SwiftUI recomputes the view hierarchy.
    @State private var didStartAnimation = false

    var body: some View {
        GeometryReader { proxy in
            let size = proxy.size

            ZStack {
                blob(
                    size: min(size.width, size.height) * 1.25,
                    xRange: -size.width * 0.35 ... size.width * 0.2,
                    yRange: -size.height * 0.35 ... -size.height * 0.05,
                    baseOpacity: 0.88
                )

                blob(
                    size: min(size.width, size.height) * 1.15,
                    xRange: -size.width * 0.15 ... size.width * 0.35,
                    yRange: size.height * 0.05 ... size.height * 0.4,
                    baseOpacity: 0.78
                )

                blob(
                    size: min(size.width, size.height) * 1.25,
                    xRange: -size.width * 0.3 ... size.width * 0.4,
                    yRange: size.height * 0.35 ... size.height * 0.8,
                    baseOpacity: 0.72
                )
            }
            .frame(width: size.width, height: size.height)
            .onAppear {
                guard !didStartAnimation else { return }
                didStartAnimation = true
                withAnimation(
                    .easeInOut(duration: 18)
                    .repeatForever(autoreverses: true)
                ) {
                    animate = true
                }
            }
        }
        .allowsHitTesting(false)
    }

    private func blob(
        size: CGFloat,
        xRange: ClosedRange<CGFloat>,
        yRange: ClosedRange<CGFloat>,
        baseOpacity: Double
    ) -> some View {
        let startX = xRange.lowerBound
        let endX = xRange.upperBound
        let startY = yRange.lowerBound
        let endY = yRange.upperBound

        return Circle()
            .fill(
                RadialGradient(
                    colors: [
                        color.opacity(baseOpacity),
                        color.opacity(baseOpacity * 0.5),
                        color.opacity(0.0)
                    ],
                    center: .center,
                    startRadius: 0,
                    endRadius: size * 0.65
                )
            )
            .frame(width: size, height: size)
            .offset(
                x: animate ? endX : startX,
                y: animate ? endY : startY
            )
            .blur(radius: 44)
            .blendMode(.multiply)
    }
}

#if DEBUG
#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        LiquidBlobBackground(color: .purple)
    }
}
#endif

