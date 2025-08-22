//
//  AnimalThumbnail.swift
//  WildSound
//
//  Created by Alexander Micksch on 19.08.25.
//

import SwiftUI

struct AnimalThumbnail: View {
    let url: URL?
    var crop: ImageCrop = .center
    var cornerRadius: CGFloat = 15
    var size: CGSize = CardMetrics.imageSize

    var body: some View {
        ZStack {
            if let url {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .empty:
                        Placeholder()
                    case .success(let img):
                        img
                            .resizable()
                            .scaledToFill()
                            .frame(
                                width: size.width,
                                height: size.height,
                                alignment: crop.alignment
                            )
                            .clipped()
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
        .frame(width: size.width, height: size.height)
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
        .background(
            RoundedRectangle(cornerRadius: cornerRadius)
                .fill(Color.gray.opacity(0.1))
        )
        .contentShape(RoundedRectangle(cornerRadius: cornerRadius))
    }

    @ViewBuilder
    private func Placeholder() -> some View {
        ZStack {
            Color.gray.opacity(0.15)
            Image(systemName: "photo")
                .imageScale(.large)
                .foregroundStyle(.gray)
        }
        .frame(width: size.width, height: size.height)
        .clipped()
    }
}
