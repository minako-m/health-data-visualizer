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
        HStack (alignment: .top, content: {
            Text("Health Data Visualizer")
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(.white)
        })
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color.blue.opacity(0.8))
    }
}

struct AuthView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var errorMessage: String?
    @State private var userRole = ""
    
    var body: some View {
        VStack {
            AuthTopView()
            Picker("Please select the who you are logging in as", selection: $userRole) {
                Text("Study Participant").tag("participant")
                Text("Clinician").tag("clinician")
            }
            .pickerStyle(.segmented)
            .padding()
            
            TextField("Email", text: $email)
                .keyboardType(.emailAddress)
                .autocapitalization(.none)
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(8.0)
            
            SecureField("Password", text: $password)
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(8.0)
            
            Button(action: {
                UserSessionManager.shared.signUp(email: email, password: password, role: userRole)
            }) {
                Text("Sign Up")
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .cornerRadius(15.0)
            }
            .padding(.top, 50)
            
            Button(action: {
                UserSessionManager.shared.signIn(email: email, password: password)
            }) {
                Text("Sign In")
                    .foregroundColor(Color.gray)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(15.0)
            }
            
            if let errorMessage = errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .padding()
            }
        }
        .padding()
    }
}
