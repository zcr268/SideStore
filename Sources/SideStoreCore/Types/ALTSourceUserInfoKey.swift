//
//  ALTSourceUserInfoKey.swift
//  SideStore
//
//  Created by Joseph Mattiello on 02/28/23.
//  Copyright © 2023 Joseph Mattiello. All rights reserved.
//

import Foundation

@objc
public enum ALTSourceUserInfoKey: Int, CaseIterable {
    case patreonAccessToken

    public var stringValue: String {
        switch self {
        case .patreonAccessToken:
            return "patreonAccessToken"
        }
    }
}
