// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 20/03/2026.
//  Copyright © 2026 Elegant Chaos Limited. All rights reserved.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Commands
import CommandsUI
import Icons
import SwiftUI
import UniformTypeIdentifiers

/// A view that displays a labeled link, which performs a command when tapped.
/// The link is styled with the .link foreground style and displays the URL as its text.
struct LabeledLink<C: CommandWithUI>: View where C.Centre == ActionStatusCommander {
  @Environment(ActionStatusCommander.self) var commander

  let title: LocalizedStringResource
  let icon: Icon
  let command: C
  let url: URL

  init(_ title: LocalizedStringResource, icon: Icon, command: C, url: URL) {
    self.title = title
    self.icon = icon
    self.command = command
    self.url = url
  }

  var body: some View {
    LabeledContent(title, icon: icon) {
      HStack(alignment: .firstTextBaseline) {
        commander.button(command) {
          Text(linkString)
            .multilineTextAlignment(.leading)
            .foregroundStyle(.link)
        }
        .buttonStyle(.borderless)
        
        Button(action: { Clipboard.copy(url) }) {
          Image(systemName: "doc.on.doc")
        }
        .buttonStyle(.borderless)
        .controlSize(.small)
      }
    }
    .foregroundStyle(.primary)
  }

  var linkString: String {
    url.scheme == "file" ? url.path : url.absoluteString
  }
}

#Preview("LabelledLink", traits: .modifier(ActionStatusPreviews.Editing())) {
  Form {
    LabeledLink("Local", icon: .revealLocalRepo, command: RevealLocalCommand(url: .testLocalURL), url: .testLocalURL)
  }
  .formStyle(.grouped)
}



#if canImport(UIKit)
import UIKit

struct Clipboard {
  static func copy(_ string: String) {
    UIPasteboard.general.string = string
  }
  
  static func copy(_ url: URL) {
    UIPasteboard.general.url = url
  }
}
#elseif canImport(AppKit)
import AppKit

struct Clipboard {
  static func copy(_ string: String) {
    let pb = NSPasteboard.general
    pb.clearContents()
    pb.setString(string, forType: .string)
  }
  
  static func copy(_ url: URL) {
    let pb = NSPasteboard.general
    pb.clearContents()
    pb.setString(url.absoluteString, forType: .URL)
  }
}

#endif
