//
//  RootContainerView.swift
//  WildSound
//
//  Created by Alexander Micksch on 15.08.25.
//

import SwiftData
import SwiftUI

private enum RootTab: Hashable {
    case quiz
    case collection
    case admin
}

struct RootContainerView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject var auth: AuthViewModel
    @Query(sort: \Animal.name, order: .forward) private var storedAnimals:
        [Animal]

    private let firestore = FirestoreService()
    @State private var selectedTab: RootTab = .quiz

    var body: some View {

        let initialAnimals =
            storedAnimals.isEmpty ? seedAnimals : Array(storedAnimals)

        RootTabs(
            initialAnimals: initialAnimals,
            selectedTab: $selectedTab
        )
        .task {
            await firestore.importAnimalsIncremental(using: modelContext)
        }
    }
}

private struct RootTabs: View {

    @EnvironmentObject var auth: AuthViewModel
    @Environment(\.modelContext) private var modelContext

    let initialAnimals: [Animal]

    @Binding var selectedTab: RootTab

    @StateObject private var quizViewModel: QuizViewModel

    init(initialAnimals: [Animal], selectedTab: Binding<RootTab>) {
        self.initialAnimals = initialAnimals
        _selectedTab = selectedTab
        _quizViewModel = StateObject(
            wrappedValue: QuizViewModel(animals: initialAnimals)
        )
    }

    var body: some View {
        TabView(selection: $selectedTab) {
            QuizGridView()
                .tabItem { Label("Quiz", systemImage: "music.note") }
                .tag(RootTab.quiz)

            CollectionsView()
                .tabItem { Label("Sammlung", systemImage: "square.grid.2x2") }
                .tag(RootTab.collection)

            if auth.isAdmin {
                AdminQuickAddView()
                    .tabItem {
                        Label("Admin", systemImage: "lock.shield")
                    }
                    .tag(RootTab.admin)
            }
        }
        .environmentObject(quizViewModel)
        .onAppear {
            quizViewModel.setModelContext(modelContext)
        }
    }
}

#Preview {

    RootContainerView()
        .environmentObject(AuthViewModel())
        .modelContainer(for: Animal.self, inMemory: true)
}
