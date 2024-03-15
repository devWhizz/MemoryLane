//
//  AddMemoryView.swift
//  MemoryLane
//
//  Created by martin on 29.01.24.
//

import SwiftUI
import PhotosUI
import FirebaseStorage
import GooglePlaces
import Combine


struct AddMemoryView: View {
    
    @EnvironmentObject var memoryViewModel: MemoryViewModel
    
    // Control the presentation of the sheet
    @Binding var isPresented: Bool
    
    // Control the presentation of the photo libraries
    @State var isCoverImagePickerShowing = false
    @State var isGalleryImagePickerShowing = false
    
    // Set color scheme
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        NavigationView {
            Form {
                // Choose category
                Section {
                    Picker("category", selection: $memoryViewModel.selectedCategory) {
                        ForEach(memoryViewModel.categories, id: \.self) { category in
                            Text(category).tag(category)
                        }
                    }
                    TextField("title", text: $memoryViewModel.title)
                    VStack {
                        ZStack(alignment: .topLeading) {
                            if memoryViewModel.description.isEmpty {
                                Text("description")
                                    .foregroundColor(.gray.opacity(0.6))
                                    .padding(.top, 10)
                                
                            }
                            TextEditor(text: $memoryViewModel.description)
                                .frame(minHeight: 100)
                        }
                    }
                }
                
                // Pick date
                Section {
                    DatePicker("date", selection: $memoryViewModel.date, displayedComponents: .date)
                }
                
                // Choose location
                Section {
                    VStack (alignment: .leading) {
                        TextField("location", text: $memoryViewModel.locationInput)
                            .disableAutocorrection(true)
                        // Trigger getPlacePredictions() when the input changes
                            .onChange(of: memoryViewModel.locationInput) {
                                memoryViewModel.getPlacePredictions(for: memoryViewModel.locationInput)
                            }
                        
                        // Display suggested locations if available
                        if !memoryViewModel.locationPredictions.isEmpty {
                            // Display list of suggested locations
                            ScrollView {
                                // Loop through the location predictions
                                ForEach(memoryViewModel.locationPredictions, id: \.attributedPrimaryText.string) { prediction in
                                    VStack(alignment: .leading) {
                                        Text(prediction.attributedPrimaryText.string)
                                            .font(.headline)
                                            .foregroundColor(colorScheme == .dark ? Color.white : Color.black)
                                        Text(prediction.attributedSecondaryText?.string ?? "")
                                            .font(.subheadline)
                                            .foregroundColor(.gray)
                                    }
                                    // Trigger selectPlace() when a prediction is tapped
                                    .onTapGesture {
                                        self.memoryViewModel.selectPlace(prediction)
                                        print("Chosen location \(memoryViewModel.locationInput)")
                                    }
                                    .frame(height: 50)
                                }
                            }
                            .background(Color.clear)
                            .cornerRadius(10)
                            .padding(.top, 5)
                            // Adjust the height of the suggestion list based on the number of predictions
                            .frame(height: CGFloat(memoryViewModel.locationPredictions.count * 30))
                        }
                    }
                }
                
                // Pick cover image
                Section {
                    HStack{
                        Button(action: {
                            isCoverImagePickerShowing = true
                        }, label: {
                            Image(systemName: "photo.fill")
                                .foregroundColor(colorScheme == .dark ? Color.orange : Color.blue)
                        })
                        Button(action: {
                            isCoverImagePickerShowing = true
                        }, label: {
                            Text("selectCoverImage")
                                .foregroundColor(colorScheme == .dark ? Color.orange : Color.blue)
                        })
                        Spacer()
                        if memoryViewModel.selectedCoverImage != nil {
                            Image(uiImage: memoryViewModel.selectedCoverImage!)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 100, height: 75)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                    }
                    .sheet(isPresented: $isCoverImagePickerShowing, content: {
                        SingleImagePicker(selectedImage: $memoryViewModel.selectedCoverImage, isPickerShowing: $isCoverImagePickerShowing)
                    })
                }
                
                // Pick gallery images
                Section{
                    VStack (alignment: .leading){
                        HStack{
                            Button(action: {
                                isGalleryImagePickerShowing = true
                            }, label: {
                                Image(systemName: "photo.fill.on.rectangle.fill")
                                    .foregroundColor(colorScheme == .dark ? Color.orange : Color.blue)
                                
                            })
                            Button(action: {
                                isGalleryImagePickerShowing = true
                            }, label: {
                                Text("selectGalleryImages")
                                    .foregroundColor(colorScheme == .dark ? Color.orange : Color.blue)
                                
                            })
                            Spacer()
                        }
                        if !memoryViewModel.selectedGalleryImages.isEmpty {
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack {
                                    ForEach(memoryViewModel.selectedGalleryImages, id: \.self) { image in
                                        Image(uiImage: image)
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: 100, height: 75)
                                            .clipShape(RoundedRectangle(cornerRadius: 12))
                                    }
                                }
                            }
                            .padding(.top, 8)
                        }
                    }
                    .sheet(isPresented: $isGalleryImagePickerShowing, content: {
                        MultipleImagesPicker(selectedImages: $memoryViewModel.selectedGalleryImages, isPickerShowing: $isGalleryImagePickerShowing)
                    })
                }
                
                // Set favorite status
                Section {
                    Toggle("favoriteMemory", isOn: $memoryViewModel.isFavorite)
                        .toggleStyle(SwitchToggleStyle(tint: colorScheme == .dark ? .orange : .blue))
                }
                
                // Create and save the new memory
                Section {
                    Button("save") {
                        MemoryUploadManager.uploadAndCreateMemory(
                            memoryViewModel: memoryViewModel,
                            title: memoryViewModel.title,
                            description: memoryViewModel.description,
                            selectedCategory: memoryViewModel.selectedCategory,
                            date: memoryViewModel.date,
                            location: memoryViewModel.location,
                            isFavorite: memoryViewModel.isFavorite,
                            selectedCoverImage: memoryViewModel.selectedCoverImage,
                            selectedGalleryImages: memoryViewModel.selectedGalleryImages
                        ) { success in
                            if success {
                                // Close sheet after saving
                                isPresented = false
                            } else {
                                // Handle failure if needed
                            }
                        }
                    }
                    .disabled(disableSaving)
                    .listRowBackground(disableSaving ? Color.gray : (colorScheme == .dark ? Color.orange : Color.blue))
                    .foregroundColor(disableSaving ? Color.white : (colorScheme == .dark ? Color.black : Color.white))
                    .frame(maxWidth: .infinity, alignment: .center)
                }
            }
            .navigationTitle("addNewMemory")
            .accentColor(colorScheme == .dark ? .orange : .blue)
            .toolbar {
                // Close button in the navigation bar
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        isPresented = false
                    }) {
                        Image(systemName: "xmark.circle")
                            .foregroundColor(colorScheme == .dark ? Color.orange : Color.blue)
                    }
                }
            }
        }
    }
    
    // Disable save button if not all necessary fields are filled in
    private var disableSaving: Bool {
        memoryViewModel.selectedCategory.isEmpty || memoryViewModel.title.isEmpty || memoryViewModel.location.isEmpty || memoryViewModel.selectedCoverImage == nil
    }
}

struct AddMemoryView_Previews: PreviewProvider {
    static var previews: some View {
        AddMemoryView(isPresented: .constant(true))
    }
}
