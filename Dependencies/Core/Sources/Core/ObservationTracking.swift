import Combine
import Foundation
import Observation

/// Token used to stop an installed observation callback.
@MainActor
public final class ObservationToken {
  @ObservationIgnored private var isCancelled = false

  /// Cancels future observation callbacks.
  public func cancel() {
    isCancelled = true
  }

  var cancelled: Bool {
    isCancelled
  }
}

/// Tracks a main-actor value and reruns the action whenever Observation reports a change.
@MainActor
@discardableResult
public func observeChange<Value>(
  of value: @escaping @autoclosure @MainActor @Sendable () -> Value,
  perform: @escaping @MainActor @Sendable (Value) -> Void
) -> ObservationToken {
  let token = ObservationToken()
  installObservation(token: token, value: value, perform: perform)
  return token
}

/// Installs a cancellable observation loop for a main-actor value.
@MainActor
private func installObservation<Value>(
  token: ObservationToken,
  value: @escaping @MainActor @Sendable () -> Value,
  perform: @escaping @MainActor @Sendable (Value) -> Void
) {
  withObservationTracking {
    guard !token.cancelled else { return }
    _ = value()
  } onChange: {
    Task { @MainActor in
      guard !token.cancelled else { return }
      perform(value())
      installObservation(token: token, value: value, perform: perform)
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
