//
//  ContactListToolbar.swift
//  Next Candles
//
//  Created by Frank Anderson on 7/4/25.
//

import SwiftUI

struct ContactListToolbar: ToolbarContent {
    
    @Environment(Router.self) var router
    @Environment(ContactImportManager.self) var cim
    let transitionNamespace: Namespace.ID
    @Environment(\.modelContext) var modelContext
    
    var body: some ToolbarContent {
        ToolbarItemGroup(placement: .topBarLeading) {
            Button("Settings", systemImage: "gear") {
                router.present(.settings)
            }
//            .matchedTransitionSource(id: "settings", in: transitionNamespace)
        }
        
//        ToolbarItemGroup(placement: .principal) { }
        
//        ToolbarItemGroup(placement: .topBarTrailing) {
//            Button("Filter", systemImage: "line.3.horizontal.decrease.circle") { }
//        }
        
        ToolbarItemGroup(placement: .topBarTrailing) {
            Button("Reload", systemImage: "arrow.trianglehead.2.clockwise.rotate.90") {
                Task { await cim.importContacts(modelContext: modelContext, showAlert: true) }
            }
        }
    }
}

#Preview {
    NavigationView {
        ContentView()
    }
    .applyEnvironment(prePopulate: true)
}
