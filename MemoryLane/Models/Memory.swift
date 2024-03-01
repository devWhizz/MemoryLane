//
//  Memory.swift
//  MemoryLane
//
//  Created by martin on 27.01.24.
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
    var galleryImages: [String]?
    
    
    static let exampleMemory = Memory(
        id: "1",
        userId: "2",
        category: "vacations",
        title: "Summer vacation",
        description: "Two weeks of pure relaxation!",
        date: Date(),
        location: "Nizza",
        isFavorite: false,
        coverImage: "https://firebasestorage.googleapis.com:443/v0/b/memorylane-mobileapp.appspot.com/o/images%2F8152F070-ADD8-42CA-BB6E-2A6B7DBC518B.jpg?alt=media&token=7b923bf1-28cc-4d1c-9586-e77264e76465",
        galleryImages: ["https://firebasestorage.googleapis.com:443/v0/b/memorylane-mobileapp.appspot.com/o/images%2F17D75A2E-88F9-4A32-B1C6-A0D9C904A8D6.jpg?alt=media&token=8caa0905-7b83-4139-9a58-d44560c3d876", "https://firebasestorage.googleapis.com:443/v0/b/memorylane-mobileapp.appspot.com/o/images%2F17D75A2E-88F9-4A32-B1C6-A0D9C904A8D6.jpg?alt=media&token=8caa0905-7b83-4139-9a58-d44560c3d876", "https://firebasestorage.googleapis.com:443/v0/b/memorylane-mobileapp.appspot.com/o/images%2F17D75A2E-88F9-4A32-B1C6-A0D9C904A8D6.jpg?alt=media&token=8caa0905-7b83-4139-9a58-d44560c3d876"]
    )
    
}
