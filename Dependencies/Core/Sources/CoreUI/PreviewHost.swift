//
//  File.swift
//  Core
//
//  Created by Sam Deane on 02/03/2026.
//

import Foundation

@MainActor struct PreviewHost: ApplicationHost {
  func modelDidChange() {
  }
  
  func settingsDidChange() {
  }
  
  let info = Bundle.main.runtimeInfo
  var refreshController: RefreshController? { return nil }
}
