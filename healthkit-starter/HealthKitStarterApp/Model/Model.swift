//
//  Model.swift
//  healthkit-starter (iOS)
//
//  Created by Christopher Schütz on 04.05.21.
//

import Foundation
import HealthKit
import CoreLocation

class Model: ObservableObject {
    @Published var dataLoaded: Bool
    
    @Published var workouts: [HKWorkout]
    @Published var heartRateSamples: [HKQuantitySample]
    @Published var routes: [HKWorkoutRoute]
    @Published var updatedRoutes: [HKWorkoutRoute]
    @Published var locations: [CLLocation]
    
    init(workouts: [HKWorkout]) {
        self.dataLoaded = false
        self.workouts = workouts
        self.heartRateSamples = []
        self.routes = []
        self.updatedRoutes = []
        self.locations = []
    }
    
    func addWorkout(_ workout: HKWorkout) {
        workouts.append(workout)
    }
    
    func addHeartRateSample(_ sample: HKQuantitySample) {
        heartRateSamples.append(sample)
    }
    
    func addRoutes(_ routes: [HKWorkoutRoute]) {
        self.routes.append(contentsOf: routes)
    }
    
    func addUpdatedRoutes(_ updatedRoutes: [HKWorkoutRoute]) {
        self.updatedRoutes.append(contentsOf: updatedRoutes)
    }
    
    func addLocations(_ locations: [CLLocation]) {
        self.locations.append(contentsOf: locations)
    }
}
