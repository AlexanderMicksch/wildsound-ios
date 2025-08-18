//
//  CollectionsView.swift
//  WildSound
//
//  Created by Alexander Micksch on 18.08.25.
//

import SwiftUI

struct CollectionsView: View {
    @EnvironmentObject var viewModel: QuizViewModel
    
    private let columns = [GridItem(.flexible(), spacing: 16),
                           GridItem(.flexible(), spacing: 16)]
    
    var sortedAnimals: [Animal] {
        viewModel.allAnimals.sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
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
                .padding(16)
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
        VStack(spacing: 10) {
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(.thinMaterial)
                Group {
                    if let url = thumbURL {
                        AsyncImage(url: url) { phase in
                            switch phase {
                            case .empty:
                                ProgressView()
                                    .frame(maxWidth: .infinity, minHeight: 120)
                            case .success(let img):
                                img.resizable()
                                    .scaledToFill()
                                    .frame(width: 180, height: 160)
                                    .cornerRadius(15)
                                    .clipped()
                            case .failure:
                                    placeholder
                            @unknown default:
                                placeholder
                            }
                        }
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                    } else {
                        placeholder
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                    }
                }
            }
            .frame(width: 190, height: 200)
            .background(.thinMaterial)
            .cornerRadius(15)
            .shadow(radius: 2)
            .overlay(alignment: .topTrailing) {
                Button {
                    viewModel.toggleFavorite(for: animal)
                } label: {
                    Image(systemName: animal.isFavorite ? "star.fill" : "star")
                        .imageScale(.large)
                        .padding(8)
                        .background(.ultraThinMaterial, in: Circle())
                }
                .buttonStyle(.plain)
                .padding(8)
            }
            
            VStack(spacing: 4) {
                Text(animal.name)
                    .font(.headline)
                    .lineLimit(1)
                
                if animal.guessedCount > 0 {
                    Text("Erraten: \(animal.guessedCount)x")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(12)
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 20))
        .shadow(radius: 2, y: 1)
        .task {
            await viewModel.ensureSummary(for: animal)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(animal.name), \(animal.isFavorite ? "Favorit," : "") \(animal.guessedCount > 0 ? "erraten \(animal.guessedCount) mal" : "noch nicht erraten")")
    }
    
    private var placeholder: some View {
        ZStack {
            Color.gray.opacity(0.2)
            Image(systemName: "photo")
                .font(.system(size: 28, weight: .semibold))
                .foregroundStyle(.gray)
        }
        .frame(maxWidth: .infinity, minHeight: 140)
    }
}


