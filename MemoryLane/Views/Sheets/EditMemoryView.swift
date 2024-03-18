//
//  EditMemoryView.swift
//  MemoryLane
//
//  Created by martin on 29.01.24.
//

import SwiftUI
import GooglePlaces
import Combine


struct EditMemoryView: View {
    
    @ObservedObject var memoryViewModel: MemoryViewModel
    
    // Control the presentation of the sheet itself
    @Binding var isPresented: Bool
    
    // Control the presentation of the photo library
    @State private var showCoverImagePicker = false
    @State private var showGalleryImagePicker = false
    
    // Set color scheme
    @Environment(\.colorScheme) var colorScheme
    
    // Memory object to display current details
    var memory: Memory
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    Picker("category", selection: $memoryViewModel.newSelectedCategory) {
                        ForEach(memoryViewModel.categories, id: \.self) { category in
                            Text(category).tag(category)
                        }
                    }
                    
                    TextField("title", text: $memoryViewModel.newTitle)
                    
                    VStack {
                        ZStack(alignment: .topLeading) {
                            TextEditor(text: $memoryViewModel.newDescription)
                                .frame(minHeight: 100)
                        }
                    }
                }
                
                Section {
                    DatePicker("date", selection: $memoryViewModel.newDate, displayedComponents: .date)
                }
                
                Section {
                    VStack(alignment: .leading) {
                        TextField("location", text: Binding(
                            get: {
                                // Use the content of locationInput as initial text
                                return memoryViewModel.newLocation.isEmpty ? memoryViewModel.locationInput : memoryViewModel.newLocation
                            },
                            set: {
                                // Update locationInput and newLocation on text input
                                memoryViewModel.locationInput = $0
                                memoryViewModel.newLocation = $0
                                memoryViewModel.getPlacePredictions(for: $0)
                            }
                        ))
                        .disableAutocorrection(true)
                        
                        if memoryViewModel.selectedLocationPrediction == nil || memoryViewModel.locationInput != memoryViewModel.selectedLocationPrediction?.attributedFullText.string {                            // Display list of suggested locations
                            ScrollView {
                                ForEach(memoryViewModel.locationPredictions, id: \.attributedPrimaryText.string) { prediction in
                                    VStack(alignment: .leading) {
                                        Text(prediction.attributedPrimaryText.string)
                                            .font(.headline)
                                            .foregroundColor(colorScheme == .dark ? Color.white : Color.black)
                                        
                                        Text(prediction.attributedSecondaryText?.string ?? "")
                                            .font(.subheadline)
                                            .foregroundColor(.gray)
                                    }
                                    .onTapGesture {
                                        self.memoryViewModel.selectEditedPlace(prediction)
                                        print("Chosen location \(memoryViewModel.locationInput)")
                                    }
                                    .frame(height: 50)
                                }
                            }
                            .background(Color.clear)
                            .cornerRadius(10)
                            .padding(.top, 5)
                            .frame(height: CGFloat(memoryViewModel.locationPredictions.count * 50))
                        }
                    }
                }
                
                Section {
                    VStack(alignment: .leading){
                        Text("changeCover")
                        ZStack(alignment: .topTrailing) {
                            // Display existing cover image
                            if let existingCoverImage = memoryViewModel.existingCoverImage {
                                Image(uiImage: existingCoverImage)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 200, height: 150)
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                            }
                            // Icon to trigger image picker
                            Image(systemName: "pencil.circle.fill")
                                .foregroundColor(colorScheme == .dark ? Color.orange : Color.blue)
                                .font(.title2)
                                .offset(x: 10, y: -10)
                                .onTapGesture {
                                    showCoverImagePicker = true
                                }
                                .sheet(isPresented: $showCoverImagePicker) {
                                    // Open image picker view
                                    SingleImagePicker(selectedImage: $memoryViewModel.existingCoverImage, isPickerShowing: $showCoverImagePicker)
                                }
                        }
                        .padding(.top, 12)
                    }
                }
                .listRowBackground(Color.clear)
                .padding(.leading, -16)
                .onAppear {
                    // Load existing cover image from Firebase Storage
                    loadExistingCoverImage()
                }
                
                Section {
                    VStack(alignment: .leading){
                        Text("changeGallery")
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack (spacing: 16) {
                                ForEach(memoryViewModel.existingGalleryImages.indices, id: \.self) { index in
                                    ZStack(alignment: .topTrailing) {
                                        if let image = memoryViewModel.existingGalleryImages[index] {
                                            Image(uiImage: image)
                                                .resizable()
                                                .scaledToFill()
                                                .frame(width: 200, height: 150)
                                                .cornerRadius(12)
                                            
                                            // Icon to trigger gallery image deletion
                                            Image(systemName: "x.circle.fill")
                                                .foregroundColor(colorScheme == .dark ? Color.orange : Color.blue)
                                                .font(.title2)
                                                .offset(x: 10, y: -10)
                                                .onTapGesture {
                                                    deleteGalleryImage(at: index)
                                                }
                                        }
                                    }
                                    .padding(.top, 12)
                                }
                                // Icon to trigger image picker
                                Button(action: {
                                    showGalleryImagePicker = true
                                }) {
                                    Image(systemName: "plus.circle.fill")
                                        .foregroundColor(colorScheme == .dark ? Color.orange : Color.blue)
                                        .font(.largeTitle)
                                        .padding(.leading, 16)
                                }
                                .sheet(isPresented: $showGalleryImagePicker, onDismiss: {
                                    // Add the selected images to existingGalleryImages when Picker is closed
                                    memoryViewModel.existingGalleryImages.append(contentsOf: memoryViewModel.selectedNewGalleryImages)
                                    // Reset selectedGalleryImages
                                    memoryViewModel.selectedNewGalleryImages = []
                                }) {
                                    // Open image picker view
                                    MultipleImagesPicker(selectedImages: $memoryViewModel.selectedNewGalleryImages, isPickerShowing: $showGalleryImagePicker)
                                }
                            }
                        }
                    }
                }
                .listRowBackground(Color.clear)
                .padding(.leading, -16)
                .padding(.top, -12)
                .onAppear {
                    // Load existing gallery images from Firebase Storage
                    if memoryViewModel.existingGalleryImages.isEmpty {
                        loadExistingGalleryImages()
                    }
                }
                
                // Update the memory
                Section {
                    Button("update") {
                        MemoryUploadManager.updateMemory(memoryViewModel, memory, memoryViewModel.newSelectedCategory, memoryViewModel.newTitle, memoryViewModel.newDescription, memoryViewModel.newDate, memoryViewModel.newLocation, memoryViewModel.existingCoverImage, memoryViewModel.existingGalleryImages.compactMap { $0 }) { success in
                            if success {
                                // Close sheet after saving
                                isPresented = false
                            }
                        }                    }
                    .listRowBackground(colorScheme == .dark ? Color.orange : Color.blue)
                    .foregroundColor(colorScheme == .dark ? Color.black : Color.white)
                    .frame(maxWidth: .infinity, alignment: .center)
                }
            }
            .navigationTitle("editMemory")
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
            .onAppear {
                // Capitalize 1st letter to display correct category in picker
                if let firstCharacter = memory.category.first {
                    memoryViewModel.newSelectedCategory = String(firstCharacter).capitalized + memory.category.dropFirst()
                }
                memoryViewModel.newTitle = memory.title
                memoryViewModel.newDescription = memory.description
                memoryViewModel.newDate = memory.date
                memoryViewModel.newLocation = memory.location
            }
        }
    }
    
    // Function to load existing image from Firebase Storage
    private func loadExistingCoverImage() {
        guard let imageURL = URL(string: memory.coverImage) else {
            print("Invalid image URL")
            return
        }
        
        URLSession.shared.dataTask(with: imageURL) { data, response, error in
            if let data = data, let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    memoryViewModel.existingCoverImage = image
                }
            } else {
                print("Error loading image: \(error?.localizedDescription ?? "Unknown error")")
            }
        }.resume()
    }
    
    // Function to load existing images from Firebase Storage
    private func loadExistingGalleryImages() {
        guard let galleryImageURLs = memory.galleryImages else {
            print("Gallery images URLs are nil")
            return
        }
        
        for imageURLString in galleryImageURLs {
            guard let imageURL = URL(string: imageURLString) else {
                print("Invalid image URL: \(imageURLString)")
                continue
            }
            
            URLSession.shared.dataTask(with: imageURL) { data, response, error in
                if let data = data, let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        memoryViewModel.existingGalleryImages.append(image)
                    }
                } else {
                    print("Error loading image: \(error?.localizedDescription ?? "Unknown error")")
                }
            }.resume()
        }
    }
    
    private func deleteGalleryImage(at index: Int) {
        memoryViewModel.existingGalleryImages.remove(at: index)
    }
}

struct EditMemoryView_Previews: PreviewProvider {
    static var previews: some View {
        EditMemoryView(memoryViewModel: MemoryViewModel(), isPresented: .constant(true), memory: Memory.exampleMemory)
    }
}
