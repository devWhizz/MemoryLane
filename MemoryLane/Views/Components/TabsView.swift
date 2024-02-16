//
//  NavigationView.swift
//  MemoryLane
//
//  Created by martin on 23.01.24.
//

import SwiftUI

struct TabsView: View {
    
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
    }
    
}

struct TabsView_Previews: PreviewProvider {
    static var previews: some View {
        TabsView()
    }
}
