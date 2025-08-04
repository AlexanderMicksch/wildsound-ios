//
//  WildSoundApp.swift
//  WildSound
//
//  Created by Alexander Micksch on 21.07.25.
//

import SwiftUI
import SwiftData

@main
struct WildSoundApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .modelContainer(for: Animal.self)
        }
    }
}
