//
//  VibeSurface.swift
//  Periodic Table
//
//  Shared surfaces for the widget look: dot-grid canvas, stippled numerals,
//  signal waveform, and atmospheric category fills.
//

import SwiftUI

// MARK: - Canvas

struct VibeCanvas: View {
    var accent: Color = AppTheme.signal

    var body: some View {
        ZStack {
            AppTheme.canvas
            RadialGradient(
                colors: [accent.opacity(0.46), accent.opacity(0.08), .clear],
                center: UnitPoint(x: 0.12, y: -0.05),
                startRadius: 8,
                endRadius: 480
            )
            RadialGradient(
                colors: [accent.opacity(0.22), .clear],
                center: UnitPoint(x: 0.95, y: 1.08),
                startRadius: 8,
                endRadius: 360
            )
            DotField()
        }
        .ignoresSafeArea()
        .allowsHitTesting(false)
    }
}

private struct DotField: View {
    var body: some View {
        Canvas { context, size in
            let spacing: CGFloat = 18
            let radius: CGFloat = 0.7
            var y = spacing * 0.5
            while y < size.height {
                var x = spacing * 0.5
                while x < size.width {
                    let rect = CGRect(x: x - radius, y: y - radius, width: radius * 2, height: radius * 2)
                    context.fill(Path(ellipseIn: rect), with: .color(.white.opacity(0.16)))
                    x += spacing
                }
                y += spacing
            }
        }
    }
}

// MARK: - Category mesh

struct CategoryMeshFill: View {
    let category: ElementCategory

    var body: some View {
        let mesh = ColorManager.shared.mesh(for: category)
        ZStack {
            LinearGradient(
                colors: [mesh.deep, mesh.mid, mesh.glow.opacity(0.9)],
                startPoint: .bottomLeading,
                endPoint: .topTrailing
            )
            RadialGradient(
                colors: [mesh.glow.opacity(0.95), mesh.mid.opacity(0.15), .clear],
                center: UnitPoint(x: 0.82, y: 0.08),
                startRadius: 4,
                endRadius: 280
            )
            RadialGradient(
                colors: [.black.opacity(0.38), .clear],
                center: UnitPoint(x: 0.05, y: 1.05),
                startRadius: 8,
                endRadius: 260
            )
        }
    }
}

// MARK: - Dotted display

struct DottedDisplay: View {
    let text: String
    var size: CGFloat = 72
    var color: Color = .white

    var body: some View {
        Text(text)
            .font(.system(size: size, weight: .heavy, design: .rounded))
            .monospacedDigit()
            .foregroundStyle(color)
            .lineLimit(1)
            .fixedSize()
            .mask {
                DotLattice(spacing: max(1.5, size * 0.046))
            }
            .accessibilityLabel(text)
    }
}

private struct DotLattice: View {
    let spacing: CGFloat

    var body: some View {
        Canvas { context, size in
            let radius = spacing * 0.36
            var y = radius
            while y < size.height {
                var x = radius
                while x < size.width {
                    let rect = CGRect(x: x - radius, y: y - radius, width: radius * 2, height: radius * 2)
                    context.fill(Path(ellipseIn: rect), with: .color(.white))
                    x += spacing
                }
                y += spacing
            }
        }
    }
}

enum AtomicDisplay {
    static func padded(_ number: Int) -> String {
        if number < 100 {
            return String(format: "%02d", number)
        }
        return String(number)
    }
}

// MARK: - Signal wave

struct SignalWave: View {
    var color: Color = AppTheme.signal

    var body: some View {
        TimelineView(.animation(minimumInterval: 1.0 / 30.0)) { timeline in
            let phase = CGFloat(timeline.date.timeIntervalSinceReferenceDate)
            Canvas { context, size in
                var path = Path()
                let mid = size.height * 0.55
                let amplitude = size.height * 0.28
                let steps = 72
                for index in 0...steps {
                    let u = CGFloat(index) / CGFloat(steps)
                    let x = u * size.width
                    let wave = sin(u * .pi * 2.6 + phase * 1.35)
                    let envelope = sin(u * .pi)
                    let y = mid - wave * amplitude * envelope
                    if index == 0 {
                        path.move(to: CGPoint(x: x, y: y))
                    } else {
                        path.addLine(to: CGPoint(x: x, y: y))
                    }
                }
                context.stroke(
                    path,
                    with: .color(color),
                    style: StrokeStyle(lineWidth: 1.6, lineCap: .round, lineJoin: .round)
                )
            }
        }
        .allowsHitTesting(false)
        .accessibilityHidden(true)
    }
}

// MARK: - Widget chrome

extension View {
    func widgetChrome(cornerRadius: CGFloat = AppTheme.cornerRadiusHero, glow: Color = .clear) -> some View {
        let shape = RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
        return self
            .clipShape(shape)
            .overlay {
                shape.strokeBorder(
                    LinearGradient(
                        colors: [Color.white.opacity(0.42), Color.white.opacity(0.05)],
                        startPoint: .top,
                        endPoint: .bottom
                    ),
                    lineWidth: 1
                )
            }
            .shadow(color: .black.opacity(0.5), radius: 18, x: 0, y: 14)
            .shadow(color: glow.opacity(0.4), radius: 28, x: 0, y: 8)
    }

    func signalCapsule() -> some View {
        self
            .font(AppFont.semibold(size: 16))
            .foregroundStyle(AppTheme.canvas)
            .padding(.horizontal, Spacing.lg)
            .padding(.vertical, Spacing.sm)
            .background(AppTheme.signal, in: Capsule())
            .shadow(color: AppTheme.signal.opacity(0.35), radius: 12, x: 0, y: 6)
    }
}
