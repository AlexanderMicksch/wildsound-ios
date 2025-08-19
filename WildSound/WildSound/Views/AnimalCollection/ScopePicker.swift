//
//  ScopePicker.swift
//  WildSound
//
//  Created by Alexander Micksch on 19.08.25.
//

import SwiftUI

struct ScopePicker: View {
    @Binding var scope: CollectionsViewModel.Scope
    
    var body: some View {
        Picker("Filter", selection: $scope) {
            ForEach(CollectionsViewModel.Scope.allCases) { scope in
                Text(scope.rawValue).tag(scope)
            }
        }
        .pickerStyle(.segmented)
        .accessibilityLabel("Filter")
    }
}

