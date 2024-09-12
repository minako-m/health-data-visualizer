//
//  Health_Data_VisualizerApp.swift
//  Health Data Visualizer
//
//  Created by Amira Mahmedjan on 04.08.2024.
//

import SwiftUI
import FirebaseCore
import FirebaseAuth

class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    FirebaseApp.configure()

    return true
  }
}

@main
struct Health_Data_VisualizerApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject private var healthDataModel = HealthDataModel()
    @StateObject private var userSessionManager = UserSessionManager.shared
        
    var body: some Scene {
        WindowGroup {
            // Observe the userSessionManager for authentication state changes
            if userSessionManager.currentUser != nil {
                if userSessionManager.currentUserRole == "clinician" {
                    ClinicianContentView()
                } else {
                    ParticipantContentView()
                        .environmentObject(healthDataModel)
                }
            } else {
                AuthView()
                    .environmentObject(userSessionManager) // Optional if needed in AuthView
            }
        }
    }
}
