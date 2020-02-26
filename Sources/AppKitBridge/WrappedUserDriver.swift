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

extension SparkleUpdatePermissionResponse {
    var converted: SUUpdatePermissionResponse { return SUUpdatePermissionResponse(automaticUpdateChecks: automaticUpdateChecks, sendSystemProfile: sendSystemProfile) }
}

extension SUUpdatePermissionResponse {
    convenience init(_ dictionary: [String:Bool]) {
        self.init(
            automaticUpdateChecks: dictionary["automaticUpdateChecks"]!,
            sendSystemProfile: dictionary["sendSystemProfile"]!
        )
    }
}

extension SparkleDownloadData {
    var converted: SPUDownloadData { return SPUDownloadData(data: data, textEncodingName: encoding, mimeType: mimeType) }
}
    
internal class WrappedUserDriver: NSObject, SPUUserDriver {
    let driver: SparkleDriver

    init(wrapping driver: SparkleDriver) {
        self.driver = driver
    }
    
    func showCanCheck(forUpdates canCheckForUpdates: Bool) {
        driver.showCanCheck(forUpdates: canCheckForUpdates)
    }
    
    func show(_ request: SPUUpdatePermissionRequest, reply: @escaping (SUUpdatePermissionResponse) -> Void) {
        driver.show(request.systemProfile) { response in reply(SUUpdatePermissionResponse(response)) }
    }
    
    func showUserInitiatedUpdateCheck(completion updateCheckStatusCompletion: @escaping (SPUUserInitiatedCheckStatus) -> Void) {
        driver.showUserInitiatedUpdateCheck() { status in
            updateCheckStatusCompletion(SPUUserInitiatedCheckStatus(rawValue: status)!)
        }
    }
    
    func dismissUserInitiatedUpdateCheck() {
        driver.dismissUserInitiatedUpdateCheck()
    }
    
    func showUpdateFound(with appcastItem: SUAppcastItem, userInitiated: Bool, reply: @escaping (SPUUpdateAlertChoice) -> Void) {
        driver.showUpdateFound(with: appcastItem.propertiesDictionary, userInitiated: userInitiated) { choice in
            reply(SPUUpdateAlertChoice(rawValue: choice)!)
        }
    }
    
    func showDownloadedUpdateFound(with appcastItem: SUAppcastItem, userInitiated: Bool, reply: @escaping (SPUUpdateAlertChoice) -> Void) {
        driver.showDownloadedUpdateFound(with: appcastItem.propertiesDictionary, userInitiated: userInitiated) { choice in
            reply(SPUUpdateAlertChoice(rawValue: choice)! )
        }
    }
    
    func showResumableUpdateFound(with appcastItem: SUAppcastItem, userInitiated: Bool, reply: @escaping (SPUInstallUpdateStatus) -> Void) {
        driver.showResumableUpdateFound(with: appcastItem.propertiesDictionary, userInitiated: userInitiated) { choice in
            reply(SPUInstallUpdateStatus(rawValue: choice)!)
        }
    }
    
    func showInformationalUpdateFound(with appcastItem: SUAppcastItem, userInitiated: Bool, reply: @escaping (SPUInformationalUpdateAlertChoice) -> Void) {
        driver.showInformationalUpdateFound(with: appcastItem.propertiesDictionary, userInitiated: userInitiated) { choice in
            reply(SPUInformationalUpdateAlertChoice(rawValue: choice)!)
        }
    }
    
    func showUpdateReleaseNotes(with downloadData: SPUDownloadData) {
        var data: [String:Any] = [ "data": downloadData.data ]
        if let name = downloadData.textEncodingName {
            data["textEncodingName"] = name
        }
        if let type = downloadData.mimeType {
            data["mimeType"] = type
        }
        driver.showUpdateReleaseNotes(with: data)
    }
    
    func showUpdateReleaseNotesFailedToDownloadWithError(_ error: Error) {
        driver.showUpdateReleaseNotesFailedToDownloadWithError(error)
    }
    
    func showUpdateNotFound(acknowledgement: @escaping () -> Void) {
        driver.showUpdateNotFound {
            acknowledgement()
        }
    }
    
    func showUpdaterError(_ error: Error, acknowledgement: @escaping () -> Void) {
        driver.showUpdaterError(error) {
            acknowledgement()
        }
    }
    
    func showDownloadInitiated(completion downloadUpdateStatusCompletion: @escaping (SPUDownloadUpdateStatus) -> Void) {
        driver.showDownloadInitiated() { status in
            downloadUpdateStatusCompletion(SPUDownloadUpdateStatus(rawValue: status)!)
        }
    }
    
    func showDownloadDidReceiveExpectedContentLength(_ expectedContentLength: UInt64) {
        driver.showDownloadDidReceiveExpectedContentLength(expectedContentLength)
    }
    
    func showDownloadDidReceiveData(ofLength length: UInt64) {
        driver.showDownloadDidReceiveData(ofLength: length)
    }
    
    func showDownloadDidStartExtractingUpdate() {
        driver.showDownloadDidStartExtractingUpdate()
    }
    
    func showExtractionReceivedProgress(_ progress: Double) {
        driver.showExtractionReceivedProgress(progress)
    }
    
    func showReady(toInstallAndRelaunch installUpdateHandler: @escaping (SPUInstallUpdateStatus) -> Void) {
        driver.showReady() { status in
            installUpdateHandler(SPUInstallUpdateStatus(rawValue: status)!)
        }
    }
    
    func showInstallingUpdate() {
        driver.showInstallingUpdate()
    }
    
    func showSendingTerminationSignal() {
        driver.showSendingTerminationSignal()
    }
    
    func showUpdateInstallationDidFinish(acknowledgement: @escaping () -> Void) {
        driver.showUpdateInstallationDidFinish() { acknowledgement() }
    }
    
    func dismissUpdateInstallation() {
        driver.dismissUpdateInstallation()
    }
}
