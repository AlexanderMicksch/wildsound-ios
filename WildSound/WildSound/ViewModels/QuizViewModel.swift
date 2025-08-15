//
//  QuizViewModel.swift
//  WildSound
//
//  Created by Alexander Micksch on 04.08.25.
//

import Foundation

@MainActor
final class QuizViewModel: ObservableObject {

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
    static func generateOptions(for animal: Animal?, from allAnimals: [Animal])
        -> [Animal]
    {
        guard let correctAnimal = animal else { return [] }
        var candidateDistractors = allAnimals.filter { $0.id != correctAnimal.id }
        candidateDistractors.shuffle()
        
        let selectedDistractors = Array(candidateDistractors.prefix(3))
        
        let options = [correctAnimal] + selectedDistractors
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
                from: allAnimals
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
                from: allAnimals
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
                from: allAnimals
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
        if let first = state.answerOptions.first(where: {
            !$0.storagePath.isEmpty
        }) {
            return first.storagePath
        }
        return nil
    }

    func canPlayCurrentSound() -> Bool {
        currentSoundStoragePath() != nil
    }
}

// TODO: Methoden für Animationen
