//
//  MoemoryItemView.swift
//  MemoryVerse
//
//  Created by syntax on 23.01.24.
//

import SwiftUI
import URLImage


struct MemoryItemView: View {
    
    @ObservedObject var memoryViewModel: MemoryViewModel
    var memory: Memory
    
    var body: some View {
        ZStack(alignment: .bottom) {
            URLImage(URL(string: memory.coverImage)!) { image in
                image
                    .resizable()
                    .scaledToFill()
                    .frame(width: 300, height: 200)                
                    .clipped()
            }
            
            HStack(spacing: 10) {
                VStack(spacing: 5) {
                    Text(memory.title)
                        .font(.title2)
                        .bold()
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Text(formattedDate(from: memory.date))
                        .font(.callout)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            .foregroundColor(.white)
            .padding(.vertical, 15)
            .padding(.horizontal, 15)
        }
        .cornerRadius(12)
    }
    
    private func formattedDate(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}

struct MemoryItemView_Previews: PreviewProvider {
    static var previews: some View {
        MemoryItemView(memoryViewModel: MemoryViewModel(), memory: exampleMemory)
    }
}

