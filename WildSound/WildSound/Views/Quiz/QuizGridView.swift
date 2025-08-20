//
//  QuizGridView.swift
//  WildSound
//
//  Created by Alexander Micksch on 07.08.25.
//

import SwiftUI

struct QuizGridView: View {

    @EnvironmentObject var viewModel: QuizViewModel

    let columns: [GridItem] = [
        GridItem(.flexible()),
        GridItem(.flexible()),
    ]

    var body: some View {
        VStack {
            if viewModel.state.currentQuestion != nil {
                Text("Welches Tier hörst du?")
                    .font(.title)
                    .fontWeight(.bold)
                    .padding()
                    .padding(.bottom)

                if let error = viewModel.soundPlayer.error {
                    Text(error)
                        .foregroundColor(.red)
                        .font(.caption)
                        .padding(.bottom, 5)
                }

                if viewModel.state.isShowingFeedback,
                    let isCorrect = viewModel.state.lastAnswerCorrect
                {
                    QuizFeedbackOverlay(isCorrect: isCorrect)
                        .onAppear {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1)
                            {
                                viewModel.nextQuestionAfterFeedback()
                            }
                        }
                }

                LazyVGrid(columns: columns, spacing: 24) {
                    ForEach(viewModel.state.answerOptions, id: \.id) { animal in
                        AnimalOptionCard(animal: animal) {
                            viewModel.answer(animal)
                        }
                        .environmentObject(viewModel)
                    }
                }

                QuizScorePanel(
                    score: viewModel.state.score,
                    currentIndex: viewModel.state.allQuestions.count
                        - viewModel.state.remainingQuestions.count + 1,
                    total: viewModel.state.allQuestions.count
                )

                SoundRoundButtton(
                    isPlaying: viewModel.soundPlayer.isPlaying,
                    isEnabled: viewModel.canPlayCurrentSound()
                ) {
                    Task { await viewModel.toggleCurrentAnimalSoundAsync() }
                }
                .padding(.top, 30)
            } else {
                QuizResultsView()
                    .environmentObject(viewModel)
            }
        }
        .ignoresSafeArea(.keyboard)
        .task {
            await viewModel.loadWikipediaSummariesForCurrentOptions()
        }
    }
}

