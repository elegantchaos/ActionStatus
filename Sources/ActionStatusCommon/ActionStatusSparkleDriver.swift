// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Developer on 27/02/2020.
//  All code (c) 2020 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Logger

let sparkleChannel = Channel("Sparkle")

class ActionStatusSparkleDriver: SparkleDriver {
    
    override func showCanCheck(forUpdates canCheckForUpdates: Bool) {
        sparkleChannel.debug("canCheckForUpdates: \(canCheckForUpdates)")
    }
    
    override func showUpdatePermissionRequest(_ request: UpdatePermissionRequest, reply: @escaping (UpdatePermissionResponse) -> Void) {
        sparkleChannel.debug("show")
    }
    
    override func showUserInitiatedUpdateCheck(completion updateCheckStatusCompletion: @escaping (UserInitiatedCheckStatus) -> Void) {
        sparkleChannel.debug("showUserInitiatedUpdateCheck")
    }
    
    override func dismissUserInitiatedUpdateCheck() {
        sparkleChannel.debug("dismissUserInitiatedUpdateCheck")
    }
    
    override func showUpdateFound(with appcastItem: AppcastItem, userInitiated: Bool, reply: @escaping (UpdateAlertChoice) -> Void) {
        sparkleChannel.debug("showUpdateFound")
    }
    
    override func showDownloadedUpdateFound(with appcastItem: AppcastItem, userInitiated: Bool, reply: @escaping (UpdateAlertChoice) -> Void) {
        sparkleChannel.debug("showDownloadedUpdateFound")
    }
    
    override func showResumableUpdateFound(with appcastItem: AppcastItem, userInitiated: Bool, reply: @escaping (InstallUpdateStatus) -> Void) {
        sparkleChannel.debug("showResumableUpdateFound")
    }
    
    override func showInformationalUpdateFound(with appcastItem: AppcastItem, userInitiated: Bool, reply: @escaping (InformationalUpdateAlertChoice) -> Void) {
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
    }
    
    override func showDownloadInitiated(completion downloadUpdateStatusCompletion: @escaping (DownloadUpdateStatus) -> Void) {
        sparkleChannel.debug("showDownloadInitiated")
    }
    
    override func showDownloadDidReceiveExpectedContentLength(_ expectedContentLength: UInt64) {
        sparkleChannel.debug("showDownloadDidReceiveExpectedContentLength")
    }
    
    override func showDownloadDidReceiveData(ofLength length: UInt64) {
        sparkleChannel.debug("showDownloadDidReceiveData")
    }
    
    override func showDownloadDidStartExtractingUpdate() {
        sparkleChannel.debug("showDownloadDidStartExtractingUpdate")
    }
    
    override func showExtractionReceivedProgress(_ progress: Double) {
        sparkleChannel.debug("showExtractionReceivedProgress")
    }
    
    override func showReady(toInstallAndRelaunch installUpdateHandler: @escaping (InstallUpdateStatus) -> Void) {
        sparkleChannel.debug("showReady")
    }
    
    override func showInstallingUpdate() {
        sparkleChannel.debug("showInstallingUpdate")
    }
    
    override func showSendingTerminationSignal() {
        sparkleChannel.debug("showSendingTerminationSignal")
    }
    
    override func showUpdateInstallationDidFinish(acknowledgement: @escaping () -> Void) {
        sparkleChannel.debug("showUpdateInstallationDidFinish")
    }
    
    override func dismissUpdateInstallation() {
        sparkleChannel.debug("dismissUpdateInstallation")
    }
    
    
}
