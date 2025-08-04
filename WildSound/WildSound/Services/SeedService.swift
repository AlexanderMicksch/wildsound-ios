//
//  SeedService.swift
//  WildSound
//
//  Created by Alexander Micksch on 04.08.25.
//

import Foundation
import SwiftData

struct SeedService {
    static func seedIfNeeded(context: ModelContext) {
        let fetchDescriptor = FetchDescriptor<Animal>()
        let animalsExist = (try? context.fetch(fetchDescriptor).isEmpty == false) ?? false
        if !animalsExist {
            seeadAnimals.forEach { context.insert($0) }
        }
    }
}

