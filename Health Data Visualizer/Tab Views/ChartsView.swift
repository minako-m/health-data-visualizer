//
//  ChartsView.swift
//  Health Data Visualizer
//
//  Created by Amira Mahmedjan on 06.08.2024.


import Foundation
import SwiftUI
import HealthKit
import Charts

struct ChartsView: View {
    @State private var stepData: [HKStatistics] = []
    @State private var errorMessage: String?
    @EnvironmentObject var healthDataModel: HealthDataModel
    
    var body: some View {
        VStack {
            if healthDataModel.weeklyStepData.isEmpty {
                Text("No data available. Please fetch the data.")
            } else {
                Text("Summary of Step Counts for the Past Week")
                    .font(.headline)
                    .foregroundColor(.blue)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
                Chart {
                    ForEach (healthDataModel.weeklyStepData, id: \.startDate) { statistic in
                        if let quantity = statistic.sumQuantity() {
                            let steps = quantity.doubleValue(for: HKUnit.count())
                            
                            BarMark (
                                x: .value("Date", statistic.startDate, unit: .day),
                                y: .value("Step Count", steps)
                            )
                            .cornerRadius(7)
                        }
                    }
                }
                .frame(height: 300)
                .padding()
            }
        }
    }
}

#Preview {
    ChartsView()
}
