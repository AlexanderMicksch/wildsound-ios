//
//  QuizViewModel+Audio.swift
//  WildSound
//
//  Created by Alexander Micksch on 20.08.25.
//

import Foundation

extension QuizViewModel {
    
    func toggleSound(for animal: Animal) {
        guard !animal.storagePath.isEmpty else {
            soundPlayer.setError("Kein Storage-Pfad für \(animal.name) hinterlegt")
            return
        }
        Task { await soundPlayer.toggle(storagePath: animal.storagePath) }
    }
    
    func stopSoundForDetail() {
        stopSound()
    }
}
