//
//  ContentView.swift
//  Shared
//
//  Created by Christopher Schütz on 23.04.21.
//

import SwiftUI
import HealthKit
import Combine

/// manages access to healthkit
public class HealthKitManager {
    /// healthstore
    public static let healthStore = HKHealthStore()
    
    private var allTypes: Set<HKObjectType> {
            guard let stepCountType = HKObjectType.quantityType(forIdentifier: .stepCount) else {
                return Set()
            }
            return Set([
                stepCountType,
                HKObjectType.workoutType()
            ])
    }
    
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
    
    func addWorkout(_ workout: HKWorkout) {
        workouts.append(workout)
    }
}

struct ContentView: View {
    // State vs Observed Object vs EnvironmentObject:
    // https://www.hackingwithswift.com/quick-start/swiftui/whats-the-difference-between-observedobject-state-and-environmentobject#:~:text=The%20rule%20is%20this%3A%20whichever,don't%20own%20it%20directly.
    
    @State private var healthKitManager: HealthKitManager?
    
    // For more complex properties - when you have a custom type you want to
    // use that might have multiple properties and methods, or might be shared
    // across multiple views - you will often use Observed Object instead.
    //
    // The devloper is responsible for managing the data herself. She needs to
    // create an instance of the class, create its own properties, and so on.
    //
    // There are several ways for an observed object to notify views that important
    // data has changed, but the easiest is using the @Published property wrapper.
    @ObservedObject var model = Model(workouts: [])
    
    // State is great for simple properties that belong to a specific view and
    // never get used outside that view, so as a result it's important to mark those
    // properties as being private to re-enforce the idea that such state is specifically
    // designed never to escape its view.
    //
    // SwiftUI manages the memory requirements for this property.
    @State private var objectLoaded = false
    
    func getResults() {
        if objectLoaded {
            return
        }
        let query = HKSampleQuery(
            sampleType: .workoutType(),
            predicate: nil,
            limit: 5,
            sortDescriptors: nil) { _, result, error in
            guard let samples = result as? [HKWorkout], error == nil else {
                print("HealthService error \(String(describing: error))")
                return
            }
            
            DispatchQueue.main.sync {
                // Update the UI here.
                _ = samples.map { sample in
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

struct ContentView_Previews: PreviewProvider {
    // StateObject is a specialized version of ObservedObject and it works in almost
    // exactly the same way.
    // The important difference is ownership - which view created the object, and which
    // view is just watching it. Whichever view is the first to create the object must
    // use StateObject, to tell SwiftUI it is the owner of the data and is responsible for keeping it alive.
    // All other view must use @ObservedObject, to tell SwiftUI they want to watch the object for changes
    // but don't own it directly.
    @StateObject private static var model = Model(workouts: [])
    
    static var previews: some View {
        ContentView(
            healthKitManager: HealthKitManager()
        )
        .previewDevice(PreviewDevice(rawValue: "iPhone X"))
    }
}
