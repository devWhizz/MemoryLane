//
//  RegisterView.swift
//  MemoryLane
//
//  Created by martin on 29.01.24.
//

import SwiftUI


struct RegisterView: View {
    
    @EnvironmentObject private var userViewModel: UserViewModel
    @EnvironmentObject var memoryViewModel: MemoryViewModel
    
    // Set color scheme
    @Environment(\.colorScheme) var colorScheme
    
    // Track user input
    @State private var name = ""
    @State private var email = ""
    @State private var password = ""
    
    // Control the display of the alert
    @State private var showAlert = false
    
    // Control the presentation of the sheet
    @Binding var isPresented: Bool
    
    // Disable register button if name, email or password is empty or password it invalid
    private var disableRegistration: Bool {
        name.isEmpty || email.isEmpty || !isValidInput()
    }
    
    var body: some View {
        NavigationView {
            VStack {
                Spacer()
                Text("createAccount")
                    .font(.title2)
                    .padding(.bottom, 16)
                // User input (Name, Email, Password)
                TextField("nickname", text: $name)
                    .autocapitalization(.none)
                    .padding(10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(colorScheme == .dark ? .white : .gray, lineWidth: 1)
                    )
                TextField("emailAddress", text: $email)
                    .autocapitalization(.none)
                    .keyboardType(.emailAddress)
                    .padding(10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(colorScheme == .dark ? .white : .gray, lineWidth: 1)
                    )
                SecureField("password", text: $password)
                    .autocapitalization(.none)
                    .padding(10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(colorScheme == .dark ? .white : .gray, lineWidth: 1)
                    )
                
                // Trigger user registration
                Button(action: {
                    if !password.isEmpty && password.count < 6 {
                        showAlert = true
                    } else {
                        register()
                    }
                }) {
                    Text("registerNow")
                        .disabled(disableRegistration)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(disableRegistration ? Color.gray : (colorScheme == .dark ? Color.orange : Color.blue))
                        .foregroundColor(disableRegistration ? Color.white : (colorScheme == .dark ? Color.black : Color.white))
                        .cornerRadius(10)
                        .padding(.vertical, 24)
                }
                .alert(isPresented: $showAlert) {
                    // Display alert for invalid input
                    Alert(title: Text("invalidInput"), message: Text("passwordTooShort"), dismissButton: .default(Text("OK")))
                }
                
                Spacer()
            }
            .padding(.horizontal, 24)
            .toolbar {
                // Toolbar icon to dismiss the sheet
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        isPresented = false
                    }) {
                        Image(systemName: "xmark.circle")
                            .foregroundColor(colorScheme == .dark ? .orange : .blue)
                    }
                }
            }
        }
    }
    
    // Perform user registration
    private func register() {
        userViewModel.register(name: name, email: email, password: password)
    }
    
    // Check the validity of user input
    private func isValidInput() -> Bool {
        let minCharacterCount = 6
        return password.count >= minCharacterCount
    }
}

struct RegisterView_Previews: PreviewProvider {
    static var previews: some View {
        RegisterView(isPresented: .constant(true))
    }
}
