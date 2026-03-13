import Combine
import Foundation
import Observation

/// Tracks a main-actor value and reruns the action whenever Observation reports a change.
@MainActor
public func observeChange<Value>(
  of value: @escaping @autoclosure @MainActor () -> Value,
  perform: @escaping @MainActor (Value) -> Void
) {
  withObservationTracking {
    _ = value()
  } onChange: {
    Task { @MainActor in
      perform(value())
      observeChange(of: value(), perform: perform)
    }
  }
}

public extension UserDefaults {
  /// Calls the supplied action whenever defaults change.
  func onActionStatusSettingsChanged(_ action: @escaping @MainActor () -> Void) -> AnyCancellable {
    NotificationCenter.default
      .publisher(for: UserDefaults.didChangeNotification, object: self)
      .sink { _ in
        Task { @MainActor in
          action()
        }
      }
  }
}
