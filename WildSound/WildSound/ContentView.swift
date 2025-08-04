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
                    Text("Quelle: \(animal.soundSource ?? "unbekannt")")
                        .font(.caption)
                    Text(animal.wikiTitle)
                        .font(.subheadline)
                }
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
            soundURL: "https://example.com/test-bird.mp3",
            wikiTitle: "Amsel",
            soundSource: "xeno-canto"
        )
        modelContext.insert(bird)
    }

    func addMammal() {
        let mammal = Animal(
            name: "Tiger",
            soundURL: "https://example.com/test-tiger.mp3",
            wikiTitle: "Tiger",
            soundSource: "firebase"
        )
        modelContext.insert(mammal)
    }
}

#Preview {
    ContentView()
}
