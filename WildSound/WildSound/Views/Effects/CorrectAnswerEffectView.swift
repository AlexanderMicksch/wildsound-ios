//
//  CorrectAnswerEffectView.swift
//  WildSound
//
//  Created by Alexander Micksch on 28.08.25.
//

import ConfettiSwiftUI
import SwiftUI

struct CorrectAnswerEffectView<Content: View>: View {
    @ObservedObject var effects: EffectsViewModel
    var wiggleAmplitude: CGFloat = 8
    var wiggleDuration: Double = 0.3
    @ViewBuilder var content: () -> Content

    @State private var confettiTrigger = 0

    var body: some View {
        ZStack {
            content()
                .wiggle(
                    active: effects.correctActive,
                    amount: wiggleAmplitude,
                    shakes: 3,
                    duration: wiggleDuration
                )
        }
        .confettiCannon(
            trigger: $confettiTrigger,
            num: 60,
            radius: 420
        )
        .onChange(of: effects.correctActive) { _, isActive in
            if isActive { confettiTrigger &+= 1 }
        }
        .accessibilityLabel("Korrekte Antwort Effekt")
    }
}

