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
    
    @State var defaultOwner: String = ""
    @State var refreshRate: RefreshRate = .automatic
    @State var displaySize: DisplaySize = .automatic
    @State var sortMode: SortMode = .name
    @State var showInMenu = true
    @State var showInDock = true
    @State var githubToken = ""
    @State var githubUser = ""
    @State var githubServer = ""
    
    public init() {
    }
    
    public var body: some View {
        let rowStyle = ClearFormRowStyle()
        
        SheetView("ActionStatus Preferences", cancelAction: handleCancel, doneAction: handleSave) {
            Form {
                FormSection(
                    header: "Connection",
                    footer: "Leave the github information blank to fall back on basic status checking (which works for public repos only)."
                ) {
                    
                    FormPickerRow(label: "Refresh Every", variable: $refreshRate, cases: RefreshRate.allCases, style: rowStyle)
                    FormFieldRow(label: "Github User", variable: $githubUser, style: DefaultFormFieldStyle(contentType: .username, clearButton: true))
                    FormFieldRow(label: "Github Server", variable: $githubServer, style: DefaultFormFieldStyle(contentType: .URL, clearButton: true))
                    FormFieldRow(label: "Github Token", variable: $githubToken, style: DefaultFormFieldStyle(contentType: .password, clearButton: true))
                }
                
                FormSection(
                    header: "Display",
                    footer: "Display settings."
                ) {
                    FormPickerRow(label: "Item Size", variable: $displaySize, cases: DisplaySize.allCases, style: rowStyle)
                    FormPickerRow(label: "Sort By", variable: $sortMode, cases: SortMode.allCases, style: rowStyle)

                    #if targetEnvironment(macCatalyst)
                    FormToggleRow(label: "Show In Menubar", variable: $showInMenu, style: rowStyle)
                    FormToggleRow(label: "Show In Dock", variable: $showInDock, style: rowStyle)
                    #endif
                }
                
                FormSection(
                    header: "Creation",
                    footer: "Defaults to use for new repos."
                ) {
                    FormFieldRow(label: "Default Owner", variable: $defaultOwner, style: DefaultFormFieldStyle(contentType: .organizationName))
                }
            }
            .padding()
        }
        .padding()
        .onAppear(perform: handleAppear)
        .environmentObject(viewState.formStyle)
    }
    
    
    func handleAppear() {
        defaultOwner = model.defaultOwner
        refreshRate = viewState.refreshRate
        displaySize = viewState.displaySize
        showInDock = UserDefaults.standard.bool(forKey: .showInDockKey)
        showInMenu = UserDefaults.standard.bool(forKey: .showInMenuKey)
        sortMode = viewState.sortMode
        githubUser = viewState.githubUser
        githubServer = viewState.githubServer
        if let token = try? Keychain.default.getToken(user: viewState.githubUser, server: viewState.githubServer) {
            githubToken = token
        }
        
    }
    
    func handleCancel() {
        presentation.wrappedValue.dismiss()
    }
    
    func handleSave() {
        model.defaultOwner = defaultOwner
        viewState.refreshRate = refreshRate
        viewState.displaySize = displaySize
        viewState.githubUser = githubUser
        viewState.githubServer = githubServer
        viewState.sortMode = sortMode
        UserDefaults.standard.set(showInDock, forKey: .showInDockKey)
        UserDefaults.standard.set(showInMenu, forKey: .showInMenuKey)
        
        // save token...
        do {
            try Keychain.default.addToken(githubToken, user: githubUser, server: githubServer)
        } catch {
            print("Failed to save token \(error)")
        }
        
        presentation.wrappedValue.dismiss()
    }
    
}

