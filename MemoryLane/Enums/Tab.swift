//
//  Tabs.swift
//  MemoryVerse
//
//  Created by syntax on 23.01.24.
//

import SwiftUI

enum Tab: String, Identifiable, CaseIterable {
    case home, search, favorites, settings
    
    var id: String { rawValue }
    
    var title: String {
        switch self {
        case .home: return "Home"
        case .search: return "Search"
        case .favorites: return "Favorites"
        case .settings: return "Settings"
        }
    }
    
    var icon: String {
        switch self {
        case .home: return "house.fill"
        case .search: return "rectangle.and.text.magnifyingglass"
        case .favorites: return "heart"
        case .settings: return "gearshape"
        }
    }
    
    var view: AnyView {
        switch self {
        case .home: return AnyView(HomeView())
        case .search: return AnyView(HomeView())
        case .favorites: return AnyView(HomeView())
        case .settings: return AnyView(SettingsView())
        }
    }
    
}
