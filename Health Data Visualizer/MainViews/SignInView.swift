//
//  SignInView.swift
//  Health Data Visualizer
//
//  Created by Amira Mahmedjan on 19.09.2024.
//

import SwiftUI

struct SignInView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var errorMessage: String?
    
    var body: some View {
        NavigationView {
            VStack {
                AuthTopView()
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
                    UserSessionManager.shared.signIn(email: email, password: password)
                }) {
                    Text("Sign In")
                        .font(.headline)
                        .padding()
                        .frame(maxWidth: .infinity) // Long rectangle
                        .background(Color.blue.opacity(0.6)) // Same as the text field border
                        .foregroundColor(.white) // White text color
                        .cornerRadius(25) // Very rounded corners
                        .padding(.top, 50)
                }
                
                HStack {
                    Text("Don't have an account yet?")
                        .font(.body)
                        .foregroundColor(.primary)
                    
                    NavigationLink(destination: AuthView()) {
                        Text("Sign up here!")
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
