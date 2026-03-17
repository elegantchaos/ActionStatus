import Foundation
import Testing

@testable import Core

@MainActor
struct UbiquitousStoreTests {
  /// Verifies that direct per-repo writes remain discoverable after recreating the store.
  @Test
  func setPersistsRepoIntoIndex() {
    let key = uniqueKey()
    let repo = Repo("ActionStatus", owner: "elegantchaos", workflow: "Tests")

    clearStore(for: key, ids: [repo.id])

    let store = UbiquitousStore(key: key)
    store.set(repo, forKey: repo.id)

    let restored = UbiquitousStore(key: key)
    #expect(restored.values[repo.id] == repo)

    clearStore(for: key, ids: [repo.id])
  }

  /// Verifies that removals update the persisted index as well as the stored object.
  @Test
  func removeDeletesRepoFromIndex() {
    let key = uniqueKey()
    let repo = Repo("ActionStatus", owner: "elegantchaos", workflow: "Tests")

    clearStore(for: key, ids: [repo.id])

    let store = UbiquitousStore(key: key)
    store.set(repo, forKey: repo.id)
    store.remove(forKey: repo.id)

    let restored = UbiquitousStore(key: key)
    #expect(restored.values[repo.id] == nil)
    #expect(restored.values.isEmpty)

    clearStore(for: key, ids: [repo.id])
  }

  private func uniqueKey() -> String {
    "UbiquitousStoreTests.\(UUID().uuidString)"
  }

  private func clearStore(for key: String, ids: [String]) {
    let store = NSUbiquitousKeyValueStore.default
    store.removeObject(forKey: key)
    for id in ids {
      store.removeObject(forKey: id)
    }
    store.synchronize()
  }
}
