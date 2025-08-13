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
    
    
}
