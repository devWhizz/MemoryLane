//
//  Tabs.swift
//  MemoryLane
//
//  Created by martin on 31.01.24.
//

import SwiftUI


enum Tab: String, Identifiable, CaseIterable {
    case home, timeline, favorites, profile
    
    var id: String { rawValue }
    
    var title: LocalizedStringKey {
        switch self {
        case .home: return LocalizedStringKey("home")
        case .timeline: return LocalizedStringKey("timeline")
        case .favorites: return LocalizedStringKey("favorites")
        case .profile: return LocalizedStringKey("profile")
        }
    }
    
    var icon: String {
        switch self {
        case .home: return "house"
        case .timeline: return "calendar.day.timeline.left"
        case .favorites: return "heart"
        case .profile: return "person"
        }
    }
    
    var view: AnyView {
        switch self {
        case .home: return AnyView(HomeView())
        case .timeline: return AnyView(TimelineView())
        case .favorites: return AnyView(FavoritesView())
        case .profile: return AnyView(ProfileView())
        }
    }
    
}
