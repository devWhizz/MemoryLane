//
//  SettingsView.swift
//  MemoryLane
//
//  Created by martin on 28.01.24.
//

import SwiftUI


struct SettingsView: View {
    
    @EnvironmentObject private var userViewModel: UserViewModel
    @StateObject private var memoryViewModel = MemoryViewModel()
    
    var body: some View {
        NavigationView {
            ScrollView {
                HStack {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("name: \(userViewModel.user?.name ?? "Martin")")
                        Text("emailAddress: \(userViewModel.user?.email ?? "example@example.com")")
                        Text("memoryCount: \(memoryViewModel.memories.count)")
                    }
                    .padding()
                    Spacer()
                }
                .navigationBarTitle("settings")
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Image(systemName: "rectangle.portrait.and.arrow.right")
                        .foregroundColor(.blue)
                        .onTapGesture {
                            // Trigger logout when the icon is tapped
                            userViewModel.logout()
                            memoryViewModel.removeListener()
                        }
                }
            }
            .onAppear {
                // Fetch memories when the view appears
                memoryViewModel.fetchMemories()
            }
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
            .environmentObject(UserViewModel())
    }
}
