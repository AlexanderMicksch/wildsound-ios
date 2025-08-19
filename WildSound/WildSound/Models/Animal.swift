//
//  Animal.swift
//  WildSound
//
//  Created by Alexander Micksch on 04.08.25.
//

import Foundation
import SwiftData

@Model
class Animal: Identifiable, Hashable {
    @Attribute(.unique) var id: UUID
    var name: String
    var storagePath: String
    var wikiTitleDe: String
    var wikiTitleEn: String?
    var isFavorite: Bool
    var guessedCount: Int
    var soundSource: SoundSource
    
    init(id: UUID = UUID(),
         name: String,
         storagePath: String,
         wikiTitleDe: String,
         wikiTitleEn: String? = nil,
         isFavorite: Bool = false,
         guessedCount: Int = 0,
         soundSource: SoundSource)
    {
        self.id = id
        self.name = name
        self.storagePath = storagePath
        self.wikiTitleDe = wikiTitleDe
        self.wikiTitleEn = wikiTitleEn
        self.isFavorite = isFavorite
        self.guessedCount = guessedCount
        self.soundSource = soundSource
    }
    
    static func == (lhs: Animal, rhs: Animal) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
