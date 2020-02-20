// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Developer on 19/02/2020.
//  All code (c) 2020 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import SwiftUI
import BindingsExtensions

struct ComposeView: View {
    @ObservedObject var generator = WorkflowGenerator()
    var repo: Repo

    @Binding var isPresented: Bool
    @State var platforms: [Bool] = []
    @State var configurations: [Bool] = []
    @State var settings = WorkflowSettings()
//    var platformBinding: Binding<[Job]> {
//        return generator.$platforms
//    }
    
    var body: some View {
        VStack {
            Form {
                Section(header: Text("Platforms")) {
                    VStack {
                        ForEach(0 ..< self.generator.platforms.count) { index in
//                            Toggle(isOn: self.$platforms[index]) {
                            Toggle(isOn: self.$generator.platforms[index].included) {
                                Text(self.generator.platforms[index].name)
                            }
                        }
                    }
                }

                Section(header: Text("Configuration")) {
                    VStack {
                        ForEach(0 ..< configurations.count) { index in
                            Toggle(isOn: self.$configurations[index]) {
                                Text(self.generator.configurations[index].name)
                            }
                        }
                    }
                }

                Section(header: Text("Other Options")) {
                    VStack {
                        Toggle("Perform Build", isOn: $settings.build)
                        Toggle("Run Tests", isOn: $settings.test)
                        Toggle("Post Notification", isOn: $settings.notify)
                        Toggle("Upload Logs", isOn: $settings.upload)
                        Toggle("Prefer Xcode Build For macOS", isOn: $settings.xCodeOnMac)
                    }
                }

            }.padding()
            
            HStack(spacing: 100.0) {
                Button(action: { self.isPresented = false }) {
                    Text("Cancel")
                }
                
                Button(action: { self.generator.generateWorkflow(for: self.repo, settings: self.settings) }) {
                    Text("Generate \(repo.workflow).yml")
                }
            }
        }
        .padding()
        .onAppear() {
            self.platforms = self.generator.platforms.map({ $0.included })
            self.platforms = self.generator.platforms.map({ $0.included })
            self.settings = self.repo.settings
        }
        .onDisappear() {
//            self.repo.settings = self.settings
        }
    }
    
    func section(for options: Binding<[Option]>, label: String) -> some View {
        Section(header: Text(label)) {
            VStack {
                ForEach(options.wrappedValue, id: \.id) { option in
                    Toggle(isOn: options.binding(for: \.included, of: option)) {
                        Text(option.name)
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
        ComposeView(repo: AppDelegate.shared.testRepos.items[0], isPresented: .constant(false))
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
