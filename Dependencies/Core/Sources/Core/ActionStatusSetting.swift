import Commands
import Foundation

/// Type-safe setting key used by ActionStatus core services.
public struct ActionStatusSettingKey<Value> {
  /// The raw defaults key.
  public let key: String

  /// The default value used when no explicit value is stored.
  public let defaultValue: Value

  /// Creates a typed setting key.
  public init(_ key: String, defaultValue: Value) {
    self.key = key
    self.defaultValue = defaultValue
  }
}

/// Boolean setting keys.
public extension ActionStatusSettingKey where Value == Bool {
  static let showInMenu = ActionStatusSettingKey("ShowInMenu", defaultValue: true)
  static let showInDock = ActionStatusSettingKey("ShowInDock", defaultValue: true)
}

public extension ActionStatusSettingKey where Value == RefreshRate {
  static let refreshInterval = ActionStatusSettingKey("RefreshInterval", defaultValue: .automatic)
}

public extension ActionStatusSettingKey where Value == SortMode {
  static let sortMode = ActionStatusSettingKey("SortMode", defaultValue: .state)
}

public extension ActionStatusSettingKey where Value == NavigationMode {
  static let navigationMode = ActionStatusSettingKey("NavigationMode", defaultValue: .edit)
  static let secondaryNavigationMode = ActionStatusSettingKey("SecondaryNavigationMode", defaultValue: .viewRepo)
  static let tertiaryNavigationMode = ActionStatusSettingKey("TertiaryNavigationMode", defaultValue: .viewWorkflows)
}

public extension ActionStatusSettingKey where Value == DisplaySize {
  static let displaySize = ActionStatusSettingKey("DisplaySize", defaultValue: .automatic)
}

/// String setting keys.
public extension ActionStatusSettingKey where Value == String {
  static let githubUser = ActionStatusSettingKey("GithubUser", defaultValue: "")
  static let githubServer = ActionStatusSettingKey("GithubServer", defaultValue: "api.github.com")
}

/// Data setting keys.
public extension ActionStatusSettingKey where Value == Data {
  static let hotKeyCombo = ActionStatusSettingKey("hotKeyCombo", defaultValue: Data())
}

public extension UserDefaults {
  /// Returns the stored or default raw-representable setting value.
  func actionStatusValue<V>(for key: ActionStatusSettingKey<V>) -> V where V: RawRepresentable {
    if let raw = object(forKey: key.key) as? V.RawValue, let value = V(rawValue: raw) {
      return value
    }
    return key.defaultValue
  }

  /// Stores a raw-representable setting value.
  func setActionStatusValue<V>(_ value: V, for key: ActionStatusSettingKey<V>) where V: RawRepresentable {
    set(value.rawValue, forKey: key.key)
  }

  /// Returns the stored or default setting value.
  func actionStatusValue<V>(for key: ActionStatusSettingKey<V>) -> V {
    object(forKey: key.key) as? V ?? key.defaultValue
  }

  /// Stores a settings-compatible value.
  func setActionStatusValue<V>(_ value: V, for key: ActionStatusSettingKey<V>) {
    set(value, forKey: key.key)
  }
}

public extension UserDefaults {
  /// Returns the configured repository navigation mode for the specified click trigger.
  func repoNavigationMode(for trigger: CommandTrigger) -> NavigationMode {
    switch trigger {
      case .primary:
        actionStatusValue(for: .navigationMode)
      case .secondary:
        actionStatusValue(for: .secondaryNavigationMode)
      case .tertiary:
        actionStatusValue(for: .tertiaryNavigationMode)
    }
  }
}
