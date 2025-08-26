//
//  CollectionsView.swift
//  WildSound
//
//  Created by Alexander Micksch on 18.08.25.
//

import SwiftUI

struct CollectionsView: View {
    @EnvironmentObject var viewModel: QuizViewModel
    @StateObject private var collectionViewModel = CollectionsViewModel()

    private let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16),
    ]

    private var visibleAnimals: [Animal] {
        let sorted = viewModel.allAnimals.sorted {
            $0.name.localizedCaseInsensitiveCompare($1.name)
                == .orderedAscending
        }
        return collectionViewModel.filter(sorted)
    }
    var body: some View {
        VStack {
            ScopePicker(scope: $collectionViewModel.scope)
                .padding()

            ScrollView {
                LazyVGrid(columns: columns, spacing: 24) {
                    ForEach(
                        visibleAnimals,
                        id: \.id
                    ) { animal in
                        NavigationLink {
                            AnimalDetailView(animal: animal)
                                .environmentObject(viewModel)
                        } label: {
                            AnimalGridCell(animal: animal)
                                .environmentObject(viewModel)
                                .task {
                                    await viewModel.ensureSummary(for: animal)
                                }
                        }
                    }
                }
                .padding(.horizontal, 6)
                .padding(.top, 5)
            }
        }
        .navigationTitle("Sammlung")
    }
}
