//
//  UserViewModel.swift
//  MemoryLane
//
//  Created by martin on 29.01.24.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage


class UserViewModel: ObservableObject {
    
    private let firebaseManager = FirebaseManager.shared
    
    @Published var user: User?
    
    // Store the details of the new user
    @Published var registerName = ""
    @Published var registerEmail = ""
    @Published var registerPassword = ""
    @Published var selectedProfilePicture: UIImage?
    
    // Store the details of the user
    @Published var userEmail = ""
    @Published var userPassword = ""
    
    // Store the updated details of the user
    @Published var isEditingName = false
    @Published var editedName = ""
    @Published var newProfilePicture = UIImage()
    @Published var showProfilePicturePicker = false
    @Published var existingProfilePicture: UIImage?
    @Published var isProfilePictureLoaded = false
    
    @Published var saveButtonIsShowing = false
    
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
    
    func registerUser(name: String, email: String, password: String, selectedProfilePicture: UIImage?) {
        firebaseManager.auth.createUser(withEmail: email, password: password) { authResult, error in
            if let error = error {
                print("Registration failed:", error.localizedDescription)
                return
            }
            
            guard let authResult = authResult, let userEmail = authResult.user.email else { return }
            print("User with email '\(userEmail)' is registered with id '\(authResult.user.uid)'")
            
            if let profilePicture = selectedProfilePicture {
                // Upload profile picture to Firebase Storage
                self.uploadProfilePicture(selectedImage: profilePicture) { result in
                    switch result {
                    case .success(let uploadedProfilePictureUrl):
                        // Create user after the image is uploaded successfully
                        self.createUser(with: authResult.user.uid, name: name, email: userEmail, profilePicture: uploadedProfilePictureUrl)
                        
                        // Automatically log in the newly registered user
                        self.login(email: userEmail, password: password)
                    case .failure(let error):
                        print("Error uploading profile picture: \(error)")
                    }
                }
            } else {
                // Use placeholder image URL if no image is selected
                let placeholderImageUrl = "https://firebasestorage.googleapis.com/v0/b/memorylane-mobileapp.appspot.com/o/placeholder-user.jpg?alt=media&token=4d4d5fce-ac35-4bc8-913c-b50d87d5c748"
                self.createUser(with: authResult.user.uid, name: name, email: userEmail, profilePicture: placeholderImageUrl)
                
                // Automatically log in the newly registered user
                self.login(email: userEmail, password: password)
            }
        }
    }
    
    // Upload image to Firebase Storage and provide the download URL
    func uploadProfilePicture(selectedImage: UIImage?, completion: @escaping (Result<String, Error>) -> Void) {
        // Ensure a valid image is provided
        guard let selectedImage = selectedImage else {
            // If no image is provided, invoke completion with an error
            completion(.failure(ImageUploadError.missingImage))
            return
        }
        
        // Resize the image before converting to data
        let resizedImage = resizeImage(image: selectedImage, targetSize: CGSize(width: 200, height: 200))
        guard let imageData = resizedImage.jpegData(compressionQuality: 0.8) else {
            // If image compression fails, invoke completion with an error
            completion(.failure(ImageUploadError.imageCompressionError))
            return
        }
        
        // Create references to Firebase Storage
        let storageRef = Storage.storage().reference()
        let fileRef = storageRef.child("profilePictures/\(UUID().uuidString).jpg")
        
        // Upload image data to Firebase Storage
        fileRef.putData(imageData, metadata: nil) { metadata, error in
            if let error = error {
                // If error during upload occurs, invoke completion with the error
                completion(.failure(error))
            } else {
                // If upload is successful, obtain the download URL
                fileRef.downloadURL { url, error in
                    guard let downloadURL = url else {
                        // If URL retrieval fails, invoke completion with the error
                        completion(.failure(error ?? ImageUploadError.missingImage))
                        return
                    }
                    
                    // Invoke completion with the success and the URL string
                    completion(.success(downloadURL.absoluteString))
                }
            }
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
    
    func createUser(with id: String, name: String, email: String, profilePicture: String) {
        // Create a FireUser object with the provided id, name and email
        let user = User(id: id, name: name, email: email, profilePicture: profilePicture)
        
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
    
    func loadExistingProfilePicture(completion: @escaping (UIImage?) -> Void) {
        guard let user = self.user else {
            completion(nil)
            return
        }
        guard let imageURL = URL(string: user.profilePicture) else {
            print("Invalid image URL")
            completion(nil)
            return
        }
        URLSession.shared.dataTask(with: imageURL) { data, response, error in
            if let data = data, let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    completion(image)
                }
            } else {
                print("Error loading image: \(error?.localizedDescription ?? "Unknown error")")
                completion(nil)
            }
        }.resume()
    }
    
    // Edit existing user
    func editUser(name: String, newProfilePicture: UIImage? = nil) {
        
        let userID = Auth.auth().currentUser?.uid
        let userRef = Firestore.firestore().collection("users").document(userID ?? "")
        
        var userData: [String: Any] = ["name": name]
        
        // Add the profile picture for updating if it has been passed
        if let newProfilePicture = newProfilePicture {
            // Upload the new profile picture to Firebase Storage
            self.uploadProfilePicture(selectedImage: newProfilePicture) { result in
                switch result {
                case .success(let uploadedProfilePictureUrl):
                    // Update the user data with the new profile picture URL
                    userData["profilePicture"] = uploadedProfilePictureUrl
                    
                    userRef.updateData(userData) { error in
                        if let error = error {
                            print("Error updating user: \(error.localizedDescription)")
                        } else {
                            print("User updated successfully")
                        }
                    }
                case .failure(let error):
                    print("Error uploading new profile picture: \(error)")
                }
            }
        } else {
            // No new profile picture provided, update user data without it
            userRef.updateData(userData) { error in
                if let error = error {
                    print("Error updating user: \(error.localizedDescription)")
                } else {
                    print("User updated successfully")
                    // Optional: Refresh the local user data if needed
                    self.fetchUser(with: userID!)
                }
            }
        }
    }
    
    func updateProfilePicture(selectedProfilePicture: UIImage?) {
        guard let profilePicture = selectedProfilePicture else {
            // If no profile picture is available, exit the function
            return
        }
        
        // Upload profile picture
        uploadProfilePicture(selectedImage: profilePicture) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(_):
                // If the upload was successful, update the user profile
                self.editUser(name: self.user?.name ?? "", newProfilePicture: profilePicture)
            case .failure(let error):
                print("Error uploading profile picture: \(error)")
            }
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
    
}
