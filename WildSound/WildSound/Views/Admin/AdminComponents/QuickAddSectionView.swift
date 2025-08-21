//
//  QuickAddSectionView.swift
//  WildSound
//
//  Created by Alexander Micksch on 21.08.25.
//

import SwiftUI

struct QuickAddSectionView: View {
    
    @Binding var name: String
    @Binding var storagePath: String
    @Binding var wikiTitleDe: String
    @Binding var selectedSoundSource: SoundSource
    
    let isValid: Bool
    let onAdd: () -> Void
    
    var body: some View {
        Section("Neues Tier hinzufügen") {
            TextField("Name", text: $name)
                .textInputAutocapitalization(.words)
                .autocorrectionDisabled()
            
            TextField("Storage-Pfad (Firebase Storage)", text: $storagePath)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .keyboardType(.asciiCapable)
            
            TextField("Wikipedia-Titel (DE)", text: $wikiTitleDe)
                .textInputAutocapitalization(.words)
                .autocorrectionDisabled()
            
            SoundSourcePickerView(selection: $selectedSoundSource)
            
            Button("Hinzufügen", action: onAdd)
                .disabled(!isValid)
        }
    }
}

