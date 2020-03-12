// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 19/02/2020.
//  All code (c) 2020 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import ActionStatusCore
import SwiftUI
import BindingsExtensions

struct GenerateView: View {
    let generator = WorkflowGenerator()
    let repoID: UUID
    
    @EnvironmentObject var model: Model
    @Binding var isPresented: Bool
    
    @State var platforms: [Bool] = []
    @State var configurations: [Bool] = []
    @State var general: [Bool] = []

    var repo: Repo {
        model.repo(withIdentifier: repoID)!
    }
    
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
        let app = Application.shared
        storeSettings()
        app.saveState()
        if let workflow = generator.generateWorkflow(for: repo, application: app.info) {
            Application.shared.save(workflow: workflow)
        }
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
        var updated = repo
        updated.settings.options = options
        model.update(repo: updated)
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
        GenerateView(repoID: Application.shared.testRepos[0].id, isPresented: .constant(false))
    }
}
