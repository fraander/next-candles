//
//  Next_CandlesApp.swift
//  Next Candles
//
//  Created by Frank Anderson on 7/28/22.
//

import SwiftUI
import UserNotifications
import Combine

/*
 
 Features
 - Better import management --> "Every contact in the contacts database has a unique ID, which you access using the identifier property. The mutable and immutable versions of the same contact have the same identifier."
     - So far, only imports new contacts
     - In the future, import changes to existing ones as well!
 - Birthday notification reminders x days out (add to list and notify as many times as you'd like)
 - More timing customization on the notifications as well (probably give options at "time of set" in a sheet)
 
 */

@main
struct Next_CandlesApp: App {
    
    @StateObject var settings: Settings = Settings.load()
    
    var body: some Scene {
        WindowGroup {
            ContactListView()
                .modelContainer(for: Contact.self)
                .environmentObject(settings)
#if os(macOS)
                .frame(minWidth: 320)
                .onAppear {
                    let _ = NSApplication.shared.windows.map { $0.tabbingMode = .disallowed }
                }
#endif
                .accentColor(Color.pink)
        }
#if os(macOS)
        .commands {
            CommandGroup(replacing: .newItem) {} //remove "New Item"-menu entry
        }
        .windowStyle(.titleBar)
        .windowToolbarStyle(.automatic)
        .defaultSize(width: 400, height: 520)
#endif
    }
}
