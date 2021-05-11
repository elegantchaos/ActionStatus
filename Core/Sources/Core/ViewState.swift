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
    let editButtonIcon = "ellipsis.circle"
    let generateButtonIcon = "doc.badge.ellipsis"
    let deleteRepoIcon = "minus.circle"
    
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
        let count: Int
        switch settings.displaySize {
            case .small: count = 4
            case .medium: count = 3
            default: count = 2
        }

        #if os(tvOS)
        return Array(repeating: .init(.flexible()), count: count)
        #else
        let cols = CGFloat(count)
        return [GridItem(.adaptive(minimum: 640 / cols, maximum: .infinity))]
        #endif
    }
     
    
}
