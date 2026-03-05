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
    onChange(of: serviceA.value) { newValue in
      assert(serviceA.value == newValue)
      print("service a changed to \(newValue)")
      self.value = newValue
    }

    withObservationTracking {
      _ = serviceA.value
    } onChange: {
      Task { @MainActor in
      }
    }
  }
}

func onChange<V>(of value: @escaping @autoclosure () -> V, perform: @escaping (V) -> ()) {
  withObservationTracking {
    _ = value()
  } onChange: {
    Task { @MainActor in
      perform(value())
      onChange(of: value(), perform: perform)
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
