//
//  CollectionsViewModel.swift
//  WildSound
//
//  Created by Alexander Micksch on 19.08.25.
//

import Foundation

@MainActor
final class CollectionsViewModel: ObservableObject {
    
    enum Scope: String, CaseIterable, Identifiable {
        case all = "Alle"
        case guessed = "Erraten"
        case favorites = "Favoriten"
        
        var id: String { rawValue }
    }
    
    @Published var scope: Scope = .all
    
    func filter(_ animals: [Animal]) -> [Animal] {
        let sorted = animals.sorted {
            $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending
        }
        switch scope {
        case .all: return sorted
        case .guessed: return sorted.filter { $0.guessedCount > 0 }
        case .favorites: return sorted.filter { $0.isFavorite }
        }
    }
}
