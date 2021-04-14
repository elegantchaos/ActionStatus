// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 11/08/2020.
//  All code (c) 2020 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Keychain
import SwiftUI
import SwiftUIExtensions

public struct PreferencesView: View {
    @Environment(\.presentationMode) var presentation
    @EnvironmentObject var viewState: ViewState
    @EnvironmentObject var model: Model

    @State var settings = Settings()
    @State var owner: String = ""
    @State var token: String = ""
    
    public init() {
    }
    
    public var body: some View {
        SheetView("ActionStatus Preferences", shortTitle: "Preferences", cancelAction: handleCancel, doneAction: handleSave) {
            PreferencesForm(settings: $settings, githubToken: $token, defaultOwner: $owner)
                .environmentObject(viewState.formStyle)
        }
        .onAppear(perform: handleAppear)
    }

    func handleCancel() {
        presentation.wrappedValue.dismiss()
    }

    
    func handleAppear() {
        settings = viewState.settings
        owner = model.defaultOwner
        token = settings.readToken()
    }
    
    func handleSave() {
        model.defaultOwner = owner
        viewState.settings = settings
        viewState.settings.writeToken(token)
        presentation.wrappedValue.dismiss()
    }

}

public struct PreferencesForm: View {
    @Binding var settings: Settings
    @Binding var githubToken: String
    @Binding var defaultOwner: String
    @EnvironmentObject var viewState: ViewState

    public var body: some View {
        let rowStyle = ClearFormRowStyle()
        Form {
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
                
                FormPickerRow(label: "Refresh Every", variable: $settings.refreshRate, cases: RefreshRate.allCases, style: rowStyle)
                FormToggleRow(label: "Github Authentication", variable: $settings.githubAuthentication, style: rowStyle)
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
                FormPickerRow(label: "Item Size", variable: $settings.displaySize, cases: DisplaySize.allCases, style: rowStyle)
                FormPickerRow(label: "Sort By", variable: $settings.sortMode, cases: SortMode.allCases, style: rowStyle)

                #if targetEnvironment(macCatalyst)
                FormToggleRow(label: "Show In Menubar", variable: $settings.showInMenu, style: rowStyle)
                FormToggleRow(label: "Show In Dock", variable: $settings.showInDock, style: rowStyle)
                #endif
            }
            
            FormSection(
                header: "Creation",
                footer: "Defaults to use for new repos."
            ) {
                FormFieldRow(label: "Default Owner", variable: $defaultOwner, style: DefaultFormFieldStyle(contentType: .organizationName))
            }
        }
        .bestFormPickerStyle()
    }
}

