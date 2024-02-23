//
//  Errors.swift
//  MemoryLane
//
//  Created by martin on 01.02.24.
//

import Foundation


enum ImageUploadError: Error {
    case missingImage
    case imageCompressionError
}

enum AuthenticationError: Error {
    case userNotLoggedIn
    case profilePictureUploadError(Error)
}

