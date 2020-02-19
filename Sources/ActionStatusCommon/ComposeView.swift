// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Developer on 19/02/2020.
//  All code (c) 2020 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import SwiftUI
import BindingsExtensions

class Option: ObservableObject {
    let id: String
    @Published var name: String
    @Published var included: Bool
    
    init(_ id: String, name: String) {
        self.id = id
        self.name = name
        self.included = false
    }
}

extension Option: Equatable {
    static func == (lhs: Option, rhs: Option) -> Bool {
        return lhs.name == rhs.name
    }
}

class Job: Option {
    let swift: String?
    
    func yaml() -> String {
        var yaml =
            """
            \(id):
                name: \(name)
            
            """
        
        if let swift = swift {
            yaml.append(
            """
                runs-on: ubunu-latest
                container: swift:\(swift)
            """
            )
        }
        
        yaml.append("\n\n")
        
        return yaml
    }
    
    init(_ id: String, name: String, swift: String? = nil) {
        self.swift = swift
        super.init(id, name: name)
    }
}

struct ComposeView: View {
    @Binding var isPresented: Bool
    @State var generateMac = true

    @State var workflow: String = "Tests"
    
    @State var platforms = [
        Job("macOS", name: "macOS"),
        Job("iOS", name: "iOS"),
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
                            Text("Build")
                        }
                    }
                }

            }.padding()
            
            HStack(spacing: 100.0) {
                Button(action: { self.isPresented = false }) {
                    Text("Cancel")
                }
                
                Button(action: { self.generateWorkflow() }) {
                    Text("Generate \(workflow).yml")
                }
            }
        }.padding()
        
    }
    
    func enabledJobs() -> [Job] {
        var jobs: [Job] = []
        var includeMac = false
        for platform in platforms {
            switch platform.id {
                case "macOS", "iOS":
                    includeMac = true
                
                default:
                    jobs.append(platform)
            }
        }
        
        if includeMac {
            jobs.append(Job("macOS-iOS", name: "macOS/iOS"))
        }
        
        return jobs
    }
    
    func enabledConfigs() -> [String] {
        return configurations.filter({ $0.included }).map({ $0.name })
    }
    
    func generateWorkflow() {
        var source =
        """
        name: \(workflow)
        
        on: [push, pull_request]
        
        jobs:
        """
        
        for job in enabledJobs() {
            source.append(job.yaml())
        }
        
        print(source)
    }
}


struct ComposeView_Previews: PreviewProvider {
    static var previews: some View {
        ComposeView(isPresented: .constant(false))
    }
}
