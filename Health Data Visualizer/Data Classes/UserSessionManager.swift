//
//  UserSessionManager.swift
//  Health Data Visualizer
//
//  Created by Amira Mahmedjan on 15.08.2024.
//

import Foundation
import FirebaseAuth

class UserSessionManager: ObservableObject {
    static let shared = UserSessionManager()
        
    @Published private(set) var currentUser: User? {
        didSet {
            print("User updated: \(String(describing: currentUser))")
        }
    }
    
    private var authStateListenerHandle: AuthStateDidChangeListenerHandle?
    
    private init() {
        authStateListenerHandle = Auth.auth().addStateDidChangeListener { [weak self] auth, user in
            DispatchQueue.main.async {
                self?.currentUser = user
            }
        }
    }
    
    func signIn(email: String, password: String) {
        Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
            if let error = error {
                print("Sign-in error: \(error.localizedDescription)")
                // Handle error appropriately
            } else if let user = authResult?.user {
                DispatchQueue.main.async {
                    self.currentUser = user
                }
                print("User signed in!!")
                print(UserSessionManager.shared.currentUser?.email ?? "No email available")
            }
        }
    }

    func signUp(email: String, password: String) {
        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            if let error = error {
                print("Sign-up error: \(error.localizedDescription)")
                // Handle error appropriately
            } else if let user = authResult?.user {
                DispatchQueue.main.async {
                    self.currentUser = user
                }
                print("User signed up!!")
                print(user)
            }
        }
    }
    
    func signOut() {
        do {
            try Auth.auth().signOut()
            DispatchQueue.main.async {
                self.currentUser = nil
            }
        } catch let signOutError as NSError {
            print("Error signing out: %@", signOutError.localizedDescription)
        }
    }
}
