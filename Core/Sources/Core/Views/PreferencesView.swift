// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 11/08/2020.
//  All code (c) 2020 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import LabelledGrid
import Keychain
import SwiftUI
import SwiftUIExtensions

public struct PreferencesView: View {
    @Environment(\.presentationMode) var presentation
    @EnvironmentObject var context: ViewContext
    @EnvironmentObject var model: Model

    @State var settings = Settings()
    @State var owner: String = ""
    @State var token: String = ""
    @State var oldestNewest: Bool = false
    
    public init() {
    }
    
    public var body: some View {
        SheetView("ActionStatus Settings", shortTitle: "Settings", cancelAction: handleCancel, doneAction: handleSave) {
            PreferencesForm(
                settings: $settings,
                githubToken: $token,
                defaultOwner: $owner,
                oldestNewest: $oldestNewest)
                .environmentObject(context.formStyle)
        }
        .onAppear(perform: handleAppear)
    }

    func handleCancel() {
        presentation.wrappedValue.dismiss()
    }

    
    func handleAppear() {
        Application.shared.pauseRefresh()
        settings = context.settings
        owner = model.defaultOwner
        token = settings.readToken()
    }
    
    func handleSave() {
        model.defaultOwner = owner
        let authenticationChanged = settings.authenticationChanged(from: context.settings)
        context.settings = settings
        context.settings.writeToken(token)
        
        if authenticationChanged {
            Application.shared.resetRefresh()
        }

        Application.shared.resumeRefresh()
        presentation.wrappedValue.dismiss()
    }

}

public struct PreferencesForm: View {
    @Environment(\.horizontalSizeClass) var horizontalSize
    
    @Binding var settings: Settings
    @Binding var githubToken: String
    @Binding var defaultOwner: String
    @Binding var oldestNewest: Bool
    @AppStorage("selectedSettingsPanel") var selectedPane: PreferenceTabs = .connection

    @EnvironmentObject var context: ViewContext

    enum PreferenceTabs: Int, CaseIterable {
        case connection
        case display
        case other
        case debug
        
        var label: String {
            switch self {
                case .connection: return "Connection"
                case .display: return "Display"
                case .other: return "Other"
                case .debug: return "Debug"
            }
        }
        
        var icon: String {
            switch self {
                case .connection: return "network"
                case .display: return "display"
                case .other: return "slider.horizontal.3"
                case .debug: return "ant"
            }
        }
        
    }

    public var body: some View {
        VStack {
            Picker("Panes", selection: $selectedPane) {
                ForEach(PreferenceTabs.allCases, id: \.self) { kind in
                    Label(kind.label, systemImage: kind.icon)
                }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal)
            .padding(.bottom, 20)
            .adaptiveIconSize()

            switch selectedPane {
                case .connection:
                    ConnectionPrefsView(settings: $settings, token: $githubToken)

                case .display:
                    DisplayPrefsView(settings: $settings)
                case .other:
                    OtherPrefsView(owner: $defaultOwner, oldestNewest: $oldestNewest)
                case .debug:
                    DebugPrefsView(settings: $settings)
            }
        }
        .padding()
    }
}


struct ConnectionPrefsView: View {
    @Binding var settings: Settings
    @Binding var token: String

    var body: some View {
        LabelledStack {
            LabelledToggle("Checking Method", icon: "lock", prompt: "Use Github API", value: $settings.githubAuthentication)
            
            if settings.githubAuthentication {
                LabelledField("User", icon: "person", placeholder: "user", text: $settings.githubUser)
                LabelledField("Server", icon: "network", placeholder: "host", text: $settings.githubServer)
                LabelledField("Token", icon: "tag", placeholder: "token", text: $token)
            }

            LabelledPicker("Refresh Rate", icon: "clock.arrow.2.circlepath", value: $settings.refreshRate, values: RefreshRate.allCases)

            Spacer()

            if settings.githubAuthentication {
                Text("With the Github API enabled, private repos are checked, and we can show queued and running jobs. The token requires the following permissions:\n  notifications, read:org, read:user, repo, workflow.")
                HStack {
                    Text("More info... ")
                    LinkButton(url: URL(string: "https://docs.github.com/en/github/authenticating-to-github/creating-a-personal-access-token#creating-a-token")!)
                }
            } else {
                Text("Without the Github API, checking works for public repos only.")
            }

        }

    }
}


struct DisplayPrefsView: View {
    @Binding var settings: Settings

    var body: some View {
        LabelledStack {
            LabelledPicker("Item Size", icon: "arrow.left.and.right", value: $settings.displaySize)
            LabelledPicker("Sort By", icon: "line.horizontal.3.decrease", value: $settings.sortMode)
            #if targetEnvironment(macCatalyst)
            LabelledToggle("Show In Menubar", icon: "filemenu.and.cursorarrow", prompt: "Show menu", value: $settings.showInMenu)
            LabelledToggle("Show In Dock", icon: "dock.rectangle", prompt: "Show icon in dock", value: $settings.showInDock)
            #endif
            
            Spacer()
        }

    }
}

struct OtherPrefsView: View {
    @Binding var owner: String
    @Binding var oldestNewest: Bool
    
    var body: some View {
        LabelledStack {
            LabelledField("Default Owner", icon: "person", placeholder: "github user or org", text: $owner)
            LabelledToggle("Workflows", icon: "flowchart", prompt: "Test lowest & highest Swift", value: $oldestNewest)

            Spacer()
        }

    }
}

struct DebugPrefsView: View {
    @Binding var settings: Settings

    var body: some View {
        LabelledStack {
            LabelledToggle("Refresh", icon: "clock.arrow.2.circlepath", prompt: "Use test refresh controller", value: $settings.testRefresh)
            
            Spacer()
        }

    }
}


struct AdaptiveIconSize: ViewModifier {
    @Environment(\.horizontalSizeClass) var horizontalSize

    func body(content: Content) -> some View {
        if horizontalSize == .compact {
            content
                .labelStyle(.iconOnly)
        } else if #available(iOS 15.0, *) {
            content
                .labelStyle(.titleAndIcon)
        } else {
            content
                .labelStyle(.automatic)
        }
    }
}

extension View {
    func adaptiveIconSize() -> some View {
        return self.modifier(AdaptiveIconSize())
    }
}
