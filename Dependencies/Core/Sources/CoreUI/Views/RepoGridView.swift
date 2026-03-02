// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 11/05/21.
//  All code (c) 2021 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import SwiftUI

public struct RepoGridView: View {
  @Environment(RepoState.self) var status
  @Environment(SettingsService.self) var settings
  @AppStorage(.displaySize) var displaySize
  
   let namespace: Namespace.ID

  #if os(tvOS)
    let focus: FocusState<Focus?>.Binding
  #endif

  public var body: some View {
    ScrollView(.vertical) {
      LazyVGrid(columns: repoGridColumns, spacing: 0) {
        ForEach(status.sortedRepos) { repo in
          #if os(tvOS)
            RepoCellView(repo: repo, selectable: false, namespace: namespace, focus: focus)
          #else
            RepoCellView(repo: repo, selectable: false, namespace: namespace)
          #endif
        }
      }
    }
    .padding()
  }
  
  var repoGridColumns: [GridItem] {
    let count: Int
    switch displaySize {
      case .small: count = 4
      case .medium: count = 3
      default: count = 2
    }
    
#if os(tvOS)
    return Array(repeating: .init(.flexible()), count: count)
#else
    let cols = CGFloat(count)
    return [GridItem(.adaptive(minimum: 640 / cols, maximum: .infinity))]
#endif
  }

}

//struct RepoGridView_Previews: PreviewProvider {
//    static var previews: some View {
//        return PreviewContext().inject(into: RepoGridView())
//    }
//}
