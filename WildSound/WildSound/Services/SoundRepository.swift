//
//  SoundRepository.swift
//  WildSound
//
//  Created by Alexander Micksch on 13.08.25.
//

import Foundation
import FirebaseStorage

struct SoundRepository {
    private let storage: Storage
    
    init(storage: Storage = Storage.storage()) {
        self.storage = storage
    }
    
    func downloadURL(for storagePath: String) async throws -> URL {
        try await withCheckedThrowingContinuation { continuation in
            let ref = storage.reference(withPath: storagePath)
            ref.downloadURL { url, error in
                if let error {
                    continuation.resume(throwing: error)
                    return
                }
                guard let url else {
                    continuation.resume(throwing: URLError(.badURL))
                    return
                }
                continuation.resume(returning: url)
            }
        }
    }
}
