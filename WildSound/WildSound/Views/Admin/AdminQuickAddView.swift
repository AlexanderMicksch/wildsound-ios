//
//  AdminQuickAddView.swift
//  WildSound
//
//  Created by Alexander Micksch on 15.08.25.
//

import SwiftData
import SwiftUI

struct AdminQuickAddView: View {

    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject var auth: AuthViewModel

    @Query(sort: \Animal.name, order: .forward) private var animals: [Animal]

    @StateObject private var adminViewModel = AdminQuickAddViewModel()
    @State private var showErrorAlert = false
    @State private var lastErrorMessage: String?

    var body: some View {
        Form {
            Section("Account") {
                LabeledContent("Angemeldet als", value: auth.user?.email ?? "-")
                LabeledContent(
                    "Admin-Rechte",
                    value: auth.isAdmin ? "Ja" : "Nein"
                )
            }

            Button(role: .destructive) {
                do {
                    try auth.signOut()
                    AppLogger.auth.info("User abgemedet")
                } catch {
                    lastErrorMessage = error.localizedDescription
                    showErrorAlert = true
                    AppLogger.auth.error(
                        "Abmelden fehlgeschlagen: \(error.localizedDescription)"
                    )
                }
            } label: {
                Label(
                    "Abmelden",
                    systemImage: "rectangle.portrait.and.arrow.right"
                )
                .frame(maxWidth: .infinity, alignment: .leading)
            }

            QuickAddSectionView(
                name: $adminViewModel.nameInput,
                storagePath: $adminViewModel.storagePathInput,
                wikiTitleDe: $adminViewModel.wikiTitleDeInput,
                selectedSoundSource: $adminViewModel.selectedSoundSource,
                isValid: adminViewModel.isValid
            ) {
                do {
                    try adminViewModel.addAnimal(using: modelContext)
                    AppLogger.firestore.info(
                        "Tier hinzugefügt: \(adminViewModel.nameInput)"
                    )
                } catch {
                    lastErrorMessage = error.localizedDescription
                    showErrorAlert = true
                    AppLogger.firestore.error(
                        "addAnimal fehlgeschlagen: \(error.localizedDescription)"
                    )
                }
            }

            AnimalsListSectionView(
                animals: animals,
                onDelete: { offsets in
                    do {
                        try adminViewModel.deleteAnimals(
                            at: offsets,
                            from: animals,
                            using: modelContext
                        )
                        AppLogger.firestore.info(
                            "Tiere gelöscht (Offsets: \(String(describing: offsets)))"
                        )
                    } catch {
                        lastErrorMessage = error.localizedDescription
                        showErrorAlert = true
                        AppLogger.firestore.error(
                            "deleteAnimals fehlgeschlagen: \(error.localizedDescription)"
                        )
                    }
                }
            )
        }
        .navigationTitle("Admin - Quick Add")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Felder leeren", role: .destructive) {
                    adminViewModel.resetFields()
                }
                .disabled(
                    adminViewModel.nameInput.isEmpty
                        && adminViewModel.storagePathInput.isEmpty
                        && adminViewModel.wikiTitleDeInput.isEmpty
                )
            }
            ToolbarItem(placement: .bottomBar) {
                Button("Alle Tiere nach Firestore exportieren") {
                    Task {
                        await adminViewModel.exportAllAnimals(
                            using: modelContext
                        )
                        AppLogger.firestore.info(
                            "Export aller Tiere nach Firestore angestoßen"
                        )
                    }
                }
            }
        }
        .overlay(alignment: .bottom) {
            if adminViewModel.showSavedBanner {
                SavedBannerView(text: "Gespeichert CHECK")
                    .transition(
                        .move(edge: .bottom).combined(with: .opacity)
                    )
            }
        }
        .animation(
            .easeInOut(duration: 0.2),
            value: adminViewModel.showSavedBanner
        )
        .onChange(of: adminViewModel.showSavedBanner) { _, show in
            guard show else { return }
            Task { @MainActor in
                try? await Task.sleep(nanoseconds: 1_000_000_000)
                withAnimation(.easeInOut(duration: 0.2)) {
                    adminViewModel.showSavedBanner = false
                }
            }
        }
        .alert("Fehler", isPresented: $showErrorAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(lastErrorMessage ?? "Unbekannter Fehler")
        }
        .onAppear {
            AppLogger.ui.info(
                "AdminQuickAddView angezeigt (isAdmin=\(auth.isAdmin, privacy: .public))"
            )
        }
    }
}
