//
//  MemoriesListView.swift
//  MemoryLane
//
//  Created by martin on 12.02.24.
//

import SwiftUI


struct TimelineView: View {
    
    @StateObject private var memoryViewModel = MemoryViewModel()
    
    // Control the visibility of the sheets
    @State private var isAddMemoryViewPresented = false
    @State private var isSearchViewPresented = false
    
    // Represent the memory to be deleted
    @State private var memoryToDelete: Memory?
    
    // Set color scheme
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        NavigationView {
            List {
                // Iterate through each month key
                ForEach(sortedMonthKeys, id: \.self) { monthKey in
                    // Create a section header for each month
                    Section(header: createSectionHeader(for: monthKey)) {
                        // Iterate through memories for the current month, sorted by date
                        ForEach(sortedMemories[monthKey]!.sorted(by: { $0.date > $1.date }), id: \.id) { memory in
                            NavigationLinkWithoutIndicator(destination: MemoryDetailView(memoryViewModel: memoryViewModel, memory: memory)) {
                                SingleMemoryItemView(memory: memory)
                            }
                            // Swipe action to trigger memory deletion
                            .swipeActions(edge: .trailing) {
                                Button(action: {
                                    // Set the memory instance to be deleted
                                    memoryToDelete = memory
                                }) {
                                    Image(colorScheme == .dark ? "trash-dark" : "trash-light")
                                }
                                .tint(.clear)
                            }
                        }
                    }
                }
                .listRowSeparator(.hidden)
                .listRowInsets(EdgeInsets())
                .padding(.vertical, 12)
            }
            .listStyle(PlainListStyle())
            .background(.clear)
            .navigationTitle("timeline")
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
            // Display an alert for confirming memory deletion
            .alert(item: $memoryToDelete) { memory in
                Alert(
                    title: Text("deleteTitle"),
                    message: Text("deletemessage"),
                    primaryButton: .destructive(Text("confirm")) {
                        // Use the memory instance supplied for the deletion
                        memoryViewModel.deleteMemory(memory: memory)
                    },
                    secondaryButton: .cancel()
                )
            }
            .onAppear {
                memoryViewModel.fetchMemories()
            }
        }
    }
    
    private func addMemory() {
        isAddMemoryViewPresented.toggle()
    }
    
    private func searchMemory() {
        isSearchViewPresented.toggle()
    }
    
    // Create section header
    private func createSectionHeader(for monthKey: String) -> some View {
        return Text(monthKey)
            .font(.title3)
            .bold()
            .foregroundColor(colorScheme == .dark ? .white : .black)
            .padding(.leading, 16)
    }
    
    // Dictionary of memories grouped by month
    var sortedMemories: [String: [Memory]] {
        let groupedMemories = Dictionary(grouping: memoryViewModel.memories, by: { getMonthYearString(for: $0.date) })
        return groupedMemories
    }
    
    // Array of sorted month keys
    var sortedMonthKeys: [String] {
        return sortedMemories.keys.sorted(by: { compareMonthYearStrings($0, $1) })
    }
    
    // Get a formatted month-year string from a date
    private func getMonthYearString(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: date)
    }
    
    // Compare two month-year strings for sorting
    private func compareMonthYearStrings(_ string1: String, _ string2: String) -> Bool {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        
        if let date1 = formatter.date(from: string1), let date2 = formatter.date(from: string2) {
            return date1 > date2
        }
        return false
    }
}

struct MemoriesListView_Previews: PreviewProvider {
    static var previews: some View {
        TimelineView()
    }
}
