//
//  AuthenticationView.swift
//  MemoryLane
//
//  Created by martin on 29.01.24.
//

import SwiftUI


struct LoginView: View {
    
    @EnvironmentObject private var userViewModel: UserViewModel
    @EnvironmentObject private var memoryViewModel: MemoryViewModel
    
    // Set color scheme
    @Environment(\.colorScheme) var colorScheme
    
    // Control the display of the register sheet
    @State private var isRegisterSheetPresented = false
    
    // Control the display of the alert
    @State private var showAlert = false
    
    var body: some View {
        VStack(spacing: 16){
            Spacer()
            VStack {
                Text("memoryLane")
                    .font(.title2)
                Text("slogan")
                    .font(.callout)
                    .multilineTextAlignment(.center)
                    .padding(.vertical, 4)
                Image(systemName: "book.pages.fill")
                    .foregroundColor(colorScheme == .dark ? .orange : .blue)
                    .font(.largeTitle)
                    .padding(.bottom, 16)
                
                // User input (Email, Password)
                TextField("emailAddress", text: $userViewModel.userEmail)
                    .autocapitalization(.none)
                    .keyboardType(.emailAddress)
                    .padding(10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(colorScheme == .dark ? .white : .gray, lineWidth: 1)
                    )
                    .background(colorScheme == .dark ? .black.opacity(0.5) : .white.opacity(0.8))
                SecureField("password", text: $userViewModel.userPassword)
                    .autocapitalization(.none)
                    .padding(10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(colorScheme == .dark ? .white : .gray, lineWidth: 1)
                    )
                    .background(colorScheme == .dark ? .black.opacity(0.5) : .white.opacity(0.8))
                
                // Trigger user login
                Button("login", action: login)
                    .disabled(disablLogin)
                    .frame(maxWidth: .infinity)
                    .padding(10)
                    .background(disablLogin ? Color.gray : (colorScheme == .dark ? Color.orange : Color.blue))
                    .foregroundColor(disablLogin ? Color.white : (colorScheme == .dark ? Color.black : Color.white))
                    .cornerRadius(10)
                    .padding(.top, 12)
                    .padding(.bottom, 24)
                
                // Text button for register sheet
                Button(action: {
                    isRegisterSheetPresented.toggle()
                }) {
                    Text("noAccount")
                        .foregroundColor(colorScheme == .dark ? .orange : .blue)
                        .font(.footnote)
                }
                .sheet(isPresented: $isRegisterSheetPresented) {
                    // Present the RegisterView as a sheet (half the screen height)
                    RegisterView(isPresented: $isRegisterSheetPresented)
                        .presentationDetents([.medium])
                        .presentationDragIndicator(.hidden)
                }
            }
            .padding(32)
            .background(colorScheme == .dark ? .black.opacity(0.7) : .white.opacity(0.8))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            Spacer()
        }
        .background(
            Image("diary-background")
                .resizable()
                .scaledToFill()
                .edgesIgnoringSafeArea(.all)
        )
        .padding(.horizontal, 48)
        .onDisappear {
            // Clear password field when the view disappears
            userViewModel.userPassword = ""
        }
    }
    
    
    // Disable login button if email or password is empty
    private var disablLogin: Bool {
        userViewModel.userEmail.isEmpty || !isValidInput()
    }
    
    // Check the validity of user input
    private func isValidInput() -> Bool {
        let minCharacterCount = 6
        return userViewModel.userPassword.count >= minCharacterCount
    }
    
    // Perform user login
    private func login() {
        userViewModel.login(email: userViewModel.userEmail, password: userViewModel.userPassword)
    }
    
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
