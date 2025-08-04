//
//  Animal.swift
//  WildSound
//
//  Created by Alexander Micksch on 04.08.25.
//

import Foundation
import SwiftData

@Model
class Animal: Identifiable {
    @Attribute(.unique) var id: UUID
    var name: String
    var soundURL: String
    var wikiTitle: String
    var isFavorite: Bool
    var guessedCount: Int
    var soundSource: SoundSource
    
    init(id: UUID = UUID(),
         name: String,
         soundURL: String,
         wikiTitle: String,
         isFavorite: Bool = false,
         guessedCount: Int = 0,
         soundSource: SoundSource)
    {
        self.id = id
        self.name = name
        self.soundURL = soundURL
        self.wikiTitle = wikiTitle
        self.isFavorite = isFavorite
        self.guessedCount = guessedCount
        self.soundSource = soundSource
    }
}
