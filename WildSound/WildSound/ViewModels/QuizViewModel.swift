//
//  QuizViewModel.swift
//  WildSound
//
//  Created by Alexander Micksch on 04.08.25.
//

import Foundation

class QuizViewModel: ObservableObject {
    @Published private(set) var state: QuizState

    init(animals: [Animal], questionLimit: Int = 10) {
        let quizPool = Array(animals.shuffled().prefix(questionLimit))
        self.state = QuizState(
            allQuestions: quizPool,
            remainingQuestions: quizPool,
            currentQuestion: quizPool.first,
            answerOptions: QuizViewModel.generateOptions(for: quizPool.first,from: quizPool),
            guessedAnimals: [],
            failedAnimals: [],
            score: 0,
            status: .running
        )
    }
    
    // Antwortmöglichkeiten erzeugen
    static func generateOptions(for animal: Animal?, from pool: [Animal]) -> [Animal] {
        guard let correct = animal else { return [] }
        var options = [correct]
        let others = pool.filter { $0.id != correct.id }.shuffled().prefix(3)
        options.append(contentsOf: others)
        return options.shuffled()
    }
    
    // Antwort prüfen
    func answer(_ animal: Animal) {
        guard let current = state.currentQuestion else { return }
        if animal.id == current.id {
            state.guessedAnimals.append(current)
            state.score += 1
        } else {
            state.failedAnimals.append(current)
        }
        state.remainingQuestions.removeAll { $0.id == current.id }
        if let next = state.remainingQuestions.first {
            state.currentQuestion = next
            state.answerOptions = QuizViewModel.generateOptions(for: next, from: state.allQuestions)
        } else {
            state.currentQuestion = nil
            state.status = .finished
        }
    }
}

// TODO: Methoden für zweite Chance, Neustart, Feedback-Reset, Sound, Animationen

