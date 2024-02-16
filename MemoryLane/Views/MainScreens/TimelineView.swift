//
//  MemoriesListView.swift
//  MemoryLane
//
//  Created by martin on 12.02.24.
//

import SwiftUI

struct TimelineView: View {
    
    @StateObject private var memoryViewModel = MemoryViewModel()
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 12) {                ForEach(sortedMonthKeys, id: \.self) { monthKey in
                    // Create a section header for each month
                    Section(header: createSectionHeader(for: monthKey)) {
                        ForEach(sortedMemories[monthKey]!.sorted(by: { $0.date > $1.date }), id: \.id) { memory in
                            NavigationLink(destination: MemoryDetailView(memoryViewModel: memoryViewModel, memory: memory)) {
                                SingleMemoryItemView(memory: memory)
                            }
                        }
                    }
                }
                }
            }
            .navigationTitle("timeline")
            .onAppear {
                memoryViewModel.fetchMemories()
            }
        }
    }
    
    // Create section header
    private func createSectionHeader(for monthKey: String) -> some View {
        return Text(monthKey)
            .font(.title2)
            .foregroundColor(.black)
            .padding(.top, 16)
            .padding(.leading, 16)
            .padding(.bottom, 8)
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
