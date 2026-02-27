// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 23/03/21.
//  All code (c) 2021 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

public enum SortMode: String, CaseIterable {
  case name
  case state

  public func sort<T>(_ repos: T) -> [Repo] where T: Collection, T.Element == Repo {
    switch self {
      case .name: return repos.sorted { $0.name < $1.name }
      case .state:
        return repos.sorted { r1, r2 in
          let p1 = statePriority(for: r1.state)
          let p2 = statePriority(for: r2.state)
          if p1 == p2 {
            if r1.state == r2.state {
              return r1.name < r2.name
            }

            return r1.state.rawValue > r2.state.rawValue
          }

          return p1 > p2
        }
    }
  }

  private func statePriority(for state: Repo.State) -> Int {
    switch state {
      case .running:
        return 4
      case .failing, .partiallyFailing:
        return 3
      case .passing, .queued:
        return 2
      case .dormant:
        return 1
      case .unknown:
        return 0
    }
  }
}

extension SortMode {
  public var labelName: String {
    switch self {
      case .name: return "Name"
      case .state: return "State"
    }
  }
}
