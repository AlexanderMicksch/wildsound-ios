//
//  QuizState.swift
//  WildSound
//
//  Created by Alexander Micksch on 04.08.25.
//

import Foundation

enum QuizStatus {
    case running
    case finished
    case secondChance
}

struct QuizState {
    var allQuestions: [Animal]              // Alle Tiere, aus denen das Quiz besteht
    var remainingQuestions: [Animal]        // verbleibende Fragen
    var currentQuestion: Animal?            // aktuell zu erratende Tier
    var answerOptions: [Animal]             // 4 Tiere zur Auswahl
    var guessedAnimals: [Animal]            // erratene Tiere
    var failedAnimals: [Animal]             // nicht erratene Tiere
    var score: Int                          // punkte
    var status: QuizStatus
    var lastAnswerCorrect: Bool? = nil
    var isShowingFeedback: Bool = false
    var wikipediaSummaries: [UUID: WikipediaSummary] = [:]
}
