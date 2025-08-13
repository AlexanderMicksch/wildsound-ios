//
//  QuizGridView.swift
//  WildSound
//
//  Created by Alexander Micksch on 07.08.25.
//

import SwiftUI
import FirebaseStorage

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
                    ZStack {
                        Color(isCorrect ? .green : .red)
                            .opacity(0.5)
                            .ignoresSafeArea()
                            .cornerRadius(15)
                        Text(isCorrect ? "Richtg!" : "Leider Falsch")
                            .font(.largeTitle)
                            .foregroundColor(.white)
                            .bold()
                    }
                    .transition(.opacity)
                    .zIndex(2)
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                            viewModel.nextQuestionAfterFeedback()
                        }
                    }
                }
                
                LazyVGrid(columns: columns, spacing: 24) {
                    ForEach(viewModel.state.answerOptions, id: \.id) { animal in
                        Button(action: {
                            viewModel.answer(animal)
                        }) {
                            VStack {
                                if let summary = viewModel.state
                                    .wikipediaSummaries[
                                        animal.id
                                    ],
                                   let url = summary.thumbnailURL
                                {
                                    AsyncImage(url: url) { phase in
                                        switch phase {
                                        case .empty:
                                            ProgressView().frame(height: 120)
                                        case .success(let image):
                                            image.resizable()
                                                .scaledToFill()
                                                .frame(width: 180, height: 160)
                                                .cornerRadius(15)
                                                .clipped()
                                        case .failure:
                                            Image(systemName: "photo")
                                                .resizable()
                                                .scaledToFit()
                                                .frame(width: 120, height: 120)
                                                .foregroundColor(.gray)
                                        @unknown default:
                                            EmptyView()
                                        }
                                    }
                                } else {
                                    Image(systemName: "photo")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 120, height: 120)
                                        .foregroundColor(.gray.opacity(0.3))
                                }
                                Text(animal.name)
                                    .font(.headline)
                                    .foregroundColor(.primary)
                                    .padding(.bottom, 5)
                            }
                            .frame(width: 190, height: 200)
                            .background(.thinMaterial)
                            .cornerRadius(15)
                            .shadow(radius: 2)
                        }
                    }
                }
                
                VStack(spacing: 5) {
                    Text("Punktestand: \(viewModel.state.score)")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .padding(.top, 10)
                    
                    Text(
                        "Frage \(viewModel.state.allQuestions.count - viewModel.state.remainingQuestions.count + 1) von \(viewModel.state.allQuestions.count)"
                    )
                    .font(.subheadline)
                    .foregroundColor(.gray)
                }
                
                Button(action: {
                    viewModel.toggleCurrentAnimalSound()
                }) {
                    ZStack {
                        Circle()
                            .fill(.ultraThinMaterial)
                            .frame(width: 75, height: 75)
                            .shadow(radius: 5)
                        Image(
                            systemName: viewModel.soundPlayer.isPlaying
                            ? "speaker.wave.2.fill" : "speaker.wave.2"
                        )
                        .font(.system(size: 35, weight: .bold))
                        .foregroundColor(.blue)
                    }
                }
                .padding(.top, 30)
                .disabled(
                    viewModel.state.currentQuestion?.soundURL.isEmpty ?? true
                )
                .accessibilityLabel(
                    viewModel.soundPlayer.isPlaying
                    ? "Tierstimme stoppen"
                    : "Tierstimme abspielen"
                )
            } else {
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
                            animal in
                            Text(animal.name)
                                .foregroundColor(.green)
                        }
                    }
                    
                    if !viewModel.state.failedAnimals.isEmpty {
                        Text("Nicht erraten:")
                            .bold()
                        ForEach(viewModel.state.failedAnimals, id: \.id) {
                            animal in
                            Text(animal.name)
                                .foregroundColor(.red)
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
                    
                    Button("Neue quizrunde starten") {
                        viewModel.restartQuiz()
                    }
                    .frame(maxWidth: .infinity)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(.blue.opacity(0.3))
                    .foregroundColor(.primary)
                    .cornerRadius(15)
                }
                .padding(.horizontal)
            }
        }
        .ignoresSafeArea(.keyboard)
        .task {
            await viewModel.loadWikipediaSummariesForCurrentOptions()
        }
    }

}

struct QuizGridView_Previews: PreviewProvider {
    static var previews: some View {
        let animals = seedAnimals
        let viewModel = QuizViewModel(animals: animals)
        QuizGridView()
            .environmentObject(viewModel)
    }
}
