// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 30/09/2025.
//  Copyright © 2025 Elegant Chaos Limited. All rights reserved.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Commands
import Icons
import SwiftUI

struct ConfirmableCommandButton<C: CommandWithUI, CC: CommandCentre>: View where C.Centre == CC {
  @State var isPresented = false
  
  let command: C
  let commander: CC
  
  var body: some View {
    let confirmation = command.confirmation ?? .init(
      title: command.name,
      cancel: String(localized: "confirmation.default.cancel"),
      message: String(localized: "confirmation.default.message"),
      confirm: String(localized: "confirmation.default.confirm")
    )
    
    Button(action: handleShowAlert) {
      Label(command.name, icon: command.icon)
    }
    .alert(confirmation.title, isPresented: $isPresented) {
      Button(confirmation.cancel, role: .cancel) {}
      Button(confirmation.confirm, role: .destructive) { handlePerformCommand() }
    } message: {
      Text(confirmation.message)
    }
  }
  
  func handleShowAlert()
  {
    withAnimation {
      isPresented = true
    }
  }
  
  func handlePerformCommand() {
    Task {
      do {
        _ = try await commander.perform(command)
      } catch {
        
      }

      withAnimation {
        isPresented = false
      }
    }
  }
}
