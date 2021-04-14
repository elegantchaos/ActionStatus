// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 09/03/20.
//  All code (c) 2020 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Bundles
import SwiftUI
import SwiftUIExtensions

struct PreviewHost: ApplicationHost {
    let info = BundleInfo(for: Bundle.main)
    var refreshController: RefreshController? { return nil }
}

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
}

public class ViewState: ObservableObject {
    @Published public var settings = Settings()

    public let host: ApplicationHost
    public let padding: CGFloat = 10
    
    #if os(tvOS)
    public let spacing: CGFloat = 640
    #else
    public let spacing: CGFloat = 256
    #endif
    
    let linkIcon = "arrow.right.circle.fill"
    let startEditingIcon = "lock.fill"
    let stopEditingIcon = "lock.open.fill"
    let preferencesIcon = "gearshape"
    
    let formStyle = FormStyle(
        headerFont: .headline,
        footerFont: Font.body.italic(),
        labelOpacity: 0.5,
        contentFont: Font.body
    )
    
    public init(host: ApplicationHost) {
        self.host = host
    }
    
    @discardableResult func addRepo(to model: Model) -> Repo {
        let newRepo = model.addRepo(viewState: self)
        host.saveState()
        settings.selectedID = newRepo.id
        return newRepo
    }
    
    var repoGridColumns: [GridItem] {
        #if os(tvOS)
        let count: Int
        switch displaySize {
            case .small: count = 4
            case .medium: count = 3
            default: count = 2
        }
        return Array(repeating: .init(.flexible()), count: count)
        #else
        return [GridItem(.adaptive(minimum: 256, maximum: 384))]
        #endif
    }
     
    
}
