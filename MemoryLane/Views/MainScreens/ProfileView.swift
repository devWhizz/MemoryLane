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
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    HStack(spacing: 24){
                        ZStack(alignment: .topTrailing) {
                            // Display existing profile picture
                            if let existingProfilePicture = userViewModel.existingProfilePicture {
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
                                        userViewModel.showProfilePicturePicker = true
                                    }
                                    .sheet(isPresented: $userViewModel.showProfilePicturePicker) {
                                        // Open image picker view
                                        SingleImagePicker(selectedImage: $userViewModel.existingProfilePicture, isPickerShowing: $userViewModel.showProfilePicturePicker)
                                            .onDisappear(){
                                                userViewModel.saveButtonIsShowing = true
                                            }
                                    }
                            }
                        }
                        if userViewModel.saveButtonIsShowing{
                            Button("saveImage") {
                                userViewModel.updateProfilePicture(existingProfilePicture: userViewModel.existingProfilePicture)
                                userViewModel.saveButtonIsShowing = false
                            }
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
                            if userViewModel.isEditingName {
                                // Save changes
                                userViewModel.editUser(name: userViewModel.editedName)
                            }
                            userViewModel.isEditingName.toggle()
                            userViewModel.editedName = userViewModel.user?.name ?? ""
                        }) {
                            Image(systemName: userViewModel.isEditingName ? "checkmark.circle.fill" : "pencil.circle.fill")
                                .foregroundColor(colorScheme == .dark ? Color.orange : Color.blue)
                        }
                        Text("userName:")
                        if userViewModel.isEditingName {
                            TextField("", text: $userViewModel.editedName)
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
                
                if !userViewModel.isProfilePictureLoaded {
                    userViewModel.loadExistingProfilePicture { image in
                        if let image = image {
                            userViewModel.existingProfilePicture = image
                        }
                        userViewModel.isProfilePictureLoaded = true
                    }
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
