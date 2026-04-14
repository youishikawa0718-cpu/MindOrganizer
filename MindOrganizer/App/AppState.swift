import Foundation
import Observation
import FirebaseAuth

@Observable
final class AppState {
    var currentUser: User?
    var isAuthenticated: Bool { currentUser != nil }
    var isGuest: Bool { currentUser == nil }
    var isLoading = true

    private var authListener: AuthStateDidChangeListenerHandle?

    init() {
        self.currentUser = Auth.auth().currentUser
        self.isLoading = false

        authListener = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            self?.currentUser = user
        }
    }
}
