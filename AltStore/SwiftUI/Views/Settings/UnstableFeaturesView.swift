//
//  UnstableFeaturesView.swift
//  SideStore
//
//  Created by naturecodevoid on 5/20/23.
//  Copyright © 2023 SideStore. All rights reserved.
//

#if UNSTABLE
import SwiftUI

struct UnstableFeaturesView: View {
    @ObservedObject private var shared = UnstableFeatures.shared
    
    var inDevMode: Bool
    
    var body: some View {
        List {
            ForEach(shared.features.filter { feature, _ in feature != .dummy && (inDevMode || feature.availableOutsideDevMode()) }.sorted(by: { _, _ in true }), id: \.key) { feature, _ in
                Toggle(isOn: Binding(get: { UnstableFeatures.enabled(feature) }, set: { newValue in UnstableFeatures.set(feature, enabled: newValue) })) {
                    Text(String(describing: feature))
                    let link = "https://github.com/SideStore/SideStore/issues/\(feature.rawValue)"
                    Link(link, destination: URL(string: link)!)
                }
            }
        }.navigationTitle(L10n.UnstableFeaturesView.title)
    }
}

struct UnstableFeaturesView_Previews: PreviewProvider {
    static var previews: some View {
        UnstableFeaturesView(inDevMode: true)
    }
}
#endif
