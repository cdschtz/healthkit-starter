//
//  ContentView.swift
//  Shared
//
//  Created by Christopher Schütz on 23.04.21.
//

import SwiftUI
import HealthKit
import Combine

public class HealthKitManager {
    
    public static let healthStore = HKHealthStore()
    
    private let allTypes = Set([
        //        HKObjectType.characteristicType(forIdentifier: .biologicalSex),
        HKObjectType.quantityType(forIdentifier: .stepCount)!,
        HKObjectType.workoutType()
    ])
    
    func requestAuthorization() {
        if HKHealthStore.isHealthDataAvailable() {
            print("authorizing...")
            
            HealthKitManager.healthStore.requestAuthorization(toShare: nil, read: allTypes) { _, error in
                print("Error: \(String(describing: error))")
            }
        }
    }
}

class Model: ObservableObject {
    @Published var workouts: [HKWorkout]
    private var cancellables = Set<AnyCancellable>()
    
    init(workouts: [HKWorkout]) {
        self.workouts = workouts
    }
    
    public func addWorkout(_ workout: HKWorkout) {
        workouts.append(workout)
    }
}

struct ContentView: View {
    
    @State var healthKitManager: HealthKitManager? = nil
    
    @ObservedObject var model: Model = Model(workouts: [
//        HKWorkout(
//            activityType: .americanFootball,
//            start: makeDate(year: 2021, month: 4, day: 26, hr: 12, min: 0, sec: 0),
//            end: makeDate(year: 2021, month: 4, day: 26, hr: 13, min: 0, sec: 0)
//        )
    ])
    @State private var objectLoaded = false
    
    func getResults() {
        if objectLoaded {
            return
        }
        let query = HKSampleQuery(
            sampleType: .workoutType(),
            predicate: nil,
            limit: 5,
            sortDescriptors: nil) { (_, result, error) in
            
            guard let samples = result as? [HKWorkout], error == nil else {
                print("HealthService error \(String(describing: error))")
                return
            }
            // get Workout Information
            for sample in samples {
                self.model.addWorkout(sample)
//                model.addWorkout(sample)
            }
            
            DispatchQueue.main.sync {
                // Update the UI here.
                let _ = samples.map { sample in
                    self.model.addWorkout(sample)
                }
                objectLoaded = true
            }
        }
        
        HealthKitManager.healthStore.execute(query)
    }
    
    init(healthKitManager: HealthKitManager) {
        self.healthKitManager = healthKitManager
    }
    
    var body: some View {
        VStack {
            Text("Top of the list")
            List {
                ForEach(model.workouts, id: \.self) { workout in
                    Text("Workout\nActivity Type: \(workout)")
                }
            }
        }
        .onAppear {
            self.healthKitManager?.requestAuthorization()
            getResults()
        }
    }
}

func makeDate(year: Int, month: Int, day: Int, hr: Int, min: Int, sec: Int) -> Date {
    let calendar = Calendar(identifier: .gregorian)
    // calendar.timeZone = TimeZone(secondsFromGMT: 0)!
    let components = DateComponents(year: year, month: month, day: day, hour: hr, minute: min, second: sec)
    return calendar.date(from: components)!
}

struct ContentView_Previews: PreviewProvider {
    @StateObject private static var model: Model = Model(
        workouts: [
            HKWorkout(
                activityType: .americanFootball,
                start: makeDate(year: 2021, month: 4, day: 26, hr: 12, min: 0, sec: 0),
                end: makeDate(year: 2021, month: 4, day: 26, hr: 13, min: 0, sec: 0)
            )
        ])
    
    static var previews: some View {
        ContentView(
            healthKitManager: HealthKitManager()
        )
//        .environmentObject(model)
        .previewDevice(PreviewDevice(rawValue: "iPhone X"))
    }
}