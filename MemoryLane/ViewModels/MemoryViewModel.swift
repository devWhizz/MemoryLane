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
import GooglePlaces


class MemoryViewModel : ObservableObject {
    
    // Firestore listener to observe changes in memories
    private var listener: ListenerRegistration?
    
    // Automatically update the UI when memories change
    @Published var memories = [Memory]()
    
    // Store the details of the new memory
    @Published var id = UUID()
    @Published var UserId = UUID()
    @Published var selectedCategory = ""
    @Published var title = ""
    @Published var description = ""
    @Published var date = Date()
    @Published var isFavorite = false
    @Published var selectedCoverImage: UIImage?
    @Published var selectedGalleryImages: [UIImage] = []
    
    // Store new memory details
    @Published var newSelectedCategory = ""
    @Published var newTitle = ""
    @Published var newDescription = ""
    @Published var newDate = Date()
    @Published var newCoverImage = ""
    @Published var newGalleryImages = [""]
    @Published var existingCoverImage: UIImage?
    @Published var existingGalleryImages: [UIImage?] = []
    @Published var selectedNewGalleryImages: [UIImage] = []
    
    @Published var searchText = ""

    // Store the details of Google Places related details
    @Published var location = ""
    @Published var newLocation = ""
    @Published var locationInput: String = ""
    @Published var locationPredictions: [GMSAutocompletePrediction] = []
    @Published private var selectedLocationPrediction: GMSAutocompletePrediction?
    
    // Set category choices
    let categories = [
        NSLocalizedString("vacations", comment: ""),
        NSLocalizedString("birthdays", comment: ""),
        NSLocalizedString("holidays", comment: ""),
        NSLocalizedString("achievements", comment: ""),
        NSLocalizedString("adventures", comment: ""),
        NSLocalizedString("family", comment: ""),
        NSLocalizedString("creativity", comment: "")
    ]
    
    // Define a mapping between categories and their localized translations
    let categoryTranslations: [String: String] = [
        "vacations": NSLocalizedString("vacations", comment: ""),
        "birthdays": NSLocalizedString("birthdays", comment: ""),
        "holidays": NSLocalizedString("holidays", comment: ""),
        "achievements": NSLocalizedString("achievements", comment: ""),
        "adventures": NSLocalizedString("adventures", comment: ""),
        "family": NSLocalizedString("family", comment: ""),
        "creativity": NSLocalizedString("creativity", comment: "")
    ]
    
    
    
    // Create a new memory document in Firestore
    func createMemory(title: String, description: String, category: String, date: Date, location: String, isFavorite: Bool, coverImage: String, galleryImages: [String]?) {
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
    
    // Search function
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
    
    // Share function
    func shareMemory(_ memory: Memory) {
        guard memory.galleryImages != nil else {
            // Handle the case when galleryImages is nil
            return
        }
        
        // Format memory details as a string
        let formattedDetails = formattedMemoryDetails(memory)
        
        // Create UIActivityViewController with the formatted details
        let activityViewController = UIActivityViewController(activityItems: [formattedDetails], applicationActivities: nil)
        
        // Present the UIActivityViewController
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else { return }
        windowScene.windows.first?.rootViewController?.present(activityViewController, animated: true, completion: nil)
    }
    
    // Format memory details into a string
    func formattedMemoryDetails(_ memory: Memory) -> String {
        let title = memory.title
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .long
        
        let formattedDate = dateFormatter.string(from: memory.date)
        
        let description = memory.description
        let location = memory.location
        let coverImageURL: String
        
        // Check if the coverImage URL is valid
        if let url = URL(string: memory.coverImage) {
            coverImageURL = url.absoluteString
        } else {
            coverImageURL = "N/A"
        }
        
        var galleryImagesString = "No gallery images"
        
        if let galleryImages = memory.galleryImages {
            // Join gallery images into a formatted string
            galleryImagesString = galleryImages.joined(separator: "\n\n")
        }
        
        // Final formatted string with all memory details
        let formattedString =
                """
                Hey there, check out this Memory:
                
                Title: \(title)
                Date: \(formattedDate)
                Location: \(location)
                
                Description:
                \(description)
                
                Cover Image:
                \(coverImageURL)
                
                Gallery Images:
                \(galleryImagesString)
                """
        
        return formattedString
    }
    
    // Dictionary of memories grouped by month
    var sortedMemories: [String: [Memory]] {
        let groupedMemories = Dictionary(grouping: memories, by: { getMonthYearString(for: $0.date) })
        return groupedMemories
    }
    
    // Array of sorted month keys
    var sortedMonthKeys: [String] {
        return sortedMemories.keys.sorted(by: { compareMonthYearStrings($0, $1) })
    }
    
    // Get a formatted month-year string from a date
    private func getMonthYearString(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: date)
    }
    
    // Compare two month-year strings for sorting
    private func compareMonthYearStrings(_ string1: String, _ string2: String) -> Bool {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        
        if let date1 = formatter.date(from: string1), let date2 = formatter.date(from: string2) {
            return date1 > date2
        }
        return false
    }
    
    // Create a session token for Google Places API
    let sessionToken = GMSAutocompleteSessionToken.init()
    
    // Fetch place predictions for a given query
    func getPlacePredictions(for query: String) {
        let placesClient = GMSPlacesClient.shared()
        // Use the findAutocompletePredictions method to retrieve place predictions
        placesClient.findAutocompletePredictions(
            fromQuery: query,
            filter: nil,
            sessionToken: sessionToken,
            callback: { (results, error) in
                // Check for errors during the API request
                if let error = error {
                    print("Error fetching place predictions: \(error)")
                    return
                }
                // If successful, update the locationPredictions array with the results
                if let results = results {
                    self.locationPredictions = results
                }
            }
        )
    }
    
    // Handle the selection of a place prediction
    func selectPlace(_ prediction: GMSAutocompletePrediction) {
        self.selectedLocationPrediction = prediction
        self.location = prediction.attributedFullText.string
        self.locationInput = prediction.attributedFullText.string
        self.locationPredictions = []
    }
    
    // Handle the selection of a new place prediction
    func selectEditedPlace(_ prediction: GMSAutocompletePrediction) {
        self.selectedLocationPrediction = prediction
        self.newLocation = prediction.attributedFullText.string
        self.locationInput = prediction.attributedFullText.string
        self.locationPredictions = []
    }
    
    // Remove Firestore listener
    func removeListener() {
        memories.removeAll()
        listener?.remove()
    }
    
}
