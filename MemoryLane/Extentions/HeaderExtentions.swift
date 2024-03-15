//
//  HeaderExtentions.swift
//  MemoryLane
//
//  Created by martin on 14.03.24.
//

import Foundation
import SwiftUI


extension View {
    
    // Create section header
    func createSectionHeader(for monthKey: String) -> some View {
        return Text(monthKey)
            .font(.title3)
            .bold()
            .foregroundColor(Color.black)
            .padding(.leading, 16)
    }
    
}
