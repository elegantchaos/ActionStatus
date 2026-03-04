// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 04/03/2026.
//  Copyright © 2026 Elegant Chaos Limited. All rights reserved.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Commands
import CommandsUI

extension Engine: CommandCentre {
  
}
/*
 // -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
 //  Created by Sam Deane on 19/09/2025.
 //  Copyright © 2025 Elegant Chaos Limited. All rights reserved.
 // -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

 import Commands
 import CommandsUI
 import Foundation
 import Logger
 import StackAppearanceService
 import StackCore
 import StackHotKeyService
 import StackSuggestionsService
 import StackModelService
 import StackSheetService
 import StackTipJar
 import StackUICommon
 import SwiftData
 import SwiftUI

 let analyticsChannel = Channel("Analytics")

 @Observable
 public class StackCommandCentre: CommandCentre {
   public var modelContainer: ModelContainer?
   public var modelError: Error?
   public var modelErrorCount = 0
   public let sortState = SortState()
   public let searchState = SearchState()
   public let notifier = Notifier()
   public let router = Router()
   public let sheets = SheetController()
   public let sharer = Sharer()

   /// Appearance service.
   public let appearanceService = SwiftUIAppearanceService()

   /// Hotkey manager.
   public let hotKeyService = HotKeyService()

   /// Intelligence manager.
   public let suggestionsService = SuggestionsService()

   /// Tip management.
   public private(set) var tipJarModel: TipJarModel?

   /// Analytics values for this device, keyed by command ID.
   /// These are completely anonymous counts of how many times each command has been used
   /// on this device.
   public var analytics: [String: Int] = [:]

   /// Database record backing the analytics values.
   private var analyticsStorage: Analytics?

   public var modelContext: ModelContext {
     modelContainer!.mainContext
   }

   public init() {
     suggestionsService.onSuggestionsChanged = { [weak self] suggestions in
       self?.updateSuggestionsSheet(with: suggestions)
     }
   }

   /// Returns true when the model container is ready.
   public var isReady: Bool {
     modelContainer != nil
   }

   public func recordStartedCommand<C: Command>(_ command: C) where C.Centre: StackCommandCentre {
     incrementAnalytics(for: command)
   }

   public func recordFinishedCommand<C: Command>(_ command: C) where C.Centre: StackCommandCentre {
   }

   public func withEnvironment<V: View>(content: () -> V) -> some View {
     assert(isReady)

     return content()
       .modelContainer(modelContainer!)
       .environment(tipJarModel!)
       .environment(router)
       .environment(sortState)
       .environment(notifier)
       .environment(sharer)
       .environment(sheets)
       .environment(appearanceService)
       .environment(hotKeyService)
       .environment(suggestionsService)
       .environment(self)
   }

   public func setupContainer() {
     assert(modelContainer == nil)
     modelError = nil
     analytics = [:]
     analyticsStorage = nil
     tipJarModel = nil

     do {
       let container: ModelContainer

       if let testError = ProcessInfo.processInfo.environment["TEST_ERROR"], modelErrorCount == 0 {
         throw TestError.testError(testError)
       } else if let testDatabaseName = ProcessInfo.processInfo.environment["TEST_DATABASE"] {
         container = try setupTestContainer(named: testDatabaseName)
       } else {
         container = try setupRealContainer()
       }
       let analyticsStorage = container.deviceAnalytics

       self.modelContainer = container

       #if os(macOS)
         hotKeyService.handler = { [weak self] in
           if let self {
             NSApp.activate(ignoringOtherApps: true)
             if self.isReady {
               self.performWithoutWaiting(NewItemCommand<StackCommandCentre>())
             }
           }
         }
       #endif

       // setup tip jar
       tipJarModel = TipJarModel(modelContext: container.mainContext)
       Task { await tipJarModel?.loadProducts() }


       self.analyticsStorage = analyticsStorage
       self.analytics = analyticsStorage.values

       incrementAnalytics(for: LaunchCommand<StackCommandCentre>())
     } catch {
       modelError = error
       modelErrorCount += 1
     }
   }

   public func setupRealContainer() throws -> ModelContainer {
     let container = try StackContainer.createSharedContainer()
     Task {
       await StackContainer.dumpDatabaseBackup(container: container)
     }
     return container
   }

   public func setupTestContainer(named name: String) throws -> ModelContainer {
     let container = try StackContainer.createFakeContainer(named: name)
     return container
   }

   public func setupPreviewContainer() throws {
     modelContainer = try StackContainer.createTestContainer()
   }

   /// Hide any currently presented sheet.
   public func dismissSheet() {
     sheets.sheet = .none
   }

   /// Increment the analytics count for the given key.
   public func incrementAnalytics(for command: any Command) {
     let key = command.id
     let existingValue = analytics[key] ?? 0
     let newValue = existingValue + 1
     analyticsChannel.debug("Incremented analytics for \(key) to \(newValue)")
     analytics[key] = newValue
     analyticsStorage?.values = analytics
   }

   /// Updates the suggestions sheet visibility after the suggestions list changes.
   private func updateSuggestionsSheet(with state: SuggestionsState) {
     switch state {
       case .none:
         if sheets.sheet == .suggestions {
           withAnimation {
             sheets.sheet = .none
           }
         }

       case .calculating(_), .suggested(_, _), .failed:
         withAnimation {
           sheets.sheet = .suggestions
         }
     }
   }
 }


 enum TestError: Error {
   case unusedError
   case testError(String)
 }

 extension TestError: LocalizedError {
   public var errorDescription: String? {
     switch self {
       case .testError(let string):
         return string
       default:
         return String(describing: self)
     }
   }
 }


 public class SearchState {
   public var initialSearch: String?

   public init() {
   }
 }

 */
