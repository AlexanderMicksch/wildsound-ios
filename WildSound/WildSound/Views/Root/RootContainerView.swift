//
//  RootContainerView.swift
//  WildSound
//
//  Created by Alexander Micksch on 15.08.25.
//

import SwiftData
import SwiftUI

struct RootContainerView: View {
    @Query(sort: \Animal.name, order: .forward) private var storedAnimals:
        [Animal]

    var body: some View {
        let initialAnimals =
            storedAnimals.isEmpty ? seedAnimals : Array(storedAnimals)
        RootTabs(initialAnimals: initialAnimals)
    }
}

private struct RootTabs: View {
    let initialAnimals: [Animal]
    @StateObject private var quizViewModel: QuizViewModel

    #if DEBUG
        private let isAdminEnabled = ProcessInfo.processInfo.arguments.contains(
            "--admin"
        )
    #endif

    init(initialAnimals: [Animal]) {
        self.initialAnimals = initialAnimals
        _quizViewModel = StateObject(
            wrappedValue: QuizViewModel(animals: initialAnimals)
        )
    }

    var body: some View {
        TabView {
            QuizGridView()
                .tabItem { Label("Quiz", systemImage: "music.note") }

            #if DEBUG
                if isAdminEnabled {
                    AdminQuickAddView()
                        .tabItem {
                            Label(
                                "Admin",
                                systemImage: "wrench.and.screwdriver"
                            )
                        }
                }
            #endif
        }
        .environmentObject(quizViewModel)
    }
}

#Preview {
    RootContainerView()
}
