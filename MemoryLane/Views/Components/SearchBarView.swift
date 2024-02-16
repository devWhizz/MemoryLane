//
//  SearchBarView.swift
//  MemoryLane
//
//  Created by martin on 09.02.24.
//

import SwiftUI


struct SearchBarView: View {
    
    @Binding var text: String
    
    // Set color scheme
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack{
            HStack {
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(colorScheme == .dark ? Color.orange : Color.blue)
                        .padding(.leading, 8)
                    
                    TextField("searchTerm", text: $text)
                        .autocapitalization(.none)
                        .foregroundColor(colorScheme == .dark ? Color.white : Color.black)
                        .padding(10)
                }
                .background(Color.gray.opacity(0.3))
                .cornerRadius(12)
                .padding(.trailing, text.isEmpty ? 0 : 8)
                
                if !text.isEmpty {
                    Button(action: {
                        text = ""
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(colorScheme == .dark ? Color.orange : Color.blue)
                    }
                    .padding(.trailing, 8)
                    .transition(.move(edge: .trailing))
                }
            }
            .padding(.horizontal)
        }
        .padding(.top, 24)
        .padding(.bottom, 16)
    }
}


struct SearchBarView_Previews: PreviewProvider {
    static var previews: some View {
        SearchBarView(text: .constant(""))
    }
}
