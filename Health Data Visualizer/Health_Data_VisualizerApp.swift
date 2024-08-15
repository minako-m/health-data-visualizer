//
//  Health_Data_VisualizerApp.swift
//  Health Data Visualizer
//
//  Created by Amira Mahmedjan on 04.08.2024.
//

import SwiftUI
import FirebaseCore


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
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(healthDataModel)
        }
    }
}
