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
    
    // Control the presentation of the sheet
    @Binding var isPresented: Bool
    
    // Store new memory details
    @State private var newSelectedCategory = ""
    @State private var newTitle = ""
    @State private var newDescription = ""
    @State private var newDate = Date()
    @State private var newLocation = ""
    @State private var newCoverImage = ""
    //    @State private var newGalleryImages = [""]
    
    @State private var existingCoverImage: UIImage?
    @State private var showCoverImagePicker = false
    
    @State private var existingGalleryImages: [UIImage?] = []
    @State private var showGalleryImagePicker = false
    
    
    
    // Autocomplete predictions for location
    @State private var locationInput = ""
    @State private var locationPredictions: [GMSAutocompletePrediction] = []
    
    // Set color scheme
    @Environment(\.colorScheme) var colorScheme
    
    // Memory object to display current details
    var memory: Memory
    
    // Set category choices
    let categories = [
        NSLocalizedString("vacations", comment: ""),
        NSLocalizedString("birthdays", comment: ""),
        NSLocalizedString("holidays", comment: ""),
        NSLocalizedString("achievements", comment: ""),
        NSLocalizedString("adventures", comment: ""),
        NSLocalizedString("family", comment: ""),
        NSLocalizedString("creativity", comment: "")
    ]
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    Picker("category", selection: $newSelectedCategory) {
                        ForEach(categories, id: \.self) { category in
                            Text(category).tag(category)
                        }
                    }
                    
                    TextField("title", text: $newTitle)
                    
                    VStack {
                        ZStack(alignment: .topLeading) {
                            TextEditor(text: $newDescription)
                                .frame(minHeight: 100)
                        }
                    }
                }
                
                Section {
                    DatePicker("date", selection: $newDate, displayedComponents: .date)
                }
                
                Section {
                    VStack(alignment: .leading) {
                        TextField("location", text: Binding(
                            get: {
                                // Use the content of locationInput as initial text
                                return newLocation.isEmpty ? locationInput : newLocation
                            },
                            set: {
                                // Update locationInput and newLocation on text input
                                locationInput = $0
                                newLocation = $0
                                getPlacePredictions(for: $0)
                            }
                        ))
                        
                        if !locationPredictions.isEmpty {
                            // Display list of suggested locations
                            ScrollView {
                                ForEach(locationPredictions, id: \.attributedPrimaryText.string) { prediction in
                                    VStack(alignment: .leading) {
                                        Text(prediction.attributedPrimaryText.string)
                                            .font(.headline)
                                            .foregroundColor(colorScheme == .dark ? Color.white : Color.black)
                                        
                                        Text(prediction.attributedSecondaryText?.string ?? "")
                                            .font(.subheadline)
                                            .foregroundColor(.gray)
                                    }
                                    .onTapGesture {
                                        self.selectPlace(prediction)
                                        print("Chosen location \(locationInput)")
                                    }
                                    .frame(height: 50)
                                }
                            }
                            .background(Color.clear)
                            .cornerRadius(10)
                            .padding(.top, 5)
                            .frame(height: CGFloat(locationPredictions.count * 50))
                        }
                    }
                }
                
                Section {
                    VStack(alignment: .leading){
                        Text("changeCover")
                        ZStack(alignment: .topTrailing) {
                            // Existing image
                            if let existingCoverImage = existingCoverImage {
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
                                    CoverImagePicker(selectedImage: $existingCoverImage, isPickerShowing: $showCoverImagePicker)
                                }
                        }
                    }
                }
                .listRowBackground(Color.clear)
                .onAppear {
                    // Load existing cover image from Firebase Storage
                    loadExistingCoverImage()
                }
                
                Section {
                    VStack(alignment: .leading){
                        Text("changeGallery")
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack {
                                ForEach(existingGalleryImages, id: \.self) { image in
                                    if let image = image {
                                        Image(uiImage: image)
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: 200, height: 150)
                                            .cornerRadius(8)
                                    }
                                    // Icon to trigger image picker
//                                    Image(systemName: "pencil.circle.fill")
//                                        .foregroundColor(colorScheme == .dark ? Color.orange : Color.blue)
//                                        .font(.title2)
                                }
                            }
                        }
                    }
                }
                .listRowBackground(Color.clear)
                .onAppear {
                    // Load existing cover image from Firebase Storage
                    if existingGalleryImages.isEmpty {
                        loadExistingGalleryImages()
                    }
                }
                
                
                // Update the memory
                Section {
                    Button("update") {
                        updateMemory()
                    }
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
                    newSelectedCategory = String(firstCharacter).capitalized + memory.category.dropFirst()
                }
                newTitle = memory.title
                newDescription = memory.description
                newDate = memory.date
                newLocation = memory.location
            }
        }
    }
    
    // Create a session token for Google Places API
    let sessionToken = GMSAutocompleteSessionToken.init()
    
    // Fetch place predictions for a given query
    func getPlacePredictions(for query: String) {
        let placesClient = GMSPlacesClient.shared()
        placesClient.findAutocompletePredictions(
            fromQuery: query,
            filter: nil,
            sessionToken: sessionToken,
            callback: { (results, error) in
                if let error = error {
                    print("Error fetching place predictions: \(error)")
                    return
                }
                if let results = results {
                    self.locationPredictions = results
                }
            }
        )
    }
    
    // Handle the selection of a place prediction
    private func selectPlace(_ prediction: GMSAutocompletePrediction) {
        self.locationPredictions = []
        self.locationInput = prediction.attributedFullText.string
        self.newLocation = prediction.attributedFullText.string
    }
    
    // Function to load existing image from Firebase Storage
    func loadExistingCoverImage() {
        guard let imageURL = URL(string: memory.coverImage) else {
            print("Invalid image URL")
            return
        }
        
        URLSession.shared.dataTask(with: imageURL) { data, response, error in
            if let data = data, let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    existingCoverImage = image
                }
            } else {
                print("Error loading image: \(error?.localizedDescription ?? "Unknown error")")
            }
        }.resume()
    }
    
    // Function to load existing images from Firebase Storage
    func loadExistingGalleryImages() {
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
                        existingGalleryImages.append(image)
                    }
                } else {
                    print("Error loading image: \(error?.localizedDescription ?? "Unknown error")")
                }
            }.resume()
        }
    }
    
    func updateMemory() {
        if let coverImage = existingCoverImage {
            // Upload cover image to Firebase Storage
            memoryViewModel.uploadImageToFirebase(selectedImage: coverImage) { [self] result in
                switch result {
                case .success(let uploadedCoverImageUrl):
                    // Update memory with the new cover image
                    memoryViewModel.editMemory(
                        memory: memory,
                        newCategory: newSelectedCategory,
                        newTitle: newTitle,
                        newDescription: newDescription,
                        newDate: newDate,
                        newLocation: newLocation,
                        newCoverImage: uploadedCoverImageUrl
                    )
                case .failure(let error):
                    print("Error uploading cover image: \(error)")
                }
            }
        }
        // Close sheet after saving
        isPresented = false
    }
}
//
//struct EditMemoryView_Previews: PreviewProvider {
//    static var previews: some View {
//        EditMemoryView(memoryViewModel: MemoryViewModel(), isPresented: .constant(true), memory: Memory.exampleMemory)
//    }
//}

