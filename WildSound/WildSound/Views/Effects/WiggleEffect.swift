//
//  WiggleEffect.swift
//  WildSound
//
//  Created by Alexander Micksch on 28.08.25.
//

import Foundation
import SwiftUI

struct WiggleEffect: GeometryEffect {
    var amount: CGFloat = 10
    var shakes: CGFloat = 3
    var animatableData: CGFloat = 0
    
    func effectValue(size: CGSize) -> ProjectionTransform {
        let x = amount * sin(animatableData * .pi * 2 * shakes)
        return ProjectionTransform(CGAffineTransform(translationX: x, y: 0))
    }
}

extension View {
    
    func wiggle(active: Bool,
                amount: CGFloat = 10,
                shakes: CGFloat = 3,
                duration: Double = 0.35) -> some View {
        modifier(WiggleTrigger(active: active,
                               amount: amount,
                               shakes: shakes,
                               duration: duration))
    }
}

private struct WiggleTrigger: ViewModifier {
    let active: Bool
    let amount: CGFloat
    let shakes: CGFloat
    let duration: Double
    @State private var phase: CGFloat = 0
    
    func body(content: Content) -> some View {
        content
            .modifier(WiggleEffect(amount: amount,
                                  shakes: shakes,
                                  animatableData: phase))
            .onChange(of: active) { _, new in
                guard new else { return }
                withAnimation(.easeInOut(duration: duration)) { phase = 1 }
                DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
                    phase = 0
                }
            }
    }
}
