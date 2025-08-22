//
//  AdminQuickAddViewModel.swift
//  WildSound
//
//  Created by Alexander Micksch on 21.08.25.
//

import Foundation
import SwiftData

@MainActor
final class AdminQuickAddViewModel: ObservableObject {
    
    @Published var nameInput: String = ""
    @Published var storagePathInput: String = ""
    @Published var wikiTitleDeInput: String = ""
    @Published var showSavedBanner: Bool = false
    @Published var selectedSoundSource: SoundSource = .xenoCanto
    @Published var selectedImageCrop: ImageCrop = .center
    
     var isValid: Bool {
        let trimmedName = nameInput.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedStoragePath = storagePathInput.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedWikiTitleDe = wikiTitleDeInput.trimmingCharacters(in: .whitespacesAndNewlines)
        
        return !trimmedName.isEmpty
        && Self.isValidStoragePath(trimmedStoragePath)
        && !trimmedWikiTitleDe.isEmpty
    }
    
     static func isValidStoragePath(_ path: String) -> Bool {
        guard !path.isEmpty else { return false }
        if path.lowercased().hasPrefix("http") { return false }
        return path.contains("/")
    }
    
    func addAnimal(using context: ModelContext) throws {
        let trimmedName = nameInput.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedStoragePath = storagePathInput.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedWikiTitleDe = wikiTitleDeInput.trimmingCharacters(in: .whitespacesAndNewlines)
        
        let newAnimal = Animal(
            name: trimmedName,
            storagePath: trimmedStoragePath,
            wikiTitleDe: trimmedWikiTitleDe,
            wikiTitleEn: nil,
            isFavorite: false,
            guessedCount: 0,
            soundSource: selectedSoundSource,
            imageCrop: .center
        )
        
        context.insert(newAnimal)
        try context.save()
        
        resetFields()
        showSavedBanner = true
    }
    
    func resetFields() {
        nameInput = ""
        storagePathInput = ""
        wikiTitleDeInput = ""
        selectedImageCrop = .center
    }
    
     func deleteAnimals(at offsets: IndexSet, from animals: [Animal], using context: ModelContext) throws {
        for index in offsets {
            context.delete(animals[index])
        }
        try context.save()
    }
}
