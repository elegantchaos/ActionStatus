// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 11/08/2020.
//  All code (c) 2020 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

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
        SheetView("ActionStatus Preferences", shortTitle: "Preferences", cancelAction: handleCancel, doneAction: handleSave) {
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
    @Binding var settings: Settings
    @Binding var githubToken: String
    @Binding var defaultOwner: String
    @Binding var oldestNewest: Bool

    @EnvironmentObject var context: ViewContext

    public var body: some View {
        return Form {
            FormSection(
                header: { Text("Connection") },
                footer: {
                    HStack {
                        Spacer()
                        VStack(alignment: .trailing) {
                            if settings.githubAuthentication {
                                Text("With authentication, checking works for private repos and shows queued and running jobs. The token requires the following permissions:\n  notifications, read:org, read:user, repo, workflow.")
                                HStack {
                                    Text("More info... ")
                                    LinkButton(url: URL(string: "https://docs.github.com/en/github/authenticating-to-github/creating-a-personal-access-token#creating-a-token")!)
                                }
                            } else {
                                Text("Without authentication, checking works for public repos only.")
                            }
                        }
                    }
                }
            ) {
                #if DEBUG
                FormToggleRow(label: "Test Refresh", variable: $settings.testRefresh)
                #endif
                
                FormPickerRow(label: "Refresh Every", variable: $settings.refreshRate, cases: RefreshRate.allCases)
                FormToggleRow(label: "Github Authentication", variable: $settings.githubAuthentication)
                if settings.githubAuthentication {
                    FormFieldRow(label: "Github User", variable: $settings.githubUser, style: DefaultFormFieldStyle(contentType: .username), clearButton: true)
                    FormFieldRow(label: "Github Server", variable: $settings.githubServer, style: DefaultFormFieldStyle(contentType: .URL), clearButton: true)
                    FormFieldRow(label: "Github Token", variable: $githubToken, style: DefaultFormFieldStyle(contentType: .password), clearButton: true)
                }
            }
            
            FormSection(
                header: "Display",
                footer: "Display settings."
            ) {
                FormPickerRow(label: "Item Size", variable: $settings.displaySize, cases: DisplaySize.allCases)
                FormPickerRow(label: "Sort By", variable: $settings.sortMode, cases: SortMode.allCases)

                #if targetEnvironment(macCatalyst)
                FormToggleRow(label: "Show In Menubar", variable: $settings.showInMenu)
                FormToggleRow(label: "Show In Dock", variable: $settings.showInDock)
                #endif
            }
            
            FormSection(
                header: "Creation",
                footer: "Defaults to use for new repos."
            ) {
                FormFieldRow(label: "Default Owner", variable: $defaultOwner, style: DefaultFormFieldStyle(contentType: .organizationName))
            }

            FormSection(
                header: "Workflows",
                footer: "Settings to use when generating workflow files."
            ) {
                FormToggleRow(label: "Test Lowest And Highest Only", variable: $oldestNewest)
            }

        }
        .bestFormPickerStyle()
    }
}

