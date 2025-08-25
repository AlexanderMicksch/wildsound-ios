//
//  SoundRepository.swift
//  WildSound
//
//  Created by Alexander Micksch on 13.08.25.
//

import FirebaseStorage
import Foundation
import os

struct SoundRepository {
    private let storage: Storage
    private let logger = Logger(subsystem: "WildSound", category: "SoundRepo")

    init(storage: Storage = Storage.storage()) {
        self.storage = storage
    }

    func downloadURL(for storagePath: String) async throws -> URL {
        guard
            !storagePath.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        else {
            logger.error("downloadURL: empty storagePath")
            throw URLError(.badURL)
        }

        return try await withCheckedThrowingContinuation { continuation in
            let ref = storage.reference(withPath: storagePath)
            ref.downloadURL { url, error in
                if let error {
                    logger.error(
                        "downloadURL returned nil URL for '\(storagePath, privacy: .public)': \(String(describing: error))"
                    )
                    continuation.resume(throwing: error)
                    return
                }
                guard let url else {
                    logger.error(
                        "downloadURL returned nil URL for '\(storagePath, privacy: .public)'"
                    )
                    continuation.resume(throwing: URLError(.badURL))
                    return
                }
                continuation.resume(returning: url)
            }
        }
    }
}
