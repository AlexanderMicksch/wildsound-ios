//
//  AppStats.swift
//  WildSound
//
//  Created by Alexander Micksch on 22.08.25.
//

import Foundation
import SwiftData

@Model
final class AppStats {
    var globalScore: Int
    
    init(globalScore: Int = 0) {
        self.globalScore = globalScore
    }
}
