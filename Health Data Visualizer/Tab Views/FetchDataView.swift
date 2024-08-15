//
//  ContentView.swift
//  Health Data Visualizer
//
//  Created by Amira Mahmedjan on 04.08.2024.
//

import SwiftUI
import HealthKit

struct FetchDataView: View {
    @State private var stepCount: Double?
    @State private var walkingRunningDistance: Double?
    @State private var errorMessage: String?
    @State private var showAlert = false
    
    @EnvironmentObject var healthDataModel: HealthDataModel
    
    var body: some View {
        VStack {
            Text("Welcome, \(UserSessionManager.shared.currentUser?.email ?? "User")!")
                .font(.headline)
                .padding()
            Text("This is an app that helps clinical researchers gather your health data, after you've given your consent, to conduct research in specific fields. Please use the 'Fetch Data' option to start data gathering. You can also view visualizations of your data in 'Charts' menu. Please contact xxx@gmail.com for more detailed information on how your data is being processed.")
                .font(.body)
                .foregroundColor(.black)
                .padding()
                .background(Color.white)
                .cornerRadius(16)
                .shadow(radius: 5)
                .padding()
            
            VStack {
                Button(action: handleFetchData) {
                    Text("Fetch Weekly Data")
                }
                .alert(isPresented: $showAlert) {
                    Alert(
                        title: Text("Data Already Fetched"),
                        message: Text("Data for the most recent week has already been fetched. Please view analysis in 'Charts'."),
                        dismissButton: .default(Text("OK"))
                    )
                }
                
                Button(action: {
                    UserSessionManager.shared.signOut()
                    healthDataModel.weeklyStepData = []
                }) {
                    Text("Sign Out")
                }
                .padding()
                
                if let errorMessage = healthDataModel.errorMessage {
                    Text("Error: \(errorMessage)")
                }
            }
        }
    }
    
    private func handleFetchData() {
        if healthDataModel.weeklyStepData.isEmpty {
            healthDataModel.requestHealthKitAccess()
            healthDataModel.fetchWeeklyStepData()
        } else {
            // Show alert if data is already fetched
            showAlert = true
        }
    }
}

#Preview {
    FetchDataView()
}
