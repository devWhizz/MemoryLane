//
//  NavigationLinkWithoutIndicator.swift
//  MemoryLane
//
//  Created by martin on 14.02.24.
//

import SwiftUI


struct NavigationLinkWithoutIndicator<Destination: View, Label: View>: View {
    
    let destination: Destination
    let label: () -> Label
    
    var body: some View {
        ZStack(alignment: .leading) {
            NavigationLink(
                destination: destination) {}
            // Make the NavigationLink transparent
                .opacity(0)
            // Put the empty label on top of it
            label()
        }
    }
}
