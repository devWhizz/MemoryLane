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
    
    // Control the visibility of the "AddMemory" sheet
    @State private var isEditMemoryViewPresented = false
    
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
                            .foregroundColor(memory.isFavorite ? .blue : .gray)
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
                            HStack(spacing: 8) {
                                ForEach(memory.galleryImages!, id: \.self) { imageUrl in
                                    if let galleryImageURL = URL(string: imageUrl) {
                                        URLImage(galleryImageURL) { image in
                                            image
                                                .resizable()
                                                .scaledToFill()
                                                .frame(width: 150, height: 100)
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
                        GoogleMapView(address: memory.location)
                            .frame(height: 300)
                        Text("\(memory.location)")
                            .font(.headline)
                            .padding(10)
                            .background(Color.white)
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
                // Trigger the EditMemory sheet
                Button(action: editMemory) {
                    Image(systemName: "slider.horizontal.2.gobackward")
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
    
}

struct MemoryDetailView_Previews: PreviewProvider {
    static var previews: some View {
        
        let memoryViewModel = MemoryViewModel()
        MemoryDetailView(memoryViewModel: memoryViewModel, memory: Memory.exampleMemory)
    }
}
