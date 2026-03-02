// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 28/01/2026.
//  Copyright © 2026 Elegant Chaos Limited. All rights reserved.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation

/// Boolean setting keys.
public extension AppSettingKey where Value == Bool {
  /// UserDefaults key for the setting that controls whether summaries are shown in item lists.
  static let showSummary = AppSettingKey("showSummary", defaultValue: false)

  /// UserDefaults key for the setting that controls whether the editor pops back automatically after changing the status of an item.
  static let autoPop = AppSettingKey("autoPop", defaultValue: true)

  /// UserDefaults key for the setting that controls whether we show extra debug options.
  static let showDebug = AppSettingKey("showDebugOptions", defaultValue: false)
}
