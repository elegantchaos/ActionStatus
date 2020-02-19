// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Developer on 19/02/2020.
//  All code (c) 2020 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import SwiftUI
import BindingsExtensions

struct ComposeView: View {
    var repo: Repo
    @Binding var isPresented: Bool
    @State var generateMac = true

    @State var workflow: String = "Tests"
    
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

    var body: some View {
        
        VStack {
            Form {
                Section(header: Text("Workflow Name")) {
                    TextField("Name", text: $workflow)
                }
                
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
                        Toggle(isOn: $build) {
                            Text("Perform Build")
                        }
                        Toggle(isOn: $test) {
                            Text("Run Tests")
                        }
                        Toggle(isOn: $notify) {
                            Text("Post Notification")
                        }
                    }
                }

            }.padding()
            
            HStack(spacing: 100.0) {
                Button(action: { self.isPresented = false }) {
                    Text("Cancel")
                }
                
                Button(action: { WorkflowGenerator(view: self).generateWorkflow() }) {
                    Text("Generate \(workflow).yml")
                }
            }
        }.padding()
        
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
