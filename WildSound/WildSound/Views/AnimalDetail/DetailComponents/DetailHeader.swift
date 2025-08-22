//
//  DetailHeader.swift
//  WildSound
//
//  Created by Alexander Micksch on 20.08.25.
//

import SwiftUI
import SwiftData

struct DetailHeader: View {
    
    @EnvironmentObject var quizViewModel: QuizViewModel
    let url: URL?
    @Bindable var animal: Animal
    
    init(url: URL?, animal: Animal) {
        self.url = url
        self._animal = Bindable(wrappedValue: animal)
    }
    
    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .topLeading) {
                AnimalThumbnail(
                    url: url,
                    crop: animal.imageCrop,
                cornerRadius: 14,
                    size: .init(width: geo.size.width, height: 240)
                )
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .strokeBorder(Color.black.opacity(0.05))
                    )
                
                if animal.guessedCount > 0 {
                    GuessBadge(count: animal.guessedCount)
                        .padding(.leading, 8)
                        .padding(.top, 8)
                }
                
                HStack {
                    Spacer()
                    FavoriteStar(animal: animal)
                        .environmentObject(quizViewModel)
                        .padding(.trailing, 8)
                        .padding(.top, 8)
                }
            }
        }
        .frame(height: 240)
        .accessibilityElement(children: .contain)
    }
}

