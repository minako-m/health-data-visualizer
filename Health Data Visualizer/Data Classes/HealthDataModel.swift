//
//  HealthDataModel.swift
//  Health Data Visualizer
//
//  Created by Amira Mahmedjan on 13.08.2024.
//

import Foundation
import SwiftUI
import Combine
import HealthKit
import Firebase
import FirebaseCore
import FirebaseFirestore

class HealthDataModel: ObservableObject {
    @Published var weeklyStepData: [HKStatistics] = []
    @Published var errorMessage: String? = nil
    
    init() {
        // Request HealthKit access when the model is initialized
        // requestHealthKitAccess()
    }
    
    func requestHealthKitAccess() {
        HealthKitManager.shared.requestHealthDataAccess { [weak self] success, error in
            if success {
                // Access granted, proceed with data fetching or other operations
            } else {
                DispatchQueue.main.async {
                    self?.errorMessage = error?.localizedDescription
                }
            }
        }
    }
    
    func fetchWeeklyStepData() {
        HealthKitManager.shared.getWeeklyStepCountData { [weak self] data, error in
            if let data = data {
                DispatchQueue.main.async {
                    self?.weeklyStepData = data
                    self?.uploadWeeklyStepData()
                }
            } else {
                DispatchQueue.main.async {
                    print("Error: \(error?.localizedDescription ?? "Unknown error")")
                    self?.errorMessage = error?.localizedDescription
                }
            }
        }
    }
    
    func uploadWeeklyStepData() {
        let db = Firestore.firestore()
        
        // Prepare data for upload
        let stepsData = weeklyStepData.map { statistic -> [String: Any] in
            let date = statistic.startDate
            let quantity = statistic.sumQuantity()
            let steps = quantity?.doubleValue(for: HKUnit.count()) ?? 0
            
            return [
                "date": date,
                "steps": steps
            ]
        }
        
        // Upload data
        db.collection("weekly_steps").addDocument(data: [
            "data": stepsData,
            "timestamp": Timestamp(date: Date())
        ]) { error in
            if let error = error {
                print("Error adding document: \(error)")
            } else {
                print("Document successfully written!")
            }
        }
    }
}
