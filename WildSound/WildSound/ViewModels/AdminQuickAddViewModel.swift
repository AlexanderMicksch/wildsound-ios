//
//  AdminQuickAddViewModel.swift
//  WildSound
//
//  Created by Alexander Micksch on 21.08.25.
//

import Foundation
import SwiftData
import os

@MainActor
final class AdminQuickAddViewModel: ObservableObject {

    @Published var nameInput: String = ""
    @Published var storagePathInput: String = ""
    @Published var wikiTitleDeInput: String = ""
    @Published var showSavedBanner: Bool = false
    @Published var selectedSoundSource: SoundSource = .xenoCanto
    @Published var selectedImageCrop: ImageCrop = .center

    private let logger = Logger(subsystem: "WildSound", category: "AdminAdd")
    private let firestore = FirestoreService()

    var isValid: Bool {
        let trimmedName = nameInput.trimmingCharacters(
            in: .whitespacesAndNewlines
        )
        let trimmedStoragePath = storagePathInput.trimmingCharacters(
            in: .whitespacesAndNewlines
        )
        let trimmedWikiTitleDe = wikiTitleDeInput.trimmingCharacters(
            in: .whitespacesAndNewlines
        )

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
        let trimmedName = nameInput.trimmingCharacters(
            in: .whitespacesAndNewlines
        )
        let trimmedStoragePath = storagePathInput.trimmingCharacters(
            in: .whitespacesAndNewlines
        )
        let trimmedWikiTitleDe = wikiTitleDeInput.trimmingCharacters(
            in: .whitespacesAndNewlines
        )

        guard !trimmedName.isEmpty else {
            logger.error("addAnimal: empty name")
            throw AppUserError.unknown
        }
        guard Self.isValidStoragePath(trimmedStoragePath) else {
            logger.error(
                "addAnimal: invalid storage path '\(trimmedStoragePath, privacy: .public)'"
            )
            throw AppUserError.invalidURL
        }
        guard !trimmedWikiTitleDe.isEmpty else {
            logger.error("addAnimal: empty wiki title")
            throw AppUserError.unknown
        }
        
        do {
            let fd = FetchDescriptor<Animal>(
                predicate: #Predicate { $0.storagePath == trimmedStoragePath }
            )
            if try context.fetch(fd).isEmpty == false {
                logger.error("addAnimal: duplicate storagePath '\(trimmedStoragePath, privacy: .public)'")
                throw AppUserError.storageFailed
            }
        } catch {
            logger.error("addAnimal: duplicate ceck failed: \(String(describing: error))")
        }

        let newAnimal = Animal(
            name: trimmedName,
            storagePath: trimmedStoragePath,
            wikiTitleDe: trimmedWikiTitleDe,
            wikiTitleEn: nil,
            isFavorite: false,
            guessedCount: 0,
            soundSource: selectedSoundSource,
            imageCrop: selectedImageCrop
        )

        context.insert(newAnimal)
        do {
            try context.save()
        } catch {
            logger.error(
                "SwiftData save (addAnimal) failed: \(String(describing: error))"
            )
            throw AppUserError.storageFailed
        }
        
        Task {
            do { try await firestore.saveAnimal(newAnimal) }
            catch { logger.error("Firestore saveAnimal failed: \(String(describing: error))") }
        }
        
        resetFields()
        showSavedBanner = true
    }

    func resetFields() {
        nameInput = ""
        storagePathInput = ""
        wikiTitleDeInput = ""
        selectedImageCrop = .center
    }

    func deleteAnimals(
        at offsets: IndexSet,
        from animals: [Animal],
        using context: ModelContext
    ) throws {
        for index in offsets {
            context.delete(animals[index])
        }
        do {
            try context.save()
        } catch {
            logger.error(
                "SwiftData save (deleteAnimals) failed: \(String(describing: error))"
            )
            throw AppUserError.storageFailed
        }
    }
    
    func exportAllAnimals(using context: ModelContext) async {
        do {
            let animals = try context.fetch(FetchDescriptor<Animal>())
            await firestore.exportAnimals(animals)
        } catch {
            logger.error("SwiftData fetch for export failed: \(String(describing: error))")
        }
    }
}
