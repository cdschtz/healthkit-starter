//
//  WorkoutService.swift
//  healthkit-starter (iOS)
//
//  Created by Christopher Schütz on 28.04.21.
//

import Combine
import HealthKit

/// provides download functionality for workouts
public class WorkoutService {
    var workoutLoaded: Bool
    
    init() {
        self.workoutLoaded = false
    }
    
    func printModelResults(_ model: Model) {
        var jsonString = ""
        let workout = model.workouts[0]
        jsonString.append("{\n")
        jsonString.append("\"data\": {\n")
        
        // general workout data
        jsonString.append("\"activityType\": \"Running Workout\",\n")
        jsonString.append("\"startDate\": \"\(workout.startDate)\",\n")
        jsonString.append("\"endDate\": \"\(workout.endDate)\",\n")
        jsonString.append("\"duration\": \"\(workout.duration)\",\n")
        // TODO: Start | save as object together with unit
        jsonString.append("\"totalDistance\": \"\(String(describing: workout.totalDistance))\",\n")
        jsonString.append("\"totalCalories\": \"\(String(describing: workout.totalEnergyBurned))\",\n")
        // TODO: End
        jsonString.append("\"sourceRevision\": \"\(workout.sourceRevision)\",\n")
        
        // heartRateSamples
        jsonString.append("\"heartRateSamples\": [\n")
        for hrSample in model.heartRateSamples {
            // TODO: Include all heartRate info: currently missing
            jsonString.append("{\"startTime\": \"\(hrSample.startDate)\", \"quantity\": \"\(hrSample.quantity)\"},\n")
        }
        jsonString.append("],\n")
        
        // locations
        // TODO: Watch out if multiple routes exist for one workout
        jsonString.append("\"locations\": [\n")
        for location in model.locations {
            jsonString.append("{\"Altitude\": \(location.altitude), \"Latitude\": \(location.coordinate.latitude), \"Longitude\": \(location.coordinate.longitude), \"Speed in m/s\": \(location.speed), \"speedAccuracy\": \(location.speedAccuracy), \"Timestamp\": \"\(location.timestamp)\"},\n")
        }
        jsonString.append("],\n")
        
        jsonString.append("}\n")
        jsonString.append("}")
        
        // print whole workout object
        print(jsonString)
    }
    
    func fetchRunWorkoutByDate(startDate: Date, endDate: Date, model: Model) {
        let workoutDay = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: [])
        
        let sortByDate = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: true)
        
        let query = HKSampleQuery(
            sampleType: .workoutType(),
            predicate: workoutDay,
            limit: 5,
            sortDescriptors: [sortByDate]
        ) { _, result, error in
            guard let samples = result as? [HKWorkout], error == nil else {
                print("HealthService error \(String(describing: error))")
                return
            }
            
            for sample in samples where sample.workoutActivityType == HKWorkoutActivityType.running {
                // Process each sample here.
                self.fetchHeartRateSamples(sample, model: model)
                self.fetchWorkoutRoute(sample, model: model)
            }
            
            DispatchQueue.main.sync {
                // Update the UI here.
                _ = samples.map { sample in
                    if sample.workoutActivityType == HKWorkoutActivityType.running {
                        model.addWorkout(sample)
                    }
                }
            }
        }
        
        HealthKitManager.healthStore.execute(query)
    }
    
    func fetchHeartRateSamples(_ workout: HKWorkout, model: Model) {
        let workoutTimeFrame = HKSampleQuery.predicateForSamples(withStart: workout.startDate, end: workout.endDate, options: [])
        
        let heartRateType = HKQuantityType.quantityType(forIdentifier: .heartRate)!
        
        let sortByDate = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: true)
        
        let query = HKSampleQuery(
            sampleType: heartRateType,
            predicate: workoutTimeFrame,
            limit: 0,
            sortDescriptors: [sortByDate]
        ) { _, result, _ in
            guard let samples = result as? [HKQuantitySample] else {
                // Handle any errors here.
                return
            }
            
            // The results come back on an anonymous background queue.
            // Dispatch to the main queue before modifying the UI.
            
            DispatchQueue.main.async {
                // Update the UI here.
                _ = samples.map { sample in
                    model.addHeartRateSample(sample)
                }
            }
        }
        
        HealthKitManager.healthStore.execute(query)
    }
    
    func fetchWorkoutRoute(_ workout: HKWorkout, model: Model) {
        // details here:
        // https://developer.apple.com/documentation/healthkit/workouts_and_activity_rings/reading_route_data
        let runningObjectQuery = HKQuery.predicateForObjects(from: workout)

        let routeQuery = HKAnchoredObjectQuery(
            type: HKSeriesType.workoutRoute(),
            predicate: runningObjectQuery,
            anchor: nil,
            limit: HKObjectQueryNoLimit
        ) { _, samples, _, _, error in
            guard error == nil else {
                // Handle any errors here.
                fatalError("The initial query failed.")
            }
            
            guard let samples = samples as? [HKWorkoutRoute] else {
                return
            }
            
            DispatchQueue.main.async {
                // Update the UI here.
                model.addRoutes(samples)
                _ = samples.map { sample in
                    self.fetchRouteSampleLocationData(sample, model: model)
                }
            }
        }

        HealthKitManager.healthStore.execute(routeQuery)
    }
    
    func fetchRouteSampleLocationData(_ route: HKWorkoutRoute, model: Model) {
        let query = HKWorkoutRouteQuery(route: route) { _, locationsOrNil, done, errorOrNil in
            // This block may be called multiple times.
            
            if errorOrNil != nil {
                // Handle any errors here.
                return
            }
            
            guard let locations = locationsOrNil else {
                fatalError("*** Invalid State: This can only fail if there was an error. ***")
            }
            
            DispatchQueue.main.async {
                // Update the UI here.
                model.addLocations(locations)
            }
                
            if done {
                // The query returned all the location data associated with the route.
                // Do something with the complete data set.
                self.printModelResults(model)
                
                // INFO: model is complete now
                DispatchQueue.main.async {
                    model.dataLoaded = true
                }
            }
            
            // You can stop the query by calling:
            // store.stop(query)
            
        }
        HealthKitManager.healthStore.execute(query)
    }
}
