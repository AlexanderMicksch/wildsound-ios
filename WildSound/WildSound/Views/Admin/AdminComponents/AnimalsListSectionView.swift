//
//  AnimalsListSectionView.swift
//  WildSound
//
//  Created by Alexander Micksch on 21.08.25.
//

import SwiftUI

struct AnimalsListSectionView: View {
    
    @EnvironmentObject var quizViewModel: QuizViewModel
    
    let animals: [Animal]
    let onDelete: (IndexSet) -> Void
    let onCropChange: (Animal, ImageCrop) -> Void
    
    var body: some View {
        Section("Gespeicherte Tiere (\(animals.count))") {
            if animals.isEmpty {
                Text("Noch keine Tiere gespeichert")
                    .foregroundStyle(.secondary)
            } else {
                List {
                    ForEach(animals, id: \.id) { animal in
                        AnimalCropRowView(animal: animal)
                            .environmentObject(quizViewModel)
                            .task { await quizViewModel.ensureSummary(for: animal) }
                            .onChange(of: animal.imageCrop) { _, newCrop in
                                onCropChange(animal, newCrop)
                            }
                    }
                    .onDelete(perform: onDelete)
                }
                .frame(minHeight: 120)
            }
        }
    }
}

