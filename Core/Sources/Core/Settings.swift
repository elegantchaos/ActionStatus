// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 13/04/21.
//  All code (c) 2021 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation
import Keychain

public extension String {
    static let defaultOwnerKey = "DefaultOwner"
    static let refreshIntervalKey = "RefreshInterval"
    static let displaySizeKey = "TextSize"
    static let showInMenuKey = "ShowInMenu"
    static let showInDockKey = "ShowInDock"
    static let githubAuthenticationKey = "GithubAuthentication"
    static let githubUserKey = "GithubUser"
    static let githubServerKey = "GithubServer"
    static let sortModeKey = "SortMode"
    static let testOldestNewestKey = "TestOldestNewest"
    static let testRefresh = "TestRefresh"
}

public struct Settings {
    public var isEditing: Bool = false
    var selectedID: UUID? = nil
    var displaySize: DisplaySize = .automatic
    var refreshRate: RefreshRate = .automatic
    var githubAuthentication: Bool = false
    var githubUser: String = ""
    var githubServer: String = "api.github.com"
    var sortMode: SortMode = .state
    var showInMenu = false
    var showInDock = false
    var testRefresh = false
    
    enum ReadResult {
        case authenticationUnchanged
        case authenticationChanged
    }
   
    func authenticationChanged(from other: Settings) -> Bool {
        guard testRefresh == other.testRefresh else { return true }
        guard githubAuthentication == other.githubAuthentication else { return true }
        guard githubUser == other.githubUser else { return true }
        guard githubServer == other.githubServer else { return true }
        return readToken() != other.readToken()
    }
    
    func readToken() -> String {
        let token = try? Keychain.default.password(for: githubUser, on: githubServer)
        return token ?? ""
    }

    func writeToken(_ token: String) {
        do {
            try Keychain.default.update(password: token, for: githubUser, on: githubServer)
        } catch {
            print("Failed to save token \(error)")
        }
    }
    
    public mutating func toggleEditing() -> Bool {
        isEditing = !isEditing
        return isEditing
    }
    
    mutating func readSettings() -> ReadResult {
        let oldSettings = self
        let defaults = UserDefaults.standard
        defaults.read(&displaySize, fromKey: .displaySizeKey)
        defaults.read(&refreshRate, fromKey: .refreshIntervalKey)
        defaults.read(&githubAuthentication, fromKey: .githubAuthenticationKey)
        defaults.read(&githubUser, fromKey: .githubUserKey, default: "")
        defaults.read(&githubServer, fromKey: .githubServerKey, default: "api.github.com")
        defaults.read(&sortMode, fromKey: .sortModeKey)
        defaults.read(&showInMenu, fromKey: .showInMenuKey)
        defaults.read(&showInDock, fromKey: .showInDockKey)
        defaults.read(&testRefresh, fromKey: .testRefresh)

        settingsChannel.debug("\(String.refreshIntervalKey) is \(refreshRate)")
        settingsChannel.debug("\(String.displaySizeKey) is \(displaySize)")
        
        return authenticationChanged(from: oldSettings) ? .authenticationChanged : .authenticationUnchanged
    }
    
    func writeSettings() {
        let defaults = UserDefaults.standard
        defaults.write(refreshRate.rawValue, forKey: .refreshIntervalKey)
        defaults.write(displaySize.rawValue, forKey: .displaySizeKey)
        defaults.write(githubAuthentication, forKey: .githubAuthenticationKey)
        defaults.write(githubUser, forKey: .githubUserKey)
        defaults.write(githubServer, forKey: .githubServerKey)
        defaults.write(sortMode.rawValue, forKey: .sortModeKey)
        defaults.write(showInDock, forKey: .showInDockKey)
        defaults.write(showInMenu, forKey: .showInMenuKey)
        defaults.write(testRefresh, forKey: .testRefresh)

        // NB: github token is stored in the keychain

    }
}

public extension UserDefaults {
    
    /// Write a value to the defaults if it has changed.
    /// We perform a comparison first to avoid triggering unnecessary
    /// notifications if the value is unchanged.
    func write(_ value: Bool, forKey key: String) {
        if bool(forKey: key) != value {
            set(value, forKey: key)
        }
    }
}

