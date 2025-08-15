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
    
    @StateObject private var quizViewModel: QuizViewModel
    
    init() {
        
        if FirebaseApp.app() == nil {
            FirebaseApp.configure()
        }
        
        _quizViewModel = StateObject(wrappedValue: QuizViewModel(animals: seedAnimals))
       
    }
    
    var body: some Scene {
        WindowGroup {
           QuizGridView()
                .environmentObject(quizViewModel)
                .modelContainer(for: Animal.self)
        }
    }
}
