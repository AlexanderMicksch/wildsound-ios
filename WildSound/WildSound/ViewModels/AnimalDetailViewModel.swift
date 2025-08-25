//
//  AnimalDetailViewModel.swift
//  WildSound
//
//  Created by Alexander Micksch on 11.08.25.
//

import Foundation
import os

@MainActor
final class AnimalDetailViewModel: ObservableObject {
    @Published var summary: WikipediaSummary?
    @Published var isLoading = false
    @Published var error: String?

    let animal: Animal
    private let service: WikipediaService
    private let logger = Logger(
        subsystem: "WildSound",
        category: "AnimalDetail"
    )

    init(animal: Animal, service: WikipediaService = WikipediaService()) {
        self.animal = animal
        self.service = service
    }

    func load() async {
        guard !isLoading else { return }
        isLoading = true
        error = nil
        defer { isLoading = false }

        do {
            let result = try await service.fetchSummary(
                titleDe: animal.wikiTitleDe,
                titleEn: animal.wikiTitleEn
            )
            summary = result
            if result == nil {
                error = "Keine Wikipedia-Zusammenfassung gefunden"
            }
        } catch let decoding as DecodingError {
            logger.error(
                "Wikipedia decoding failed: \(String(describing: decoding))"
            )
            error = AppUserError.parsingFailed.localizedDescription
        } catch let url as URLError {
            logger.error("Wikipedia network failed: \(String(describing: url))")
            error = AppUserError.fetchFailed.localizedDescription
        } catch {
            logger.error(
                "Wikipedia unknown error: \(String(describing: error))"
            )
            self.error = AppUserError.unknown.localizedDescription
        }
    }
}
