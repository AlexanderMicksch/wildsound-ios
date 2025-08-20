//
//  AnimalCard.swift
//  WildSound
//
//  Created by Alexander Micksch on 19.08.25.
//

import SwiftUI

struct AnimalCard: View {
    @EnvironmentObject var viewModel: QuizViewModel
    @Bindable var animal: Animal

    init(animal: Animal) { self._animal = Bindable(wrappedValue: animal) }

    private var thumbURL: URL? {
        viewModel.state.wikipediaSummaries[animal.id]?.thumbnailURL
    }

    var body: some View {
        VStack {
            ZStack(alignment: .topLeading) {
                AnimalThumbnail(url: thumbURL)
                    .frame(width: 180, height: 160)
                    .clipShape(RoundedRectangle(cornerRadius: 15))

                if animal.guessedCount > 0 {
                    GuessBadge(count: animal.guessedCount)
                        .padding(.leading, 4)
                        .padding(.top, 3)
                }
            }

            Text(animal.name)
                .font(.headline)
                .foregroundStyle(.primary)
                .padding(.bottom, 5)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)
        }
        .frame(width: 190, height: 200)
        .background(.thinMaterial)
        .cornerRadius(15)
        .shadow(radius: 2)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(
            "\(animal.name)\(animal.isFavorite ? " Favorit," : "")"
        )
    }
}

