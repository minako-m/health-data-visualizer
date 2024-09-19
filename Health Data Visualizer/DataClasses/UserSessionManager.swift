//
//  UserSessionManager.swift
//  Health Data Visualizer
//
//  Created by Amira Mahmedjan on 15.08.2024.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore

class UserSessionManager: ObservableObject {
    static let shared = UserSessionManager()
        
    @Published private(set) var currentUser: User? {
        didSet {
            print("User updated: \(String(describing: currentUser))")
            if let userId = currentUser?.uid {
                fetchUserRole(userId: userId)
            }
        }
    }
    
    @Published private(set) var currentUserRole: String? {
        didSet {
            print("User role updated: \(String(describing: currentUserRole))")
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

    func signUp(email: String, password: String, role: String) {
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
                
                self.addUserRole(userId: user.uid, role: role)
            }
        }
    }
    
    private func addUserRole(userId: String, role: String) {
        let db = Firestore.firestore()
        db.collection("users").document(userId).setData(["role": role]) { error in
            if let error = error {
                print("Error adding role: \(error.localizedDescription)")
            } else {
                self.currentUserRole = role
                print("Role added successfully")
            }
        }
    }
    
    func fetchUserRole(userId: String) {
        let db = Firestore.firestore()
        db.collection("users").document(userId).getDocument { (document, error) in
            if let document = document, document.exists {
                let role = document.data()?["role"] as? String
                DispatchQueue.main.async {
                    self.currentUserRole = role
                }
            } else {
                print("No such document or error: \(error?.localizedDescription ?? "Unknown error")")
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
