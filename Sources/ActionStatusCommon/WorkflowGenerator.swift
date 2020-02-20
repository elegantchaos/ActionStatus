// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 19/02/20.
//  All code (c) 2020 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import UIKit

class WorkflowGenerator {
    var platforms = [
        Job("macOS", name: "macOS", platform: .mac),
        Job("iOS", name: "iOS", platform: .mac),
        Job("tvOS", name: "tvOS", platform: .mac),
        Job("watchOS", name: "watchOS", platform: .mac),
        Job("linux-50", name: "Linux (Swift 5.0)", swift: "5.0"),
        Job("linux-51", name: "Linux (Swift 5.1)", swift: "5.1")
    ]

    var configurations = [
        Option("debug", name: "Debug"),
        Option("release", name: "Release")
    ]

    func enabledJobs(settings: WorkflowSettings) -> [Job] {
        var jobs: [Job] = []
        var macPlatforms: [String] = []
        for platform in platforms {
            if settings.platforms.contains(platform.id) {
                switch platform.platform {
                    case .mac:
                        macPlatforms.append(platform.id)
                    default:
                        jobs.append(platform)
                }
            }
        }
        
        if macPlatforms.count > 0 {
            let macID = macPlatforms.joined(separator: "-")
            let macName = macPlatforms.joined(separator: "/")
            
            // unless xCodeOnMac is set, remove macOS from the platforms built with xCode
            if !settings.xCodeOnMac, let index = macPlatforms.firstIndex(of: "macOS") {
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
        return configurations.filter({ $0.included }).map({ $0.name })
    }
    
    func generateWorkflow(for repo: Repo, settings: WorkflowSettings) {
        var source =
        """
        name: \(repo.workflow)
        
        on: [push, pull_request]
        
        jobs:

        """
        
        for job in enabledJobs(settings: settings) {
            source.append(job.yaml(build: settings.build, test: settings.test, notify: settings.notify, upload: settings.upload, package: repo.name, configurations: enabledConfigs()))
        }
        
        if let data = source.data(using: .utf8) {
            do {
                let url = UIApplication.newDocumentURL(name: repo.workflow, withPathExtension: "yml", makeUnique: false)
                try data.write(to: url)
                let model = AppDelegate.shared.repos
                
                #if targetEnvironment(macCatalyst)
                // ugly hack - the SwiftUI sheet doesn't work properly on the mac
                model.hideComposeWindow()
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now().advanced(by: .seconds(1))) {
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
