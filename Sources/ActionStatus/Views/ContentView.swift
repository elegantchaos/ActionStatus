// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 12/02/20.
//  All code (c) 2020 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import ActionStatusCore
import SwiftUI
import SwiftUIExtensions
import BindingsExtensions

struct ContentView: View {
    
    @EnvironmentObject var model: Model
    @EnvironmentObject var viewState: ViewState
    
    var body: some View {
        NavigationView {
            VStack(alignment: .center) {
                if model.itemIdentifiers.count == 0 {
                    NoReposView()
                }
                
                RepoListView()
                Spacer()
                FooterView()
            }
            .setupNavigation()
            .sheet(isPresented: $viewState.hasSheet) { self.sheetView() }
        }
        .setupNavigationStyle()
        .onAppear(perform: onAppear)
    }
    
    func onAppear()  {
        #if !os(tvOS)
        UITableView.appearance().separatorStyle = .none
        #endif
        
        self.model.refresh()
    }
    
    func sheetView() -> some View {
        switch viewState.sheetType {
            case .save:
                #if !os(tvOS)
                return AnyView(DocumentPickerViewController(picker: Application.shared.pickerForSavingWorkflow()))
            #endif

            case .edit:
                if let id = viewState.composingID {
                    return AnyView(
                        EditView(repoID: id, title: "Edit")
                            .environmentObject(self.model) // TODO: this should not be needed, but seems to be :(
                    )
            }

            case .compose:
                if let id = viewState.composingID {
                    return AnyView(
                        GenerateView(repoID: id, isPresented: self.$viewState.hasSheet)
                            .environmentObject(self.model) // TODO: this should not be needed, but seems to be :(
                    )
            }
        }
        
        return AnyView(EmptyView())
    }
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

fileprivate extension View {
    #if os(tvOS) || targetEnvironment(macCatalyst)
    
    // MARK: tvOS/macOS Don't show nav bar
    
    func setupNavigation() -> some View {
        return
            navigationBarTitle("")
                .navigationBarHidden(true)
    }
    
    func setupNavigationStyle() -> some View {
        return navigationViewStyle(StackNavigationViewStyle())
    }
    
    #elseif canImport(UIKit)
    
    // MARK: iOS
    
    func setupNavigation() -> some View {
        return
            navigationBarTitle("Action Status", displayMode: .inline)
                .navigationBarItems(
                    leading: AddButton(),
                    trailing: EditButton())
    }
    
    func setupNavigationStyle() -> some View {
        return navigationViewStyle(StackNavigationViewStyle())
    }
    
    #endif
}
