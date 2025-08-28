//
//  EffectsViewModel.swift
//  WildSound
//
//  Created by Alexander Micksch on 28.08.25.
//

import Foundation
import SwiftUI

@MainActor
final class EffectsViewModel: ObservableObject {
    @Published var correctActive = false
    @Published var wrongActive = false
    @Published var confettiCounter = 0
    @Published var highlightedCorrectId: UUID?
    
    var correctDuration: TimeInterval = 1.0
    var wrongDuration: TimeInterval = 0.6
    
    func triggerCorrect(highlightId: UUID? = nil) {
        highlightedCorrectId = highlightId
        correctActive = true
        confettiCounter &+= 1
        Haptics.success()
        
        Task { [weak self] in
            guard let self else { return }
            try? await Task.sleep(nanoseconds: UInt64(self.correctDuration * 1_000_000_000))
            self.correctActive = false
            self.highlightedCorrectId = nil
        }
    }
    
    func triggerWrong() {
        wrongActive = true
        Haptics.error()
        
        Task { [weak self] in
            guard let self else { return }
            try? await Task.sleep(nanoseconds: UInt64(self.wrongDuration * 1_000_000_000))
            self.wrongActive = false
        }
    }
    
    func reset() {
        correctActive = false
        wrongActive = false
        highlightedCorrectId = nil
    }
}

enum Haptics {
    static func success() { UINotificationFeedbackGenerator().notificationOccurred(.success) }
    static func error() { UINotificationFeedbackGenerator().notificationOccurred(.error) }
}
