//
//  User.swift
//  MemoryLane
//
//  Created by martin on 26.01.24.
//

import Foundation


struct User: Codable {
    var id: String
    var name: String
    var email: String
    var profilePicture: String
    
    
    static let exampleUser = User(
        id: "1",
        name: "Lothar",
        email: "lothar@test.de",
        profilePicture: "https://firebasestorage.googleapis.com/v0/b/memorylane-mobileapp.appspot.com/o/placeholder-user.jpg?alt=media&token=4d4d5fce-ac35-4bc8-913c-b50d87d5c748"
    )
    
}
