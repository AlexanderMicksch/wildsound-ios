//
//  ImageCrop.swift
//  WildSound
//
//  Created by Alexander Micksch on 22.08.25.
//

import Foundation
import SwiftUI

enum ImageCrop: String, Codable, CaseIterable, Sendable {
    case center, top, bottom, leading, trailing
    case topLeading, topTrailing, bottomLeading, bottomTrailing

    var alignment: Alignment {
        switch self {
        case .center: .center
        case .top: .top
        case .bottom: .bottom
        case .leading: .leading
        case .trailing: .trailing
        case .topLeading: .topLeading
        case .topTrailing: .topTrailing
        case .bottomLeading: .bottomLeading
        case .bottomTrailing: .bottomTrailing
        }
    }

    var displayName: String {
        switch self {
        case .center: "Zentriert"
        case .top: "Oben"
        case .bottom: "Unten"
        case .leading: "Links"
        case .trailing: "Rechts"
        case .topLeading: "Oben‑links"
        case .topTrailing: "Oben‑rechts"
        case .bottomLeading: "Unten‑links"
        case .bottomTrailing: "Unten‑rechts"
        }
    }
}
