// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Developer on 26/02/2020.
//  All code (c) 2020 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation
import Sparkle

class WrappedUserDriver: NSObject, SPUUserDriver {
    let driver: SparkleDriver

    init(wrapping driver: SparkleDriver) {
        self.driver = driver
    }
    
    func showCanCheck(forUpdates canCheckForUpdates: Bool) {
        driver.showCanCheck(forUpdates: canCheckForUpdates)
    }
    
    func show(_ request: SPUUpdatePermissionRequest, reply: @escaping (SUUpdatePermissionResponse) -> Void) {
        driver.show(request.systemProfile) { response in
            reply(SUUpdatePermissionResponse(automaticUpdateChecks: response.automaticUpdateChecks, sendSystemProfile: response.sendSystemProfile))
        }
    }
    
    func showUserInitiatedUpdateCheck(completion updateCheckStatusCompletion: @escaping (SPUUserInitiatedCheckStatus) -> Void) {
        driver.showUserInitiatedUpdateCheck() { status in
            updateCheckStatusCompletion(SPUUserInitiatedCheckStatus(rawValue: status.rawValue)!)
        }
    }
    
    func dismissUserInitiatedUpdateCheck() {
        driver.dismissUserInitiatedUpdateCheck()
    }
    
    func showUpdateFound(with appcastItem: SUAppcastItem, userInitiated: Bool, reply: @escaping (SPUUpdateAlertChoice) -> Void) {
    }
    
    func showDownloadedUpdateFound(with appcastItem: SUAppcastItem, userInitiated: Bool, reply: @escaping (SPUUpdateAlertChoice) -> Void) {
    }
    
    func showResumableUpdateFound(with appcastItem: SUAppcastItem, userInitiated: Bool, reply: @escaping (SPUInstallUpdateStatus) -> Void) {
    }
    
    func showInformationalUpdateFound(with appcastItem: SUAppcastItem, userInitiated: Bool, reply: @escaping (SPUInformationalUpdateAlertChoice) -> Void) {
    }
    
    func showUpdateReleaseNotes(with downloadData: SPUDownloadData) {
    }
    
    func showUpdateReleaseNotesFailedToDownloadWithError(_ error: Error) {
    }
    
    func showUpdateNotFound(acknowledgement: @escaping () -> Void) {
    }
    
    func showUpdaterError(_ error: Error, acknowledgement: @escaping () -> Void) {
    }
    
    func showDownloadInitiated(completion downloadUpdateStatusCompletion: @escaping (SPUDownloadUpdateStatus) -> Void) {
    }
    
    func showDownloadDidReceiveExpectedContentLength(_ expectedContentLength: UInt64) {
    }
    
    func showDownloadDidReceiveData(ofLength length: UInt64) {
    }
    
    func showDownloadDidStartExtractingUpdate() {
    }
    
    func showExtractionReceivedProgress(_ progress: Double) {
    }
    
    func showReady(toInstallAndRelaunch installUpdateHandler: @escaping (SPUInstallUpdateStatus) -> Void) {
    }
    
    func showInstallingUpdate() {
    }
    
    func showSendingTerminationSignal() {
    }
    
    func showUpdateInstallationDidFinish(acknowledgement: @escaping () -> Void) {
    }
    
    func dismissUpdateInstallation() {
    }
    
    
}
