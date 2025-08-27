//
//  QuizResultsView.swift
//  WildSound
//
//  Created by Alexander Micksch on 20.08.25.
//

import SwiftData
import SwiftUI

struct QuizResultsView: View {

    @EnvironmentObject var viewModel: QuizViewModel
    @Environment(\.modelContext) private var modelContext
    @StateObject private var resultViewModel = ResultsViewModel()

    private var guessed: [Animal] { viewModel.state.guessedAnimals }
    private var failed: [Animal] { viewModel.state.failedAnimals }

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                Text("Quiz beendet!")
                    .font(.largeTitle)
                    .bold()
                    .padding(.top, 8)

                HStack(spacing: 16) {
                    StatCard(
                        title: "Punkte",
                        value: viewModel.state.score
                    )
                    StatCard(
                        title: "Highscore",
                        value: resultViewModel.highscore
                    )
                }

                Text(
                    "Richtig: \(guessed.count) von \(viewModel.state.allQuestions.count)"
                )
                .font(.headline)

                if !guessed.isEmpty {
                    SectionHeader(title: "Erraten")
                        .underline()
                    LazyVGrid(columns: CardMetrics.Results.columns, spacing: 12)
                    {
                        ForEach(guessed, id: \.id) { animal in
                            AnimalResultTile(
                                title: animal.name,
                                url: resultViewModel.thumbURL(for: animal),
                                crop: animal.imageCrop,
                                tint: .green
                            )
                        }
                    }
                }

                if !failed.isEmpty {
                    SectionHeader(title: "Nicht erraten")
                        .underline()
                    LazyVGrid(columns: CardMetrics.Results.columns, spacing: 12)
                    {
                        ForEach(failed, id: \.id) { animal in
                            AnimalResultTile(
                                title: animal.name,
                                url: resultViewModel.thumbURL(for: animal),
                                crop: animal.imageCrop,
                                tint: .red
                            )
                        }
                    }
                }

                VStack(spacing: 10) {
                    if !failed.isEmpty {
                        PrimaryActionButton(
                            title: "Nicht erratene Tiere nochmal spielen",
                            background: .orange.opacity(0.3)
                        ) { viewModel.startSecondChance() }
                    }

                    if viewModel.hasMoreRoundsInCycle {
                        PrimaryActionButton(
                            title: "Nächste Runde",
                            background: .blue.opacity(0.3)
                        ) { viewModel.startNextRound() }
                    } else {
                        PrimaryActionButton(
                            title: "Spiel neu starten",
                            background: .blue.opacity(0.3)
                        ) { viewModel.restartQuizFromBeginning() }
                    }

                    if !viewModel.hasMoreRoundsInCycle,
                        viewModel.hasGlobalFailedLeft
                    {
                        PrimaryActionButton(
                            title: "Alle falschen nochmal spielen",
                            background: .blue.opacity(0.3)
                        ) { viewModel.playGlobalFailedAcrossRounds() }
                    }

                    PrimaryActionButton(
                        title: "Highscore zurücksetzen",
                        background: .red.opacity(0.2)
                    ) { resultViewModel.resetHighscore() }
                }
                .padding(.top, 8)
            }
            .padding(.horizontal)
            .padding(.bottom, 16)
        }
        .task {
            resultViewModel.setModelContext(
                modelContext,
                summaries: viewModel.state.wikipediaSummaries
            )
        }
    }
}
