//
//  Next_CandlesApp.swift
//  Next Candles
//
//  Created by Frank Anderson on 7/28/22.
//

import SwiftUI

/*
 Features
-  Show current month at top or show Jan->Dec toggle
 - Better import management
 - Add custom/manually
 - Highlight upcoming in x days
 - Birthday reminders x days out
 - Tap to detail to show contact card
 - Search
 */

@main
struct Next_CandlesApp: App {
    
    var body: some Scene {
        WindowGroup {
            ContactListView()
                .modelContainer(for: Contact.self)
        }
    }
}
