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
    
    // Control the presentation of the photo library
    @State private var isImagePickerShowing = false
    
    // Control the display of the alert
    @State private var showAlert = false
    
    // Control the presentation of the sheet itself
    @Binding var isPresented: Bool
    
    // Disable register button if profile picture, name, email or password is empty or password it invalid
    private var disableRegistration: Bool {
        userViewModel.registerName.isEmpty || userViewModel.registerEmail.isEmpty || !isValidInput()
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
                        if let selectedProfilePicture = userViewModel.selectedProfilePicture {
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
                        SingleImagePicker(selectedImage: $userViewModel.selectedProfilePicture, isPickerShowing: $isImagePickerShowing)
                    })
                    
                }
                
                TextField("userName", text: $userViewModel.registerName)
                    .autocapitalization(.none)
                    .padding(10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(colorScheme == .dark ? .white : .gray, lineWidth: 1)
                    )
                    .padding(.top, 12)
                
                TextField("emailAddress", text: $userViewModel.registerEmail)
                    .autocapitalization(.none)
                    .keyboardType(.emailAddress)
                    .padding(10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(colorScheme == .dark ? .white : .gray, lineWidth: 1)
                    )
                
                SecureField("password", text: $userViewModel.registerPassword)
                    .autocapitalization(.none)
                    .padding(10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(colorScheme == .dark ? .white : .gray, lineWidth: 1)
                    )
                
                // Trigger user registration
                Button(action: {
                    if !userViewModel.registerPassword.isEmpty && userViewModel.registerPassword.count < 6 {
                        showAlert = true
                    } else {
                        register()
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
    
    // Check the validity of user input
    private func isValidInput() -> Bool {
        let minCharacterCount = 6
        return userViewModel.registerPassword.count >= minCharacterCount
    }
    
    // Perform user login
    private func register() {
        userViewModel.registerUser(name: userViewModel.registerName, email: userViewModel.registerEmail, password: userViewModel.registerPassword, selectedProfilePicture: userViewModel.selectedProfilePicture)
    }
    
}

struct RegisterView_Previews: PreviewProvider {
    static var previews: some View {
        RegisterView(isPresented: .constant(true))
    }
}
