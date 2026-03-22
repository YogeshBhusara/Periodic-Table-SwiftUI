//
//  CardAnimationState.swift
//  Periodic Table
//
//  Created by Cursor AI on 11/12/25.
//

import SwiftUI

struct CardAnimationState {
    var isExpanded: Bool = false
    var scale: CGFloat = 1
    var offset: CGSize = .zero
    var opacity: Double = 1
    var blurRadius: CGFloat = 0

    static let identity = CardAnimationState()
}

