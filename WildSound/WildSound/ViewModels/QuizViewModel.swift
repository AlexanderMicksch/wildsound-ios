//
//  QuizViewModel.swift
//  WildSound
//
//  Created by Alexander Micksch on 04.08.25.
//

import Foundation
import SwiftData
import os

@MainActor
final class QuizViewModel: ObservableObject {

    let allAnimals: [Animal]
    let soundPlayer = SoundPlayerService()
    let wikipediaService = WikipediaService()

    @Published private(set) var state: QuizState
    @Published private(set) var highscore: Int = 0
 
    private(set) var globalFailedAcrossRounds = Set<UUID>()

    private var didScoreCurrentQuestion = false
    private var questionLimit: Int
    private var unusedCorrectQueue: [Animal]
    private var modelContext: ModelContext?
    private var appStats: AppStats?
    private let logger = Logger(subsystem: "WildSound", category: "Quiz")

    var hasMoreRoundsInCycle: Bool {
        !unusedCorrectQueue.isEmpty
    }

    var globalFailedAnimals: [Animal] {
        allAnimals.filter { globalFailedAcrossRounds.contains($0.id) }
    }

    var hasGlobalFailedLeft: Bool {
        !globalFailedAcrossRounds.isEmpty
    }

    init(animals: [Animal], questionLimit: Int = 6) {
        let shuffledAnimals = animals.shuffled()
        let countForThisRound = min(questionLimit, shuffledAnimals.count)
        let initialRoundPool = Array(shuffledAnimals.prefix(countForThisRound))
        let remainingAfterFirstRound = Array(
            shuffledAnimals.dropFirst(countForThisRound)
        )

        self.allAnimals = animals
        self.questionLimit = questionLimit
        self.unusedCorrectQueue = remainingAfterFirstRound

        self.state = QuizState(
            allQuestions: initialRoundPool,
            remainingQuestions: initialRoundPool,
            currentQuestion: initialRoundPool.first,
            answerOptions: QuizViewModel.generateOptions(
                for: initialRoundPool.first,
                from: animals
            ),
            guessedAnimals: [],
            failedAnimals: [],
            score: 0,
            status: .running
        )
    }

    func setModelContext(_ context: ModelContext) {
        self.modelContext = context
        do {
            if let existing = try context.fetch(FetchDescriptor<AppStats>())
                .first
            {
                self.appStats = existing
                self.highscore = existing.globalScore
            } else {
                let stats = AppStats(globalScore: 0)
                context.insert(stats)
                do { try context.save() } catch {
                    logger.error(
                        "SwiftData initial save failed: \(String(describing: error))"
                    )
                }
                self.appStats = stats
                self.highscore = stats.globalScore
            }
        } catch {
            logger.error(
                "SwiftData fetch AppStats failed: \(String(describing: error))"
            )
            let stats = AppStats(globalScore: 0)
            context.insert(stats)
            do { try context.save() } catch {
                logger.error(
                    "SwiftData save after fetch-error failed: \(String(describing: error))"
                )
            }
            self.appStats = stats
            self.highscore = stats.globalScore
        }
    }

    // Antwortmöglichkeiten erzeugen
    static func generateOptions(for animal: Animal?, from allAnimals: [Animal])
        -> [Animal]
    {
        guard let correctAnimal = animal else { return [] }
        var candidateDistractors = allAnimals.filter {
            $0.id != correctAnimal.id
        }
        candidateDistractors.shuffle()

        let selectedDistractors = Array(candidateDistractors.prefix(3))

        let options = [correctAnimal] + selectedDistractors
        return options.shuffled()
    }

    // Antwort prüfen
    func answer(_ animal: Animal) {
        guard let current = state.currentQuestion else { return }
        guard !didScoreCurrentQuestion else { return }

        if animal.id == current.id {
            state.guessedAnimals.append(current)
            state.score += 1
            state.lastAnswerCorrect = true
            globalFailedAcrossRounds.remove(current.id)

            if let stats = appStats {
                stats.globalScore += 1
                highscore = stats.globalScore
            }

            if let index = allAnimals.firstIndex(where: { $0.id == current.id })
            {
                allAnimals[index].guessedCount += 1
            }

            if let ctx = modelContext {
                do { try ctx.save() } catch {
                    logger.error(
                        "SwiftData save after answer() failed: \(String(describing: error))"
                    )
                }
            }

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
            didScoreCurrentQuestion = false
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

    func startNextRound() {
        stopSound()

        for animal in state.failedAnimals {
            globalFailedAcrossRounds.insert(animal.id)
        }

        let quizPool = dequeueRoundPool()

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
            score: state.score,
            status: .running
        )

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
            score: state.score,
            status: .secondChance
        )

        Task {
            await loadWikipediaSummariesForCurrentOptions()
        }
    }

