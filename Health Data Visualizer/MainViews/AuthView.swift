//
//  AuthView.swift
//  Health Data Visualizer
//
//  Created by Amira Mahmedjan on 15.08.2024.
//

import Foundation
import SwiftUI
import FirebaseAuth

struct AuthTopView: View {
    var body: some View {
        Text("Wearipedia")
            .font(.largeTitle) // Large title
            .bold() // Bold text
            .multilineTextAlignment(.center) // Center text
            .padding()
            .frame(maxWidth: .infinity, alignment: .top)
            .foregroundColor(.white)
    }
}

struct AuthView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var errorMessage: String?
    @State private var userRole = ""
    
    var body: some View {
        NavigationView {
            VStack {
                AuthTopView()
                Picker("Please select the who you are logging in as", selection: $userRole) {
                    Text("Study Participant").tag("participant")
                    Text("Clinician").tag("clinician")
                }
                .pickerStyle(.segmented)
                .padding()
                
                TextField("Email", text: $email)
                    .padding()
                    .frame(height: 50)
                    .background(Color.white)
                    .cornerRadius(20)
                    .overlay( // Adding the custom border
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.blue.opacity(0.6), lineWidth: 1) // Light blue border
                    )
                    .padding(.horizontal)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                
                SecureField("Password", text: $password)
                    .padding()
                    .frame(height: 50)
                    .background(Color.white)
                    .cornerRadius(20)
                    .overlay( // Adding the custom border
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.blue.opacity(0.6), lineWidth: 1) // Light blue border
                    )
                    .padding(.horizontal)
                
                Button(action: {
                    UserSessionManager.shared.signUp(email: email, password: password, role: userRole)
                }) {
                    Text("Sign Up")
                        .font(.headline)
                        .padding()
                        .frame(maxWidth: .infinity) // Long rectangle
                        .background(Color.blue.opacity(0.6)) // Same as the text field border
                        .foregroundColor(.white) // White text color
                        .cornerRadius(25) // Very rounded corners
                        .padding(.horizontal)
                }
                .padding(.top, 50)
                
                HStack {
                    Text("Already signed up?")
                        .font(.body)
                        .foregroundColor(.primary)
                    
                    NavigationLink(destination: SignInView()) {
                        Text("Sign in here!")
                            .font(.body)
                            .foregroundColor(.blue)
                    }
                }
                .padding()
                
                if let errorMessage = errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .padding()
                }
            }
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.blue.opacity(0.3).ignoresSafeArea())
        }
    }
}
