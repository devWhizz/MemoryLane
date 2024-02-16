//
//  FirebaseManager.swift
//  MemoryVerse
//
//  Created by syntax on 22.01.24.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore
import FirebaseFirestoreSwift

class FirebaseManager {
    
    // Singleton instance to be shared across the application
    static let shared = FirebaseManager()
    
    // Firebase Authentication object for user authentication operations
    let auth = Auth.auth()
    // Firestore database object for handling data storage and retrieval
    let database = Firestore.firestore()
    
    var userId: String? {
            auth.currentUser?.uid
        }
    
}