    func playGlobalFailedAcrossRounds() {
        stopSound()

        let pool = allAnimals.filter {
            globalFailedAcrossRounds.contains($0.id)
        }
        .shuffled()

        guard !pool.isEmpty else { return }

        state = QuizState(
            allQuestions: pool,
            remainingQuestions: pool,
            currentQuestion: pool.first,
            answerOptions: QuizViewModel.generateOptions(
                for: pool.first,
                from: allAnimals
            ),
            guessedAnimals: [],
            failedAnimals: [],
            score: state.score,
            status: .secondChance
        )

        Task { await loadWikipediaSummariesForCurrentOptions() }
    }

    func restartQuizFromBeginning() {
        stopSound()

        globalFailedAcrossRounds.removeAll()

        unusedCorrectQueue = allAnimals.shuffled()
        let quizPool = dequeueRoundPool()

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

    private func dequeueRoundPool() -> [Animal] {
        if unusedCorrectQueue.isEmpty {
            unusedCorrectQueue = allAnimals.shuffled()
        }

        let countForThisRound = min(questionLimit, unusedCorrectQueue.count)
        let roundPool = Array(unusedCorrectQueue.prefix(countForThisRound))
        unusedCorrectQueue.removeFirst(countForThisRound)
        return roundPool
    }

    private func resetScoreIfCycleCompleted() {
        let noRoundsLeft = unusedCorrectQueue.isEmpty
        let noCurrentLeft = state.remainingQuestions.isEmpty
        let noFailedLeft = state.failedAnimals.isEmpty
        let noGlobalFailedLeft = globalFailedAcrossRounds.isEmpty

        if noRoundsLeft && noCurrentLeft && noFailedLeft && noGlobalFailedLeft {
            state.score = 0
        }
    }

    func stopSound() {
        soundPlayer.stop()
    }

    func loadWikipediaSummariesForCurrentOptions() async {
        for animal in state.answerOptions {
            guard state.wikipediaSummaries[animal.id] == nil else { continue }
            do {
                let summary = try await wikipediaService.fetchSummary(
                    titleDe: animal.wikiTitleDe,
                    titleEn: animal.wikiTitleEn
                )
                state.wikipediaSummaries[animal.id] = summary
            } catch {
                logger.error(
                    "Wiki fetch failed for \(animal.name): \(String(describing: error))"
                )
            }
        }
    }

    func ensureSummary(for animal: Animal) async {
        guard state.wikipediaSummaries[animal.id] == nil else { return }
        do {
            let summary = try await wikipediaService.fetchSummary(
                titleDe: animal.wikiTitleDe,
                titleEn: animal.wikiTitleEn
            )
            state.wikipediaSummaries[animal.id] = summary
        } catch {
            logger.error(
                "ensureSummary failed for \(animal.name): \(String(describing: error))"
            )
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

    func toggleFavorite(for animal: Animal) {
        animal.isFavorite.toggle()
        if let ctx = modelContext {
            do { try ctx.save() } catch {
                logger.error(
                    "SwiftData save after toggleFavorite failed: \(String(describing: error))"
                )
            }
        }
    }

    func toggleFavorite(id: UUID) {
        if let animal = allAnimals.first(where: { $0.id == id }) {
            toggleFavorite(for: animal)
        }
    }

    func isFavorite(_ animal: Animal) -> Bool { animal.isFavorite }

    func toggleSound(for animal: Animal) async {
        guard !animal.storagePath.isEmpty else {
            soundPlayer.setError(
                "Kein Storage-Pfad für \(animal.name) hinterlegt"
            )
            return
        }
        await soundPlayer.toggle(storagePath: animal.storagePath)
    }
}
// TODO: Methoden für Animationen
