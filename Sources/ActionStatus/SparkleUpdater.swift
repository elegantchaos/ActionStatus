// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 02/03/20.
//  All code (c) 2020 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Logger

#if canImport(SparkleBridgeClient)
import SparkleBridgeClient

let sparkleChannel = Channel("Sparkle")

class SparkleUpdater: Updater {
    let driver: Driver
    
    override init() {
        driver = Driver()
        super.init()
        driver.updater = self
    }
    
    override func installUpdate() {
        respondToUpdate(choice: .update)
    }
    
    override func skipUpdate() {
        respondToUpdate(choice: .skip)
    }
    
    override func ignoreUpdate() {
        respondToUpdate(choice: .later)
    }
    
    func respondToUpdate(choice: SparkleDriver.UpdateAlertChoice) {
        driver.updateCallback?(choice)
        driver.updateCallback = nil
        hasUpdate = false
    }
    
    class Driver: SparkleDriver, ObservableObject {
        var updater: SparkleUpdater?
        var updateCallback: UpdateAlertCallback?
        
        var expected: UInt64 = 0 {
            didSet {
                updater?.progress = expected > 0 ? Double(received)/Double(expected) : 0
            }
        }
        var received: UInt64 = 0 {
            didSet {
                updater?.progress = expected > 0 ? Double(received)/Double(expected) : 0
            }
        }
        
        var percent: Int {
            return Int((updater?.progress ?? 0) * 100)
        }
        
        override func showCanCheck(forUpdates canCheckForUpdates: Bool) {
            sparkleChannel.debug("canCheckForUpdates: \(canCheckForUpdates)")
        }
        
        override func showUpdatePermissionRequest(_ request: UpdatePermissionRequest, reply: @escaping (UpdatePermissionResponse) -> Void) {
            sparkleChannel.debug("show")
        }
        
        override func showUserInitiatedUpdateCheck(completion updateCheckStatusCompletion: @escaping (UserInitiatedCheckStatus) -> Void) {
            sparkleChannel.debug("showUserInitiatedUpdateCheck")
            updater?.status = "Checking for update."
        }
        
        override func dismissUserInitiatedUpdateCheck() {
            sparkleChannel.debug("dismissUserInitiatedUpdateCheck")
            updater?.status = ""
        }
        
        override func showUpdateFound(with appcastItem: AppcastItem, userInitiated: Bool, reply: @escaping UpdateAlertCallback) {
            sparkleChannel.debug("showUpdateFound")
            updater?.hasUpdate = true
            updater?.status = "Update available."
            updateCallback = reply
        }
        
        override func showDownloadedUpdateFound(with appcastItem: AppcastItem, userInitiated: Bool, reply: @escaping UpdateAlertCallback) {
            sparkleChannel.debug("showDownloadedUpdateFound")
        }
        
        override func showResumableUpdateFound(with appcastItem: AppcastItem, userInitiated: Bool, reply: @escaping UpdateStatusCallback) {
            sparkleChannel.debug("showResumableUpdateFound")
        }
        
        override func showInformationalUpdateFound(with appcastItem: AppcastItem, userInitiated: Bool, reply: @escaping InformationCallback) {
            sparkleChannel.debug("showInformationalUpdateFound")
        }
        
        override func showUpdateReleaseNotes(withDownloadData downloadData: Data, encoding: String?, mimeType: String?) {
            sparkleChannel.debug("showUpdateReleaseNotes")
        }
        
        override func showUpdateReleaseNotesFailedToDownloadWithError(_ error: Error) {
            sparkleChannel.debug("showUpdateReleaseNotesFailedToDownloadWithError")
        }
        
        override func showUpdateNotFound(acknowledgement: @escaping () -> Void) {
            sparkleChannel.debug("showUpdateNotFound")
        }
        
        override func showUpdaterError(_ error: Error, acknowledgement: @escaping () -> Void) {
            sparkleChannel.debug("showUpdaterError \(error)")
            #if DEBUG
            updater?.status = String(describing: error)
            #else
            updater?.status = "Failed to launch installer."
            #endif
        }
        
        override func showDownloadInitiated(completion downloadUpdateStatusCompletion: @escaping DownloadStatusCallback) {
            sparkleChannel.debug("showDownloadInitiated")
            updater?.status = "Downloading update..."
        }
        
        override func showDownloadDidReceiveExpectedContentLength(_ expectedContentLength: UInt64) {
            sparkleChannel.debug("showDownloadDidReceiveExpectedContentLength")
            expected = expectedContentLength
        }
        
        override func showDownloadDidReceiveData(ofLength length: UInt64) {
            sparkleChannel.debug("showDownloadDidReceiveData")
            received += length
            updater?.status = "Downloading update... (\(percent)%)"
        }
        
        override func showDownloadDidStartExtractingUpdate() {
            sparkleChannel.debug("showDownloadDidStartExtractingUpdate")
            updater?.status = "Extracting update..."
        }
        
        override func showExtractionReceivedProgress(_ progress: Double) {
            sparkleChannel.debug("showExtractionReceivedProgress")
            updater?.progress = progress
            updater?.status = "Extracting update... (\(percent)%)"
        }
        
        override func showReady(toInstallAndRelaunch installUpdateHandler: @escaping UpdateStatusCallback) {
            sparkleChannel.debug("showReady")
            updater?.status = "Restarting..."
            installUpdateHandler(.installAndRelaunch)
        }
        
        override func showInstallingUpdate() {
            sparkleChannel.debug("showInstallingUpdate")
            updater?.status = "Installing update..."
        }
        
        override func showSendingTerminationSignal() {
            sparkleChannel.debug("showSendingTerminationSignal")
            updater?.status = "Sending termination..."
        }
        
        override func showUpdateInstallationDidFinish(acknowledgement: @escaping () -> Void) {
            sparkleChannel.debug("showUpdateInstallationDidFinish")
            updater?.status = "Installation finished."
        }
        
        override func dismissUpdateInstallation() {
            sparkleChannel.debug("dismissUpdateInstallation")
            updater?.status = ""
        }
        
        
    }
}
#endif
