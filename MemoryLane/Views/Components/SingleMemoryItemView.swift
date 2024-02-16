//
//  FavoritesItemView.swift
//  MemoryLane
//
//  Created by martin on 01.02.24.
//

import SwiftUI

struct SingleMemoryItemView: View {
    
    let memory: Memory
    
    var body: some View {
        HStack {
            // Use AsyncImage for loading images from URLs
            AsyncImage(url: URL(string: memory.coverImage)) { phase in
                switch phase {
                case .empty:
                    Image(systemName: "photo.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 50, height: 50)
                        .clipped()
                        .foregroundColor(.blue)
                case .success(let image):
                    // Loaded image
                    image
                        .resizable()
                        .scaledToFill()
                        .frame(width: 150, height: 100)
                        .clipShape(
                            .rect(
                                topLeadingRadius: 12,
                                bottomLeadingRadius: 12,
                                bottomTrailingRadius: 0,
                                topTrailingRadius: 0
                            )
                        )
                case .failure:
                    // Error state
                    Image(systemName: "photo.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 50, height: 50)
                        .clipped()
                        .foregroundColor(.blue)
                @unknown default:
                    // Handle future cases
                    EmptyView()
                }
            }
            VStack (alignment: .leading) {
                Text(memory.title)
                    .font(.headline)
                    .foregroundColor(.black)
                Text(formattedDate(from: memory.date))
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            Spacer()
        }
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.blue, lineWidth: 1) // Rahmenfarbe und -breite anpassen
        )
        .padding(.horizontal, 16)
        
    }
    // Format the date
    private func formattedDate(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}

struct FavoritesItemView_Previews: PreviewProvider {
    static var previews: some View {
        SingleMemoryItemView(memory: exampleMemory)
    }
}
