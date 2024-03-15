//
//  MemoryUploadManager.swift
//  MemoryLane
//
//  Created by martin on 14.03.24.
//

import FirebaseStorage
import Foundation
import UIKit


class MemoryUploadManager {
    
    static func uploadAndCreateMemory(memoryViewModel: MemoryViewModel, title: String, description: String, selectedCategory: String, date: Date, location: String, isFavorite: Bool, selectedCoverImage: UIImage?, selectedGalleryImages: [UIImage], completion: @escaping (Bool) -> Void) {
        if let coverImage = selectedCoverImage {
            // Upload cover image to Firebase Storage
            memoryViewModel.uploadImageToFirebase(selectedImage: coverImage) { result in
                switch result {
                case .success(let uploadedCoverImageUrl):
                    // Cover image uploaded successfully, now handle gallery images
                    var galleryImageUrls: [String] = []
                    
                    // Check if gallery images are selected
                    if !selectedGalleryImages.isEmpty {
                        // Upload each gallery image to Firebase Storage
                        let dispatchGroup = DispatchGroup()
                        
                        for galleryImage in selectedGalleryImages {
                            dispatchGroup.enter()
                            
                            memoryViewModel.uploadImageToFirebase(selectedImage: galleryImage) { result in
                                switch result {
                                case .success(let uploadedGalleryImageUrl):
                                    // Gallery image uploaded successfully, append URL to galleryImageUrls
                                    galleryImageUrls.append(uploadedGalleryImageUrl)
                                case .failure(let error):
                                    print("Error uploading gallery image: \(error)")
                                }
                                
                                dispatchGroup.leave()
                            }
                        }
                        
                        // Notify when all gallery images are uploaded
                        dispatchGroup.notify(queue: .main) {
                            // Create memory after all images are uploaded successfully
                            createMemory(memoryViewModel: memoryViewModel, title: title, description: description, selectedCategory: selectedCategory, date: date, location: location, isFavorite: isFavorite, coverImageUrl: uploadedCoverImageUrl, galleryImageUrls: galleryImageUrls, completion: completion)
                        }
                    } else {
                        // No gallery images selected, create memory with cover image only
                        createMemory(memoryViewModel: memoryViewModel, title: title, description: description, selectedCategory: selectedCategory, date: date, location: location, isFavorite: isFavorite, coverImageUrl: uploadedCoverImageUrl, galleryImageUrls: galleryImageUrls, completion: completion)
                    }
                    
                case .failure(let error):
                    print("Error uploading cover image: \(error)")
                    completion(false)
                }
            }
        } else {
            completion(false)
        }
    }
    
    private static func createMemory(memoryViewModel: MemoryViewModel, title: String, description: String, selectedCategory: String, date: Date, location: String, isFavorite: Bool, coverImageUrl: String, galleryImageUrls: [String], completion: @escaping (Bool) -> Void) {
        memoryViewModel.createMemory(
            title: title,
            description: description,
            category: selectedCategory,
            date: date,
            location: location,
            isFavorite: isFavorite,
            coverImage: coverImageUrl,
            galleryImages: galleryImageUrls
        )
        
        completion(true)
    }
    
    static func updateMemory(_ memoryViewModel: MemoryViewModel, _ memory: Memory, _ newSelectedCategory: String, _ newTitle: String, _ newDescription: String, _ newDate: Date, _ newLocation: String, _ existingCoverImage: UIImage?, _ existingGalleryImages: [UIImage], completion: @escaping (Bool) -> Void) {
        guard let coverImage = existingCoverImage else {
            print("No cover image to update")
            completion(false)
            return
        }
        
        memoryViewModel.uploadImageToFirebase(selectedImage: coverImage) { result in
            switch result {
            case .success(let uploadedCoverImageUrl):
                var galleryImageUrls: [String] = []
                
                let dispatchGroup = DispatchGroup()
                
                for galleryImage in existingGalleryImages {
                    dispatchGroup.enter()
                    memoryViewModel.uploadImageToFirebase(selectedImage: galleryImage) { result in
                        switch result {
                        case .success(let uploadedGalleryImageUrl):
                            galleryImageUrls.append(uploadedGalleryImageUrl)
                        case .failure(let error):
                            print("Error uploading gallery image: \(error)")
                        }
                        dispatchGroup.leave()
                    }
                }
                
                dispatchGroup.notify(queue: .main) {
                    memoryViewModel.editMemory(
                        memory: memory,
                        newCategory: newSelectedCategory,
                        newTitle: newTitle,
                        newDescription: newDescription,
                        newDate: newDate,
                        newLocation: newLocation,
                        newCoverImage: uploadedCoverImageUrl,
                        newGalleryImages: galleryImageUrls
                    )
                    completion(true)
                }
            case .failure(let error):
                print("Error uploading cover image: \(error)")
                completion(false)
            }
        }
    }
}
