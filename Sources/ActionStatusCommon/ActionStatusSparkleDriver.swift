// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Developer on 27/02/2020.
//  All code (c) 2020 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Logger
import SparkleBridgeClient

let sparkleChannel = Channel("Sparkle")

class ActionStatusSparkleDriver: SparkleDriver, ObservableObject {
    var updateCallback: UpdateAlertCallback?
    
    var expected: UInt64 = 0 {
        didSet {
            progress = expected > 0 ? Double(received)/Double(expected) : 0
        }
    }
    var received: UInt64 = 0 {
        didSet {
            progress = expected > 0 ? Double(received)/Double(expected) : 0
        }
    }
    
    var percent: Int {
        return Int(progress * 100)
    }
    
    @Published var progress: Double = 0
    @Published var status: String = ""
    
    var hasUpdate: Bool {
        return updateCallback != nil
    }
    
    func installUpdate() {
        updateCallback?(.update)
        updateCallback = nil
    }
    
    func skipUpdate() {
        updateCallback?(.skip)
        updateCallback = nil
    }
    
    func ignoreUpdate() {
        updateCallback?(.later)
        updateCallback = nil
    }
    
    override func showCanCheck(forUpdates canCheckForUpdates: Bool) {
        sparkleChannel.debug("canCheckForUpdates: \(canCheckForUpdates)")
    }
    
    override func showUpdatePermissionRequest(_ request: UpdatePermissionRequest, reply: @escaping (UpdatePermissionResponse) -> Void) {
        sparkleChannel.debug("show")
    }
    
    override func showUserInitiatedUpdateCheck(completion updateCheckStatusCompletion: @escaping (UserInitiatedCheckStatus) -> Void) {
        sparkleChannel.debug("showUserInitiatedUpdateCheck")
        status = "Checking for update."
    }
    
    override func dismissUserInitiatedUpdateCheck() {
        sparkleChannel.debug("dismissUserInitiatedUpdateCheck")
        status = ""
    }
    
    override func showUpdateFound(with appcastItem: AppcastItem, userInitiated: Bool, reply: @escaping UpdateAlertCallback) {
        sparkleChannel.debug("showUpdateFound")
        status = "Update available."
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
        sparkleChannel.debug("showUpdaterError")
    }
    
    override func showUpdaterError(_ error: Error, acknowledgement: @escaping () -> Void) {
        sparkleChannel.debug("showUpdaterError")
        status = "Failed to launch installer."
    }
    
    override func showDownloadInitiated(completion downloadUpdateStatusCompletion: @escaping DownloadStatusCallback) {
        sparkleChannel.debug("showDownloadInitiated")
        status = "Downloading update..."
    }
    
    override func showDownloadDidReceiveExpectedContentLength(_ expectedContentLength: UInt64) {
        sparkleChannel.debug("showDownloadDidReceiveExpectedContentLength")
        expected = expectedContentLength
    }
    
    override func showDownloadDidReceiveData(ofLength length: UInt64) {
        sparkleChannel.debug("showDownloadDidReceiveData")
        received += length
        status = "Downloading update... (\(percent)%)"
    }
    
    override func showDownloadDidStartExtractingUpdate() {
        sparkleChannel.debug("showDownloadDidStartExtractingUpdate")
        status = "Extracting update..."
    }
    
    override func showExtractionReceivedProgress(_ progress: Double) {
        sparkleChannel.debug("showExtractionReceivedProgress")
        self.progress = progress
        status = "Extracting update... (\(percent)%)"
    }
    
    override func showReady(toInstallAndRelaunch installUpdateHandler: @escaping UpdateStatusCallback) {
        sparkleChannel.debug("showReady")
        status = "Restarting..."
        installUpdateHandler(.installAndRelaunch)
    }
    
    override func showInstallingUpdate() {
        sparkleChannel.debug("showInstallingUpdate")
        status = "Installing update..."
    }
    
    override func showSendingTerminationSignal() {
        sparkleChannel.debug("showSendingTerminationSignal")
        status = "Sending termination..."
    }
    
    override func showUpdateInstallationDidFinish(acknowledgement: @escaping () -> Void) {
        sparkleChannel.debug("showUpdateInstallationDidFinish")
        status = "Installation finished."
    }
    
    override func dismissUpdateInstallation() {
        sparkleChannel.debug("dismissUpdateInstallation")
        status = ""
    }
    
    
}
