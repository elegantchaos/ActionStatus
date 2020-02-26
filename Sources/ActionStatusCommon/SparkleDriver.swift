// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 26/02/20.
//  All code (c) 2020 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation

typealias SparkleUpdatePermissionRequest = [[String:String]]

enum SparkleUserInitiatedCheckStatus: UInt {
    case done = 0
    case cancelled = 1
}

enum SparkleInstallUpdateStatus: UInt {
    case install
    case installAndRelaunch
    case dismiss
}

enum SparkleInformationalUpdateAlertChoice: Int {
    case dismiss
    case skip
}

enum SparkleDownloadUpdateStatus: UInt {
    case done
    case cancelled
}

struct SparkleUpdatePermissionResponse {
    let automaticUpdateChecks: Bool
    let sendSystemProfile: Bool
}

enum SparkleUpdateAlertChoice: Int {
    case update
    case later
    case skip
}

struct SparkleAppcastItem { }
struct SparkleDownloadData { }


protocol SparkleDriver {
    func showCanCheck(forUpdates canCheckForUpdates: Bool)
    func show(_ request: SparkleUpdatePermissionRequest, reply: @escaping (SparkleUpdatePermissionResponse) -> Void)
    func showUserInitiatedUpdateCheck(completion updateCheckStatusCompletion: @escaping (SparkleUserInitiatedCheckStatus) -> Void)
    func dismissUserInitiatedUpdateCheck()
    func showUpdateFound(with appcastItem: SparkleAppcastItem, userInitiated: Bool, reply: @escaping (SparkleUpdateAlertChoice) -> Void)
    func showDownloadedUpdateFound(with appcastItem: SparkleAppcastItem, userInitiated: Bool, reply: @escaping (SparkleUpdateAlertChoice) -> Void)
    func showResumableUpdateFound(with appcastItem: SparkleAppcastItem, userInitiated: Bool, reply: @escaping (SparkleInstallUpdateStatus) -> Void)
    func showInformationalUpdateFound(with appcastItem: SparkleAppcastItem, userInitiated: Bool, reply: @escaping (SparkleInformationalUpdateAlertChoice) -> Void)
    func showUpdateReleaseNotes(with downloadData: SparkleDownloadData)
    func showUpdateReleaseNotesFailedToDownloadWithError(_ error: Error)
    func showUpdateNotFound(acknowledgement: @escaping () -> Void)
    func showUpdaterError(_ error: Error, acknowledgement: @escaping () -> Void)
    func showDownloadInitiated(completion downloadUpdateStatusCompletion: @escaping (SparkleDownloadUpdateStatus) -> Void)
    func showDownloadDidReceiveExpectedContentLength(_ expectedContentLength: UInt64)
    func showDownloadDidReceiveData(ofLength length: UInt64)
    func showDownloadDidStartExtractingUpdate()
    func showExtractionReceivedProgress(_ progress: Double)
    func showReady(toInstallAndRelaunch installUpdateHandler: @escaping (SparkleInstallUpdateStatus) -> Void)
    func showInstallingUpdate()
    func showSendingTerminationSignal()
    func showUpdateInstallationDidFinish(acknowledgement: @escaping () -> Void)
    func dismissUpdateInstallation()
}
