// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Developer on 19/02/2020.
//  All code (c) 2020 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import ActionStatusCore
import SwiftUI
import BindingsExtensions

struct ComposeView: View {
    let generator = WorkflowGenerator()
    
    @Binding var repo: Repo
    @Binding var isPresented: Bool
    
    @State var platforms: [Bool] = []
    @State var configurations: [Bool] = []
    @State var general: [Bool] = []
       
    var body: some View {
        VStack {
            Text("\(repo.name)/\(repo.owner)").multilineTextAlignment(.center)
            
            Form {
                togglesSection(title: "Platforms", options: self.generator.platforms, toggles: $platforms)
                togglesSection(title: "Configuration", options: self.generator.configurations, toggles: $configurations)
                togglesSection(title: "Other Options", options: self.generator.general, toggles: $general)
            }.padding()
            
            Spacer()
            
            HStack() {
                Button(action: onCancel) { Text("Cancel") }
                Spacer()
                Button(action: onGenerate) { Text("Generate \(repo.workflow).yml") }
            }
        }
        .padding()
        .onAppear(perform: onAppear)
        .onDisappear(perform: onDisappear)
    }
    
    func onAppear() {
        fetchSettings()
    }
    
    func onDisappear() {
        storeSettings()
    }
    
    func onCancel() {
        isPresented = false
    }
    func onGenerate() {
        storeSettings()
        Application.shared.saveState()
        let source = generator.generateWorkflow(for: repo)
        Application.shared.saveWorkflow(named: repo.workflow, source: source)
    }
    
    func fetchSettings() {
        let settings = repo.settings
        platforms = generator.toggleSet(for: generator.platforms, in: settings)
        configurations = generator.toggleSet(for: generator.configurations, in: settings)
        general = generator.toggleSet(for: generator.general, in: settings)
    }
    
    func storeSettings() {
        var options: [String] = []
        options.append(contentsOf: generator.enabledIdentifiers(for: generator.platforms, toggleSet: platforms))
        options.append(contentsOf: generator.enabledIdentifiers(for: generator.configurations, toggleSet: configurations))
        options.append(contentsOf: generator.enabledIdentifiers(for: generator.general, toggleSet: general))
        repo.settings.options = options
    }
    
    func togglesSection(title: String, options: [Option], toggles: Binding<[Bool]>) -> some View {
        let allSet = toggles.wrappedValue.filter({ $0 }).count == toggles.wrappedValue.count
        return Section(header:
            HStack {
                Text(title).font(.headline)
                Spacer()
                Button(action: {
                    for n in 0 ..< toggles.wrappedValue.count {
                        toggles[n].wrappedValue = !allSet
                    }
                }) {
                    Text(allSet ? "disable all" : "enable all")
                        
                }
            }
        ) {
                    
            VStack {
                ForEach(0 ..< toggles.wrappedValue.count) { index in
                    Toggle(isOn: toggles[index]) {
                        Text(options[index].name)
                    }
                }
            }
        }
    }
 
}


struct ComposeView_Previews: PreviewProvider {
    static var previews: some View {
        ComposeView(repo: Application.shared.$testRepos.items[0], isPresented: .constant(false))
    }
}
