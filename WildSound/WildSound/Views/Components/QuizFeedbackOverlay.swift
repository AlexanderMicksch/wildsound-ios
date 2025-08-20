//
//  QuizFeedbackOverlay.swift
//  WildSound
//
//  Created by Alexander Micksch on 20.08.25.
//

import SwiftUI

struct QuizFeedbackOverlay: View {
    let isCorrect: Bool
    
    var body: some View {
         ZStack {
            Color(isCorrect ? .green : .red)
                .opacity(0.5)
                .ignoresSafeArea()
                .cornerRadius(15)
            Text(isCorrect ? "Richtig!" : "Leider Falsch")
                 .font(.largeTitle).bold()
                .foregroundColor(.white)
        }
        .transition(.opacity)
        .zIndex(2)
        .accessibilityLabel(isCorrect ? "Antwort war richtig" : "Antwort war falsch")
    }
}

