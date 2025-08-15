//
//  WildSoundApp.swift
//  WildSound
//
//  Created by Alexander Micksch on 21.07.25.
//

import Firebase
import SwiftData
import SwiftUI

@main
struct WildSoundApp: App {
    init() {
        if FirebaseApp.app() == nil {
            FirebaseApp.configure()
        }
    }

    var body: some Scene {
        WindowGroup {
            RootContainerView()
        }
        .modelContainer(for: Animal.self)
    }
}
