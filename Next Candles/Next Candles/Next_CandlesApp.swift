//
//  Next_CandlesApp.swift
//  Next Candles
//
//  Created by Frank Anderson on 7/28/22.
//

import SwiftUI

@main
struct Next_CandlesApp: App {
    
    @StateObject var settings = SettingsVM()
    @StateObject var contacts = ContactsVM()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(settings)
                .environmentObject(contacts)
            
        }
    }
}

extension Array where Element == ContactWrapper {
    
}
