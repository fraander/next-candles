//
//  ContactListToolbar.swift
//  Next Candles
//
//  Created by Frank Anderson on 7/4/25.
//

import SwiftUI

struct ContactListToolbar: ToolbarContent {
    
    @Environment(Router.self) var router
    let transitionNamespace: Namespace.ID
    
    var body: some ToolbarContent {
        ToolbarItemGroup(placement: .topBarLeading) {
            Button("Settings", systemImage: "gear") {
                router.present(.settings)
            }
//            .matchedTransitionSource(id: "settings", in: transitionNamespace)
        }
        
//        ToolbarItemGroup(placement: .principal) { }
        
        ToolbarItemGroup(placement: .topBarTrailing) {
            Button("Filter", systemImage: "line.3.horizontal.decrease.circle") { }
        }
    }
}

#Preview {
    NavigationView {
        ContentView()
    }
    .applyEnvironment(prePopulate: true)
}
