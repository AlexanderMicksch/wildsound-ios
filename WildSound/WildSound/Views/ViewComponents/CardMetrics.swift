//
//  CardMetrics.swift
//  WildSound
//
//  Created by Alexander Micksch on 20.08.25.
//

import Foundation
import CoreGraphics
import SwiftUI

enum CardMetrics {
    static let cardSize = CGSize(width: 190, height: 200)
    static let imageSize = CGSize(width: 180, height: 160)
    
    enum Results {
        static let columns: [GridItem] = [
            GridItem(.adaptive(minimum: 84), spacing: 12, alignment: .top)
        ]
        static let tileCornerRadius: CGFloat = 12
        static let imageSize = CGSize(width: 96, height: 72)
    }
}
