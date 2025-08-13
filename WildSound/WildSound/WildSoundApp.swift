//
//  WildSoundApp.swift
//  WildSound
//
//  Created by Alexander Micksch on 21.07.25.
//

import SwiftUI
import SwiftData
import Firebase

@main
struct WildSoundApp: App {
    
    init() {
        #if DEBUG
        let isPreview = ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1"
        #else
        let isPreview = false
        #endif
        if !isPreview, FirebaseApp.app() == nil {
            FirebaseApp.configure()
        }
       
    }
    
    @StateObject private var quizViewModel = QuizViewModel(animals: [])
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(quizViewModel)
                .modelContainer(for: Animal.self)
        }
    }
}
