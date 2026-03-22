//
//  HapticManager.swift
//  Periodic Table
//
//  Created by Cursor AI on 11/12/25.
//

import CoreHaptics
import UIKit

final class HapticManager {
    static let shared = HapticManager()

    private let lightImpact = UIImpactFeedbackGenerator(style: .light)
    private let mediumImpact = UIImpactFeedbackGenerator(style: .medium)
    private let heavyImpact = UIImpactFeedbackGenerator(style: .heavy)
    private let selectionGenerator = UISelectionFeedbackGenerator()
    private var engine: CHHapticEngine?

    private init() {
        prepareGenerators()
        prepareEngine()
    }

    func playLightTap() {
        lightImpact.impactOccurred()
    }

    func playMediumImpact() {
        mediumImpact.impactOccurred()
    }

    func playHeavyImpact() {
        heavyImpact.impactOccurred()
    }

    func playSelectionChange() {
        selectionGenerator.selectionChanged()
    }

    func playQuizCelebration() {
        guard let engine else { return }
        Task(priority: .utility) {
            do {
                try engine.start()
                let events = [
                    CHHapticEvent(eventType: .hapticTransient, parameters: [], relativeTime: 0),
                    CHHapticEvent(eventType: .hapticTransient, parameters: [], relativeTime: 0.1),
                    CHHapticEvent(eventType: .hapticTransient, parameters: [], relativeTime: 0.2)
                ]
                let pattern = try CHHapticPattern(events: events, parameters: [])
                let player = try engine.makePlayer(with: pattern)
                try player.start(atTime: 0)
            } catch {
                #if DEBUG
                print("HapticManager error: \(error.localizedDescription)")
                #endif
            }
        }
    }

    private func prepareGenerators() {
        lightImpact.prepare()
        mediumImpact.prepare()
        heavyImpact.prepare()
        selectionGenerator.prepare()
    }

    private func prepareEngine() {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
        do {
            engine = try CHHapticEngine()
            try engine?.start()
        } catch {
            #if DEBUG
            print("Failed to initialize haptic engine: \(error.localizedDescription)")
            #endif
        }
    }
}

