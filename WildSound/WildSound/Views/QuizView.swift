//
//  QuizView.swift
//  WildSound
//
//  Created by Alexander Micksch on 05.08.25.
//

import SwiftUI

struct QuizView: View {
    
    @ObservedObject var viewModel: QuizViewModel
    
    var body: some View {
        VStack(spacing: 25) {
            if let question = viewModel.state.currentQuestion {
                Text("Welches Tier hörst du?")
                    .font(.title2)
                    .padding(.top)
                
                Text(question.name)
                    .font(.largeTitle)
                    .bold()
                    .padding(.bottom, 10)
                
                if viewModel.state.isShowingFeedback, let isCorrect = viewModel.state.lastAnswerCorrect {
                    ZStack {
                        Color(isCorrect ? .green : .red)
                            .opacity(0.7)
                            .ignoresSafeArea()
                        Text(isCorrect ? "Richtig!" : "Leider falsch")
                            .font(.largeTitle)
                            .foregroundColor(.white)
                            .bold()
                    }
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                            viewModel.nextQuestionAfterFeedback()
                        }
                    }
                }
                
                ForEach(viewModel.state.answerOptions, id: \.id) { animal in
                    Button(action: {
                        viewModel.answer(animal)
                    }) {
                        Text(animal.name)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(.blue.opacity(0.2))
                            .foregroundColor(.primary)
                            .cornerRadius(15)
                    }
                }
                Text("Punktestand: \(viewModel.state.score)")
                    .padding(.top, 20)
                
                Text("Frage \(viewModel.state.allQuestions.count - viewModel.state.remainingQuestions.count + 1) von \(viewModel.state.allQuestions.count)")
                    .font(.caption)
                    .foregroundColor(.gray)
            } else {
                VStack(spacing: 10) {
                    Text("Quiz beendet!")
                        .font(.title)
                        .padding(.bottom)
                    
                    Text("Richtig: \(viewModel.state.guessedAnimals.count)")
                    Text("Falsch: \(viewModel.state.failedAnimals.count)")
                }
            }
        }
        .padding()
    }
}

#Preview {
    QuizView(viewModel: QuizViewModel(animals: seedAnimals))
}
