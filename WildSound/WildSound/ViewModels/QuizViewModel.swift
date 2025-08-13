//
//  QuizViewModel.swift
//  WildSound
//
//  Created by Alexander Micksch on 04.08.25.
//

import Foundation

class QuizViewModel: ObservableObject {

    let allAnimals: [Animal]
    let soundPlayer = SoundPlayerService()
    let wikipediaService = WikipediaService()

    @Published private(set) var state: QuizState
    private var questionLimit: Int

    init(animals: [Animal], questionLimit: Int = 10) {
        self.allAnimals = animals
        self.questionLimit = questionLimit
        let quizPool = Array(animals.shuffled().prefix(questionLimit))
        self.state = QuizState(
            allQuestions: quizPool,
            remainingQuestions: quizPool,
            currentQuestion: quizPool.first,
            answerOptions: QuizViewModel.generateOptions(
                for: quizPool.first,
                from: quizPool
            ),
            guessedAnimals: [],
            failedAnimals: [],
            score: 0,
            status: .running
        )
    }

    // Antwortmöglichkeiten erzeugen
    static func generateOptions(for animal: Animal?, from pool: [Animal])
        -> [Animal]
    {
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
            state.lastAnswerCorrect = true
        } else {
            state.failedAnimals.append(current)
            state.lastAnswerCorrect = false
        }
        state.isShowingFeedback = true
    }

    func nextQuestionAfterFeedback() {
        stopSound()
        guard let current = state.currentQuestion else { return }
        state.remainingQuestions.removeAll { $0.id == current.id }
        if let next = state.remainingQuestions.first {
            state.currentQuestion = next
            state.answerOptions = QuizViewModel.generateOptions(
                for: next,
                from: state.allQuestions
            )
        } else {
            state.currentQuestion = nil
            state.status = .finished
        }
        state.isShowingFeedback = false
        state.lastAnswerCorrect = nil
        Task {
            await loadWikipediaSummariesForCurrentOptions()
        }
    }

    func startSecondChance() {
        stopSound()
        let secondChancePool = state.failedAnimals.shuffled()
        state = QuizState(
            allQuestions: secondChancePool,
            remainingQuestions: secondChancePool,
            currentQuestion: secondChancePool.first,
            answerOptions: QuizViewModel.generateOptions(
                for: secondChancePool.first,
                from: secondChancePool
            ),
            guessedAnimals: [],
            failedAnimals: [],
            score: 0,
            status: .secondChance
        )
        Task {
            await loadWikipediaSummariesForCurrentOptions()
        }
    }

    func restartQuiz() {
        stopSound()
        let quizPool = Array(allAnimals.shuffled().prefix(questionLimit))
        state = QuizState(
            allQuestions: quizPool,
            remainingQuestions: quizPool,
            currentQuestion: quizPool.first,
            answerOptions: QuizViewModel.generateOptions(
                for: quizPool.first,
                from: quizPool
            ),
            guessedAnimals: [],
            failedAnimals: [],
            score: 0,
            status: .running
        )
        Task {
            await loadWikipediaSummariesForCurrentOptions()
        }
    }

    func stopSound() {
        soundPlayer.stop()
    }

    @MainActor
    func loadWikipediaSummariesForCurrentOptions() async {
        for animal in state.answerOptions {
            if state.wikipediaSummaries[animal.id] == nil {
                if let summary = try? await wikipediaService.fetchSummary(
                    titleDe: animal.wikiTitleDe,
                    titleEn: animal.wikiTitleEn
                ) {
                    state.wikipediaSummaries[animal.id] = summary
                }
            }
        }
    }
    
    @MainActor
    func toggleCurrentAnimalSoundAsync() async {
        guard let path = currentSoundStoragePath() else {
            soundPlayer.setError("Kein Storage-Pfad für diese Frage gefunden")
            return
        }
        if soundPlayer.isPlaying {
            soundPlayer.stop()
        } else {
            await soundPlayer.play(storagePath: path)
        }
    }
    
    func currentSoundStoragePath() -> String? {
        if let current = state.currentQuestion, !current.storagePath.isEmpty {
            return current.storagePath
        }
        if let first = state.answerOptions.first(where: { !$0.storagePath.isEmpty }) {
            return first.storagePath
        }
        return nil
    }
    
    func canPlayCurrentSound() -> Bool {
        currentSoundStoragePath() != nil
    }
}

// TODO: Methoden für Animationen
