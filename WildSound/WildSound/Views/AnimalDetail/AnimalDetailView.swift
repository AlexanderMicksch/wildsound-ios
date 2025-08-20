//
//  AnimalDetailView.swift
//  WildSound
//
//  Created by Alexander Micksch on 11.08.25.
//

import SwiftUI

struct AnimalDetailView: View {
    let animal: Animal
    @StateObject private var viewModel: AnimalDetailViewModel
    @EnvironmentObject private var quizViewModel: QuizViewModel

    init(animal: Animal) {
        self.animal = animal
        _viewModel = StateObject(
            wrappedValue: AnimalDetailViewModel(animal: animal)
        )
    }

    private var headerURL: URL? {
        viewModel.summary?.thumbnailURL
            ?? quizViewModel.state.wikipediaSummaries[animal.id]?.thumbnailURL
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {

                DetailHeader(url: headerURL, animal: animal)
                    .environmentObject(quizViewModel)
                
                DetailSoundBar(animal: animal)
                    .environmentObject(quizViewModel)
                    .frame(maxWidth: .infinity)
                    .padding(.top, 8)

                Text(viewModel.summary?.title ?? animal.name)
                    .font(.title2).bold()
                    .accessibilityAddTraits(.isHeader)

                if let error = quizViewModel.soundPlayer.error {
                    Text(error).foregroundStyle(.red).font(.caption)
                }

               
                if viewModel.isLoading {
                    HStack {
                        Spacer()
                        ProgressView("Lade Wikipedia...")
                        Spacer()
                    }
                } else if let error = viewModel.error {
                    Text(error)
                        .foregroundStyle(.red)
                        .font(.footnote)
                } else if let extract = viewModel.summary?.extract,
                    !extract.isEmpty
                {
                    Text(extract).font(.body)
                } else {
                    Text("Keine Beschreibung verfügbar")
                        .foregroundStyle(.secondary).font(.footnote)
                }
            }
            .padding()
        }
        .navigationTitle(animal.name)
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await viewModel.load()
        }
        .onDisappear { quizViewModel.stopSound() }
    }
}

