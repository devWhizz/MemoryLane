//
//  UserViewModel.swift
//  MemoryLane
//
//  Created by martin on 29.01.24.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore


class UserViewModel: ObservableObject {
    
    @Published var user: User?
    private let firebaseManager = FirebaseManager.shared
    
    
    // Check if a user is logged in
    var userIsLoggedIn: Bool {
        user != nil
    }
    var name: String {
        user?.name ?? ""
    }
    var email: String {
        user?.email ?? ""
    }
    
    init() {
        // Check authentication status
        checkAuth()
    }
    
    // Check the current authentication status
    private func checkAuth() {
        guard let currentUser = firebaseManager.auth.currentUser else {
            print("Not logged in")
            return
        }
        // If a user is logged in, call the fetchUser function to retrieve the user
        self.fetchUser(with: currentUser.uid)
    }
    
    // Attempt to log in with provided email and password
    func login(email: String, password: String) {
        firebaseManager.auth.signIn(withEmail: email, password: password) { authResult, error in
            if let error {
                print("Login failed:", error.localizedDescription)
                return
            }
            
            guard let authResult, let email = authResult.user.email else { return }
            print("User with email '\(email)' is logged in with id '\(authResult.user.uid)'")
            
            // Call the fetchUser function to load additional user data
            self.fetchUser(with: authResult.user.uid)
        }
    }
    
    // Attempt to register a new user with provided email and password
    func register(name: String, email: String, password: String) {
        firebaseManager.auth.createUser(withEmail: email, password: password) { authResult, error in
            if let error {
                print("Registration failed:", error.localizedDescription)
                return
            }
            
            guard let authResult, let email = authResult.user.email else { return }
            print("User with email '\(email)' is registered with id '\(authResult.user.uid)'")
            
            self.createUser(with: authResult.user.uid, name: name, email: email)
            
            // Automatically log in the newly registered user
            self.login(email: email, password: password)
        }
    }
    
    // Log out the current user
    func logout() {
        do {
            try firebaseManager.auth.signOut()
            self.user = nil
        } catch {
            print("Error signing out: ", error.localizedDescription)
        }
    }
    
    func createUser(with id: String, name: String, email: String) {
        // Create a FireUser object with the provided id, name and email
        let user = User(id: id, name: name, email: email)
        
        // Try to save the user data to the Firestore database
        do {
            try firebaseManager.database.collection("users").document(id).setData(from: user)
        } catch let error {
            print("Error saving User: \(error)")
        }
    }
    
    func fetchUser(with id: String) {
        // Retrieve user data from the Firestore database using the provided id
        firebaseManager.database.collection("users").document(id).getDocument { document, error in
            if let error {
                print("Fetching user failed:", error.localizedDescription)
                return
            }
            
            // Check if the document exists
            guard let document else {
                print("Doument does't exist.")
                return
            }
            
            // Try to convert the document data to a FireUser object
            do {
                let user = try document.data(as: User.self)
                // Update the user property with the retrieved user data
                self.user = user
            } catch {
                print("Document isn't a User", error.localizedDescription)
            }
        }
    }
    
}
