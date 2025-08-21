//
//  DetailSoundBar.swift
//  WildSound
//
//  Created by Alexander Micksch on 20.08.25.
//

import SwiftUI

struct DetailSoundBar: View {

    @EnvironmentObject var quizViewModel: QuizViewModel
    let animal: Animal

    var body: some View {
        HStack {
            Spacer()
            SoundRoundButtton(
                isPlaying: quizViewModel.soundPlayer.isPlaying,
                isEnabled: !animal.storagePath.isEmpty,
            ) {
                Task {
                    await quizViewModel.toggleSound(for: animal)
                }
            }
            Spacer()
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Audio-Steuerung für \(animal.name)")
    }
}
