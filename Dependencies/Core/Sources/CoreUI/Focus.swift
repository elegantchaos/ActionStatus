// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 11/05/21.
//  All code (c) 2021 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

/// Focus state values for keyboard and remote navigation in ActionStatus.
///
/// Used as the generic parameter of `FocusState<Focus?>` throughout repo list
/// and grid views. `.prefs` provides a target for the tvOS preferences button
/// in `FooterView`.
public enum Focus: Hashable, Equatable {
  /// Focus is on the repository cell with the given stable ID.
  case repo(String)
  /// Focus is on the preferences button.
  case prefs
}
