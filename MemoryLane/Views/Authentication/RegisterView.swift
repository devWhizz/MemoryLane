//
//  RegisterView.swift
//  MemoryVerse
//
//  Created by syntax on 22.01.24.
//

import SwiftUI

struct RegisterView: View {
    
    @EnvironmentObject private var userViewModel: UserViewModel
    @StateObject private var memoryViewModel = MemoryViewModel()
    @State private var name = ""
    @State private var email = ""
    @State private var password = ""
    
    // Disable register button if email or password is empty
    private var disableAuthentication: Bool {
        name.isEmpty || email.isEmpty || password.isEmpty
    }

    var body: some View {
        VStack {
            Spacer()

            // Name-Eingabe
            TextField("Name", text: $name)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .autocapitalization(.none)
            
            // Email-Eingabe
            TextField("Emailadresse", text: $email)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .autocapitalization(.none)
                .keyboardType(.emailAddress)

            // Passwort-Eingabe
            SecureField("Passwort", text: $password)
                .autocapitalization(.none)
                .textFieldStyle(RoundedBorderTextFieldStyle())

            // Registrieren-Button (kann entsprechend deiner Authentifizierungsmethode angepasst werden)
            Button(action: {
                register()
                print("Registrieren Button tapped")
            }) {
                Text("Registrieren")
                    .disabled(disableAuthentication)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.gray)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .padding(.vertical, 24)
            }
            
            Spacer()
        }
        .padding(.horizontal, 24)
    }
    
    private func register() {
        userViewModel.register(name: name, email: email, password: password)
    }
}

struct RegisterView_Previews: PreviewProvider {
    static var previews: some View {
        RegisterView()
    }
}
