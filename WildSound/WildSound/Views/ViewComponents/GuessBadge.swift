//
//  GuessBadge.swift
//  WildSound
//
//  Created by Alexander Micksch on 19.08.25.
//

import SwiftUI

struct GuessBadge: View {
    let count: Int
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: "checkmark.circle.fill")
            Text("\(count)")
        }
        .font(.caption2.bold())
        .foregroundStyle(.white)
        .padding(.horizontal, 4)
        .padding(.vertical, 3)
        .background(Color.green.opacity(0.75), in: Capsule())
        .accessibilityLabel("Richtig geraten: \(count)")
    }
}
