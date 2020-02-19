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
        self.included = true
    }
}

extension Option: Equatable {
    static func == (lhs: Option, rhs: Option) -> Bool {
        return lhs.name == rhs.name
    }
}

class Job: Option {
    enum Platform {
        case mac
        case linux
    }
    
    let swift: String?
    let platform: Platform
    let includeXcode: Bool
    
    func yaml(build: Bool, test: Bool, notify: Bool, package: String) -> String {
        var yaml =
            """
            \(id):
                name: \(name)
            
            """
        
        switch (platform) {
            case .mac:
            yaml.append(
            """
                runs-on: macOS-latest

            """
            )
            
            case .linux:
                let swift = self.swift ?? "5.1"
                yaml.append(
            """
                runs-on: ubunu-latest
                container: swift:\(swift)

            """
                )
        }
        
        yaml.append(
            """
                steps:
                - name: Checkout
                  uses: actions/checkout@v1
                - name: Swift Version
                  run: swift --version

            """
        )

        if build {
            yaml.append(
            """
                - name: Build
                  run: swift build -v

            """
            )
        }

        if test {
            yaml.append(
            """
                - name: Test
                  run: swift test -v

            """
            )
        }

        if includeXcode {
            if build {
                yaml.append(
                """
                    - name: Build (iOS)
                      run: xcodebuild clean build -workspace . -scheme \(package) -destination "name=iPad Pro (11-inch)"

                """
                )
            }

            if test {
                yaml.append(
                """
                    - name: Test (iOS)
                      run: xcodebuild test -workspace . -scheme \(package) -destination "name=iPad Pro (11-inch)"

                """
                )
            }
        }
        
        if notify {
            yaml.append(
            """
                - name: Slack Notification
                  uses: elegantchaos/slatify@master
                  if: always()
                  with:
                    type: ${{ job.status }}
                    job_name: '\(name)'
                    mention_if: 'failure'
                    url: ${{ secrets.SLACK_WEBHOOK }}

            """
            )
        }

        yaml.append("\n\n")
        
        return yaml
    }
    
    init(_ id: String, name: String, platform: Platform = .linux, swift: String? = nil, includeXcode: Bool = false) {
        self.platform = platform
        self.swift = swift
        self.includeXcode = includeXcode
        super.init(id, name: name)
    }
}

struct ComposeView: View {
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
                
                Button(action: { self.generateWorkflow() }) {
                    Text("Generate \(workflow).yml")
                }
            }
        }.padding()
        
    }
    
    func enabledJobs() -> [Job] {
        var jobs: [Job] = []
        var macOS = false
        var iOS = false
        for platform in platforms {
            switch platform.id {
                case "macOS":
                    macOS = true
                case "iOS":
                    iOS = true
                
                default:
                    jobs.append(platform)
            }
        }
        
        if macOS || iOS {
            jobs.append(
                Job("macOS-iOS", name: "macOS/iOS", platform: .mac, includeXcode: iOS)
            )
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
            source.append(job.yaml(build: build, test: test, notify: notify, package: "Test"))
        }
        
        print(source)
    }
}


struct ComposeView_Previews: PreviewProvider {
    static var previews: some View {
        ComposeView(isPresented: .constant(false))
    }
}
