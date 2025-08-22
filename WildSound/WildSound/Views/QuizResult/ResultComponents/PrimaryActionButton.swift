//
//  PrimaryActionButton.swift
//  WildSound
//
//  Created by Alexander Micksch on 22.08.25.
//

import SwiftUI

struct PrimaryActionButton: View {

    let title: String
    let background: Color
    var action: () -> Void
    
    var body: some View {
        Button(title, action: action)
            .frame(maxWidth: .infinity)
            .padding()
            .background(background)
            .foregroundColor(.primary)
            .clipShape(RoundedRectangle(cornerRadius: 15))
    }
}


