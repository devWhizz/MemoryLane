//
//  RegisterView.swift
//  MemoryLane
//
//  Created by martin on 29.01.24.
//

import SwiftUI


struct RegisterView: View {
    
    @EnvironmentObject private var userViewModel: UserViewModel
    @EnvironmentObject var memoryViewModel: MemoryViewModel
    
    // Set color scheme
    @Environment(\.colorScheme) var colorScheme
    
    // Track user input
    @State private var name = ""
    @State private var email = ""
    @State private var password = ""
    @State var selectedProfilePicture: UIImage?
    
    // Control the presentation of the photo library
    @State private var isImagePickerShowing = false
    
    // Control the display of the alert
    @State private var showAlert = false
    
    // Control the presentation of the sheet itself
    @Binding var isPresented: Bool
    
    // Disable register button if profile picture, name, email or password is empty or password it invalid
    private var disableRegistration: Bool {
        name.isEmpty || email.isEmpty || !isValidInput()
    }
    
    var body: some View {
        NavigationView {
            VStack {
                Spacer()
                Text("createAccount")
                    .font(.title2)
                    .padding(.bottom, 16)
                // User input (Profile picture, Name, Email, Password)
                HStack{
                    HStack {
                        // Show the selected profile picture or the placeholder
                        if let selectedProfilePicture = selectedProfilePicture {
                            Image(uiImage: selectedProfilePicture)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 75, height: 75)
                                .padding(.trailing, 12)
                                .clipShape(Circle())
                                .overlay(
                                    Circle().stroke(colorScheme == .dark ? Color.orange : Color.blue, lineWidth: 2)
                                )
                        } else {
                            AsyncImage(url: URL(string: "https://firebasestorage.googleapis.com/v0/b/memorylane-mobileapp.appspot.com/o/placeholder-user.jpg?alt=media&token=4d4d5fce-ac35-4bc8-913c-b50d87d5c748")) { phase in
                                switch phase {
                                case .empty:
                                    Image(systemName: "person.circle.fill")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 50, height: 50)
                                        .clipped()
                                        .foregroundColor(.accentColor)
                                case .success(let image):
                                    // Loaded image
                                    image
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 75, height: 75)
                                        .clipShape(Circle())
                                        .overlay(
                                            Circle().stroke(colorScheme == .dark ? Color.orange : Color.blue, lineWidth: 2)
                                        )
                                case .failure:
                                    // Error state
                                    Image(systemName: "photo.fill")
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 75, height: 75)
                                        .clipShape(Circle())
                                        .overlay(
                                            Circle().stroke(colorScheme == .dark ? Color.orange : Color.blue, lineWidth: 2)
                                        )
                                @unknown default:
                                    // Handle future cases
                                    EmptyView()
                                }
                            }
                        }
                        
                        Button(action: {
                            isImagePickerShowing = true
                        }, label: {
                            Text("selectProfilePicture")
                                .foregroundColor(colorScheme == .dark ? Color.orange : Color.blue)
                                .padding(.leading, 12)
                        })
                        Spacer()
                    }
                    .sheet(isPresented: $isImagePickerShowing, content: {
                        SingleImagePicker(selectedImage: $selectedProfilePicture, isPickerShowing: $isImagePickerShowing)
                    })
                    
                }
                
                TextField("userName", text: $name)
                    .autocapitalization(.none)
                    .padding(10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(colorScheme == .dark ? .white : .gray, lineWidth: 1)
                    )
                    .padding(.top, 12)
                
                TextField("emailAddress", text: $email)
                    .autocapitalization(.none)
                    .keyboardType(.emailAddress)
                    .padding(10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(colorScheme == .dark ? .white : .gray, lineWidth: 1)
                    )
                
                SecureField("password", text: $password)
                    .autocapitalization(.none)
                    .padding(10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(colorScheme == .dark ? .white : .gray, lineWidth: 1)
                    )
                
                // Trigger user registration
                Button(action: {
                    if !password.isEmpty && password.count < 6 {
                        showAlert = true
                    } else {
                        uploadAndRegisterUser()
                    }
                }) {
                    Text("registerNow")
                        .disabled(disableRegistration)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(disableRegistration ? Color.gray : (colorScheme == .dark ? Color.orange : Color.blue))
                        .foregroundColor(disableRegistration ? Color.white : (colorScheme == .dark ? Color.black : Color.white))
                        .cornerRadius(10)
                        .padding(.vertical, 24)
                }
                .alert(isPresented: $showAlert) {
                    // Display alert for invalid input
                    Alert(title: Text("invalidInput"), message: Text("passwordTooShort"), dismissButton: .default(Text("OK")))
                }
                
                Spacer()
            }
            .padding(.horizontal, 24)
            .toolbar {
                // Toolbar icon to dismiss the sheet
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        isPresented = false
                    }) {
                        Image(systemName: "xmark.circle")
                            .foregroundColor(colorScheme == .dark ? .orange : .blue)
                    }
                }
            }
        }
    }
    
    func uploadAndRegisterUser() {
        if let profilePicture = selectedProfilePicture {
            // Upload profile picture to Firebase Storage
            memoryViewModel.uploadImageToFirebase(selectedImage: profilePicture) { [self] result in
                switch result {
                case .success(let uploadedProfilePictureUrl):
                    // Create user after image is uploaded successfully
                    register(profilePictureUrl: uploadedProfilePictureUrl)
                case .failure(let error):
                    print("Error uploading profile picture: \(error)")
                }
            }
        } else {
            // Use placeholder image URL if no image is selected
            let placeholderImageUrl = "https://firebasestorage.googleapis.com/v0/b/memorylane-mobileapp.appspot.com/o/placeholder-user.jpg?alt=media&token=4d4d5fce-ac35-4bc8-913c-b50d87d5c748"
            register(profilePictureUrl: placeholderImageUrl)
        }
    }
    
    
    // Perform user registration
    private func register(profilePictureUrl: String) {
        userViewModel.register(name: name, email: email, password: password, profilePicture: profilePictureUrl)
    }
    
    // Check the validity of user input
    private func isValidInput() -> Bool {
        let minCharacterCount = 6
        return password.count >= minCharacterCount
    }
}

struct RegisterView_Previews: PreviewProvider {
    static var previews: some View {
        RegisterView(isPresented: .constant(true))
    }
}
