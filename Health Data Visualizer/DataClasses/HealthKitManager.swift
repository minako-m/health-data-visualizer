//
//  HealthKitManager.swift
//  Health Data Visualizer
//
//  Created by Amira Mahmedjan on 05.08.2024.
//

import Foundation
import HealthKit

class HealthKitManager {
    static let shared = HealthKitManager()
    private let healthStore = HKHealthStore()
    
    private init() {}
    
    func requestHealthDataAccess(completion: @escaping (Bool, Error?) -> Void) {
        let typesToShare: Set<HKSampleType> = [] // Define types to write
        let typesToRead: Set = [
            HKObjectType.quantityType(forIdentifier: .stepCount)!,
            HKSampleType.quantityType(forIdentifier: .distanceWalkingRunning)!,
            HKSampleType.quantityType(forIdentifier: .bodyFatPercentage)!,
        ]

        healthStore.requestAuthorization(toShare: typesToShare, read: typesToRead) { success, error in
            if success {
                
            }
        }
    }
    
    func getWeeklyData(for quantityType: HKQuantityType, startDate: Date, completion: @escaping ([HKStatistics]?, Error?) -> Void) {
        print("We just called getWeeklyData slayyy")
        let calendar = Calendar.current
        let now = Date()
        
        // Define the start of the 7-day period by subtracting 6 days from today
        let startOfPeriod = startDate
        // Define the end of the period as now
        let endOfPeriod = now
        
        // Create the predicate for fetching samples from the start to end of the week
        let predicate = HKQuery.predicateForSamples(withStart: startOfPeriod, end: endOfPeriod)
        
        // Create the query to fetch weekly data
        let query = HKStatisticsCollectionQuery(
            quantityType: quantityType,
            quantitySamplePredicate: predicate,
            options: .cumulativeSum,
            anchorDate: startOfPeriod,
            intervalComponents: DateComponents(day: 1)
        )
        
        // Handle the results of the query
        query.initialResultsHandler = { query, result, error in
            if let error = error {
                print("HealthKit query error: \(error.localizedDescription)")
                completion(nil, error)
                return
            }
            
            guard let result = result else {
                print("No results returned from HealthKit.")
                completion(nil, nil)
                return
            }
            // Retrieve the statistics and print each one
            let stats = result.statistics()
            
            print("Fetched \(stats.count) data points:")
            for stat in stats {
                let startDate = stat.startDate
                let endDate = stat.endDate
                
                // Print the cumulative sum if available
                if let quantity = stat.sumQuantity() {
                    let value = quantity.doubleValue(for: HKUnit.meter()) // Convert to appropriate unit, e.g., steps
                    print("From \(startDate) to \(endDate): \(value) steps")
                } else {
                    print("No data available for dates \(startDate) to \(endDate)")
                }
            }
            
            completion(stats, nil)
        }
        healthStore.execute(query)
    }
    
    func getWeeklyStepCountData(completion: @escaping ([HKStatistics]?, Error?) -> Void) {
        let stepCount = HKObjectType.quantityType(forIdentifier: .stepCount)!
        let calendar = Calendar.current
        let now = Date()
        
        let endOfWeek = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: now)
        let endOfWeekDate = calendar.date(from: endOfWeek)!
        let startOfWeekDate = calendar.date(byAdding: .day, value: -7, to: endOfWeekDate)!
        
        let predicate = HKQuery.predicateForSamples(withStart: startOfWeekDate, 
                                                    end: endOfWeekDate)
        let query = HKStatisticsCollectionQuery(
            quantityType: stepCount,
            quantitySamplePredicate: predicate,
            options: .cumulativeSum,
            anchorDate: startOfWeekDate,
            intervalComponents: DateComponents(day: 1)
        )
        
        query.initialResultsHandler = { query, result, error in
            guard let result = result else {
                completion(nil, error)
                return
            }
            let stats = result.statistics()
            
            completion(stats, nil)
        }
        healthStore.execute(query)
    }
    
    func getStepCountData(completion: @escaping (Double?, Error?) -> Void) {
        let stepCount = HKObjectType.quantityType(forIdentifier: .stepCount)!
        let calendar = NSCalendar.current
        let now = Date()
        let startOfDay = calendar.startOfDay(for: now)
        
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: now, options: .strictStartDate)
        let query = HKStatisticsQuery(quantityType: stepCount, quantitySamplePredicate: predicate, options: .cumulativeSum) { query, result, error in
            guard let result = result, let sum = result.sumQuantity() else {
                completion(nil, error)
                return
            }
            let stepCount = sum.doubleValue(for: HKUnit.count())
            completion(stepCount, nil)
        }
        healthStore.execute(query)
    }
    
    func getDistanceData(completion: @escaping (Double?, Error?) -> Void) {
        let distance = HKObjectType.quantityType(forIdentifier: .distanceWalkingRunning)!
        let calendar = NSCalendar.current
        let now = Date()
        let startOfDay = calendar.startOfDay(for: now)
        
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: now, options: .strictStartDate)
        let query = HKStatisticsQuery(quantityType: distance, quantitySamplePredicate: predicate, options: .cumulativeSum) { query, result, error in
            guard let result = result, let sum = result.sumQuantity() else {
                completion(nil, error)
                return
            }
            let distance = sum.doubleValue(for: HKUnit.meter())
            completion(distance, nil)
        }
        healthStore.execute(query)
    }
}
