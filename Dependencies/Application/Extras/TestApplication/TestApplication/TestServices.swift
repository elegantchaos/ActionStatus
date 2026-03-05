//
//  TestServices.swift
//  TestApplication
//
//  Created by Sam Deane on 05/03/2026.
//

import Foundation
import SwiftUI

@Observable class ServiceA {
  var value = 0
}

@Observable class ServiceB {
  var value = 0
  let serviceA: ServiceA
  
  init(serviceA: ServiceA) {
    self.serviceA = serviceA
    withObservationTracking {
      _ = serviceA.value
    } onChange: {
      Task { @MainActor in
        print("service a changed to \(serviceA.value)")
        self.value = serviceA.value
      }
    }
  }
}

struct ServiceAView: View {
  @Environment(ServiceA.self) var serviceA
  
  var body: some View {
    Text("A is \(serviceA.value)")
    Button("Change A") {
      serviceA.value += 1
    }
  }
}

struct ServiceBView: View {
  @Environment(ServiceB.self) var serviceB

  var body: some View {
    Text("B is \(serviceB.value)")
  }
}
