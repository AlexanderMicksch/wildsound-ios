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

    var sortedAnimals: [Animal] {
        viewModel.allAnimals.sorted {
            $0.name.localizedCaseInsensitiveCompare($1.name)
                == .orderedAscending
        }
    }

    var body: some View {
        NavigationStack {
            VStack {
                Picker("Filter", selection: $collectionViewModel.scope) {
                    ForEach(CollectionsViewModel.Scope.allCases) { scope in
                        Text(scope.rawValue).tag(scope)
                    }
                }
                .pickerStyle(.segmented)
                .padding()
            }

            ScrollView {
                LazyVGrid(columns: columns, spacing: 24) {
                    ForEach(
                        collectionViewModel.filter(viewModel.allAnimals),
                        id: \.id
                    ) { animal in
                        AnimalCard(animal: animal)
                            .environmentObject(viewModel)
                    }
                }
                .padding(.horizontal, 6)
                .padding(.top, 5)
            }
            .navigationTitle("Sammlung")
        }
    }
}

private struct AnimalCard: View {
    @EnvironmentObject var viewModel: QuizViewModel
    @Bindable var animal: Animal

    init(animal: Animal) {
        self._animal = Bindable(wrappedValue: animal)
    }

    var thumbURL: URL? {
        viewModel.state.wikipediaSummaries[animal.id]?.thumbnailURL
    }

    var body: some View {
        ZStack(alignment: .topTrailing) {
            VStack {
                ZStack(alignment: .topLeading) {
                    if let url = thumbURL {
                        AsyncImage(url: url) { phase in
                            switch phase {
                            case .empty:
                                ProgressView()
                                    .frame(height: 120)
                            case .success(let img):
                                img.resizable()
                                    .scaledToFill()
                                    .frame(width: 180, height: 160)
                                    .cornerRadius(15)
                                    .clipped()
                            case .failure:
                                Image(systemName: "photo")
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 180, height: 160)
                                    .foregroundColor(.gray)
                            @unknown default:
                                EmptyView()
                            }
                        }
                    } else {
                        Image(systemName: "photo")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 180, height: 160)
                            .foregroundColor(.gray.opacity(0.3))
                    }

                    if animal.guessedCount > 0 {
                        HStack(spacing: 4) {
                            Image(systemName: "checkmark.circle.fill")
                            Text("\(animal.guessedCount)")
                        }
                        .font(.caption2.bold())
                        .foregroundColor(.white)
                        .padding(.horizontal, 4)
                        .padding(.vertical, 3)
                        .background(Color.green.opacity(0.7), in: Capsule())
                        .padding(.leading, 4)
                        .padding(.top, 3)
                    }

                }

                Text(animal.name)
                    .font(.headline)
                    .foregroundColor(.primary)
                    .padding(.bottom, 5)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)
            }
            .frame(width: 190, height: 200)
            .background(.thinMaterial)
            .cornerRadius(15)
            .shadow(radius: 2)

            
            Button {
                viewModel.toggleFavorite(for: animal)
            } label: {
                Image(systemName: animal.isFavorite ? "star.fill" : "star")
                    .font(.headline)
                    .foregroundColor(.yellow)
                    .padding(6)
                    .background(Color.black.opacity(0.3), in: Circle())

            }
            .buttonStyle(.plain)
            .padding(.top, 6)
            .padding(.trailing, 6)

        }
        .task {
            await viewModel.ensureSummary(for: animal)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(
            "\(animal.name)\(animal.isFavorite ? "Favorit," : "")"
        )
    }
}
