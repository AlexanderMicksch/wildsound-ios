//
//  AdminLoginView.swift
//  WildSound
//
//  Created by Alexander Micksch on 26.08.25.
//

import SwiftUI

struct AdminLoginView: View {
    let onSucces: () -> Void
    @EnvironmentObject var auth: AuthViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var email = ""
    @State private var password = ""
    @State private var errorText: String?
    
    var body: some View {
        Form {
            Section("Anmeldung") {
                TextField("E-Mail", text: $email)
                    .keyboardType(.emailAddress)
                    .textInputAutocapitalization(.never)
                    .textContentType(.username)
                
                SecureField("Passwort", text: $password)
                    .textContentType(.password)
            }
            
            if let errorText {
                Text(errorText).foregroundStyle(.red)
            }
            
            Button {
                Task {
                    do {
                        try await auth.signIn(email: email, pasword: password)
                        onSucces()
                        AppLogger.auth.info("Login erfolgreich – warte auf Admin-Flag")
                        await MainActor.run { dismiss() }
                    } catch {
                        AppLogger.auth.error("Login fehlgeschlagen: \(error.localizedDescription)")
                        errorText = error.localizedDescription
                    }
                }
            } label: {
                Label("Anmelden", systemImage: "lock.open")
                    .frame(maxWidth: .infinity)
            }
            .disabled(email.isEmpty || password.isEmpty)
        }
        .navigationTitle("Admin Login")
    }
}

