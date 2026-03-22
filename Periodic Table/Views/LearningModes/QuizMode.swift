import SwiftUI

struct QuizModeView: View {
    @EnvironmentObject private var dataStore: ElementDataStore
    @EnvironmentObject private var quizManager: QuizManager
    @Environment(\.colorScheme) private var colorScheme
    @State private var isAnswerRevealed = false

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            VStack(alignment: .leading, spacing: 16) {
                header
                modePicker
            }
            .padding(Spacing.lg)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(colorScheme == .dark ? AppTheme.cardBackgroundDark : Color(.secondarySystemGroupedBackground))
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadiusLarge, style: .continuous))
            .glassEffect(.regular.interactive(), in: .rect(cornerRadius: AppTheme.cornerRadiusLarge))
            .designCodeShadow(.normal, colorScheme: colorScheme)
            .designCodeInnerGlow(colorScheme: colorScheme, cornerRadius: AppTheme.cornerRadiusLarge)
            .id("quiz-header-card")
            .compositingGroup()

            if let question = quizManager.currentQuestion {
                questionCard(for: question)
            } else {
                ContentUnavailableView("Loading quiz", systemImage: "hourglass", description: Text("Preparing a new question..."))
                    .frame(maxWidth: .infinity)
            }
        }
        .task { await prepareQuiz() }
        .onChange(of: quizManager.quizMode) { _, _ in
            Task { await prepareQuiz(force: true) }
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Quiz Challenge")
                .font(AppFont.heading1)

            HStack(spacing: 12) {
                Label("Streak: \(quizManager.streak)", systemImage: "flame")
                    .foregroundStyle(.orange)
                Label("Best: \(quizManager.bestStreak)", systemImage: "trophy")
                    .foregroundStyle(.yellow)
                Label("Accuracy: \(accuracy, specifier: "%.0f")%", systemImage: "checkmark.circle")
                    .foregroundStyle(.green)
            }
            .font(.subheadline)
        }
    }

    private var modePicker: some View {
        Picker("Quiz Mode", selection: $quizManager.quizMode) {
            Text("Random").tag(QuizManager.QuizMode.random)
            ForEach(ElementCategory.allCases) { category in
                Text(category.categoryName).tag(QuizManager.QuizMode.category(category))
            }
            ForEach(QuizManager.ElementProperty.allCases) { property in
                Text(property.label).tag(QuizManager.QuizMode.property(property))
            }
        }
        .pickerStyle(.menu)
    }

    private func questionCard(for question: QuizManager.QuizQuestion) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(question.prompt)
                .font(AppFont.heading2)
                .lineLimit(nil)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, alignment: .leading)

            VStack(spacing: 12) {
                ForEach(question.choices) { choice in
                    Button {
                        select(choice, for: question)
                    } label: {
                        HStack {
                            Text(choice.symbol)
                                .font(.title3.weight(.bold))
                            VStack(alignment: .leading, spacing: 4) {
                                Text(choice.name)
                                    .font(.subheadline)
                            }
                            Spacer()
                            if !question.isAboutAtomicNumber || isAnswerRevealed {
                                Text("\(choice.atomicNumber)")
                                    .font(.caption2)
                                    .foregroundStyle(.secondary)
                            }
                            if isAnswerRevealed {
                                Image(systemName: choice == question.answer ? "checkmark.circle" : "xmark.circle")
                                    .foregroundStyle(choice == question.answer ? ColorManager.quizSuccess : ColorManager.quizError)
                            }
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(choiceBackground(choice: choice, question: question))
                        .clipShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadiusMedium + 4, style: .continuous))
                        .designCodeShadow(.subtle, colorScheme: colorScheme)
                    }
                    .disabled(isAnswerRevealed)
                }
            }

            if isAnswerRevealed, let hint = question.hint {
                Text(hint)
                    .font(.callout)
                    .lineLimit(nil)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .glassEffect(.regular.interactive(), in: .rect(cornerRadius: AppTheme.cornerRadiusMedium + 4))
                    .designCodeShadow(.subtle, colorScheme: colorScheme)
            }

            Button(action: nextQuestion) {
                Label(isAnswerRevealed ? "Next Question" : "Skip", systemImage: "arrow.forward.circle")
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
        .glassEffect(.regular.interactive(), in: .rect(cornerRadius: AppTheme.cornerRadiusLarge + 8))
        .designCodeShadow(.normal, colorScheme: colorScheme)
        .designCodeInnerGlow(colorScheme: colorScheme, cornerRadius: AppTheme.cornerRadiusLarge + 8)
    }

    private func select(_ choice: ElementCard, for question: QuizManager.QuizQuestion) {
        guard !isAnswerRevealed else { return }
        quizManager.submitAnswer(choice)
        isAnswerRevealed = true
        if quizManager.lastAnswerCorrect == true {
            HapticManager.shared.playHeavyImpact()
        } else {
            HapticManager.shared.playMediumImpact()
        }
    }

    private func nextQuestion() {
        Task { await prepareQuiz(force: true) }
    }

    private func prepareQuiz(force: Bool = false) async {
        guard !dataStore.elements.isEmpty else { return }
        if force {
            quizManager.generateQuestion(from: dataStore.elements)
        } else if quizManager.currentQuestion == nil {
            quizManager.generateQuestion(from: dataStore.elements)
        }
        isAnswerRevealed = false
    }

    private func choiceBackground(choice: ElementCard, question: QuizManager.QuizQuestion) -> some ShapeStyle {
        if !isAnswerRevealed {
            return colorScheme == .dark ? AppTheme.cardBackgroundDark : Color(.secondarySystemBackground)
        }
        if choice == question.answer {
            return ColorManager.quizSuccess.opacity(0.25)
        }
        if quizManager.lastAnswerCorrect == false && choice == question.answer {
            return ColorManager.quizSuccess.opacity(0.25)
        }
        return ColorManager.quizError.opacity(0.15)
    }

    private var accuracy: Double {
        guard quizManager.totalAnswered > 0 else { return 100 }
        return Double(quizManager.correctAnswers) / Double(quizManager.totalAnswered) * 100
    }
}

#if DEBUG
#Preview {
    QuizModeView()
        .environmentObject(ElementDataStore(previewElements: ElementCard.sampleElements))
        .environmentObject(UIStateManager())
        .environmentObject(QuizManager())
        .padding()
}
#endif
