//
//  HomeView.swift
//  MemoryLane
//
//  Created by martin on 22.01.24.
//

import SwiftUI

struct HomeView: View {
    
    @EnvironmentObject private var userViewModel: UserViewModel
    @StateObject private var memoryViewModel = MemoryViewModel()
    
    // Control the visibility of the "AddMemory" sheet
    @State private var isAddMemoryViewPresented = false
    
    var body: some View {
        NavigationView {
            VStack {
                // Iterate through memory categories
                ForEach(memoryViewModel.memoryCategories, id: \.self) { category in
                    // Display section only if there are memories in that category
                    if let categoryMemories = memoryViewModel.memoriesByCategory[category] {
                        // Section title
                        Text(category)
                            .font(.headline)
                            .padding(.top, 16)
                            .padding(.horizontal, 16)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 16) {
                                // Iterate through memories in the current category
                                ForEach(categoryMemories) { memory in
                                    NavigationLink(
                                        destination: MemoryDetailView(memoryViewModel: memoryViewModel, memory: memory),
                                        label: {
                                            MemoryItemView(memoryViewModel: memoryViewModel, memory: memory)
                                        })
                                }

                            }
                            .padding(.horizontal, 16)
                        }
                    }
                }
                
                Spacer()
            }
            .navigationTitle("Memories")
            .toolbar {
                Button(action: addMemory) {
                    Image(systemName: "plus.circle.fill")
                }
            }
            .sheet(isPresented: $isAddMemoryViewPresented) {
                AddMemoryView(isPresented: $isAddMemoryViewPresented)
            }
            .onAppear {
                memoryViewModel.fetchMemories()
            }
        }
    }

    private func addMemory() {
        isAddMemoryViewPresented.toggle()
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
            .environmentObject(UserViewModel())
    }
}
