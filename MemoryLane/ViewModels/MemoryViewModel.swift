//
//  MemoryViewModel.swift
//  MemoryLane
//
//  Created by martin on 29.01.24.
//

import Foundation
import SwiftUI
import FirebaseFirestore
import FirebaseFirestoreSwift
import PhotosUI
import FirebaseStorage


class MemoryViewModel : ObservableObject {
    
    // Firestore listener to observe changes in memories
    private var listener: ListenerRegistration?
    
    // Automatically update the UI when memories change
    @Published var memories = [Memory]()
    
    // Upload image to Firebase Storage and provide the download URL
    func uploadImageToFirebase(selectedImage: UIImage?, completion: @escaping (Result<String, Error>) -> Void) {
        // Ensure a valid image is provided
        guard let selectedImage = selectedImage else {
            // If no image is provided, invoke completion with an error
            completion(.failure(ImageUploadError.missingImage))
            return
        }
        
        // Resize the image before converting to data
        let resizedImage = resizeImage(image: selectedImage, targetSize: CGSize(width: 400, height: 400))
        guard let imageData = resizedImage.jpegData(compressionQuality: 0.2) else {
            // If image compression fails, invoke completion with an error
            completion(.failure(ImageUploadError.imageCompressionError))
            return
        }
        
        // Create references to Firebase Storage
        let storageRef = Storage.storage().reference()
        let fileRef = storageRef.child("images/\(UUID().uuidString).jpg")
        
        // Upload image data to Firebase Storage
        fileRef.putData(imageData, metadata: nil) { metadata, error in
            if let error = error {
                // If error during upload occurs, invoke completion with the error
                completion(.failure(error))
            } else {
                // If upload is successful, obtain the download URL
                fileRef.downloadURL { url, error in
                    if let url = url {
                        // If URL is obtained, invoke completion with the success and the URL string
                        completion(.success(url.absoluteString))
                    } else if let error = error {
                        // If URL retrieval fails, invoke completion with the error
                        completion(.failure(error))
                    }
                }
            }
        }
    }
    
    // Create a new memory document in Firestore
    func createMemory(title: String, description: String, category: String, date: Date, location: String, isFavorite: Bool, coverImage: String, galleryImages: [String]) {
        // Ensure there is a valid user ID available
        guard let userId = FirebaseManager.shared.userId else {
            return
        }
        
        // Translate the category to a format suitable for Firestore collection
        let translatedCategory = translateCategory(category)
        
        // Create a new Memory object with the provided details
        var memory = Memory(
            userId: userId,
            category: translatedCategory,
            title: title,
            description: description,
            date: date,
            location: location,
            isFavorite: isFavorite,
            coverImage: coverImage,
            galleryImages: galleryImages
        )
        
        // Remove empty strings from the galleryImages array
        memory.galleryImages = memory.galleryImages?.filter { !$0.isEmpty }
        
        // Attempt to add the memory document to the Firestore collection
        do {
            // Add the memory document to the Firestore collection and obtain its document ID
            let documentReference = try FirebaseManager.shared.database.collection("memories").addDocument(from: memory)
            
            // Update the memory object with the document ID
            memory.id = documentReference.documentID
            
            // Update the document with the document ID
            try FirebaseManager.shared.database.collection("memories").document(memory.id!).setData(from: memory)
        } catch let error {
            print("Error saving memory: \(error)")
        }
    }
    
