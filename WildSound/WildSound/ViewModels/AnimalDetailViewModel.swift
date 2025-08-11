//
//  AnimalDetailViewModel.swift
//  WildSound
//
//  Created by Alexander Micksch on 11.08.25.
//

import Foundation

@MainActor
final class AnimalDetailViewModel: ObservableObject {
    @Published var summary: WikipediaSummary?
    @Published var isLoading = false
    @Published var error: String?
    
    let animal: Animal
    private let service: WikipediaService
    
    init(animal: Animal, service: WikipediaService = WikipediaService()) {
        self.animal = animal
        self.service = service
    }
    
    func load() async {
        guard !isLoading else { return }
        isLoading = true
        error = nil
        do {
            let result = try await service.fetchSummary(
                titleDe: animal.wikiTitleDe,
                titleEn: animal.wikiTitleEn
            )
            summary = result
            if result == nil {
                error = "Keine Wikipedia-Zusammenfassung gefunden"
            }
        } catch {
            self.error = "Wikipedia-Anfrage fehlgeschlagen"
        }
        isLoading = false
    }
}
