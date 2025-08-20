//
//  SoundRoundButtton.swift
//  WildSound
//
//  Created by Alexander Micksch on 20.08.25.
//

import SwiftUI

struct SoundRoundButtton: View {

    let isPlaying: Bool
    let isEnabled: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            ZStack {
                Circle()
                    .fill(.ultraThinMaterial)
                    .frame(width: 75, height: 75)
                    .shadow(radius: 5)
                Image(
                    systemName: isPlaying
                        ? "speaker.wave.2.fill" : "speaker.wave.2"
                )
                .font(.system(size: 35, weight: .bold))
                .foregroundColor(.blue)
            }
        }
        .disabled(!isEnabled)
        .accessibilityLabel(
            isPlaying
                ? "Tierstimme stoppen"
                : "Tierstimme abspielen"
        )
    }
}