    func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage {
        let size = image.size
        let widthRatio  = targetSize.width  / size.width
        let heightRatio = targetSize.height / size.height
        
        // Determine the scale factor that will fit the image within the target size while maintaining aspect ratio
        let scaleFactor = min(widthRatio, heightRatio)
        
        // Calculate the new size based on the scale factor
        let scaledSize = CGSize(width: size.width * scaleFactor, height: size.height * scaleFactor)
        
        let renderer = UIGraphicsImageRenderer(size: scaledSize)
        let scaledImage = renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: scaledSize))
        }
        
        return scaledImage
    }
    
    
    // Translate category from localized string to a specific category string
    func translateCategory(_ category: String) -> String {
        switch category {
        case NSLocalizedString("vacations", comment: ""):
            return "vacations"
        case NSLocalizedString("birthdays", comment: ""):
            return "birthdays"
        case NSLocalizedString("holidays", comment: ""):
            return "holidays"
        case NSLocalizedString("achievements", comment: ""):
            return "achievements"
        case NSLocalizedString("adventures", comment: ""):
            return "adventures"
        case NSLocalizedString("family", comment: ""):
            return "family"
        case NSLocalizedString("creativity", comment: ""):
            return "creativity"
            
        default:
            return category
        }
    }
    
    // Provide an array of unique memory categories, sorted alphabetically
    var memoryCategories: [String] {
        Set(memories.map { $0.category }).sorted()
    }
    
    // Group memories by category
    var memoriesByCategory: [String: [Memory]] {
        Dictionary(grouping: memories, by: { $0.category })
    }
    
    // Fetch memories for the authenticated user from Firestore
    func fetchMemories() {
        // Check if a user ID is present
        guard let userId = FirebaseManager.shared.userId else { return }
        
        // Use Firestore listener to observe changes in the "memories" collection
        self.listener = FirebaseManager.shared.database.collection("memories")
        // Only fetch memories for the current user
            .whereField("userId", isEqualTo: userId)
        // Firestore Snapshot Listener
            .addSnapshotListener { querySnapshot, error in
                if let error {
                    print(error.localizedDescription)
                    return
                }
                // Check if Firestore documents are present
                guard let documents = querySnapshot?.documents else {
                    print("Error loading memories.")
                    return
                }
                
                // Convert Firestore documents to Memory objects and update the local array
                self.memories = documents.compactMap { queryDocumentSnapshot -> Memory? in
                    // Try to convert Firestore data to a Memory object
                    try? queryDocumentSnapshot.data(as: Memory.self)
                }
            }
    }
    
    // Update an existing memory in Firestore
    func editMemory(memory: Memory, newCategory: String, newTitle: String, newDescription: String, newDate: Date, newLocation: String, newCoverImage: String, newGalleryImages: [String]?
    ) {
        guard let memoryIndex = memories.firstIndex(where: { $0.id == memory.id }) else { return }
        
        // Translate the category to a format suitable for Firestore collection
        let translatedCategory = translateCategory(newCategory)
        
        var updatedMemory = memory
        updatedMemory.category = translatedCategory.lowercased()
        updatedMemory.title = newTitle
        updatedMemory.description = newDescription
        updatedMemory.date = newDate
        updatedMemory.location = newLocation
        updatedMemory.coverImage = newCoverImage
        updatedMemory.galleryImages = newGalleryImages
        
        do {
            try FirebaseManager.shared.database
                .collection("memories")
                .document(memory.id ?? "")
                .setData(from: updatedMemory)
            
            // Update the local array with the edited memory
            memories[memoryIndex] = updatedMemory
        } catch let error {
            print("Error updating memory: \(error)")
        }
    }
    
    // Delete a memory from Firestore
    func deleteMemory(memory: Memory) {
        FirebaseManager.shared.database
            .collection("memories")
            .document(memory.id ?? "")
            .delete { error in
                if let error = error {
                    print("Fehler beim Löschen der Erinnerung: \(error)")
                }
            }
    }
    
    
    // Toggle the isFavorite status of a memory
    func toggleFavoriteStatus(for memory: Memory) {
        guard let memoryIndex = memories.firstIndex(where: { $0.id == memory.id }) else { return }
        
        var updatedMemory = memory
        updatedMemory.isFavorite.toggle()
        
        do {
            try FirebaseManager.shared.database
                .collection("memories")
                .document(memory.id ?? "")
                .setData(from: updatedMemory)
            
            // Update the local array with the edited memory
            memories[memoryIndex] = updatedMemory
        } catch let error {
            print("Error updating memory: \(error)")
        }
    }
    
    // Fetch favorite memories for the authenticated user from Firestore
    func fetchFavoriteMemories() {
        // Check if a user ID is present
        guard let userId = FirebaseManager.shared.userId else { return }
        
        // Use Firestore listener to observe changes in the "memories" collection
        self.listener = FirebaseManager.shared.database.collection("memories")
            .whereField("userId", isEqualTo: userId)
            .whereField("isFavorite", isEqualTo: true)
            .addSnapshotListener { querySnapshot, error in
                if let error {
                    print(error.localizedDescription)
                    return
                }
                
                // Check if Firestore documents are present
                guard let documents = querySnapshot?.documents else {
                    print("Error loading memories.")
                    return
                }
                
                // Convert Firestore documents to Memory objects and update the local array
                self.memories = documents.compactMap { queryDocumentSnapshot -> Memory? in
                    // Try to convert Firestore data to a Memory object
                    try? queryDocumentSnapshot.data(as: Memory.self)
                }
            }
    }
    
    // Searchfunction
    func searchMemories(query: String) {
        // Convert search term to lower case for a non-distinctive search
        let lowercaseQuery = query.lowercased()
        
        // Perform a query in the Firestore database
        FirebaseManager.shared.database.collection("memories")
            .whereField("userId", isEqualTo: FirebaseManager.shared.userId ?? "")
            .getDocuments { querySnapshot, error in
                if let error = error {
                    print("Error searching memories: \(error)")
                    return
                }
                
                // Check if Firestore documents are present
                guard let documents = querySnapshot?.documents else {
                    print("No search results.")
                    return
                }
                
                // Convert Firestore documents to Memory objects and update the local array
                self.memories = documents.compactMap { queryDocumentSnapshot -> Memory? in
                    // Try to convert Firestore data to a Memory object
                    guard let memory = try? queryDocumentSnapshot.data(as: Memory.self) else {
                        return nil
                    }
                    
                    // Check if search term appears in the lowercase title or location
                    let lowercaseTitle = memory.title.lowercased()
                    let lowercaseLocation = memory.location.lowercased()
                    
                    if lowercaseTitle.contains(lowercaseQuery) || lowercaseLocation.contains(lowercaseQuery) {
                        return memory
                    } else {
                        return nil
                    }
                }
            }
    }
    
    // Remove Firestore listener
    func removeListener() {
        memories.removeAll()
        listener?.remove()
    }
    
}
