//
//  SettingsView.swift
//  MemoryLane
//
//  Created by martin on 28.01.24.
//

import SwiftUI


struct ProfileView: View {
    
    @EnvironmentObject private var userViewModel: UserViewModel
    @EnvironmentObject private var memoryViewModel: MemoryViewModel
    
    // Dark mode preference stored in AppStorage
    @AppStorage("isDarkModeEnabled") private var isDarkModeEnabled: Bool = false
    
    // Set color scheme
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text("nickname: \(userViewModel.user?.name ?? "Martin")")
                    Text("emailAddress: \(userViewModel.user?.email ?? "example@example.com")")
                    Text("memoryCount: \(memoryViewModel.memories.count)")
                    // Toggle for dark mode preference
                    Toggle("darkMode", isOn: $isDarkModeEnabled)
                        .toggleStyle(SwitchToggleStyle(tint: .orange))
                        .padding(.top, 24)
                }
                .padding(24)
            }
            .navigationBarTitle("profile")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Image(systemName: "rectangle.portrait.and.arrow.right")
                        .foregroundColor(.accentColor)
                        .onTapGesture {
                            // Trigger logout when the icon is tapped
                            userViewModel.logout()
                            memoryViewModel.removeListener()
                        }
                }
            }
            .onAppear {
                memoryViewModel.fetchMemories()
            }
        }
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
            .environmentObject(UserViewModel())
            .environmentObject(MemoryViewModel())
    }
}
