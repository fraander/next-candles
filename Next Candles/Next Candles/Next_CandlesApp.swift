//
//  Next_CandlesApp.swift
//  Next Candles
//
//  Created by Frank Anderson on 7/28/22.
//

import SwiftUI

/*
 Features
 - Better import management --> "Every contact in the contacts database has a unique ID, which you access using the identifier property. The mutable and immutable versions of the same contact have the same identifier."
    - So far, only imports new contacts
    - In the future, import changes to existing ones as well!
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
