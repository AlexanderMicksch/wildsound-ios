//
//  ResultsViewModel.swift
//  WildSound
//
//  Created by Alexander Micksch on 22.08.25.
//

import Foundation
import SwiftData

@MainActor
final class ResultsViewModel: ObservableObject {
    
    @Published private(set) var highscore: Int = 0
    
    private var modelContext: ModelContext?
    private var appStats: AppStats?
    private var summaries: [UUID: WikipediaSummary] = [:]
    
    func setModelContext(_ ctx: ModelContext, summaries: [UUID: WikipediaSummary]) {
        modelContext = ctx
        self.summaries = summaries
        Task { await loadHighscore() }
    }
    
    func loadHighscore() async {
        guard let ctx = modelContext else { return }
        do {
            if let existing = try ctx.fetch(FetchDescriptor<AppStats>()).first {
                appStats = existing
                highscore = existing.globalScore
            } else {
                let stats = AppStats(globalScore: 0)
                ctx.insert(stats)
                try ctx.save()
                appStats = stats
                highscore = 0
            }
        } catch { }
    }
    
    func resetHighscore() {
        guard let ctx = modelContext, let stats = appStats else { return }
        stats.globalScore = 0
        try? ctx.save()
        highscore = 0
    }
    
    func thumbURL(for animal: Animal) -> URL? {
        summaries[animal.id]?.thumbnailURL
    }
}
