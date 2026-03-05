//
//  TestServices.swift
//  TestApplication
//
//  Created by Sam Deane on 05/03/2026.
//

import Application
import Foundation
import SwiftUI

@MainActor @Observable class ServiceA {
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


struct ServiceAView: View {
  @Environment(ServiceA.self) var serviceA

  var body: some View {
    VStack {
      Text("A is \(serviceA.value)")
      Button("Change A") {
        serviceA.value += 1
      }
      Text("(body called \(bodyCount)")
    }
  }

  static var bodyCount = 0
  var bodyCount: Int {
    let v = Self.bodyCount + 1
    Self.bodyCount = v
    return v
  }
}

struct ServiceBView: View {
  @Environment(ServiceB.self) var serviceB

  var body: some View {
    VStack {
      Text("B is \(serviceB.value)")
      Button("Change B") {
        serviceB.value += 1
      }
      Text("(body called \(bodyCount)")
    }
  }

  static var bodyCount = 0
  var bodyCount: Int {
    let v = Self.bodyCount + 1
    Self.bodyCount = v
    return v
  }
}
