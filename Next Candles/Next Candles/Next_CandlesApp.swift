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
 - iCloud Sync with SwiftData
 - Detail view made adjustable to other screen sizes; show existing notifications on the screen
 - Refactor helper functions; simplify code and views
 - Calculate date relative more correctly
 */

class AlertRouter: ObservableObject {
    @Published private(set) var alert: Alert? = nil
    @Published fileprivate(set) var isPresented = false
    
    func setAlert(_ alert: Alert) {
        self.alert = alert
        isPresented = true
    }
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
                                Color.secondary.opacity(0.4).allowsHitTesting(true)
                                ProgressView()
                            }
                            .ignoresSafeArea(.all)
                        }
                    }
                    .animation(.easeInOut, value: progressRouter.isLoading)
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
