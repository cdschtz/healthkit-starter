//
//  healthkit_starterApp.swift
//  Shared
//
//  Created by Christopher Schütz on 23.04.21.
//

import SwiftUI
import HealthKit

@main
struct healthkit_starterApp: App {
    var healthKitManager: HealthKitManager = HealthKitManager()
    
    @StateObject private var model: Model = Model(
        workouts: [
            HKWorkout(
                activityType: .americanFootball,
                start: makeDate(year: 2021, month: 4, day: 26, hr: 12, min: 0, sec: 0),
                end: makeDate(year: 2021, month: 4, day: 26, hr: 13, min: 0, sec: 0)
            )
        ])
    
    var body: some Scene {
        WindowGroup {
            ContentView(healthKitManager: healthKitManager)
                .environmentObject(model)
        }
    }
}
