//
//  Next_CandlesApp.swift
//  Next Candles
//
//  Created by Frank Anderson on 7/28/22.
//

import SwiftUI

/*
 Bugs
 - When removing the last contact from a month, the month sticks around
 - Loading for the first time brings the whole app to a halt -- setup some "import" screen to get around this
 - Names that are long mixed with dates that are long has a weird rendering error. Is there a way to shorten dates / truncate
 
 Features
 - Birthday reminders x days out
 - Highlight upcoming in x days
 - Tap to detail to show contact card
 - Better import management
 - Show/hide hidden
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
