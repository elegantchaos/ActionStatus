// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 19/02/20.
//  All code (c) 2020 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

struct WorkflowGenerator {
    let view: ComposeView
    
    func enabledJobs() -> [Job] {
        var jobs: [Job] = []
        var macOS = false
        var iOS = false
        for platform in view.platforms {
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
        return view.configurations.filter({ $0.included }).map({ $0.name })
    }
    
    func generateWorkflow() {
        var source =
        """
        name: \(view.workflow)
        
        on: [push, pull_request]
        
        jobs:
        """
        
        for job in enabledJobs() {
            source.append(job.yaml(build: view.build, test: view.test, notify: view.notify, package: "Test"))
        }
        
        print(source)
    }
}
