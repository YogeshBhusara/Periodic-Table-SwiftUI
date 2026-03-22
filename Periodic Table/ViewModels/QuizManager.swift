//
//  QuizManager.swift
//  Periodic Table
//
//  Created by Cursor AI on 11/12/25.
//

import Foundation

@MainActor
final class QuizManager: ObservableObject {
    enum QuizMode: Hashable {
        case random
        case category(ElementCategory)
        case property(ElementProperty)
    }

    /// Question styles used in random mode for variety (fun facts, discovery, uses, properties, etc.).
    private enum QuestionStyle: CaseIterable {
        case atomicNumber
        case symbol
        case discoveryYear
        case discoveredBy
        case use
        case funFact
        case descriptionSnippet
        case meltingPoint
        case boilingPoint
        case electronegativity
        case density
        case superlative
    }

    /// Superlative prompts: "Which element...?" with expected atomic number. Used when style == .superlative.
    private static let superlativePrompts: [(prompt: String, atomicNumber: Int)] = [
        (String(localized: "Which element is the most abundant in the universe?", comment: "Quiz superlative"), 1),
        (String(localized: "Which element is the lightest metal and can float on water?", comment: "Quiz superlative"), 3),
        (String(localized: "Which element makes up about 78% of Earth's atmosphere?", comment: "Quiz superlative"), 7),
        (String(localized: "Which element is the most electronegative and reactive?", comment: "Quiz superlative"), 9),
        (String(localized: "Which element is essential for thyroid hormones?", comment: "Quiz superlative"), 53),
        (String(localized: "Which element has the highest melting point of any metal?", comment: "Quiz superlative"), 74),
        (String(localized: "Which element is the densest naturally occurring element?", comment: "Quiz superlative"), 76),
        (String(localized: "Which metal is liquid at room temperature?", comment: "Quiz superlative"), 80),
        (String(localized: "Which element is used in household smoke detectors?", comment: "Quiz superlative"), 95),
        (String(localized: "Which element was discovered by Marie Curie?", comment: "Quiz superlative"), 84),
        (String(localized: "Which element is the main component of steel?", comment: "Quiz superlative"), 26),
        (String(localized: "Which element is the foundation of all known life on Earth?", comment: "Quiz superlative"), 6),
        (String(localized: "Which element is key in rechargeable lithium-ion batteries?", comment: "Quiz superlative"), 3),
        (String(localized: "Which element glows reddish-orange when electrified (neon signs)?", comment: "Quiz superlative"), 10),
        (String(localized: "Which element is the best electrical conductor among metals?", comment: "Quiz superlative"), 47),
    ]

