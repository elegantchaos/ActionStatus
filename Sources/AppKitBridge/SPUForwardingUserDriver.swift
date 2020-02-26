// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Developer on 26/02/2020.
//  All code (c) 2020 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation
import Sparkle

protocol SparkleConvertable: RawRepresentable {
    associatedtype SparkleType
    var converted: SparkleType { get }
}

extension SparkleConvertable where SparkleType: RawRepresentable, RawValue == SparkleType.RawValue {
    var converted: SparkleType { return SparkleType(rawValue: self.rawValue)! }
}

extension SparkleUserInitiatedCheckStatus: SparkleConvertable {
    typealias SparkleType = SPUUserInitiatedCheckStatus
}

extension SparkleDownloadUpdateStatus: SparkleConvertable {
    typealias SparkleType = SPUDownloadUpdateStatus
}

extension SparkleInstallUpdateStatus: SparkleConvertable {
    typealias SparkleType = SPUInstallUpdateStatus
}

extension SparkleUpdateAlertChoice: SparkleConvertable {
    typealias SparkleType = SPUUpdateAlertChoice
}

extension SparkleInformationalUpdateAlertChoice: SparkleConvertable {
    typealias SparkleType = SPUInformationalUpdateAlertChoice
}

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
            updateCheckStatusCompletion(status.converted)
        }
    }
    
    func dismissUserInitiatedUpdateCheck() {
        driver.dismissUserInitiatedUpdateCheck()
    }
    
    func showUpdateFound(with appcastItem: SUAppcastItem, userInitiated: Bool, reply: @escaping (SPUUpdateAlertChoice) -> Void) {
        driver.showUpdateFound(with: <#T##SparkleAppcastItem#>, userInitiated: <#T##Bool#>, reply: <#T##(SparkleUpdateAlertChoice) -> Void#>)
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
