//
//  ContactListToolbar.swift
//  Next Candles
//
//  Created by Frank Anderson on 7/4/25.
//

import SwiftUI

struct ContactListToolbar: ToolbarContent {
    
    @Environment(Router.self) var router
    
    var body: some ToolbarContent {
        ToolbarItemGroup(placement: .topBarLeading) {
            Button("Settings", systemImage: "gear") {
                router.present(.settings)
            }
        }
        
//        ToolbarItemGroup(placement: .principal) { }
        
        ToolbarItemGroup(placement: .topBarTrailing) {
            Menu("More", systemImage: "ellipsis") {
                Button("Button 1") {}
                Button("Button 2") {}
                Button("Button 3") {}
            }
        }
    }
}

#Preview {
    NavigationView {
        BackgroundView()
            .toolbar { ContactListToolbar() }
    }
    .applyEnvironment(prePopulate: true)
}
