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
    
    @EnvironmentObject var healthDataModel: HealthDataModel
    
    var body: some View {
        VStack {
            Text("Clicking the button will print a message to the console.")
                .font(.body)
                .foregroundColor(.black)
                .padding()
                .background(Color.white)
                .cornerRadius(16)
                .shadow(radius: 5)
                .padding()
            
            VStack {
                if healthDataModel.weeklyStepData.isEmpty {
                    Button("Fetch Weekly Data") {
                        healthDataModel.requestHealthKitAccess()
                        healthDataModel.fetchWeeklyStepData()
                    }
                } else {
                    Text("Data for the most recent week already fetched. Please view analysis in 'Charts'")
                }
                
                if let errorMessage = healthDataModel.errorMessage {
                    Text("Error: \(errorMessage)")
                }
            }
            
            /*Button(action: {healthDataModel.fetchWeeklyStepData()}) {
                Text("Get Health Data")
                    .foregroundColor(.white)
                    .padding() // Adds padding inside the button
                    .frame(width: 200, height: 50) // Sets the size of the button
                    .background(Color.blue) // Sets the button color
                    .cornerRadius(12) // Rounds the corners of the button
                    .shadow(radius: 10)
            }
            .padding()*/
            
            /*if let stepCount = stepCount {
                Text("Step count: \(stepCount)")
            } else if let errorMessage = errorMessage {
                Text("Error: \(errorMessage)")
            } else {
                Text("Requesting HealthKit access...")
            }
            
            if let walkingRunningDistance = walkingRunningDistance {
                Text("Walking and Running Distance: \(walkingRunningDistance)")
            } else if let errorMessage = errorMessage {
                Text("Error: \(errorMessage)")
            } else {
                Text("Requesting HealthKit access...")
            }*/
        }
    }
}

#Preview {
    FetchDataView()
}
