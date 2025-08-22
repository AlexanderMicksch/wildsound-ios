//
//  StatCard.swift
//  WildSound
//
//  Created by Alexander Micksch on 22.08.25.
//

import SwiftUI

struct StatCard: View {
    
    let title: String
    let value: Int
    
    var body: some View {
        VStack(spacing: 8) {
            Text(title)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            
            Text("\(value)")
                .font(.system(size: 36, weight: .bold, design: .rounded))
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(.thinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(radius: 1)
    }
}

