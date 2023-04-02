//
//  PatreonAPI+UIApplication.swift
//  AltStore
//
//  Created by Riley Testut on 8/20/19.
//  Copyright © 2019 Riley Testut. All rights reserved.
//

import AuthenticationServices
import CoreData
import Foundation
import SideStoreCore

@available(iOS 13.0, *)
extension PatreonAPI: ASWebAuthenticationPresentationContextProviding {
    public func presentationAnchor(for _: ASWebAuthenticationSession) -> ASPresentationAnchor {
        UIApplication.alt_shared?.keyWindow ?? UIWindow()
    }
}
