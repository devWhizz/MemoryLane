//
//  SettingsView.swift
//  MemoryLane
//
//  Created by martin on 28.01.24.
//

import SwiftUI
import URLImage


struct ProfileView: View {
    
    @EnvironmentObject private var userViewModel: UserViewModel
    @EnvironmentObject private var memoryViewModel: MemoryViewModel
    
    // Dark mode preference stored in AppStorage
    @AppStorage("isDarkModeEnabled") private var isDarkModeEnabled: Bool = false
    
    // Set color scheme
    @Environment(\.colorScheme) var colorScheme
    
    @State private var isEditingName = false
    @State private var editedName = ""
    
    @State private var newProfilePicture = UIImage()
    @State private var showProfilePicturePicker = false
    @State private var existingProfilePicture: UIImage?
    @State private var saveButtonIsShowing = false
    @State private var isProfilePictureLoaded = false
    
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    HStack(spacing: 24){
                        ZStack(alignment: .topTrailing) {
                            // Display existing profile picture
                            if let existingProfilePicture = existingProfilePicture {
                                Image(uiImage: existingProfilePicture)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 125, height: 125)
                                    .clipShape(Circle())
                                    .overlay(Circle().stroke(colorScheme == .dark ? Color.orange : Color.blue, lineWidth: 2))
                                
                                // Icon to trigger image picker
                                Image(systemName: "pencil.circle.fill")
                                    .foregroundColor(colorScheme == .dark ? Color.orange : Color.blue)
                                    .font(.title)
                                    .offset(x:5)
                                    .onTapGesture {
                                        showProfilePicturePicker = true
                                    }
                                    .sheet(isPresented: $showProfilePicturePicker) {
                                        // Open image picker view
                                        SingleImagePicker(selectedImage: $existingProfilePicture, isPickerShowing: $showProfilePicturePicker)
                                            .onDisappear(){
                                                saveButtonIsShowing = true
                                            }
                                    }
                            }
                        }
                        if saveButtonIsShowing{
                            Button("saveImage", action: updateProfilePicture)
                                .foregroundColor(colorScheme == .dark ? Color.black : Color.white)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(colorScheme == .dark ? Color.orange : Color.blue)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                    }
                    .padding(.top, 16)
                    
                    HStack {
                        Button(action: {
                            if isEditingName {
                                // Save changes
                                userViewModel.editUser(name: editedName)
                            }
                            isEditingName.toggle()
                            editedName = userViewModel.user?.name ?? ""
                        }) {
                            Image(systemName: isEditingName ? "checkmark.circle.fill" : "pencil.circle.fill")
                                .foregroundColor(colorScheme == .dark ? Color.orange : Color.blue)
                        }
                        Text("userName:")
                        if isEditingName {
                            TextField("", text: $editedName)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                        } else {
                            Text(userViewModel.user?.name ?? "")
                        }
                        Spacer()
                    }
                    .font(.title3)
                    .padding(.top, 16)
                    
                    Text("emailAddress: \(userViewModel.user?.email ?? "")")
                    
                    Text("memoryCount: \(memoryViewModel.memories.count)")
                        .font(.title3)
                        .bold()
                        .padding(.vertical, 24)
                    
                    // Toggle for dark mode preference
                    Toggle("darkMode", isOn: $isDarkModeEnabled)
                        .toggleStyle(SwitchToggleStyle(tint: .orange))
                        .frame(width: 170)
                }
                
            }
            .padding()
            .navigationBarTitle("profile")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Image(systemName: "rectangle.portrait.and.arrow.forward")
                        .foregroundColor(.accentColor)
                        .onTapGesture {
                            // Trigger logout when the icon is tapped
                            userViewModel.logout()
                            memoryViewModel.removeListener()
                        }
                }
            }
            .onAppear {
                memoryViewModel.fetchMemories()
                
                if !isProfilePictureLoaded {
                    loadExistingProfilePicture()
                    isProfilePictureLoaded = true
                }
            }
        }
    }
    
    // Function to load existing image from Firebase Storage
    func loadExistingProfilePicture() {
        let user: User = self.userViewModel.user!
        guard let imageURL = URL(string: user.profilePicture) else {
            print("Invalid image URL")
            return
        }
        URLSession.shared.dataTask(with: imageURL) { data, response, error in
            if let data = data, let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    existingProfilePicture = image
                }
            } else {
                print("Error loading image: \(error?.localizedDescription ?? "Unknown error")")
            }
        }.resume()
    }
    
    func updateProfilePicture() {
        if let profilePicture = existingProfilePicture {
            userViewModel.uploadProfilePicture(selectedImage: profilePicture) { [self] result in
                switch result {
                case .success(_):
                    userViewModel.editUser(
                        name: userViewModel.user?.name ?? "",
                        newProfilePicture: profilePicture)
                case .failure(let error):
                    print("Error uploading profile picture: \(error)")
                }
            }
        }
    }
    
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
            .environmentObject(UserViewModel())
            .environmentObject(MemoryViewModel())
    }
}
