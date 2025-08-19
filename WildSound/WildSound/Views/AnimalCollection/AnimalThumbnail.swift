//
//  AnimalThumbnail.swift
//  WildSound
//
//  Created by Alexander Micksch on 19.08.25.
//

import SwiftUI

struct AnimalThumbnail: View {
    let url: URL?

    var body: some View {
        Group {
            if let url {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .empty:
                        ProgressView().frame(
                            maxWidth: .infinity,
                            maxHeight: .infinity
                        )
                    case .success(let img):
                        img.resizable().scaledToFill()
                    case .failure:
                        Placeholder()
                    @unknown default:
                        Placeholder()
                    }
                }
            } else {
                Placeholder()
            }
        }
        .background(Color.gray.opacity(0.1))
    }

    @ViewBuilder
    private func Placeholder() -> some View {
        ZStack {
            Color.gray.opacity(0.15)
            Image(systemName: "photo")
                .imageScale(.large)
                .foregroundStyle(.gray)
        }
    }
}
