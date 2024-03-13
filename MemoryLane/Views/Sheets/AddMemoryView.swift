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
    
    // Store the details of the new memory
    @State private var id = UUID()
    @State private var UserId = UUID()
    @State private var selectedCategory = ""
    @State private var title = ""
    @State private var description = ""
    @State private var date = Date()
    @State private var location = ""
    @State private var isFavorite = false
    
    @State var selectedCoverImage: UIImage?
    @State private var selectedGalleryImages: [UIImage] = []
    
    @State private var locationInput = ""
    @State private var locationPredictions: [GMSAutocompletePrediction] = []
    @State private var selectedLocationPrediction: GMSAutocompletePrediction?
    
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
                    Picker("category", selection: $selectedCategory) {
                        ForEach(categories, id: \.self) {
                            Text($0)
                        }
                    }
                    TextField("title", text: $title)
                    VStack {
                        ZStack(alignment: .topLeading) {
                            if description.isEmpty {
                                Text("description")
                                    .foregroundColor(.gray.opacity(0.6))
                                    .padding(.top, 10)
                                
                            }
                            TextEditor(text: $description)
                                .frame(minHeight: 100)
                        }
                    }
                }
                
                // Pick date
                Section {
                    DatePicker("date", selection: $date, displayedComponents: .date)
                }
                
                // Choose location
                Section {
                    VStack (alignment: .leading) {
                        TextField("location", text: $locationInput)
                            .disableAutocorrection(true)
                        // Trigger getPlacePredictions() when the input changes
                            .onReceive(Just(locationInput)) { _ in
                                getPlacePredictions(for: locationInput)
                            }
                        // Display suggested locations if available
                        if !locationPredictions.isEmpty {
                            // Display list of suggested locations
                            ScrollView {
                                // Loop through the location predictions
                                ForEach(locationPredictions, id: \.attributedPrimaryText.string) { prediction in
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
                                        self.selectPlace(prediction)
                                        print("Chosen location \(locationInput)")
                                    }
                                    .frame(height: 50)
                                }
                            }
                            .background(Color.clear)
                            .cornerRadius(10)
                            .padding(.top, 5)
                            // Adjust the height of the suggestion list based on the number of predictions
                            .frame(height: CGFloat(locationPredictions.count * 30))
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
                        if selectedCoverImage != nil {
                            Image(uiImage: selectedCoverImage!)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 100, height: 75)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                    }
                    .sheet(isPresented: $isCoverImagePickerShowing, content: {
                        SingleImagePicker(selectedImage: $selectedCoverImage, isPickerShowing: $isCoverImagePickerShowing)
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
                        if !selectedGalleryImages.isEmpty {
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack {
                                    ForEach(selectedGalleryImages, id: \.self) { image in
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
                        MultipleImagesPicker(selectedImages: $selectedGalleryImages, isPickerShowing: $isGalleryImagePickerShowing)
                    })
                }
                
                // Set favorite status
                Section {
                    Toggle("favoriteMemory", isOn: $isFavorite)
                        .toggleStyle(SwitchToggleStyle(tint: colorScheme == .dark ? .orange : .blue))
                }
                
                // Create and save the new memory
                Section {
                    Button("save") {
                        uploadAndCreateMemory()
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
    
    // Create a session token for Google Places API
    let sessionToken = GMSAutocompleteSessionToken.init()
    
    // Fetch place predictions for a given query
    func getPlacePredictions(for query: String) {
        let placesClient = GMSPlacesClient.shared()
        // Use the findAutocompletePredictions method to retrieve place predictions
        placesClient.findAutocompletePredictions(
            fromQuery: query,
            filter: nil,
            sessionToken: sessionToken,
            callback: { (results, error) in
                // Check for errors during the API request
                if let error = error {
                    print("Error fetching place predictions: \(error)")
                    return
                }
                // If successful, update the locationPredictions array with the results
                if let results = results {
                    self.locationPredictions = results
                }
            }
        )
    }
    
    // Handle the selection of a place prediction
    private func selectPlace(_ prediction: GMSAutocompletePrediction) {
        self.selectedLocationPrediction = prediction
        self.location = prediction.attributedFullText.string
        self.locationInput = prediction.attributedFullText.string
        self.locationPredictions = []
    }
    
    // Disable save button if not all necessary fields are filled in
    private var disableSaving: Bool {
        selectedCategory.isEmpty || title.isEmpty || location.isEmpty || selectedCoverImage == nil
    }
    
    func uploadAndCreateMemory() {
        if let coverImage = selectedCoverImage {
            // Upload cover image to Firebase Storage
            memoryViewModel.uploadImageToFirebase(selectedImage: coverImage) { [self] result in
                switch result {
                case .success(let uploadedCoverImageUrl):
                    // Cover image uploaded successfully, now handle gallery images
                    var galleryImageUrls: [String] = []
                    
                    // Check if gallery images are selected
                    if !selectedGalleryImages.isEmpty {
                        // Upload each gallery image to Firebase Storage
                        let dispatchGroup = DispatchGroup()
                        
                        for galleryImage in selectedGalleryImages {
                            dispatchGroup.enter()
                            
                            memoryViewModel.uploadImageToFirebase(selectedImage: galleryImage) { result in
                                switch result {
                                case .success(let uploadedGalleryImageUrl):
                                    // Gallery image uploaded successfully, append URL to galleryImageUrls
                                    galleryImageUrls.append(uploadedGalleryImageUrl)
                                case .failure(let error):
                                    print("Error uploading gallery image: \(error)")
                                }
                                
                                dispatchGroup.leave()
                            }
                        }
                        
                        // Notify when all gallery images are uploaded
                        dispatchGroup.notify(queue: .main) {
                            // Create memory after all images are uploaded successfully
                            createMemory(coverImageUrl: uploadedCoverImageUrl, galleryImageUrls: galleryImageUrls)
                        }
                    } else {
                        // No gallery images selected, create memory with cover image only
                        createMemory(coverImageUrl: uploadedCoverImageUrl, galleryImageUrls: galleryImageUrls)
                    }
                    
                case .failure(let error):
                    print("Error uploading cover image: \(error)")
                }
            }
        }
    }
    
    // Create memory after all images are uploaded
    private func createMemory(coverImageUrl: String, galleryImageUrls: [String]) {
        memoryViewModel.createMemory(
            title: title,
            description: description,
            category: selectedCategory,
            date: date,
            location: location,
            isFavorite: isFavorite,
            coverImage: coverImageUrl,
            galleryImages: galleryImageUrls
        )
        
        // Close sheet after saving
        isPresented = false
    }
}

struct AddMemoryView_Previews: PreviewProvider {
    static var previews: some View {
        AddMemoryView(isPresented: .constant(true))
    }
}
