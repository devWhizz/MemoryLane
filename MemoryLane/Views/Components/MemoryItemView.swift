//
//  MoemoryItemView.swift
//  MemoryLane
//
//  Created by martin on 29.01.24.
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
                    Text(memory.date, style: .date)
                        .font(.callout)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Text(memory.title)
                        .font(.title2)
                        .bold()
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            .foregroundColor(.white)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(Color.black.opacity(0.5))
            .clipShape(
                .rect(
                    topLeadingRadius: 0,
                    bottomLeadingRadius: 12,
                    bottomTrailingRadius: 12,
                    topTrailingRadius: 0
                )
            )        }
        .cornerRadius(12)
    }
}

struct MemoryItemView_Previews: PreviewProvider {
    static var previews: some View {
        MemoryItemView(memoryViewModel: MemoryViewModel(), memory: Memory.exampleMemory)
    }
}

