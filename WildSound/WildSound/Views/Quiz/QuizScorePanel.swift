//
//  QuizScorePanel.swift
//  WildSound
//
//  Created by Alexander Micksch on 20.08.25.
//

import SwiftUI

struct QuizScorePanel: View {
    
    let score: Int
    let currentIndex: Int
    let total: Int
    
    var body: some View {
        VStack(spacing: 5) {
            Text("Punktestand: \(score)")
                .font(.title3)
                .fontWeight(.semibold)
                .padding(.top, 10)
            Text(
                "Frage \(currentIndex) von \(total)"
            )
            .font(.subheadline)
            .foregroundColor(.gray)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Punktestand \(score). Frage \(currentIndex) von \(total)")
    }
}


