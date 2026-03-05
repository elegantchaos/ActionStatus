import SwiftUI

@MainActor public func onChange<V>(
  of value: @escaping @autoclosure @MainActor () -> V,
  perform: @escaping @MainActor (V) -> Void
) {
  withObservationTracking {
    _ = value()
  } onChange: {
    Task { @MainActor in
      perform(value())
      onChange(of: value(), perform: perform)
    }
  }
}

nonisolated public func onChangeSendable<V>(of value: @escaping @autoclosure @Sendable () -> V, perform: @escaping @Sendable (V) -> Void) {
  withObservationTracking {
    _ = value()
  } onChange: {
      perform(value())
    onChangeSendable(of: value(), perform: perform)
  }
}

