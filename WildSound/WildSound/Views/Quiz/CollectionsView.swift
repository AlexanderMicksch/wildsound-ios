//
//  CollectionsView.swift
//  WildSound
//
//  Created by Alexander Micksch on 18.08.25.
//

import SwiftUI

struct CollectionsView: View {
    @EnvironmentObject var viewModel: QuizViewModel

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
            ScrollView {
                LazyVGrid(columns: columns, spacing: 16) {
                    ForEach(sortedAnimals, id: \.id) { animal in
                        AnimalCard(animal: animal)
                            .environmentObject(viewModel)
                    }
                }
                .padding(.horizontal, 2)
               
            }
            .navigationTitle("Sammlung")
            .background(Color(.systemGroupedBackground))
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
            VStack(spacing: 6) {
                if let url = thumbURL {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .empty:
                            ProgressView()
                                .frame(maxWidth: .infinity, minHeight: 120)
                        case .success(let img):
                            img.resizable()
                                .scaledToFill()
                                .frame(width: 185, height: 140)
                                .cornerRadius(15)
                                .clipped()
                        case .failure:
                            Image(systemName: "photo")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 120, height: 140)
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
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)
                
                if animal.guessedCount > 0 {
                    Text("\(animal.guessedCount)x erraten")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity)
                        .padding(.bottom, 8)
                }
            }
            .frame(width: 190, height: 205)
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
                .padding(.top, 10)
                .padding(.trailing, 6)
            }
        .task {
            await viewModel.ensureSummary(for: animal)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(
            "\(animal.name)\(animal.isFavorite ? "Favorit," : "")")
    }
}
