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
    var wikiTitleDe: String
    var wikiTitleEn: String?
    var isFavorite: Bool
    var guessedCount: Int
    var soundSource: SoundSource
    
    init(id: UUID = UUID(),
         name: String,
         soundURL: String,
         wikiTitleDe: String,
         wikiTitleEn: String? = nil,
         isFavorite: Bool = false,
         guessedCount: Int = 0,
         soundSource: SoundSource)
    {
        self.id = id
        self.name = name
        self.soundURL = soundURL
        self.wikiTitleDe = wikiTitleDe
        self.wikiTitleEn = wikiTitleEn
        self.isFavorite = isFavorite
        self.guessedCount = guessedCount
        self.soundSource = soundSource
    }
}
