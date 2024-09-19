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
    @Published var weeklyData: [String: [HKStatistics]] = [:]
    
    init() {}
    
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
    
    // Generic function to fetch weekly data of any type
    func fetchWeeklyData(for quantityType: HKQuantityType) {
        HealthKitManager.shared.getWeeklyData(for: quantityType) { [weak self] data, error in
            if let data = data {
                DispatchQueue.main.async {
                    self?.handleWeeklyData(data, for: quantityType)
                }
            } else {
                DispatchQueue.main.async {
                    print("Error: \(error?.localizedDescription ?? "Unknown error in fetchWeeklyData")")
                    self?.errorMessage = error?.localizedDescription
                }
            }
        }
    }
    
    private func handleWeeklyData(_ data: [HKStatistics], for quantityType: HKQuantityType) {
        // Store data in a dictionary by quantity type identifier
        weeklyData[quantityType.identifier] = data
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
        guard let user = UserSessionManager.shared.currentUser else {
            print("No user is signed in")
            return
        }
        
        let db = Firestore.firestore()
        let userID = user.uid
        
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
        
        db.collection("users").document(userID)
            .collection("stepData").addDocument(data: ["steps": stepsData]) { error in
            if let error = error {
                print("Error writing document: \(error)")
            } else {
                print(UserSessionManager.shared.currentUser?.uid as Any)
                print("Document successfully written!")
            }
        }
    }
}
