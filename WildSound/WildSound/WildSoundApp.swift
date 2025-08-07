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
    
    @StateObject private var quizViewModel = QuizViewModel(animals: [])
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(quizViewModel)
                .modelContainer(for: Animal.self)
        }
    }
}
