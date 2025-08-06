//
//  WikipediaService.swift
//  WildSound
//
//  Created by Alexander Micksch on 06.08.25.
//

import Foundation

final class WikipediaService {
    
    func fetchSummary(
        titleDe: String,
        titleEn: String? = nil
    ) async throws -> WikipediaSummary? {
        let encodedTitleDe = titleDe.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? titleDe
        let apiURLDe = "https://de.wikipedia.org/api/rest_v1/page/summary/\(encodedTitleDe)"
        if let summary = try await fetchSummaryFrom(urlString: apiURLDe) {
            return summary
        }
        if let titleEn {
            let encodedTitleEn = titleEn.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? titleEn
            let apiURLEn = "https://en.wikipedia.org/api/rest_v1/page/summary/\(encodedTitleEn)"
            return try await fetchSummaryFrom(urlString: apiURLEn)
        }
        return nil
    }
    
    private func fetchSummaryFrom(urlString: String) async throws -> WikipediaSummary? {
        guard let url = URL(string: urlString) else { return nil }
        let (data, response) = try await URLSession.shared.data(from: url)
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            return nil
        }
        let summary = try JSONDecoder().decode(WikipediaSummary.self, from: data)
        return summary
    }
}
