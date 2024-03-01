//
//  MemoryDetailView.swift
//  MemoryLane
//
//  Created by martin on 30.01.24.
//

import SwiftUI
import URLImage


struct MemoryDetailView: View {
    
    // Observe changes in the MemoryViewModel
    @ObservedObject var memoryViewModel: MemoryViewModel
    
    // Control the visibility of the editMemory sheet
    @State private var isEditMemoryViewPresented = false
    
    @State private var showingDeleteAlert = false
    
    // Set color scheme
    @Environment(\.colorScheme) var colorScheme
    
    
    // Memory object to display details
    var memory: Memory
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // Display cover image
                if let coverImageURL = URL(string: memory.coverImage) {
                    URLImage(coverImageURL) { image in
                        ZStack(alignment: .bottomLeading) {
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .scaledToFill()
                                .frame(maxWidth: .infinity)
                                .frame(height: 220)
                                .clipped()
                            
                            Rectangle()
                                .fill(Color.black.opacity(0.5))
                                .frame(height: 50)
                            
                            Text(memory.title)
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                        }
                    }
                    
                    HStack {
                        Text(memory.date, style: .date)
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .padding(.horizontal)
                        
                        Spacer()
                        
                        Image(systemName: memory.isFavorite ? "heart.fill" : "heart")
                            .foregroundColor(memory.isFavorite ? .accentColor : .gray)
                            .padding(.horizontal)
                            .onTapGesture {
                                // Toggle the isFavorite status
                                memoryViewModel.toggleFavoriteStatus(for: memory)
                            }
                    }
                    .padding(.vertical, 12)
                    
                    Text(memory.description)
                        .font(.body)
                        .padding(.horizontal)
                    
                    // Display image gallery
                    if !memory.galleryImages!.isEmpty {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 16) {
                                ForEach(memory.galleryImages!, id: \.self) { imageUrl in
                                    if let galleryImageURL = URL(string: imageUrl) {
                                        URLImage(galleryImageURL) { image in
                                            image
                                                .resizable()
                                                .scaledToFill()
                                                .frame(width: 300, height: 185)
                                                .cornerRadius(8)
                                        }
                                        .padding(.vertical, 16)
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                    ZStack(alignment: .bottom) {
                        // Display Google Map with the memory location
                        GoogleMapViewWithControls(address: memory.location)
                        Text("\(memory.location)")
                            .font(.headline)
                            .foregroundColor(colorScheme == .dark ? .white : .black)
                            .multilineTextAlignment(.center)
                            .padding(10)
                            .background(colorScheme == .dark ? .black : .white)
                            .cornerRadius(8)
                            .shadow(radius: 5)
                            .padding(.horizontal, 20)
                            .padding(.bottom, 20)
                    }
                }
                Spacer()
                
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                // Share memory
                Button(action: shareMemory) {
                    Image(systemName: "square.and.arrow.up")
                }
                // Trigger the EditMemory sheet
                Button(action: editMemory) {
                    Image(systemName: "slider.horizontal.2.gobackward")
                }
                // Delete memory
                Button(action: {
                    showingDeleteAlert = true
                }) {
                    Image(systemName: "trash")
                }
                .alert(isPresented: $showingDeleteAlert) {
                    Alert(
                        title: Text("deleteTitle"),
                        message: Text("deletemessage"),
                        primaryButton: .destructive(Text("confirm")) {
                            memoryViewModel.deleteMemory(memory: memory)
                        },
                        secondaryButton: .cancel()
                    )
                }
            }
            .sheet(isPresented: $isEditMemoryViewPresented) {
                EditMemoryView(memoryViewModel: memoryViewModel, isPresented: $isEditMemoryViewPresented, memory: memory)
            }
        }
    }
    
    private func editMemory() {
        isEditMemoryViewPresented.toggle()
    }
    
    private func shareMemory() {
        guard memory.galleryImages != nil else {
            // Handle the case when galleryImages is nil
            return
        }
        
        // Format memory details as a string
        let formattedDetails = formattedMemoryDetails()
        
        // Create UIActivityViewController with the formatted details
        let activityViewController = UIActivityViewController(activityItems: [formattedDetails], applicationActivities: nil)
        
        // Present the UIActivityViewController
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else { return }
        windowScene.windows.first?.rootViewController?.present(activityViewController, animated: true, completion: nil)
    }
    
    // Format memory details into a string
    func formattedMemoryDetails() -> String {
        let title = memory.title
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .long
        
        let formattedDate = dateFormatter.string(from: memory.date)
        
        let description = memory.description
        let location = memory.location
        let coverImageURL: String
        
        // Check if the coverImage URL is valid
        if let url = URL(string: memory.coverImage) {
            coverImageURL = url.absoluteString
        } else {
            coverImageURL = "N/A"
        }
        
        var galleryImagesString = "No gallery images"
        
        if let galleryImages = memory.galleryImages {
            // Join gallery images into a formatted string
            galleryImagesString = galleryImages.joined(separator: "\n\n")
        }
        
        // Final formatted string with all memory details
        let formattedString =
            """
            Hey there, check out this Memory:
            
            Title: \(title)
            Date: \(formattedDate)
            Location: \(location)
            
            Description:
            \(description)
            
            Cover Image:
            \(coverImageURL)
            
            Gallery Images:
            \(galleryImagesString)
            """
        
        return formattedString
    }
    
}

struct MemoryDetailView_Previews: PreviewProvider {
    static var previews: some View {
        let memoryViewModel = MemoryViewModel()
        MemoryDetailView(memoryViewModel: memoryViewModel, memory: Memory.exampleMemory)
    }
}
