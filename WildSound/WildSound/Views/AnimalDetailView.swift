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
    
    init(animal: Animal) {
        self.animal = animal
        _viewModel = StateObject(wrappedValue: AnimalDetailViewModel(animal: animal))
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                
                if viewModel.isLoading {
                    HStack {
                        Spacer()
                        ProgressView("Lade Wikipedia...")
                        Spacer()
                    }
                }
                    
                    if let error = viewModel.error {
                        Text(error)
                            .foregroundStyle(.red)
                            .font(.footnote)
                    }
                    
                    if let summary = viewModel.summary {
                        if let url = summary.thumbnailURL {
                            AsyncImage(url: url) { phase in
                                switch phase {
                                case .empty:
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 10).fill(.gray.opacity(0.2)).frame(height: 220)
                                        ProgressView()
                                    }
                                case .success(let image):
                                    image
                                        .resizable()
                                        .scaledToFit()
                                        .clipShape(RoundedRectangle(cornerRadius: 10))
                                case .failure:
                                    placeholderImage
                                @unknown default:
                                    placeholderImage
                                }
                            }
                            .accessibilityHidden(true)
                        } else {
                            placeholderImage
                        }
                        
                        Text(summary.title)
                            .font(.title2).bold()
                            .accessibilityAddTraits(.isHeader)
                        
                        if let extract = summary.extract, !extract.isEmpty {
                            Text(extract).font(.body)
                        } else {
                            Text("Keine Beschreibung verfügbar")
                                .foregroundStyle(.secondary)
                                .font(.footnote)
                        }
                        
                    } else if !viewModel.isLoading && viewModel.error == nil {
                        Text("Keine Daten verfügbar")
                            .foregroundStyle(.secondary)
                            .font(.footnote)
                    }
                }
                    .padding()
            }
            .navigationTitle(animal.name)
            .navigationBarTitleDisplayMode(.inline)
            .task { await viewModel.load() }
        }
       
    private var placeholderImage: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10)
                .fill(.gray.opacity(0.2))
                .frame(height: 220)
            Image(systemName: "photo")
                .font(.system(size: 28))
                .foregroundStyle(.gray)
        }
        .accessibilityLabel("Kein Bild verfügbar")
    }
}

#Preview {
    let animal = seedAnimals.first!
    let tiger = seedAnimals.first { $0.name == "Tiger" }!
    NavigationStack {
        AnimalDetailView(animal: tiger)
    }
}
