//
//  AnimalGridCell.swift
//  WildSound
//
//  Created by Alexander Micksch on 19.08.25.
//

import SwiftUI

struct AnimalGridCell: View {
    @EnvironmentObject var viewModel: QuizViewModel
    @Bindable var animal: Animal
    
    init(animal: Animal) { self._animal = Bindable(wrappedValue: animal) }
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            AnimalCard(animal: animal)
                .environmentObject(viewModel)
                .contentShape(RoundedRectangle(cornerRadius: 15))
            
            FavoriteStar(animal: animal)
                .environmentObject(viewModel)
                .padding(.top, 6)
                .padding(.trailing, 6)
        }
    }
}

