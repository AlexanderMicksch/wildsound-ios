//
//  FirestoreService.swift
//  WildSound
//
//  Created by Alexander Micksch on 26.08.25.
//

import FirebaseFirestore
import Foundation
import SwiftData
import os

@MainActor
final class FirestoreService {
    private let db: Firestore
    private let logger = Logger(subsystem: "WildSound", category: "Firestore")
    private let collectionName = "animals"

    init(db: Firestore = Firestore.firestore()) {
        self.db = db
    }

    func saveAnimal(_ animal: Animal) async throws {
        let dto = AnimalDTO(animal)
        let docID = dto.id.uuidString
        var data = makeDataDict(from: dto)
        data["updatedAT"] = FieldValue.serverTimestamp()

        do {
            try await db.collection(collectionName)
                .document(docID)
                .setData(data, merge: true)
        } catch {
            logger.error(
                "saveAnimal failed (\(docID, privacy: .public)): \(String(describing: error))"
            )
            throw error
        }
    }

    func updateFields(for id: UUID, fields: [String: Any]) async throws {
        var patch = fields
        patch["updatedAT"] = FieldValue.serverTimestamp()
        try await db.collection(collectionName)
            .document(id.uuidString)
            .updateData(patch)
    }
    
    func updateImageCrop(for id: UUID, to crop: ImageCrop) async throws {
        try await db.collection(collectionName)
            .document(id.uuidString)
            .updateData([
                "imageCropRaw": crop.rawValue,
                "updatedAT": FieldValue.serverTimestamp()
            ])
    }
    
    func exportAnimals(_ animals: [Animal]) async {
        for a in animals {
            do { try await saveAnimal(a) } catch {
                logger.error(
                    "exportAnimals failed (\(a.id.uuidString, privacy: .public)): \(String(describing: error))"
                )
            }
        }
    }

    private func makeDataDict(from dto: AnimalDTO) -> [String: Any] {
        [
            "id": dto.id.uuidString,
            "name": dto.name,
            "storagePath": dto.storagePath,
            "wikiTitleDe": dto.wikiTitleDe,
            "wikiTitleEn": dto.wikiTitleEn as Any,
            "isFavorite": dto.isFavorite,
            "guessedCount": dto.guessedCount,
            "soundSourceRaw": dto.soundSourceRaw,
            "imageCropRaw": dto.imageCropRaw,
        ]
    }

    func fetchAnimalsChanged(since lastSync: Date?) async throws -> [AnimalDTO]
    {
        var query: Query = db.collection(collectionName)
        if let lastSync {
            query = query.whereField(
                "updatedAT",
                isGreaterThan: Timestamp(date: lastSync)
            )
        }

        let snap = try await query.getDocuments()
        return snap.documents.compactMap { doc in
            let data = doc.data()
            guard
                let idStr = data["id"] as? String,
                let id = UUID(uuidString: idStr),
                let name = data["name"] as? String,
                let storagePath = data["storagePath"] as? String,
                let wikiTitleDe = data["wikiTitleDe"] as? String,
                let isFavorite = data["isFavorite"] as? Bool,
                let guessedCount = data["guessedCount"] as? Int,
                let soundSourceRaw = data["soundSourceRaw"] as? String,
                let imageCropRaw = data["imageCropRaw"] as? String
            else {
                return nil
            }
            let wikiTitleEn = data["wikiTitleEn"] as? String

            return AnimalDTO(
                id: id,
                name: name,
                storagePath: storagePath,
                wikiTitleDe: wikiTitleDe,
                wikiTitleEn: wikiTitleEn,
                isFavorite: isFavorite,
                guessedCount: guessedCount,
                soundSourceRaw: soundSourceRaw,
                imageCropRaw: imageCropRaw
            )
        }
    }

    @MainActor
    func importAnimalsIncremental(using context: ModelContext) async {
        let key = "lastSyncAT_animals"
        let lastSync = UserDefaults.standard.object(forKey: key) as? Date

        do {
            let dtos = try await fetchAnimalsChanged(since: lastSync)
            guard !dtos.isEmpty else { return }

            for dto in dtos {
                upsert(dto: dto, in: context)
            }
            do {
                try context.save()
            } catch {
                logger.error(
                    "SwiftData save after import failed: \(String(describing: error))"
                )
            }

            UserDefaults.standard.set(Date(), forKey: key)
        } catch {
            logger.error(
                "incremental import failed: \(String(describing: error))"
            )
        }
    }

    @MainActor
    private func upsert(dto: AnimalDTO, in context: ModelContext) {
        do {
            let fd = FetchDescriptor<Animal>(
                predicate: #Predicate { $0.storagePath == dto.storagePath }
            )
            if let existing = try context.fetch(fd).first {
                existing.name = dto.name
                existing.wikiTitleDe = dto.wikiTitleDe
                existing.wikiTitleEn = dto.wikiTitleEn
                existing.isFavorite = dto.isFavorite
                existing.guessedCount = dto.guessedCount
                existing.soundSource =
                    SoundSource(rawValue: dto.soundSourceRaw)
                    ?? existing.soundSource
                existing.imageCrop =
                    ImageCrop(rawValue: dto.imageCropRaw) ?? existing.imageCrop
            } else {
                let a = Animal(
                    name: dto.name,
                    storagePath: dto.storagePath,
                    wikiTitleDe: dto.wikiTitleDe,
                    isFavorite: dto.isFavorite,
                    guessedCount: dto.guessedCount,
                    soundSource: SoundSource(rawValue: dto.soundSourceRaw)
                        ?? .xenoCanto,
                    imageCrop: ImageCrop(rawValue: dto.imageCropRaw) ?? .center
                )
                context.insert(a)
            }
        } catch {
            logger.error(
                "upser(dto:) fetch failed: \(String(describing: error))"
            )
        }
    }
}
