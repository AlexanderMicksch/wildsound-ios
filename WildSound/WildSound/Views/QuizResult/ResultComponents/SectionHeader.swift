//
//  SectionHeader.swift
//  WildSound
//
//  Created by Alexander Micksch on 22.08.25.
//

import SwiftUI

struct SectionHeader: View {
    
    let title: String
    
    var body: some View {
        HStack {
            Text(title)
                .font(.title3.weight(.semibold))
            Spacer()
        }
        .padding(.top, 6)
    }
}


