//
//  ContactDetailToolbar.swift
//  Next Candles
//
//  Created by Frank Anderson on 7/4/25.
//

import SwiftUI

struct ContactDetailToolbar: ToolbarContent {
    
    @Environment(Router.self) var router
    
    var body: some ToolbarContent {
//        ToolbarItemGroup(placement: .topBarLeading) {
//            Button(role: .close) { router.popToHome() }
//        }
        
//        ToolbarItemGroup(placement: .principal) {
//            Text("Contact Details")
//        }
        
        ToolbarItemGroup(placement: .topBarTrailing) {
//            Button(role: .confirm) { router.popToHome() }
            Button("Close", systemImage: "chevron.down", role: .close) { router.popToHome() }
        }
    }
}

#Preview {
    NavigationView {
        BackgroundView()
            .toolbar { ContactDetailToolbar() }
    }
    .applyEnvironment(prePopulate: true)
}
