//
//  Next_CandlesApp.swift
//  Next Candles
//
//  Created by Frank Anderson on 7/28/22.
//

import SwiftUI

/*
 Bugs
 - Names that are long mixedwith dates that are long has a weird rendering error. Is there a way to shorten dates / truncate
 
 Features
 - Better import management
 - Add custom/manually
 - Show/hide hidden
 - Highlight upcoming in x days
 - Reset / delete all
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
