//
//  healthkit_starterApp.swift
//  Shared
//
//  Created by Christopher Schütz on 23.04.21.
//

import SwiftUI
import HealthKit

@main
struct HealthKitStarterApp: App {
    var healthKitManager = HealthKitManager()
    
    @StateObject private var model = Model(workouts: [])
    
    var body: some Scene {
        WindowGroup {
            ContentView(healthKitManager: healthKitManager)
                .environmentObject(model)
        }
    }
}