    enum ElementProperty: CaseIterable, Identifiable {
        case atomicNumber
        case symbol
        case electronegativity
        case meltingPoint
        case boilingPoint
        case density

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
            case .density:
                return String(localized: "Density", comment: "Quiz property label")
            }
        }
    }

    struct QuizQuestion: Identifiable {
        let id = UUID()
        let prompt: String
        let answer: ElementCard
        let choices: [ElementCard]
        let hint: String?
        /// When true, option cards should hide atomic numbers until the user selects an answer.
        let isAboutAtomicNumber: Bool
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

        switch quizMode {
        case .random:
            generateRandomModeQuestion(from: elements, filtered: filteredElements)
        case .category, .property:
            generateFixedModeQuestion(from: filteredElements)
        }
        lastAnswerCorrect = nil
    }

    private func generateRandomModeQuestion(from all: [ElementCard], filtered: [ElementCard]) {
        let styles = QuestionStyle.allCases.shuffled()
        for style in styles {
            let valid = validElementsForStyle(filtered, style: style, allElements: all)
            guard valid.count >= 4 else { continue }
            let answer: ElementCard
            if style == .superlative, let pair = Self.superlativePrompts.shuffled().first(where: { p in valid.contains(where: { $0.atomicNumber == p.atomicNumber }) }) {
                answer = valid.first { $0.atomicNumber == pair.atomicNumber }!
            } else if style == .superlative {
                continue
            } else {
                answer = valid.randomElement()!
            }
            let others = valid.filter { $0.atomicNumber != answer.atomicNumber }.shuffled()
            let choices = (Array(others.prefix(3)) + [answer]).shuffled()
            let prompt = makePromptForRandomMode(for: answer, style: style)
            let hint = makeHintForRandomMode(for: answer, style: style)
            currentQuestion = QuizQuestion(prompt: prompt, answer: answer, choices: choices, hint: hint, isAboutAtomicNumber: style == .atomicNumber)
            return
        }
        generateFixedModeQuestion(from: filtered)
    }

    private func validElementsForStyle(_ elements: [ElementCard], style: QuestionStyle, allElements: [ElementCard]) -> [ElementCard] {
        switch style {
        case .atomicNumber, .symbol:
            return elements
        case .discoveryYear:
            return elements.filter { $0.discoveryYear != nil && !($0.discoveryYear?.isEmpty ?? true) }
        case .discoveredBy:
            return elements.filter { $0.discoveredBy != nil && !($0.discoveredBy?.isEmpty ?? true) }
        case .use:
            return elements.filter { !$0.uses.isEmpty }
        case .funFact:
            return elements.filter { !$0.funFacts.isEmpty }
        case .descriptionSnippet:
            return elements.filter { !$0.description.trimmingCharacters(in: .whitespaces).isEmpty }
        case .meltingPoint:
            return elements.filter { $0.meltingPoint != nil }
        case .boilingPoint:
            return elements.filter { $0.boilingPoint != nil }
        case .electronegativity:
            return elements.filter { $0.electronegativity != nil }
        case .density:
            return elements.filter { $0.density != nil }
        case .superlative:
            let nums = Set(Self.superlativePrompts.map(\.atomicNumber))
            return elements.filter { nums.contains($0.atomicNumber) }
        }
    }

    private func makePromptForRandomMode(for element: ElementCard, style: QuestionStyle) -> String {
        switch style {
        case .atomicNumber:
            return String(localized: "Which element has atomic number \(element.atomicNumber)?", comment: "Quiz random")
        case .symbol:
            return String(localized: "Which element has the symbol \(element.symbol)?", comment: "Quiz random")
        case .discoveryYear:
            return String(localized: "Which element was discovered in \(element.discoveryYear ?? "")?", comment: "Quiz random")
        case .discoveredBy:
            return String(localized: "Which element was discovered by \(element.discoveredBy ?? "")?", comment: "Quiz random")
        case .use:
            let use = element.uses.randomElement() ?? element.uses[0]
            return String(localized: "Which element is used in \(use)?", comment: "Quiz random")
        case .funFact:
            let fact = element.funFacts.randomElement() ?? element.funFacts[0]
            return String(localized: "Which element: \(fact)", comment: "Quiz random")
        case .descriptionSnippet:
            let firstSentence: String
            if let idx = element.description.firstIndex(of: ".") {
                firstSentence = String(element.description[..<idx].trimmingCharacters(in: .whitespaces)) + "."
            } else {
                firstSentence = element.description.trimmingCharacters(in: .whitespaces)
            }
            return String(localized: "Which element is described as: \"\(firstSentence)\"?", comment: "Quiz random")
        case .meltingPoint:
            let v = element.meltingPoint ?? 0
            return String(localized: "Which element melts at \(formattedValue(v, fractionDigits: 0)) K?", comment: "Quiz random")
        case .boilingPoint:
            let v = element.boilingPoint ?? 0
            return String(localized: "Which element boils at \(formattedValue(v, fractionDigits: 0)) K?", comment: "Quiz random")
        case .electronegativity:
            let v = element.electronegativity ?? 0
            return String(localized: "Which element has an electronegativity of \(formattedValue(v, fractionDigits: 2))?", comment: "Quiz random")
        case .density:
            let v = element.density ?? 0
            return String(localized: "Which element has a density of \(formattedValue(v, fractionDigits: 2)) g/cm³?", comment: "Quiz random")
        case .superlative:
            if let pair = Self.superlativePrompts.first(where: { $0.atomicNumber == element.atomicNumber }) {
                return pair.prompt
            }
            return String(localized: "Which element has atomic number \(element.atomicNumber)?", comment: "Quiz fallback")
        }
    }

    private func makeHintForRandomMode(for element: ElementCard, style: QuestionStyle) -> String? {
        switch style {
        case .atomicNumber:
            return String(localized: "Its symbol is \(element.symbol).", comment: "Quiz hint")
        case .symbol:
            return String(localized: "Atomic number \(element.atomicNumber).", comment: "Quiz hint")
        case .discoveryYear, .discoveredBy:
            return element.description
        case .use, .funFact, .descriptionSnippet:
            return element.category.categoryName + " · " + element.description
        case .meltingPoint, .boilingPoint, .electronegativity, .density:
            return String(localized: "Used in \(element.uses.first ?? element.category.categoryName).", comment: "Quiz hint")
        case .superlative:
            return element.description
        }
    }

    private func generateFixedModeQuestion(from filtered: [ElementCard]) {
        let answer = filtered.randomElement()!
        let others = filtered.filter { $0.atomicNumber != answer.atomicNumber }.shuffled()
        let choices = (Array(others.prefix(3)) + [answer]).shuffled()
        let prompt = makePrompt(for: answer)
        let hint = makeHint(for: answer)
        let isAboutAtomicNumber: Bool
        if case .property(.atomicNumber) = quizMode { isAboutAtomicNumber = true }
        else { isAboutAtomicNumber = false }
        currentQuestion = QuizQuestion(prompt: prompt, answer: answer, choices: choices, hint: hint, isAboutAtomicNumber: isAboutAtomicNumber)
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
                case .density:
                    return element.density != nil
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
                    localized: "Which element has an electronegativity of \(formattedValue(value, fractionDigits: 2))?",
                    comment: "Quiz prompt electronegativity"
                )
            case .meltingPoint:
                let value = element.meltingPoint ?? 0
                return String(
                    localized: "Which element melts at \(formattedValue(value, fractionDigits: 0)) K?",
                    comment: "Quiz prompt melting point"
                )
            case .boilingPoint:
                let value = element.boilingPoint ?? 0
                return String(
                    localized: "Which element boils at \(formattedValue(value, fractionDigits: 0)) K?",
                    comment: "Quiz prompt boiling point"
                )
            case .density:
                let value = element.density ?? 0
                return String(
                    localized: "Which element has a density of \(formattedValue(value, fractionDigits: 2)) g/cm³?",
                    comment: "Quiz prompt density"
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
                let initial = String(element.name.prefix(1))
                return String(localized: "The element name starts with \(initial).", comment: "Quiz hint")
            case .atomicNumber:
                return String(localized: "The chemical symbol is \(element.symbol).", comment: "Quiz hint")
            case .electronegativity:
                return String(localized: "This element is \(element.category.categoryName.lowercased()).", comment: "Quiz hint")
            case .meltingPoint, .boilingPoint:
                return String(
                    localized: "This element is often used in \(element.uses.first ?? element.description).",
                    comment: "Quiz hint"
                )
            case .density:
                return String(localized: "This element is \(element.category.categoryName.lowercased()).", comment: "Quiz hint")
            }
        }
    }

    private func formattedValue(_ value: Double, fractionDigits: Int) -> String {
        let formatter = NumberFormatter()
        formatter.minimumFractionDigits = fractionDigits
        formatter.maximumFractionDigits = fractionDigits
        formatter.locale = .current
        return formatter.string(from: NSNumber(value: value)) ?? "\(value)"
    }
}

