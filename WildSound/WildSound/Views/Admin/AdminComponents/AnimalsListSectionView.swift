//
//  AnimalsListSectionView.swift
//  WildSound
//
//  Created by Alexander Micksch on 21.08.25.
//

import SwiftUI

struct AnimalsListSectionView: View {
    
    let animals: [Animal]
    let onDelete: (IndexSet) -> Void
    
    var body: some View {
        Section("Gespeicherte Tiere (\(animals.count))") {
            if animals.isEmpty {
                Text("Noch keine Tiere gespeichert")
                    .foregroundStyle(.secondary)
            } else {
                List {
                    ForEach(animals, id: \.id) { animal in
                        AnimalRowView(animal: animal)
                    }
                    .onDelete(perform: onDelete)
                }
                .frame(minHeight: 120)
            }
        }
    }
}
