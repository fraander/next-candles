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
 Enablers
 - Setup global alerts so that it's easier to show them; use EnvironmentObject?
 
 Features
 - Better import management --> "Every contact in the contacts database has a unique ID, which you access using the identifier property. The mutable and immutable versions of the same contact have the same identifier."
     - So far, only imports new contacts
     - In the future, import changes to existing ones as well!
 - Birthday notification reminders x days out (add to list and notify as many times as you'd like)
 - More timing customization on the notifications as well (probably give options at "time of set" in a sheet)
 - iCloud Sync with SwiftData
 - Jump to a detail screen when you launch from a notification or when you tap on a person
    - Detail view started, needs to have actions added and be adjustable to other screen sizes
 */

@main
struct Next_CandlesApp: App {
    
    @Environment(\.openURL) var openURL
    @UIApplicationDelegateAdaptor var appDelegate: NCAppDelegate
    @StateObject var settings: Settings = Settings.load()
    
    var body: some Scene {
        WindowGroup {
            ContactListView()
                .modelContainer(for: Contact.self)
                .environmentObject(settings)
                .onNotification { response in
                    
                    if let u = response.notification.request.content.targetContentIdentifier {
                        if let url = URL(string: u) {
                            openURL.callAsFunction(url)
                        }
                    }
                    
//                    print(response.notification.request.content.targetContentIdentifier)
                }
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
