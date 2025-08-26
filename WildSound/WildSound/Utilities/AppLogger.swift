//
//  AppLogger.swift
//  WildSound
//
//  Created by Alexander Micksch on 26.08.25.
//

import Foundation
import os

enum AppLogger {
    private static let subsystem = "de.alexander.wildsound"
    
    static let auth      = Logger(subsystem: subsystem, category: "Auth")
    static let firestore = Logger(subsystem: subsystem, category: "Firestore")
    static let ui        = Logger(subsystem: subsystem, category: "UI")
    static let sound     = Logger(subsystem: subsystem, category: "Sound")
    static let network   = Logger(subsystem: subsystem, category: "Network")
}
