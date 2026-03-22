//
//  QuizManager.swift
//  Periodic Table
//
//  Created by Cursor AI on 11/12/25.
//

import Foundation

@MainActor
final class QuizManager: ObservableObject {
    enum QuizMode: Equatable {
        case random
        case category(ElementCategory)
        case property(ElementProperty)
    }

    enum ElementProperty: CaseIterable, Identifiable {
        case atomicNumber
        case symbol
        case electronegativity
        case meltingPoint
        case boilingPoint

        var id: String { label }

        var label: String {
            switch self {
            case .atomicNumber:
                return String(localized: "Atomic Number", comment: "Quiz property label")
            case .symbol:
                return String(localized: "Symbol", comment: "Quiz property label")
            case .electronegativity:
                return String(localized: "Electronegativity", comment: "Quiz property label")
            case .meltingPoint:
                return String(localized: "Melting Point", comment: "Quiz property label")
            case .boilingPoint:
                return String(localized: "Boiling Point", comment: "Quiz property label")
            }
        }
    }

    struct QuizQuestion: Identifiable {
        let id = UUID()
        let prompt: String
        let answer: ElementCard
        let choices: [ElementCard]
        let hint: String?
    }

    @Published private(set) var currentQuestion: QuizQuestion?
    @Published private(set) var streak: Int = 0
    @Published private(set) var bestStreak: Int = 0
    @Published private(set) var totalAnswered: Int = 0
    @Published private(set) var correctAnswers: Int = 0
    @Published private(set) var lastAnswerCorrect: Bool?
    @Published var quizMode: QuizMode = .random

    func generateQuestion(from elements: [ElementCard]) {
        guard elements.count >= 4 else {
            currentQuestion = nil
            return
        }

        let filteredElements = filterElements(elements, for: quizMode)
        guard filteredElements.count >= 4 else {
            currentQuestion = nil
            return
        }

        let answer = filteredElements.randomElement()!
        let choices = Array(filteredElements.shuffled().prefix(3)) + [answer]
        let shuffledChoices = choices.shuffled()
        let prompt = makePrompt(for: answer)
        let hint = makeHint(for: answer)
        currentQuestion = QuizQuestion(prompt: prompt, answer: answer, choices: shuffledChoices, hint: hint)
        lastAnswerCorrect = nil
    }

    func submitAnswer(_ element: ElementCard) {
        guard let currentQuestion else { return }
        totalAnswered += 1
        if element == currentQuestion.answer {
            correctAnswers += 1
            streak += 1
            bestStreak = max(bestStreak, streak)
            lastAnswerCorrect = true
            HapticManager.shared.playHeavyImpact()
        } else {
            streak = 0
            lastAnswerCorrect = false
            HapticManager.shared.playMediumImpact()
        }
    }

    func resetProgress() {
        streak = 0
        bestStreak = 0
        totalAnswered = 0
        correctAnswers = 0
        lastAnswerCorrect = nil
    }

    func setMode(_ mode: QuizMode, elements: [ElementCard]) {
        quizMode = mode
        generateQuestion(from: elements)
    }

    private func filterElements(_ elements: [ElementCard], for mode: QuizMode) -> [ElementCard] {
        switch mode {
        case .random:
            return elements
        case .category(let category):
            return elements.filter { $0.category == category }
        case .property(let property):
            return elements.filter { element in
                switch property {
                case .atomicNumber, .symbol:
                    return true
                case .electronegativity:
                    return element.electronegativity != nil
                case .meltingPoint:
                    return element.meltingPoint != nil
                case .boilingPoint:
                    return element.boilingPoint != nil
                }
            }
        }
    }

    private func makePrompt(for element: ElementCard) -> String {
        switch quizMode {
        case .random:
            return String(
                localized: "Guess the element with atomic number \(element.atomicNumber).",
                comment: "Quiz prompt for random mode"
            )
        case .category(let category):
            return String(
                localized: "Which element belongs to \(category.categoryName)?",
                comment: "Quiz prompt for category mode"
            )
        case .property(let property):
            switch property {
            case .atomicNumber:
                return String(
                    localized: "Which element has atomic number \(element.atomicNumber)?",
                    comment: "Quiz prompt atomic number"
                )
            case .symbol:
                return String(
                    localized: "Which element has the symbol \(element.symbol)?",
                    comment: "Quiz prompt symbol"
                )
            case .electronegativity:
                let value = element.electronegativity ?? 0
                return String(
                    localized: "Which element has an electronegativity of \(value, specifier: \"%.2f\")?",
                    comment: "Quiz prompt electronegativity"
                )
            case .meltingPoint:
                let value = element.meltingPoint ?? 0
                return String(
                    localized: "Which element melts at \(value, specifier: \"%.0f\") K?",
                    comment: "Quiz prompt melting point"
                )
            case .boilingPoint:
                let value = element.boilingPoint ?? 0
                return String(
                    localized: "Which element boils at \(value, specifier: \"%.0f\") K?",
                    comment: "Quiz prompt boiling point"
                )
            }
        }
    }

    private func makeHint(for element: ElementCard) -> String? {
        switch quizMode {
        case .random, .category:
            return element.description
        case .property(let property):
            switch property {
            case .symbol:
                return String(localized: "The element name starts with \(element.name.prefix(1)).", comment: "Quiz hint")
            case .atomicNumber:
                return String(localized: "The chemical symbol is \(element.symbol).", comment: "Quiz hint")
            case .electronegativity:
                return String(localized: "This element is \(element.category.categoryName.lowercased()).", comment: "Quiz hint")
            case .meltingPoint, .boilingPoint:
                return String(
                    localized: "This element is often used in \(element.uses.first ?? element.description).",
                    comment: "Quiz hint"
                )
            }
        }
    }
}

