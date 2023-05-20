//
//  UnstableFeatures.swift
//  SideStore
//
//  Created by naturecodevoid on 5/20/23.
//  Copyright © 2023 SideStore. All rights reserved.
//

import SwiftUI

// I prefixed it with Available to make UnstableFeatures come up first in autocomplete, feel free to rename it if you know a better name
enum AvailableUnstableFeature: String, CaseIterable {
    // The value will be the GitHub Issue number. For example, "123" would correspond to https://github.com/SideStore/SideStore/issues/123
    //
    // Unstable features must have a GitHub Issue for tracking progress, PRs and feedback/commenting.
    
    case jitUrlScheme = "0"
    
    /// Dummy variant to ensure there is always at least one variant. DO NOT USE!
    case dummy = "dummy"
    
    func availableOutsideDevMode() -> Bool {
        switch self {
        // If your unstable feature is stable enough to be used by nightly users who are not alpha testers or developers,
        // you may want to have it available in the "Unstable Features" menu in Settings (outside of dev mode). To do so, add this:
        //case .yourFeature: return true
        case .jitUrlScheme: return true
        
        default: return false
        }
    }
}


class UnstableFeatures: ObservableObject {
    #if UNSTABLE
    static let shared = UnstableFeatures()
    @Published var features: [AvailableUnstableFeature: Bool] = [:]
    
    static func load() {
        if shared.features.count > 0 { return print("It seems unstable features have already been loaded, skipping") }
        
        if let rawFeatures = UserDefaults.shared.unstableFeatures,
           let rawFeatures = try? JSONDecoder().decode([String: Bool].self, from: rawFeatures) {
            for rawFeature in rawFeatures {
                if let feature = AvailableUnstableFeature.allCases.first(where: { feature in String(describing: feature) == rawFeature.key }) {
                    shared.features[feature] = rawFeature.value
                } else {
                    print("Unknown unstable feature: \(rawFeature.key) = \(rawFeature.value)")
                }
            }
            for feature in AvailableUnstableFeature.allCases {
                if shared.features[feature] == nil {
                    shared.features[feature] = false
                }
            }
            save(load: true)
        } else {
            print("Setting all unstable features to false since we couldn't load them from UserDefaults (either they were never saved or there was an error decoding JSON)")
            for feature in AvailableUnstableFeature.allCases {
                shared.features[feature] = false
            }
            save()
        }
    }
    
    private static func save(load: Bool = false) {
        var rawFeatures: [String: Bool] = [:]
        for feature in shared.features {
            rawFeatures[String(describing: feature.key)] = feature.value
        }
        UserDefaults.shared.unstableFeatures = try! JSONEncoder().encode(rawFeatures)
        print("\(load ? "Loaded" : "Saved") unstable features: \(String(describing: rawFeatures))")
    }
    
    static func set(_ feature: AvailableUnstableFeature, enabled: Bool) {
        shared.features[feature] = enabled
        save()
    }
    #endif
    
    @inline(__always) // hopefully this will help the compiler realize that if statements that use this function should be removed on non-unstable builds
    static func enabled(_ feature: AvailableUnstableFeature) -> Bool {
        #if UNSTABLE
        shared.features[feature] ?? false
        #else
        false
        #endif
    }
}
