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
            HKSampleType.quantityType(forIdentifier: .bodyMass)!,
        ]

        healthStore.requestAuthorization(toShare: typesToShare, read: typesToRead) { success, error in
            completion(success, error)
        }
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
            
            /*print("Number of statistics retrieved: \(stats.count)")

            for stat in stats {
                let startDate = stat.startDate
                let endDate = stat.endDate
                let sumQuantity = stat.sumQuantity()
                let steps = sumQuantity?.doubleValue(for: HKUnit.count()) ?? 0.0
                print("Start date: \(startDate), End date: \(endDate), Steps: \(steps)")
            }*/
            
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
