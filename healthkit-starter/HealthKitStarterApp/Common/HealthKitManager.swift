//
//  HealthKitManager.swift
//  healthkit-starter (iOS)
//
//  Created by Christopher Schütz on 04.05.21.
//

import Foundation
import HealthKit

/// manages access to healthkit
public class HealthKitManager {
    /// healthstore
    public static let healthStore = HKHealthStore()
    
    private var allTypes: Set<HKObjectType> {
        guard let stepCountType = HKObjectType.quantityType(forIdentifier: .stepCount) else {
            return Set()
        }
        
        guard let heartRateType = HKObjectType.quantityType(forIdentifier: .heartRate) else {
            return Set()
        }
        
        return Set([
            stepCountType,
            heartRateType,
            HKObjectType.workoutType(),
            HKSeriesType.workoutRoute()
        ])
    }
    
    func requestAuthorization() {
        if HKHealthStore.isHealthDataAvailable() {
            HealthKitManager.healthStore.requestAuthorization(toShare: nil, read: allTypes) { _, error in
                print("Error: \(String(describing: error))")
            }
        }
    }
}
