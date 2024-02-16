//
//  EditMemoryView.swift
//  MemoryLane
//
//  Created by martin on 22.01.24.
//

import SwiftUI

struct EditMemoryView: View {
    
    @ObservedObject var memoryViewModel: MemoryViewModel
    
    var memory: Memory
    
    // Store the new title of the memory
    @State private var newTitle = ""
    // Store the new description of the memory
    @State private var newDescription = ""
    @State private var newLocation = ""
    @State private var newCoverImage = ""
    @State private var newGaleryImages = [""]
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    TextField("Title", text: $newTitle)
                    TextField("Description", text: $newDescription)
                    TextField("Location", text: $newLocation)
                }
                Section {
                    Button("Aktualisieren") {
                        memoryViewModel.editMemory(memory: memory, newTitle: newTitle, newDescription: newDescription, newLocation: newLocation, newCoverImage: newCoverImage, newGalleryImages: newGaleryImages)
                    }
                }
            }
            .navigationTitle("Edit Memory")
            .onAppear {
                // Set initial values when the view appears
                newTitle = memory.title
                newDescription = memory.description
                newLocation = memory.location
            }
        }
    }
}

struct EditMemoryView_Previews: PreviewProvider {
    static var previews: some View {
        EditMemoryView(memoryViewModel: MemoryViewModel(), memory: exampleMemory)
    }
}

