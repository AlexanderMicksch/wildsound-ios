//
//  FavoriteStar.swift
//  WildSound
//
//  Created by Alexander Micksch on 19.08.25.
//

import SwiftUI

struct FavoriteStar: View {
    @EnvironmentObject var viewModel: QuizViewModel
    @Bindable var animal: Animal

    init(animal: Animal) { self._animal = Bindable(wrappedValue: animal) }

    var body: some View {
        Button {
            viewModel.toggleFavorite(for: animal)
        } label: {
            Image(systemName: animal.isFavorite ? "star.fill" : "star")
                .font(.headline)
                .foregroundStyle(.yellow)
                .padding(6)
                .background(Color.black.opacity(0.3), in: Circle())
        }
        .buttonStyle(.borderless)
        .accessibilityLabel(
            animal.isFavorite ? "Favorit entfernen" : "Als Favorit markieren"
        )
    }
}
