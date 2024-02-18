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
 - iCloud Sync with SwiftData
 - Refactor helper functions; simplify code and views
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
    #if os(iOS)
    @UIApplicationDelegateAdaptor var appDelegate: NCAppDelegate
    #elseif os(macOS)
    @NSApplicationDelegateAdaptor var appDelegate: NCAppDelegate
    #endif
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
