//
//  NavigationView.swift
//  MemoryLane
//
//  Created by martin on 28.01.24.
//

import SwiftUI


struct TabsView: View {
    
    // Set color scheme
    @Environment(\.colorScheme) var colorScheme
    
    init() {
        // Set color for unselected icons in the TabView
        UITabBar.appearance().unselectedItemTintColor = UIColor.lightGray
    }
    
    var body: some View {
        TabView {
            ForEach(Tab.allCases) { tab in
                tab.view
                    .tabItem {
                        Image(systemName: tab.icon)
                        Text(tab.title)
                    }
                    .tag(tab)
            }
        }
        // Dynamically set accent color based on colorScheme
        .accentColor(colorScheme == .dark ? Color.orange : Color.blue)
    }
}
