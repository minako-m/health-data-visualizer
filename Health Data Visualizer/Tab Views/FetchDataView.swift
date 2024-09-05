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
                Button("Fetch Weekly Data") {
                    fetchData(for: .activeEnergyBurned, unit: HKUnit.kilocalorie())
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
                    healthDataModel.weeklyData = [:]
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
    
    private func fetchData(for type: HKQuantityTypeIdentifier, unit: HKUnit) {
        // Check if there's already fetched data for the specified type
        if let statistics = healthDataModel.weeklyData[type.rawValue], !statistics.isEmpty {
            // Show alert if data is already fetched
            showAlert = true
            
            // Print fetched data to the console
            print("Fetched Weekly Data for \(type.rawValue):")
            for statistic in statistics {
                let startDate = statistic.startDate
                let endDate = statistic.endDate
                if let sumQuantity = statistic.sumQuantity() {
                    let value = sumQuantity.doubleValue(for: unit)
                    print("Start: \(startDate), End: \(endDate), Value: \(value) \(unit)")
                } else {
                    print("No sum quantity available for this statistic.")
                }
            }
        } else {
            // No data yet, so request access and fetch the data
            healthDataModel.requestHealthKitAccess()
            
            if let quantityType = HKQuantityType.quantityType(forIdentifier: type) {
                healthDataModel.fetchWeeklyData(for: quantityType)
            } else {
                print("Error: Invalid HealthKit quantity type identifier.")
            }
        }
    }
}

#Preview {
    FetchDataView()
}
