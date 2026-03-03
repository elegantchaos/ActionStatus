//
//  File.swift
//  Application
//
//  Created by Sam Deane on 03/03/2026.
//

import Foundation

/// The run state of the engine.
public indirect enum EngineState {
  /// Nothing has happened yet.
  case uninitialised
  
  /// We've called initialise() and are waiting for startup() to complete.
  /// The startup UI will be showing.
  case starting
  
  /// We completed startup() without error.
  /// The running UI will be showing.
  case running
  
  /// We caught an error during initialisation or startup, or
  /// were given one to display.
  /// The error UI will be showing.
  case error(Error, EngineState)
  
  /// We're shutting down.
  /// The running UI will still be showing.
  case terminating
}
