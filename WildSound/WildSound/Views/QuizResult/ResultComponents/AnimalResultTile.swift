//
//  AnimalResultTile.swift
//  WildSound
//
//  Created by Alexander Micksch on 22.08.25.
//

import SwiftUI

struct AnimalResultTile: View {
    
    let title: String
    let url: URL?
    let tint: Color
    
    var body: some View {
        VStack(spacing: 6) {
            AnimalThumbnail(url: url)
                .frame(width: CardMetrics.Results.imageSize.width,
                       height: CardMetrics.Results.imageSize.height)
                .clipShape(RoundedRectangle(cornerRadius: CardMetrics.Results.tileCornerRadius))
            
            Text(title)
                .font(.caption)
                .lineLimit(2)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)
        }
        .padding(8)
        .background(.opacity(0.2))
        .overlay(
            RoundedRectangle(cornerRadius: CardMetrics.Results.tileCornerRadius)
                .stroke(tint.opacity(0.5), lineWidth: 6)
        )
        .clipShape(RoundedRectangle(cornerRadius: CardMetrics.Results.tileCornerRadius))
    }
}

