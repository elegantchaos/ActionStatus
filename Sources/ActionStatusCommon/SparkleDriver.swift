// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 26/02/20.
//  All code (c) 2020 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation

typealias SparkleUpdatePermissionRequest = [[String:String]]
typealias SparkleAppcastItem = [AnyHashable:Any]

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

enum SparkleUpdateAlertChoice: Int {
    case update
    case later
    case skip
}

struct SparkleUpdatePermissionResponse {
    let automaticUpdateChecks: Bool
    let sendSystemProfile: Bool
}

struct SparkleDownloadData {
    let data: Data
    let encoding: String?
    let mimeType: String?
}
//
//@objc protocol SparkleDriver {
//    func showCanCheck(forUpdates canCheckForUpdates: Bool)
//    func show(_ request: SparkleUpdatePermissionRequest, reply: @escaping ([String:Bool]) -> Void)
//    func showUserInitiatedUpdateCheck(completion updateCheckStatusCompletion: @escaping (UInt) -> Void)
//    func dismissUserInitiatedUpdateCheck()
//    func showUpdateFound(with appcastItem: SparkleAppcastItem, userInitiated: Bool, reply: @escaping (Int) -> Void)
//    func showDownloadedUpdateFound(with appcastItem: SparkleAppcastItem, userInitiated: Bool, reply: @escaping (Int) -> Void)
//    func showResumableUpdateFound(with appcastItem: SparkleAppcastItem, userInitiated: Bool, reply: @escaping (UInt) -> Void)
//    func showInformationalUpdateFound(with appcastItem: SparkleAppcastItem, userInitiated: Bool, reply: @escaping (Int) -> Void)
//    func showUpdateReleaseNotes(with downloadData: [String:Any])
//    func showUpdateReleaseNotesFailedToDownloadWithError(_ error: Error)
//    func showUpdateNotFound(acknowledgement: @escaping () -> Void)
//    func showUpdaterError(_ error: Error, acknowledgement: @escaping () -> Void)
//    func showDownloadInitiated(completion downloadUpdateStatusCompletion: @escaping (UInt) -> Void)
//    func showDownloadDidReceiveExpectedContentLength(_ expectedContentLength: UInt64)
//    func showDownloadDidReceiveData(ofLength length: UInt64)
//    func showDownloadDidStartExtractingUpdate()
//    func showExtractionReceivedProgress(_ progress: Double)
//    func showReady(toInstallAndRelaunch installUpdateHandler: @escaping (UInt) -> Void)
//    func showInstallingUpdate()
//    func showSendingTerminationSignal()
//    func showUpdateInstallationDidFinish(acknowledgement: @escaping () -> Void)
//    func dismissUpdateInstallation()
//}

//protocol SparkleConvertable: RawRepresentable {
//    associatedtype SparkleType
//    var converted: SparkleType { get }
//}
//
//extension SparkleConvertable where RawValue == SparkleType {
//    var converted: SparkleType { return self.rawValue }
//}
//
//extension SparkleUserInitiatedCheckStatus: SparkleConvertable {
//    var converted: UInt {
//        <#code#>
//    }
//
//    typealias SparkleType = UInt
//}
//
//extension SparkleDownloadUpdateStatus: SparkleConvertable {
//    typealias SparkleType = SPUDownloadUpdateStatus
//}
//
//extension SparkleInstallUpdateStatus: SparkleConvertable {
//    typealias SparkleType = SPUInstallUpdateStatus
//}
//
//extension SparkleUpdateAlertChoice: SparkleConvertable {
//    typealias SparkleType = SPUUpdateAlertChoice
//}
//
//extension SparkleInformationalUpdateAlertChoice: SparkleConvertable {
//    typealias SparkleType = SPUInformationalUpdateAlertChoice
//}
//
//extension SparkleUpdatePermissionResponse {
//    var converted: SUUpdatePermissionResponse { return SUUpdatePermissionResponse(automaticUpdateChecks: automaticUpdateChecks, sendSystemProfile: sendSystemProfile) }
//}

//protocol ExpandedSparkleDriver: SparkleDriver {
//    func show(_ request: SparkleUpdatePermissionRequest, reply: @escaping (SparkleUpdatePermissionResponse) -> Void)
//    func showUserInitiatedUpdateCheck(completion updateCheckStatusCompletion: @escaping (SparkleUserInitiatedCheckStatus) -> Void)
//    func showUpdateFound(with appcastItem: SparkleAppcastItem, userInitiated: Bool, reply: @escaping (SparkleUpdateAlertChoice) -> Void)
//    func showDownloadedUpdateFound(with appcastItem: SparkleAppcastItem, userInitiated: Bool, reply: @escaping (SparkleUpdateAlertChoice) -> Void)
//    func showResumableUpdateFound(with appcastItem: SparkleAppcastItem, userInitiated: Bool, reply: @escaping (SparkleInstallUpdateStatus) -> Void)
//    func showInformationalUpdateFound(with appcastItem: SparkleAppcastItem, userInitiated: Bool, reply: @escaping (SparkleInformationalUpdateAlertChoice) -> Void)
//    func showUpdateReleaseNotes(with downloadData: SparkleDownloadData)
//    func showDownloadInitiated(completion downloadUpdateStatusCompletion: @escaping (SparkleDownloadUpdateStatus) -> Void)
//    func showReady(toInstallAndRelaunch installUpdateHandler: @escaping (SparkleInstallUpdateStatus) -> Void)
//}

