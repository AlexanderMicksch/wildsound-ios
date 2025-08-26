//
//  AuthViewModel.swift
//  WildSound
//
//  Created by Alexander Micksch on 26.08.25.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore


@MainActor
final class AuthViewModel: ObservableObject {
    
    enum AuthState: Equatable {
        case signedOut
        case loading
        case signedIn
    }
    
    @Published private(set) var state: AuthState = .signedOut
    @Published private(set) var isAdmin: Bool = false
    @Published private(set) var user: FirebaseAuth.User?
    
    private let db: Firestore
    private var authListener: AuthStateDidChangeListenerHandle?
    
    init(db: Firestore = Firestore.firestore()) {
        self.db = db
        self.authListener = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            guard let self else { return }
            Task { await self.updateFor(user: user) }
        }
    }
    
    deinit {
        if let l = authListener { Auth.auth().removeStateDidChangeListener(l) }
    }
    
    func signIn(email: String, pasword: String) async throws {
        state = .loading
        do {
            let result = try await Auth.auth().signIn(withEmail: email, password: pasword)
            await updateFor(user: result.user)
        } catch {
            state = .signedOut
            isAdmin = false
            AppLogger.auth.error("Login fehlgeschlagen für \(email) – \(error.localizedDescription)")
            throw error
        }
    }
    
    func signOut() throws {
        try Auth.auth().signOut()
        user = nil
        isAdmin = false
        state = .signedOut
    }
    
    private func updateFor(user: FirebaseAuth.User?) async {
        self.user = user
        guard let uid = user?.uid else {
            self.isAdmin = false
            self.state = .signedOut
            return
        }
        self.state = .signedIn
        self.isAdmin = await fetchIsAdmin(uid: uid)
    }
    
    private func fetchIsAdmin(uid: String) async -> Bool {
        do {
            let snapshot = try await db.collection("admins").document(uid).getDocument()
            if snapshot.exists {
                AppLogger.auth.info("Admin gefunden für UID: \(uid)")
                return true
            } else {
                AppLogger.auth.warning("Kein Admin-Dokument für UID: \(uid)")
                return false
            }
        } catch {
            AppLogger.auth.error("Fehler beim Admin-Check für UID: \(uid) - \(error.localizedDescription)")
            return false
        }
    }
}
