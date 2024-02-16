//
//  Memory.swift
//  MemoryLane
//
//  Created by martin on 22.01.24.
//

import Foundation
import FirebaseFirestoreSwift

struct Memory: Codable, Identifiable {
    @DocumentID var id: String?
    var userId: String
    var category: String
    var title: String
    var description: String
    var date: Date
    var location: String
    var isFavorite: Bool
    var coverImage: String
    var galeryImages: [String]?
    
}

let exampleMemory = Memory(
    id: "1",
    userId: "2",
    category: "Vacation",
    title: "Summer vacation",
    description: "Two weeks of pure relaxation!",
    date: Date(),
    location: "Nizza",
    isFavorite: false,
    coverImage: "https://firebasestorage.googleapis.com/v0/b/memoryverse-mobileapp.appspot.com/o/beach-example.jpg?alt=media&token=ff46c2fb-2d68-4176-a6dc-ee4203177257",
    galeryImages: ["https://firebasestorage.googleapis.com/v0/b/memoryverse-mobileapp.appspot.com/o/beach-example.jpg?alt=media&token=ff46c2fb-2d68-4176-a6dc-ee4203177257", "https://firebasestorage.googleapis.com/v0/b/memoryverse-mobileapp.appspot.com/o/beach-example.jpg?alt=media&token=ff46c2fb-2d68-4176-a6dc-ee4203177257", "https://firebasestorage.googleapis.com/v0/b/memoryverse-mobileapp.appspot.com/o/beach-example.jpg?alt=media&token=ff46c2fb-2d68-4176-a6dc-ee4203177257"]
)

