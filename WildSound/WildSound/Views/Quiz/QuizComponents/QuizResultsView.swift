//
//  QuizResultsView.swift
//  WildSound
//
//  Created by Alexander Micksch on 20.08.25.
//

import SwiftUI

struct QuizResultsView: View {
    
    @EnvironmentObject var viewModel: QuizViewModel
    
    var body: some View {
        VStack(spacing: 10) {
            Text("Quiz beendet!")
                .font(.title)
                .padding(.bottom)
            
            Text(
                "Richtig: \(viewModel.state.guessedAnimals.count) von \(viewModel.state.allQuestions.count)"
            )
            .font(.headline)
            .padding(.bottom)
            
            if !viewModel.state.guessedAnimals.isEmpty {
                Text("Erraten:")
                    .bold()
                ForEach(viewModel.state.guessedAnimals, id: \.id) {
                    Text($0.name)
                        .foregroundStyle(.green)
                }
            }
            
            if !viewModel.state.failedAnimals.isEmpty {
                Text("Nicht erraten:")
                    .bold()
                ForEach(viewModel.state.failedAnimals, id: \.id) {
                    Text($0.name)
                        .foregroundStyle(.red)
                }
            }
            
            if !viewModel.state.failedAnimals.isEmpty {
                Button("Nicht erratene Tiere nochmal spielen") {
                    viewModel.startSecondChance()
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(.orange.opacity(0.3))
                .foregroundColor(.primary)
                .cornerRadius(15)
            }
            
            if viewModel.hasMoreRoundsInCycle {
                Button("Nächste Runde...") {
                    viewModel.startNextRound()
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(.blue.opacity(0.3))
                .foregroundColor(.primary)
                .cornerRadius(15)
            } else {
                Button("Spiel neu starten") {
                    viewModel.restartQuizFromBeginning()
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(.blue.opacity(0.3))
                .foregroundColor(.primary)
                .cornerRadius(15)
            }
            
            if !viewModel.hasMoreRoundsInCycle, viewModel.hasGlobalFailedLeft {
                Button("Alle falschen nochmal") {
                    viewModel.playGlobalFailedAcrossRounds()
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(.blue.opacity(0.3))
                .foregroundColor(.primary)
                .cornerRadius(15)
            }
        }
        .padding(.horizontal)
    }
}


