//
//  FavoritesItemView.swift
//  MemoryLane
//
//  Created by martin on 01.02.24.
//

import SwiftUI


struct SingleMemoryItemView: View {
    
    // Set color scheme
    @Environment(\.colorScheme) var colorScheme
    
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
                        .foregroundColor(.accentColor)
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
                        .foregroundColor(.accentColor)
                @unknown default:
                    // Handle future cases
                    EmptyView()
                }
            }
            VStack (alignment: .leading, spacing: 8) {
                Text(memory.date, style: .date)
                    .font(.subheadline)
                    .foregroundColor(.gray)
                Text(memory.title)
                    .font(.headline)
                    .bold()
                    .foregroundColor(colorScheme == .dark ? .white : .black)
                Text(memory.location)
                    .font(.subheadline)
                    .foregroundColor(colorScheme == .dark ? Color.orange : Color.blue)
                    .lineLimit(1)
            }
            Spacer()
        }
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(colorScheme == .dark ? .white : .black, lineWidth: 0.5)
        )
        .padding(.horizontal, 16)
        
    }
}

struct FavoritesItemView_Previews: PreviewProvider {
    static var previews: some View {
        SingleMemoryItemView(memory: Memory.exampleMemory)
    }
}
