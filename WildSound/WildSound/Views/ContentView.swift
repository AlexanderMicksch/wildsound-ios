//
//  ContentView.swift
//  WildSound
//
//  Created by Alexander Micksch on 21.07.25.
//

import SwiftData
import SwiftUI

struct ContentView: View {

    @Environment(\.modelContext) private var modelContext
    @Query var animals: [Animal]

    var body: some View {
        NavigationStack {
            List(animals) { animal in
                VStack(alignment: .leading) {
                    Text(animal.name)
                        .font(.headline)
                    Text("Quelle: \(animal.soundSource.displayName)")
                        .font(.caption)
                    Text(animal.wikiTitleDe)
                        .font(.subheadline)
                }
            }
            .onAppear {
                SeedService.seedIfNeeded(context: modelContext)
            }
            .navigationTitle("Tiere")
            .toolbar {
                Button("Beispiel-Vogel") {
                    addBird()
                }
                Button("Beispiel-Tier") {
                    addMammal()
                }
            }
        }
    }

    func addBird() {
        let bird = Animal(
            name: "Amsel",
            storagePath: "https://example.com/test-bird.mp3",
            wikiTitleDe: "Amsel",
            soundSource: .xenoCanto
        )
        modelContext.insert(bird)
    }

    func addMammal() {
        let mammal = Animal(
            name: "Tiger",
            storagePath: "https://example.com/test-tiger.mp3",
            wikiTitleDe: "Tiger",
            soundSource: .firebase
        )
        modelContext.insert(mammal)
    }
}

#Preview {
    ContentView()
}
