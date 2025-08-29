//
//  ResultsViewModel.swift
//  WildSound
//
//  Created by Alexander Micksch on 22.08.25.
//

import Foundation
import SwiftData
import os

@MainActor
final class ResultsViewModel: ObservableObject {
    
    @Published private(set) var highscore: Int = 0
    
    private var modelContext: ModelContext?
    private var appStats: AppStats?
    private var summaries: [UUID: WikipediaSummary] = [:]
    private let logger = Logger(subsystem: "WildSound", category: "Results")
    
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
                do { try ctx.save() }
                catch {
                    logger.error("SwiftData initial save (highscore 0) failed: \(String(describing: error))")
                }
                appStats = stats
                highscore = 0
            }
        } catch {
            logger.error("SwiftData fetch AppStats in Results failed: \(String(describing: error))")
            let stats = AppStats(globalScore: 0)
            ctx.insert(stats)
            do { try ctx.save() }
            catch {
                logger.error("SwiftData save after failed fetch in Results failed: \(String(describing: error))")
            }
            appStats = stats
            highscore = 0
        }
    }
    
    func resetHighscore() {
        guard let ctx = modelContext, let stats = appStats else { return }
        stats.globalScore = 0
        do { try ctx.save() }
        catch {
            logger.error("SwiftData save after resetHighscore failed: \(String(describing: error))")
        }
        highscore = 0
    }
    
    func thumbURL(for animal: Animal) -> URL? {
        summaries[animal.id]?.thumbnailURL
    }
}
