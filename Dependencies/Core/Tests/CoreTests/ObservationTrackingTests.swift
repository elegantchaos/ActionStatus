import XCTest

@testable import Core

/// Tests the cancellable observation helper used by Core services.
@MainActor
final class ObservationTrackingTests: XCTestCase {
  /// Simple observable value source for observation tests.
  @Observable
  final class ObservableValue {
    var value = 0
  }

  /// Verifies that each sequential change produces one callback.
  func testObserveChangeDeliversOneCallbackPerSequentialChange() async {
    let source = ObservableValue()
    let firstCallback = expectation(description: "first callback")
    let secondCallback = expectation(description: "second callback")
    var observedValues: [Int] = []

    _ = observeChange(of: source.value) { value in
      observedValues.append(value)
      switch value {
      case 1:
        firstCallback.fulfill()
      case 2:
        secondCallback.fulfill()
      default:
        break
      }
    }

    source.value = 1
    await fulfillment(of: [firstCallback], timeout: 1.0)

    source.value = 2
    await fulfillment(of: [secondCallback], timeout: 1.0)

    XCTAssertEqual(observedValues, [1, 2])
  }

  /// Verifies that cancelling the token stops later callbacks.
  func testObservationTokenCancelStopsFutureCallbacks() async {
    let source = ObservableValue()
    let firstCallback = expectation(description: "first callback")
    let cancelledCallback = expectation(description: "cancelled callback")
    cancelledCallback.isInverted = true

    let token = observeChange(of: source.value) { value in
      if value == 1 {
        firstCallback.fulfill()
      } else {
        cancelledCallback.fulfill()
      }
    }

    source.value = 1
    await fulfillment(of: [firstCallback], timeout: 1.0)

    token.cancel()
    source.value = 2

    await fulfillment(of: [cancelledCallback], timeout: 0.2)
  }
}
