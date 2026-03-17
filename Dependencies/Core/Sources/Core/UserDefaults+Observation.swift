import Application
import Foundation

public extension UserDefaults {
  /// Calls the supplied action whenever defaults change.
  @MainActor
  func onActionStatusSettingsChanged(_ action: @escaping @MainActor () -> Void) -> NotificationToken
  {
    NotificationCenter.default.onMainActorNotification(
      named: UserDefaults.didChangeNotification,
      object: self
    ) {
      action()
    }
  }
}
