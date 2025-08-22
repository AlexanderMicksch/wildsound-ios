//
//  AnimalCropRowView.swift
//  WildSound
//
//  Created by Alexander Micksch on 21.08.25.
//

import SwiftUI
import SwiftData

struct AnimalCropRowView: View {
    
    @EnvironmentObject var quizViewModel: QuizViewModel
    @Environment(\.modelContext) private var modelContext
    
    @Bindable var animal: Animal
    
    init(animal: Animal) {
        self._animal = Bindable(wrappedValue: animal)
    }
    
    private var thumbURL: URL? {
        quizViewModel.state.wikipediaSummaries[animal.id]?.thumbnailURL
    }
    
    var body: some View {
        HStack(spacing: 12) {
            AnimalThumbnail(
                url: thumbURL,
                crop: animal.imageCrop,
                cornerRadius: 10,
                size: .init(width: 84, height: 64)
            )
            
            VStack(alignment: .leading, spacing: 6) {
                Text(animal.name)
                    .font(.headline)
                
                Picker("Ausrichtung", selection: $animal.imageCrop) {
                    ForEach(ImageCrop.allCases, id: \.self) { crop in
                        Text(crop.displayName).tag(crop)
                    }
                }
                .pickerStyle(.menu)
            }
            Spacer()
        }
        .onChange(of: animal.imageCrop) { _, _ in
            try? modelContext.save()
        }
        .task { await quizViewModel.ensureSummary(for: animal) }
    }
}

