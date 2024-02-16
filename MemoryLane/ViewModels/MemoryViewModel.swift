//
//  MemoryViewModel.swift
//  MemoryLane
//
//  Created by martin on 22.01.24.
//

import Foundation
import SwiftUI
import FirebaseFirestore
import FirebaseFirestoreSwift
import PhotosUI

class MemoryViewModel : ObservableObject {
    
    // Firestore listener to observe changes in memories
    private var listener: ListenerRegistration?
    
    // Automatically update the UI when memories change
    @Published var memories = [Memory]()
    
    @Published var selectedImage: PhotosPickerItem?
    @Published var selectedImageData: Data?
    
    // Create a new memory in Firestore
    func createMemory(title: String, description: String, category: String, date: Date, location: String, isFavorite: Bool, coverImage: String, galeryImages: [String]) {
        guard let userId = FirebaseManager.shared.userId else { return }
        
        let memory = Memory(
            userId: userId,
            category: category,
            title: title,
            description: description,
            date: date,
            location: location,
            isFavorite: isFavorite,
            coverImage: coverImage,
            galeryImages: galeryImages
        )
        do {
            try FirebaseManager.shared.database.collection("memories").addDocument(from: memory)
        } catch let error {
            print("Error saving memory: \(error)")
        }
    }
    
    // Berechne die eindeutigen Kategorien aus den Memories
        var memoryCategories: [String] {
            Set(memories.map { $0.category }).sorted()
        }

        // Gruppiere die Memories nach Kategorien
        var memoriesByCategory: [String: [Memory]] {
            Dictionary(grouping: memories, by: { $0.category })
        }
    
    // Fetch memories for the authenticated user from Firestore
    func fetchMemories() {
        guard let userId = FirebaseManager.shared.userId else { return }
        
        // Use Firestore listener to observe changes in the "memories" collection
        self.listener = FirebaseManager.shared.database.collection("memories")
            .whereField("userId", isEqualTo: userId)
            .addSnapshotListener { querySnapshot, error in
                if let error {
                    print(error.localizedDescription)
                    return
                }
                
                guard let documents = querySnapshot?.documents else {
                    print("Error loading memories.")
                    return
                }
                
                // Convert Firestore documents to Memory objects and update the local array
                self.memories = documents.compactMap { queryDocumentSnapshot -> Memory? in
                    try? queryDocumentSnapshot.data(as: Memory.self)
                }
            }
    }
    
    // Update an existing memory in Firestore
    func editMemory(memory: Memory, newTitle: String, newDescription: String, newLocation: String, newCoverImage: String, newGalleryImages: [String]?) {
        guard let memoryIndex = memories.firstIndex(where: { $0.id == memory.id }) else { return }
        
        var updatedMemory = memory
        updatedMemory.title = newTitle
        updatedMemory.description = newDescription
        updatedMemory.location = newLocation
        updatedMemory.coverImage = newCoverImage
        updatedMemory.galeryImages = newGalleryImages
        
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
        guard let memoryIndex = memories.firstIndex(where: { $0.id == memory.id }) else { return }
        
        FirebaseManager.shared.database
            .collection("memories")
            .document(memory.id ?? "")
            .delete { error in
                if let error = error {
                    print("Error deleting memory: \(error)")
                } else {
                    // Remove the memory from the local array
                    self.memories.remove(at: memoryIndex)
                }
            }
    }
    
    func removeListener() {
        memories.removeAll()
        listener?.remove()
    }

    
}
