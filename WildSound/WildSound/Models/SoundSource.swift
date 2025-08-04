//
//  SoundSource.swift
//  WildSound
//
//  Created by Alexander Micksch on 04.08.25.
//

import Foundation

enum SoundSource: String, Codable {
    case firebase
    case xenoCanto
    
    var displayName: String {
        switch self {
        case .firebase:
            return "Firebase"
        case .xenoCanto:
            return "Xeno-Canto"
        }
    }
}
