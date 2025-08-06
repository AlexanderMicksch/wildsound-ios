//
//  WikipediaSummary.swift
//  WildSound
//
//  Created by Alexander Micksch on 06.08.25.
//

import Foundation

struct WikipediaSummary: Decodable {
    let title: String
    let extract: String?
    let thumbnailURL: URL?
    
    private enum CodingKeys: String, CodingKey {
        case title, extract, thumbnail
    }
    
    private enum ThumbnailKeys: String, CodingKey {
        case source
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        title = try container.decode(String.self, forKey: .title)
        extract = try container.decodeIfPresent(String.self, forKey: .extract)
        if let thumbnailContainer = try? container.nestedContainer(keyedBy: ThumbnailKeys.self, forKey: .thumbnail) {
            let urlString = try thumbnailContainer.decodeIfPresent(String.self, forKey: .source)
            thumbnailURL = urlString.flatMap(URL.init)
        } else {
            thumbnailURL = nil
        }
    }
}
