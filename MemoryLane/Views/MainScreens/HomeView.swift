//
//  HomeView.swift
//  MemoryLane
//
//  Created by martin on 26.01.24.
//

import SwiftUI


struct HomeView: View {
    
    @EnvironmentObject private var userViewModel: UserViewModel
    @StateObject private var memoryViewModel = MemoryViewModel()
    
    // Control the visibility of the sheets
    @State private var isAddMemoryViewPresented = false
    @State private var isSearchViewPresented = false
    
    var body: some View {
        NavigationView {
            ScrollView{
                VStack (alignment: .leading) {
                    // Iterate through memory categories
                    ForEach(memoryViewModel.memoryCategories, id: \.self) { category in
                        // Display section only if there are memories in that category
                        if let categoryMemories = memoryViewModel.memoriesByCategory[category] {
                            // Section title
                            Text(NSLocalizedString(category, comment: ""))
                                .font(.title3)
                                .bold()
                                .padding(.top, 24)
                                .padding(.leading, 16)
                            
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
                .navigationTitle("memories")
                .toolbar {
                    Button(action: searchMemory) {
                        Image(systemName: "magnifyingglass.circle")
                    }
                    Button(action: addMemory) {
                        Image(systemName: "plus.circle")
                    }
                }
                .sheet(isPresented: $isAddMemoryViewPresented) {
                    AddMemoryView(isPresented: $isAddMemoryViewPresented)
                }
                .sheet(isPresented: $isSearchViewPresented) {
                    SearchView(isPresented: $isSearchViewPresented)
                }
                .onAppear {
                    memoryViewModel.fetchMemories()
                }
            }
        }
    }
    
    private func addMemory() {
        isAddMemoryViewPresented.toggle()
    }
    
    private func searchMemory() {
        isSearchViewPresented.toggle()
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
            .environmentObject(UserViewModel())
    }
}
