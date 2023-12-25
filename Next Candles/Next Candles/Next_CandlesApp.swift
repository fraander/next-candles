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
 - Setup global loading screen so that it's easier to block interaction when needed
 - Change how notifications are stored since you can reference differently now; store Notifs in UserDefaults and match identifier with notification's identifier to know if a contact has one set (Removes sync bugs)
 
 Features
 - Better import management --> "Every contact in the contacts database has a unique ID, which you access using the identifier property. The mutable and immutable versions of the same contact have the same identifier."
     - So far, only imports new contacts; In the future, import changes to existing ones as well!
     - Would be better to just store identifier and call the data from contacts app on load each time; that way it stays up to date and the app doesn't have to serve as the Source of Truth.
 - Birthday notification reminders x days out (add to list and notify as many times as you'd like)
 - More timing customization on the notifications as well (probably give options at "time of set" in a sheet)
 - iCloud Sync with SwiftData
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
