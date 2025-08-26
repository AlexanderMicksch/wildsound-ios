//
//  AnimalDTO.swift
//  WildSound
//
//  Created by Alexander Micksch on 26.08.25.
//

import Foundation

struct AnimalDTO: Codable, Sendable {
    let id: UUID
    let name: String
    let storagePath: String
    let wikiTitleDe: String
    let wikiTitleEn: String?
    let isFavorite: Bool
    let guessedCount: Int
    let soundSourceRaw: String
    let imageCropRaw: String

    var isValid: Bool {
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            && !storagePath.trimmingCharacters(in: .whitespacesAndNewlines)
                .isEmpty
    }
}

extension AnimalDTO {
    init(_ a: Animal) {
        self.id = a.id
        self.name = a.name
        self.storagePath = a.storagePath
        self.wikiTitleDe = a.wikiTitleDe
        self.wikiTitleEn = a.wikiTitleEn
        self.isFavorite = a.isFavorite
        self.guessedCount = a.guessedCount
        self.soundSourceRaw = a.soundSource.rawValue
        self.imageCropRaw = a.imageCrop.rawValue
    }
}
