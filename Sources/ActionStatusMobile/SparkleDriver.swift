// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 26/02/20.
//  All code (c) 2020 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation

class SparkleDriver: NSObject, SparkleBridge {
    typealias UpdatePermissionRequest = [[String:String]]
    typealias UpdatePermissionResponse = SparkleBridgeUpdatePermissionResponse
    
    typealias AppcastItem = [AnyHashable:Any]
    
    typealias UpdateAlertCallback = (UpdateAlertChoice) -> Void
    typealias UserInitiatedCallback = (UserInitiatedCheckStatus) -> Void
    typealias UpdateStatusCallback = (InstallUpdateStatus) -> Void
    typealias DownloadStatusCallback = (DownloadUpdateStatus) -> Void
    typealias InformationCallback = (InformationalUpdateAlertChoice) -> Void
    
    enum UserInitiatedCheckStatus: UInt {
        case done = 0
        case cancelled = 1
    }

    enum InstallUpdateStatus: UInt {
        case install
        case installAndRelaunch
        case dismiss
    }

    enum InformationalUpdateAlertChoice: Int {
        case dismiss
        case skip
    }

    enum DownloadUpdateStatus: UInt {
        case done
        case cancelled
    }

    enum UpdateAlertChoice: Int {
        case update
        case later
        case skip
    }

    /// Implemented API Calling On To Swiftifed Version - Subclass Should Not Override
    ///
    
    final func showUserInitiatedUpdateCheck(completion updateCheckStatusCompletion: @escaping (UInt) -> Void) {
        showUserInitiatedUpdateCheck() { response in updateCheckStatusCompletion(response.rawValue) }
    }
    
    final func showUpdateFound(withAppcastItem appcastItem: AppcastItem, userInitiated: Bool, reply: @escaping (Int) -> Void) {
        showUpdateFound(with: appcastItem, userInitiated: userInitiated) { response in reply(response.rawValue) }
    }
    
    final func showDownloadedUpdateFound(withAppcastItem appcastItem: AppcastItem, userInitiated: Bool, reply: @escaping (Int) -> Void) {
        showDownloadedUpdateFound(with: appcastItem, userInitiated: userInitiated) { response in reply(response.rawValue) }
    }

    final func showResumableUpdateFound(withAppcastItem appcastItem: AppcastItem, userInitiated: Bool, reply: @escaping (UInt) -> Void) {
        showResumableUpdateFound(with: appcastItem, userInitiated: userInitiated) { response in reply(response.rawValue) }
    }
    
    final func showInformationalUpdateFound(withAppcastItem appcastItem: AppcastItem, userInitiated: Bool, reply: @escaping (Int) -> Void) {
        showInformationalUpdateFound(with: appcastItem, userInitiated: userInitiated) { response in reply(response.rawValue) }
    }

    final func showDownloadInitiated(completion downloadUpdateStatusCompletion: @escaping (UInt) -> Void) {
        showDownloadInitiated() { response in downloadUpdateStatusCompletion(response.rawValue) }
    }
    
    final func showReady(toInstallAndRelaunch installUpdateHandler: @escaping (UInt) -> Void) {
        showReady() { response in installUpdateHandler(response.rawValue) }
    }

    /// Bridged API - Subclass Should Override
    
    func showCanCheck(forUpdates canCheckForUpdates: Bool) { }
    func showUpdatePermissionRequest(_ request: UpdatePermissionRequest, reply: @escaping (UpdatePermissionResponse) -> Void) { }
    func dismissUserInitiatedUpdateCheck() { }
    func showUpdateReleaseNotes(withDownloadData downloadData: Data, encoding: String?, mimeType: String?) { }
    func showUpdateReleaseNotesFailedToDownloadWithError(_ error: Error) { }
    func showUpdateNotFound(acknowledgement: @escaping () -> Void) { }
    func showUpdaterError(_ error: Error, acknowledgement: @escaping () -> Void) { }
    func showDownloadDidReceiveExpectedContentLength(_ expectedContentLength: UInt64) { }
    func showDownloadDidReceiveData(ofLength length: UInt64) { }
    func showDownloadDidStartExtractingUpdate() { }
    func showExtractionReceivedProgress(_ progress: Double) { }
    func showInstallingUpdate() { }
    func showSendingTerminationSignal() { }
    func showUpdateInstallationDidFinish(acknowledgement: @escaping () -> Void) { }
    func dismissUpdateInstallation() { }

    /// Swiftified API - Subclasses Should Override
    
    func showUserInitiatedUpdateCheck(completion updateCheckStatusCompletion: @escaping UserInitiatedCallback) { }
    func showUpdateFound(with appcastItem: AppcastItem, userInitiated: Bool, reply: @escaping UpdateAlertCallback) { }
    func showDownloadedUpdateFound(with appcastItem: AppcastItem, userInitiated: Bool, reply: @escaping UpdateAlertCallback) { }
    func showResumableUpdateFound(with appcastItem: AppcastItem, userInitiated: Bool, reply: @escaping UpdateStatusCallback) { }
    func showInformationalUpdateFound(with appcastItem: AppcastItem, userInitiated: Bool, reply: @escaping InformationCallback) { }
    func showDownloadInitiated(completion downloadUpdateStatusCompletion: @escaping DownloadStatusCallback) { }
    func showReady(toInstallAndRelaunch installUpdateHandler: @escaping UpdateStatusCallback) { }
}
