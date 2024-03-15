//
//  FavoritesView.swift
//  MemoryLane
//
//  Created by martin on 01.02.24.
//

import SwiftUI


struct FavoritesView: View {
    
    @EnvironmentObject private var memoryViewModel: MemoryViewModel
    
    // Set color scheme
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        NavigationView {
            List {
                ForEach(memoryViewModel.memories.filter { $0.isFavorite }) { memory in
                    ZStack{
                        NavigationLinkWithoutIndicator(destination: MemoryDetailView(memoryViewModel: memoryViewModel, memory: memory)) {
                            SingleMemoryItemView(memory: memory)
                        }}
                    .swipeActions(edge: .trailing){
                        Button(action: { memoryViewModel.toggleFavoriteStatus(for: memory) }) {
                            Image(colorScheme == .dark ? "heart-slash-dark" : "heart-slash-light")
                        }
                        .tint(.clear)
                    }
                    .listRowSeparator(.hidden)
                    .listRowInsets(EdgeInsets())
                    .padding(.vertical, 12)
                }
            }
            .listStyle(PlainListStyle())
            .background(.clear)
            .navigationTitle("Favorites")
        }
        .onAppear {
            memoryViewModel.fetchFavoriteMemories()
        }
    }
}

struct FavoritesView_Previews: PreviewProvider {
    static var previews: some View {
        FavoritesView()
            .environmentObject(MemoryViewModel())
    }
}
