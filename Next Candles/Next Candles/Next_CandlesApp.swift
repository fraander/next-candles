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
 - Change how notifications are stored since you can reference differently now; store Notifs in UserDefaults and match identifier with notification's identifier to know if a contact has one set (Removes sync bugs)
 - Detail view buttons can be either Menu or Button
 
 Features
 - Birthday notification reminders x days out (add to list and notify as many times as you'd like)
 - More timing customization on the notifications as well (probably give options at "time of set" in a sheet)
 - iCloud Sync with SwiftData
 - Detail view made adjustable to other screen sizes; show existing notifications on the screen
 */

class AlertRouter: ObservableObject {
    @Published var alert: Alert? {
        didSet { isPresented = alert != nil }
    }
    @Published var isPresented = false
}

class ProgressViewRouter: ObservableObject {
    @Published var isLoading = false
}

@main
struct Next_CandlesApp: App {
    
    @Environment(\.openURL) var openURL
    @UIApplicationDelegateAdaptor var appDelegate: NCAppDelegate
    @StateObject var settings: Settings = Settings.load()
    @StateObject var alertRouter: AlertRouter = AlertRouter()
    @StateObject var progressRouter: ProgressViewRouter = ProgressViewRouter()
    
    var body: some Scene {
        WindowGroup {
            ContactListView()
                .fontDesign(.rounded)
                .modelContainer(for: Contact.self)
                .environmentObject(settings)
                .environmentObject(alertRouter)
                .environmentObject(progressRouter)
                .onNotification { response in
                    if let u = response.notification.request.content.targetContentIdentifier {
                        if let url = URL(string: u) {
                            openURL.callAsFunction(url)
                        }
                    }
                }
                .alert(isPresented: $alertRouter.isPresented) {
                    alertRouter.alert ?? Alert(title: Text(""))
                }
                .overlay {
                    Group {
                        if (progressRouter.isLoading) {
                            ZStack {
                                Color.primary.opacity(0.1).allowsHitTesting(false)
                                ProgressView()
                            }
                        }
                    }
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
