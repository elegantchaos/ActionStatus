// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Developer on 19/02/2020.
//  All code (c) 2020 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import SwiftUI
import BindingsExtensions

struct ComposeView: View {
    var repo: Repo
    @Binding var isPresented: Bool
    
    @State var platforms = [
        Job("macOS", name: "macOS", platform: .mac),
        Job("iOS", name: "iOS", platform: .mac),
        Job("linux-50", name: "Linux (Swift 5.0)", swift: "5.0"),
        Job("linux-51", name: "Linux (Swift 5.1)", swift: "5.1")
    ]

    @State var configurations = [
        Option("debug", name: "Debug"),
        Option("release", name: "Release")
    ]

    @State var build = true
    @State var test = true
    @State var notify = true
    @State var upload = true
    
    var body: some View {
        
        VStack {
            Form {
                Section(header: Text("Platforms")) {
                    VStack {
                        ForEach(platforms, id: \.name) { platform in
                            Toggle(isOn: self.$platforms.binding(for: \.included, of: platform)) {
                                Text(platform.name)
                            }
                        }
                    }
                }

                Section(header: Text("Configuration")) {
                    VStack {
                        ForEach(configurations, id: \.name) { configuration in
                            Toggle(isOn: self.$configurations.binding(for: \.included, of: configuration)) {
                                Text(configuration.name)
                            }
                        }
                    }
                }

                Section(header: Text("Other Options")) {
                    VStack {
                        Toggle("Perform Build", isOn: $build)
                        Toggle(isOn: $test) {
                            Text("Run Tests")
                        }
                        Toggle(isOn: $notify) {
                            Text("Post Notification")
                        }
                        Toggle(isOn: $upload) {
                            Text("Upload Logs")
                        }
                    }
                }

            }.padding()
            
            HStack(spacing: 100.0) {
                Button(action: { self.isPresented = false }) {
                    Text("Cancel")
                }
                
                Button(action: { WorkflowGenerator(view: self).generateWorkflow() }) {
                    Text("Generate \(repo.workflow).yml")
                }
            }
        }
            .padding()
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
