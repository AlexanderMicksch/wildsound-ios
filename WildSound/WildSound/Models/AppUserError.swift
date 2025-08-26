//
//  AppUserError.swift
//  WildSound
//
//  Created by Alexander Micksch on 25.08.25.
//

import Foundation

enum AppUserError: LocalizedError {
    case invalidURL
    case fetchFailed
    case storageFailed
    case parsingFailed
    case authFailed
    case audioFailed
    case unknown

    var errorDescription: String? {
        switch self {
        case .invalidURL:   "Die URL ist ungültig"
        case .fetchFailed:  "Laden ist fehlgeschlagen"
        case .storageFailed:"Speichern/Laden ist fehlgeschlagen"
        case .parsingFailed:"Unerwartetes Datenformat"
        case .authFailed:   "Anmeldung fehlgeschlagen"
        case .audioFailed:  "Audio‑Wiedergabe nicht möglich"
        case .unknown:      "Ein unbekannter Fehler ist aufgetreten"
        }
    }

    var recoverySuggestion: String? {
        switch self {
        case .invalidURL:   "Überprüfe die URL."
        case .fetchFailed:  "Versuche es später erneut."
        case .storageFailed:"Bitte erneut versuchen."
        case .parsingFailed:"Später erneut versuchen."
        case .authFailed:   "Anmeldedaten prüfen."
        case .audioFailed:  "Lautstärke/Audiogerät prüfen."
        case .unknown:      "Später erneut versuchen."
        }
    }
    
    func log(context: String = "") {
        let ctx = context.isEmpty ? "" : "[\(context)] "
        AppLogger.ui.error("\(ctx)\(self.localizedDescription)")
    }
}
