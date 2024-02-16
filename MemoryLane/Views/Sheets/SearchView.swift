//
//  SearchView.swift
//  MemoryLane
//
//  Created by martin on 06.02.24.
//

import SwiftUI


struct SearchView: View {
    
    @State private var searchText = ""
    @StateObject private var memoryViewModel = MemoryViewModel()
    
    // Control the presentation of the sheet
    @Binding var isPresented: Bool
    
    // Set color scheme
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        
        NavigationView {
            ScrollView {
                VStack(alignment: .center, spacing: 12) {
                    SearchBarView(text: $searchText)
                        .onChange(of: searchText) {
                            memoryViewModel.searchMemories(query: searchText)
                        }
                        .padding(.vertical, 24)

                    if searchText.isEmpty {
                        Text("noSearchTerm")
                            .font(.headline)
                    } else if memoryViewModel.memories.isEmpty {
                        Text("noSearchResults")
                            .font(.headline)
                    } else {
                        ForEach(memoryViewModel.memories, id: \.id) { memory in
                            NavigationLink(destination: MemoryDetailView(memoryViewModel: memoryViewModel, memory: memory)) {
                                SingleMemoryItemView(memory: memory)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Search")
            .toolbar {
                // Close button in the navigation bar
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


struct SearchView_Previews: PreviewProvider {
    static var previews: some View {
        SearchView(isPresented: .constant(true))
    }
}
