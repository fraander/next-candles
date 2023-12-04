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
 - Birthday notification reminders x days out (add to list and notify as many times as you'd like)
 - Search
 */

@main
struct Next_CandlesApp: App {
    
    @StateObject var settings: Settings = Settings.load()
    
    var body: some Scene {
        WindowGroup {
            ContactListView()
                .modelContainer(for: Contact.self)
                .environmentObject(settings)
        }
    }
}
