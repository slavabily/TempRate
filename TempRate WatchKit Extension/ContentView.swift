//
//  ContentView.swift
//  TempRate WatchKit Extension
//
//  Created by slava bily on 07.12.2020.
//

import SwiftUI
import HealthKit

struct ContentView: View {
    
    private var healthStore = HKHealthStore()
    let bodyTemperatureQuantity = HKUnit(from: "degC")
        
    @State private var value = 36.6
    
    func start() {
        authorizeHealthKit()
        startBodyTemperatureQuery(quantityTypeIdentifier: .bodyTemperature)
    }
    
    func authorizeHealthKit() {
        
        // Used to define the identifiers that create quantity type objects.
        let healthKitTypes: Set = [
            HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.bodyTemperature)!]
        // Requests permission to save and read the specified data types.
        healthStore.requestAuthorization(toShare: healthKitTypes, read: healthKitTypes) { _, _ in }
    }
    
    private func process(_ samples: [HKQuantitySample], type: HKQuantityTypeIdentifier) {
        // variable initialization
        var lastBodyTemperatureRate = 0.0
        
        // cycle and value assignment
        for sample in samples {
            if type == .bodyTemperature {
                lastBodyTemperatureRate = sample.quantity.doubleValue(for: bodyTemperatureQuantity)
            }
            
            self.value = lastBodyTemperatureRate
            
            print("The last temperature value is: \(value)")
        }
    }
    
    private func startBodyTemperatureQuery(quantityTypeIdentifier: HKQuantityTypeIdentifier) {
            
            // We want data points from our current device
            let devicePredicate = HKQuery.predicateForObjects(from: [HKDevice.local()])
            
            // A query that returns changes to the HealthKit store, including a snapshot of new changes and continuous monitoring as a long-running query.
            let updateHandler: (HKAnchoredObjectQuery, [HKSample]?, [HKDeletedObject]?, HKQueryAnchor?, Error?) -> Void = {
                query, samples, deletedObjects, queryAnchor, error in
                
             // A sample that represents a quantity, including the value and the units.
            guard let samples = samples as? [HKQuantitySample] else {
                return
            }
                
            self.process(samples, type: quantityTypeIdentifier)

            }
            
            // It provides us with both the ability to receive a snapshot of data, and then on subsequent calls, a snapshot of what has changed.
            let query = HKAnchoredObjectQuery(type: HKObjectType.quantityType(forIdentifier: quantityTypeIdentifier)!, predicate: devicePredicate, anchor: nil, limit: HKObjectQueryNoLimit, resultsHandler: updateHandler)
            
            query.updateHandler = updateHandler
            
            // query execution
            
            healthStore.execute(query)
        }
    
    var body: some View {
            VStack{
                HStack{
                    Text("""
                            Body
                            temp
                        """)
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(Color.red)
                        .padding(.bottom, 28.0)
                    Spacer()
                    Text("🌡")
                        .font(.system(size: 50))
                    Spacer()

                }
                
                HStack{
                    Text("\(value, specifier: "%.1f")")
                        .fontWeight(.regular)
                        .font(.system(size: 60))
                    
                    Text("℃")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(Color.red)
                        .padding(.bottom, 28.0)
                    
                    Spacer()
                }
            }
            .padding()
            .onAppear(perform: start)
        }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
