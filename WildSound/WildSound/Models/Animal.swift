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
    var isGuessed: Bool
    var soundSource: String?
    
    init(id: UUID = UUID(),
         name: String,
         soundURL: String,
         wikiTitle: String,
         isFavorite: Bool = false,
         isGuessed: Bool = false,
         soundSource: String? = nil)
    {
        self.id = id
        self.name = name
        self.soundURL = soundURL
        self.wikiTitle = wikiTitle
        self.isFavorite = isFavorite
        self.isGuessed = isGuessed
        self.soundSource = soundSource
    }
}
