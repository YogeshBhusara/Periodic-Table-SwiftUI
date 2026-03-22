//
//  ElementOrbitalView.swift
//  Periodic Table
//
//  Shows 3D Bohr model from bohr_model_3d when available, else 2D orbital visualization.
//

import SwiftUI

struct ElementOrbitalView: View {
    let element: ElementCard
    var height: CGFloat = 216

    private var is3D: Bool {
        guard let urlString = element.bohrModel3DURL,
              let url = URL(string: urlString),
              url.scheme == "https" else { return false }
        return true
    }

    var body: some View {
        Group {
            if is3D, let url = URL(string: element.bohrModel3DURL!) {
                BohrModel3DView(modelURL: url, height: height)
            } else {
                OrbitalVisualization(element: element)
                    .frame(height: height)
            }
        }
        .allowsHitTesting(is3D)
    }
}

#if DEBUG
#Preview {
    ElementOrbitalView(element: .hydrogen, height: 216)
        .padding()
        .background(Color.black.opacity(0.3))
}
#endif
