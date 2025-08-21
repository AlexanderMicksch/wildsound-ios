//
//  AnimalRowView.swift
//  WildSound
//
//  Created by Alexander Micksch on 21.08.25.
//

import SwiftUI

struct AnimalRowView: View {
    
    let animal: Animal
    
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(animal.name).bold()
            Text(animal.storagePath)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
}

