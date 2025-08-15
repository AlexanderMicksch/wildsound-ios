//
//  SoundSource.swift
//  WildSound
//
//  Created by Alexander Micksch on 04.08.25.
//

import Foundation

enum SoundSource: String, Codable, CaseIterable {
    case freesound
    case xenoCanto
    
    
    var displayName: String {
        switch self {
        case .freesound:
            return "Freesound.org"
        case .xenoCanto:
            return "Xeno-Canto"
        }
    }
}
