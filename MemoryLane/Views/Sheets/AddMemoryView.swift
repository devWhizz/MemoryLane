//
//  AddMemoryView.swift
//  MemoryLane
//
//  Created by martin on 22.01.24.
//

import SwiftUI
import PhotosUI

struct AddMemoryView: View {
    
    @ObservedObject var memoryViewModel = MemoryViewModel()
    
    let categories = ["Vacations", "Birthdays", "Holidays", "Achievements", "Adventures", "Family", "Creativity"]
    
    // State variables to store the details of the new phone
    @State private var id = UUID()
    @State private var UserId = UUID()
    @State private var selectedCategory = "Vacations"
    @State private var title = ""
    @State private var description = ""
    @State private var date = Date()
    @State private var location = ""
    @State private var isFavorite = false
    @State private var coverImage = ""
    @State private var galeryImage = ""
    
    @Binding var isPresented: Bool
    
    // Disable save button if email or password is empty
    private var disableAuthentication: Bool {
        selectedCategory.isEmpty || title.isEmpty || description.isEmpty || location.isEmpty || coverImage.isEmpty
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    Picker("Category", selection: $selectedCategory) {
                        ForEach(categories, id: \.self) {
                            Text($0)
                        }
                    }
                    TextField("Title", text: $title)
                    TextField("Description", text: $description)
                }
                Section {
                    DatePicker("Date", selection: $date, displayedComponents: .date)
                    TextField("Location", text: $location)
                    
                }
                Section {
                    Toggle("Favorite Memory", isOn: $isFavorite)
                }
                Section{
//                    TextField("Image-URL", text: $coverImage)
                    PhotosPicker(selection: $memoryViewModel.selectedImage, matching: .images, photoLibrary: .shared()) {
                        Text("Choose cover image")
                    }
                }
                                        
                Section {
                    Button("Save") {
                        memoryViewModel.createMemory(title: title, description: description, category: selectedCategory, date: date, location: location, isFavorite: isFavorite, coverImage: coverImage, galeryImages: [galeryImage])

                        isPresented = false
                        
                    }
                    .disabled(disableAuthentication)

                }
                
            }
            .navigationTitle("Add new Memory")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        isPresented = false
                    }) {
                        Image(systemName: "xmark.circle")
                    }
                }
            }
            
            
        }
    }
}

struct AddMemoryView_Previews: PreviewProvider {
    static var previews: some View {
        let memoryViewModel = MemoryViewModel()
        AddMemoryView(isPresented: .constant(true))
            .environmentObject(memoryViewModel)
    }
}

