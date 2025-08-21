//
//  SoundSourcePickerView.swift
//  WildSound
//
//  Created by Alexander Micksch on 21.08.25.
//

import SwiftUI

struct SoundSourcePickerView: View {
    
    @Binding var selection: SoundSource
    
    var body: some View {
        Section("Herkunft des Sounds") {
            Picker("Quelle", selection: $selection) {
                ForEach(SoundSource.allCases, id: \.self) { source in
                    Text(source.displayName).tag(source)
                }
            }
            .pickerStyle(.segmented)
        }
    }
}


