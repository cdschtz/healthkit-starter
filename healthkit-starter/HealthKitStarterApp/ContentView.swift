//
//  ContentView.swift
//  Shared
//
//  Created by Christopher Schütz on 23.04.21.
//

import SwiftUI
import HealthKit
import Combine
import CoreLocation

struct ContentView: View {
    @State private var healthKitManager: HealthKitManager?
    
    @ObservedObject var model = Model(workouts: [])
    
    init(healthKitManager: HealthKitManager) {
        self.healthKitManager = healthKitManager
    }
    
    var body: some View {
        VStack {
            switch self.model.dataLoaded {
            case false:
                Text("Loading")
            case true:
                Text("Finished!")
            }
        }
        .onAppear {
            self.healthKitManager?.requestAuthorization()
            
            let service = WorkoutService()
            
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy/MM/dd HH:mm"
                    
            guard let startDate = formatter.date(from: "2021/05/02 00:00") else {
                fatalError("*** Unable to create the start date ***")
            }
            
            guard let endDate = formatter.date(from: "2021/05/02 23:59") else {
                fatalError("*** Unable to create the end date ***")
            }
            
            service.fetchRunWorkoutByDate(startDate: startDate, endDate: endDate, model: self.model)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    @StateObject private static var model = Model(workouts: [])
    
    static var previews: some View {
        ContentView(
            healthKitManager: HealthKitManager()
        )
        .previewDevice(PreviewDevice(rawValue: "iPhone X"))
    }
}
