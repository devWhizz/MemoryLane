//
//  AuthenticationView.swift
//  MemoryVerse
//
//  Created by syntax on 22.01.24.
//

import SwiftUI

struct LoginView: View {
    
    @EnvironmentObject private var userViewModel: UserViewModel
    @StateObject private var memoryViewModel = MemoryViewModel()
    @State private var email = ""
    @State private var password = ""
    @State private var isRegisterSheetPresented = false
    
    // Disable login button if email or password is empty
    private var disableAuthentication: Bool {
        email.isEmpty || password.isEmpty
    }
    
    var body: some View {
        
        VStack(spacing: 16){
            Spacer()
            VStack {
                // Email
                TextField("Email address", text: $email)
                    .autocapitalization(.none)
                    .keyboardType(.emailAddress)
                    .padding(10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.gray, lineWidth: 1)
                    )
                
                // Password
                SecureField("Password", text: $password)
                    .autocapitalization(.none)
                    .padding(10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.gray, lineWidth: 1)
                    )
                // Login button
                Button("Login", action: login)
                    .disabled(disableAuthentication)
                    .frame(maxWidth: .infinity)
                    .padding(10)
                    .background(Color.gray)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .padding(.top, 12)
                    .padding(.bottom, 24)
                
                
                // Text button for register sheet
                Button(action: {
                    isRegisterSheetPresented.toggle()
                }) {
                    Text("No account yet? Register now.")
                        .foregroundColor(.blue)
                        .font(.footnote)
                }
                .sheet(isPresented: $isRegisterSheetPresented) {
                    RegisterView()
                }
            }
            .padding(32)
            .background(Color .white)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            Spacer()
        }
        .background(
            Image("tagebuch")
                .resizable()
                .scaledToFill()
                .edgesIgnoringSafeArea(.all)
        )
        .padding(.horizontal, 48)
        
    }
    
    
    private func login() {
        userViewModel.login(email: email, password: password)
    }
}


struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