class ExpandedSparkleDriver: NSObject, SparkleBridge {
    func showCanCheck(forUpdates canCheckForUpdates: Bool) {
    }
    
    func showUpdatePermissionRequest(_ request: [[String : String]], reply: @escaping ([String : NSNumber]) -> Void) {
    }
    
    func dismissUserInitiatedUpdateCheck() {
    }
    
    func showUpdateFound(withAppcastItem appcastItem: [AnyHashable : Any], userInitiated: Bool, reply: @escaping (Int) -> Void) {
    }
    
    func showDownloadedUpdateFound(withAppcastItem appcastItem: [AnyHashable : Any], userInitiated: Bool, reply: @escaping (Int) -> Void) {
    }
    
    func showResumableUpdateFound(withAppcastItem appcastItem: [AnyHashable : Any], userInitiated: Bool, reply: @escaping (UInt) -> Void) {
    }
    
    func showInformationalUpdateFound(withAppcastItem appcastItem: [AnyHashable : Any], userInitiated: Bool, reply: @escaping (Int) -> Void) {
    }
    
    func showUpdateReleaseNotes(withDownloadData downloadData: [AnyHashable : Any]) {
    }
    
    func showUpdateReleaseNotesFailedToDownloadWithError(_ error: Error) {
    }
    
    func showUpdateNotFound(acknowledgement: @escaping () -> Void) {
    }
    
    func showUpdaterError(_ error: Error, acknowledgement: @escaping () -> Void) {
    }
    
    func showDownloadDidReceiveExpectedContentLength(_ expectedContentLength: UInt64) {
    }
    
    func showDownloadDidReceiveData(ofLength length: UInt64) {
    }
    
    func showDownloadDidStartExtractingUpdate() {
    }
    
    func showExtractionReceivedProgress(_ progress: Double) {
    }
    
    func showInstallingUpdate() {
    }
    
    func showSendingTerminationSignal() {
    }
    
    func showUpdateInstallationDidFinish(acknowledgement: @escaping () -> Void) {
    }
    
    func dismissUpdateInstallation() {
    }
    
    func showUserInitiatedUpdateCheck(completion updateCheckStatusCompletion: @escaping (UInt) -> Void) {
        showUserInitiatedUpdateCheck() { response in updateCheckStatusCompletion(response.rawValue) }
        
    }
    
    func showDownloadInitiated(completion downloadUpdateStatusCompletion: @escaping (UInt) -> Void) {
        showDownloadInitiated() { response in downloadUpdateStatusCompletion(response.rawValue) }
    }
    
    func showReady(toInstallAndRelaunch installUpdateHandler: @escaping (UInt) -> Void) {
        showReady() { response in installUpdateHandler(response.rawValue) }
    }

    /// Swiftified API
    
    func show(_ request: SparkleUpdatePermissionRequest, reply: @escaping (SparkleUpdatePermissionResponse) -> Void) {
    }
    func showUserInitiatedUpdateCheck(completion updateCheckStatusCompletion: @escaping (SparkleUserInitiatedCheckStatus) -> Void) {
    }
    func showUpdateFound(with appcastItem: SparkleAppcastItem, userInitiated: Bool, reply: @escaping (SparkleUpdateAlertChoice) -> Void) {
    }
    func showDownloadedUpdateFound(with appcastItem: SparkleAppcastItem, userInitiated: Bool, reply: @escaping (SparkleUpdateAlertChoice) -> Void) {
    }
    func showResumableUpdateFound(with appcastItem: SparkleAppcastItem, userInitiated: Bool, reply: @escaping (SparkleInstallUpdateStatus) -> Void) {
    }
    func showInformationalUpdateFound(with appcastItem: SparkleAppcastItem, userInitiated: Bool, reply: @escaping (SparkleInformationalUpdateAlertChoice) -> Void) {
    }
    func showUpdateReleaseNotes(with downloadData: SparkleDownloadData) {
    }
    func showDownloadInitiated(completion downloadUpdateStatusCompletion: @escaping (SparkleDownloadUpdateStatus) -> Void) {
    }
    func showReady(toInstallAndRelaunch installUpdateHandler: @escaping (SparkleInstallUpdateStatus) -> Void) {
    }

}
