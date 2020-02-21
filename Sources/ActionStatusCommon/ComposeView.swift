// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Developer on 19/02/2020.
//  All code (c) 2020 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

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
            Form {
                togglesSection(title: "Platforms", options: self.generator.platforms, toggles: $platforms)
                togglesSection(title: "Configuration", options: self.generator.configurations, toggles: $configurations)
                togglesSection(title: "Other Options", options: self.generator.general, toggles: $general)
            }.padding()
            
            HStack(spacing: 100.0) {
                Button(action: { self.isPresented = false }) {
                    Text("Cancel")
                }
                
                Button(action: { self.generator.generateWorkflow(for: self.repo) }) {
                    Text("Generate \(repo.workflow).yml")
                }
            }
        }
        .padding()
        .onAppear(perform: onAppear)
        .onDisappear(perform: onDisappear)
    }
    
    func onAppear() {
        let settings = repo.settings
        platforms = generator.toggleSet(for: generator.platforms, in: settings)
        configurations = generator.toggleSet(for: generator.configurations, in: settings)
        general = generator.toggleSet(for: generator.general, in: settings)
    }
    
    func onDisappear() {
        var options: [String] = []
        options.append(contentsOf: generator.identifiers(for: generator.platforms, toggleSet: platforms))
        options.append(contentsOf: generator.identifiers(for: generator.configurations, toggleSet: configurations))
        options.append(contentsOf: generator.identifiers(for: generator.general, toggleSet: general))
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

struct OptionsSection: View {
    @Binding var options: [Option]
    let label: String
    
    var body: some View {
        Section(header: Text(label)) {
            VStack {
                ForEach(options, id: \.id) { option in
                    Toggle(isOn: self.$options.binding(for: \.included, of: option)) {
                        Text(option.name)
                    }
                }
            }
        }
    }
}

struct ComposeView_Previews: PreviewProvider {
    static var previews: some View {
        ComposeView(repo: AppDelegate.shared.$testRepos.items[0], isPresented: .constant(false))
    }
}

/// Wrapper around the `UIDocumentPickerViewController`.
struct DocumentPickerViewController {
    private let url: URL
    
    private let supportedTypes: [String] = ["public.item"]

    // Callback to be executed when users close the document picker.
    private let onDismiss: () -> Void

    init(url: URL, onDismiss: @escaping () -> Void) {
        self.url = url
        self.onDismiss = onDismiss
    }
}

// MARK: - UIViewControllerRepresentable

extension DocumentPickerViewController: UIViewControllerRepresentable {

    typealias UIViewControllerType = UIDocumentPickerViewController

    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        let documentPickerController = UIDocumentPickerViewController(url: url, in: .exportToService)
        documentPickerController.allowsMultipleSelection = false
        documentPickerController.delegate = context.coordinator
        return documentPickerController
    }

    func updateUIViewController(_ uiViewController: DocumentPickerViewController.UIViewControllerType, context: Context) {
        
    }

    // MARK: Coordinator

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UIDocumentPickerDelegate, ObservableObject {
        var parent: DocumentPickerViewController

        init(_ documentPickerController: DocumentPickerViewController) {
            parent = documentPickerController
        }

        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentAt url: URL) {
        }

        func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
            parent.onDismiss()

        }
    }
}
