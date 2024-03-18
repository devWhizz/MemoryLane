//
//  HomeView.swift
//  MemoryLane
//
//  Created by martin on 26.01.24.
//

import SwiftUI


struct HomeView: View {
    
    @EnvironmentObject private var memoryViewModel: MemoryViewModel
    
    // Control the visibility of the sheets
    @State private var isAddMemoryViewPresented = false
    @State private var isSearchViewPresented = false
    
    var body: some View {
        NavigationView {
            ScrollView{
                VStack (alignment: .leading) {
                    // Iterate through memory categories, sorted alphabetically based on localized translations
                    ForEach(memoryViewModel.memoryCategories.sorted(by: { (category1, category2) in
                        // Obtain translations for category names or use the original names as fallback
                        let translation1 = memoryViewModel.categoryTranslations[category1] ?? category1
                        let translation2 = memoryViewModel.categoryTranslations[category2] ?? category2
                        // Compare the translated category names in a localized manner
                        return translation1.localizedCompare(translation2) == .orderedAscending
                    }), id: \.self) { category in
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
                                    // Iterate through memories in the current category, sorted by date
                                    ForEach(categoryMemories.sorted(by: { $0.date > $1.date })) { memory in
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
                        .onDisappear {
                            // Reset search query and fetch memories when search sheet is closed
                            memoryViewModel.searchText = ""
                            memoryViewModel.fetchMemories()
                        }
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
            .environmentObject(MemoryViewModel())
    }
}
