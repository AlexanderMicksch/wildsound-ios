//
//  StartView.swift
//  WildSound
//
//  Created by Alexander Micksch on 26.08.25.
//

import SwiftUI

struct StartView: View {

    @EnvironmentObject var auth: AuthViewModel
    @State private var goToRoot = false
    @State private var showLogin = false
    @State private var errorText: String?

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Spacer()
                Image("AppLogo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 120, height: 120)
                    .shadow(radius: 6)
                    .cornerRadius(20)
                
                Spacer()
                Text("WildSound")
                    .font(.largeTitle.bold())
                    .padding(.top, 24)

                Button {
                    do {
                        try auth.signOut()
                        AppLogger.auth.info("Gastmodus: SignOut erzwungen")
                    } catch {
                        errorText = error.localizedDescription
                        AppLogger.auth.error(
                            "SignOut (Gastmodus) fehlgeschlagen: \(error.localizedDescription)"
                        )
                    }
                    goToRoot = true
                } label: {
                    Label(
                        "Spielen ohne Anmeldung",
                        systemImage: "gamecontroller"
                    )
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)

                Button {
                    AppLogger.ui.info("Admin-Login aufgerufen")
                    showLogin = true
                } label: {
                    Label("Als Admin anmelden", systemImage: "lock.shield")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)

                Spacer(minLength: 350)
            }
            .padding()

            .navigationDestination(isPresented: $goToRoot) {
                RootContainerView()
            }
            .sheet(isPresented: $showLogin) {
                AdminLoginView(onSuccess: {
                    showLogin = false
                    goToRoot = true
                })
                .scrollDismissesKeyboard(.interactively)
            }

            .alert("Fehler", isPresented: .constant(errorText != nil)) {
                Button("OK") { errorText = nil }
            } message: {
                Text(errorText ?? "")
            }
        }
    }
}
