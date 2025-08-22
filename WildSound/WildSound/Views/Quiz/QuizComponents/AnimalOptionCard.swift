//
//  AnimalOptionCard.swift
//  WildSound
//
//  Created by Alexander Micksch on 20.08.25.
//

import SwiftUI

struct AnimalOptionCard: View {

    @EnvironmentObject var viewModel: QuizViewModel

    let animal: Animal
    var action: () -> Void

    private var thumbURL: URL? {
        viewModel.state.wikipediaSummaries[animal.id]?.thumbnailURL
    }

    var body: some View {
        Button(action: action) {
            VStack {
                AnimalThumbnail(
                    url: thumbURL,
                    crop: animal.imageCrop,
                    size: CardMetrics.imageSize
                )
                    

                Text(animal.name)
                    .font(.headline)
                    .foregroundStyle(.primary)
                    .padding(.bottom, 5)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)
            }
            .frame(width: CardMetrics.cardSize.width,
                   height: CardMetrics.cardSize.height)
            .background(.thinMaterial)
            .cornerRadius(15)
            .shadow(radius: 2)
            .contentShape(RoundedRectangle(cornerRadius: 15))
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Antwortoptionen: \(animal.name)")
    }
}
