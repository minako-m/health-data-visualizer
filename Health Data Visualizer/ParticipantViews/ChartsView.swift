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
    
    var dataType: HKQuantityTypeIdentifier
    var unit: HKUnit
    var title: String
    
    var body: some View {
        VStack {
            if let statistics = healthDataModel.weeklyData[dataType.rawValue], !statistics.isEmpty {
                Text("Summary of \(title) for the Past Week")
                    .font(.headline)
                    .foregroundColor(.blue)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
                Chart {
                    ForEach (statistics, id: \.startDate) { statistic in
                        if let quantity = statistic.sumQuantity() {
                            let value = quantity.doubleValue(for: unit)
                            
                            BarMark (
                                x: .value("Date", statistic.startDate, unit: .day),
                                y: .value(title, value)
                            )
                            .cornerRadius(7)
                        }
                    }
                }
                .frame(height: 300)
                .padding()
            } else {
                Text("No data available. Please fetch the data.")
            }
        }
    }
}

//#Preview {
//    ChartsView()
//}
