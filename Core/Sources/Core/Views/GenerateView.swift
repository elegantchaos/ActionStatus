// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 19/02/2020.
//  All code (c) 2020 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import SwiftUI
import BindingsExtensions

struct GenerateView: View {
    let generator = Generator()
    let repoID: UUID
    
    @EnvironmentObject var model: Model
    @EnvironmentObject var context: ViewContext
    @Environment(\.presentationMode) var presentation
    
    @State var platforms: [Bool] = []
    @State var compilers: [Bool] = []
    @State var configurations: [Bool] = []
    @State var general: [Bool] = []

    var repo: Repo {
        model.repo(withIdentifier: repoID)!
    }
    
    var body: some View {
        return SheetView(repo.name, shortTitle: repo.name, cancelAction: onCancel, doneAction: onGenerate, doneLabel: "Save") {
            VStack {
                Text("Settings for workflow '\(repo.workflow).yml' in repo \(repo.owner)/\(repo.name).")
                    .font(.subheadline)
                    .padding(.top, context.padding)

                Form {
                    TogglesView(title: "Platforms", options: self.generator.platforms, toggles: $platforms)
                    TogglesView(title: "Swift", options: self.generator.compilers, toggles: $compilers)
                    TogglesView(title: "Configuration", options: self.generator.configurations, toggles: $configurations)
                    TogglesView(title: "Other Options", options: self.generator.general, toggles: $general)
                }
                
                Spacer()
            }
        }
        .onAppear(perform: onAppear)
    }
    
    func onAppear() {
        fetchSettings()
    }
    
    func onCancel() {
        presentation.wrappedValue.dismiss()
    }

    func onGenerate() {
        let host = context.host
        storeSettings()
        if let output = generator.generateWorkflow(for: repo, application: host.info) {
            host.save(output: output)
        }
        host.saveState()
    }
    
    func fetchSettings() {
        let settings = repo.settings
        platforms = generator.toggleSet(for: generator.platforms, in: settings)
        compilers = generator.toggleSet(for: generator.compilers, in: settings)
        configurations = generator.toggleSet(for: generator.configurations, in: settings)
        general = generator.toggleSet(for: generator.general, in: settings)
    }
    
    func storeSettings() {
        var options: [String] = []
        options.append(contentsOf: generator.enabledIdentifiers(for: generator.platforms, toggleSet: platforms))
        options.append(contentsOf: generator.enabledIdentifiers(for: generator.compilers, toggleSet: compilers))
        options.append(contentsOf: generator.enabledIdentifiers(for: generator.configurations, toggleSet: configurations))
        options.append(contentsOf: generator.enabledIdentifiers(for: generator.general, toggleSet: general))
        var updated = repo
        updated.settings.options = options
        model.update(repo: updated)
    }
    
}

struct TogglesView: View {
    @EnvironmentObject var context: ViewContext

    let title: String
    let options: [Option]
    let toggles: Binding<[Bool]>
    
    var body: some View {
        let count = toggles.wrappedValue.count
        let allSet = Binding<Bool> {
            toggles.wrappedValue.filter({ $0 }).count == count
        } set: { newValue in
            for n in 0 ..< toggles.wrappedValue.count {
                toggles[n].wrappedValue = newValue
            }
        }

        return Section(header:
            HStack {
                Text(title).font(context.formStyle.headerFont)
                Spacer()
                Toggle("Enable All", isOn: allSet)
            }
        ) {
            return VStack {
                ForEach(0 ..< count, id: \.self) { index in
                    HStack {
                        Toggle(isOn: toggles[index]) {
                            Text(options[index].label)
                        }
                        Spacer()
                    }
                }
            }
        }

    }
}
struct ComposeView_Previews: PreviewProvider {
    static var previews: some View {
        let context = PreviewContext()
        return context.inject(into: GenerateView(repoID: context.testRepo.id))
    }
}
