// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 19/02/20.
//  All code (c) 2020 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import UIKit

struct WorkflowGenerator {
    let view: ComposeView
    
    func enabledJobs() -> [Job] {
        var jobs: [Job] = []
        var macPlatforms: [String] = []
        for platform in view.platforms {
            switch platform.platform {
                case .mac:
                    macPlatforms.append(platform.id)
                default:
                    jobs.append(platform)
            }
        }
        
        if macPlatforms.count > 0 {
            let macID = macPlatforms.joined(separator: "-")
            let macName = macPlatforms.joined(separator: "/")
            
            // unless xCodeOnMac is set, remove macOS from the platforms built with xCode
            if !view.xCodeOnMac, let index = macPlatforms.firstIndex(of: "macOS") {
                macPlatforms.remove(at: index)
            }
            
            // make a catch-all job
            jobs.append(
                Job(macID, name: macName, platform: .mac, xcodePlatforms: macPlatforms)
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
        name: \(view.repo.workflow)
        
        on: [push, pull_request]
        
        jobs:

        """
        
        for job in enabledJobs() {
            source.append(job.yaml(build: view.build, test: view.test, notify: view.notify, upload: view.upload, package: view.repo.name, configurations: enabledConfigs()))
        }
        
        if let data = source.data(using: .utf8) {
            do {
                let url = UIApplication.newDocumentURL(name: view.repo.workflow, withPathExtension: "yml")
                try data.write(to: url)
                let model = AppDelegate.shared.repos
                
                #if targetEnvironment(macCatalyst)
                model.hideComposeWindow()
                DispatchQueue.main.async {
                    AppDelegate.shared.pickFile(url: url)
                }
                #else
                model.exportURL = url
                model.exportYML = source
                model.isSaving = true
                #endif
            } catch {
                print(error)
            }
        }
    }
}
