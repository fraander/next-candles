//
//  NCAppDelegate.swift
//  Next Candles
//
//  Created by Frank Anderson on 12/21/23.
//

import Foundation
#if os(iOS)
import UIKit
#elseif os(macOS)
import UserNotifications
#endif
import SwiftUI


public class NotificationHandler: ObservableObject {
    /// The shared notification system for the process
    public static let shared = NotificationHandler()
    
    /// Latest available notification
    @Published private(set) var latestNotification: UNNotificationResponse? = .none // default value
    
    /// Handles the receiving of a UNNotificationResponse and propagates it to the app
    ///
    /// - Parameters:
    ///   - notification: The UNNotificationResponse to handle
    public func handle(notification: UNNotificationResponse) {
        self.latestNotification = notification
    }
}


#if os(iOS)
typealias AppDelegate = UIApplicationDelegate
typealias Application = UIApplication
#elseif os(macOS)
typealias AppDelegate = NSApplicationDelegate
typealias Application = NSApplication
#endif


class NCAppDelegate: NSObject, AppDelegate, UNUserNotificationCenterDelegate {
#if os(iOS)
    func application(
        _ application: Application,
        didFinishLaunchingWithOptions launchOptions: [Application.LaunchOptionsKey : Any]? = nil
    ) -> Bool {
        return launchAction()
    }
#elseif os(macOS)
    func applicationDidFinishLaunching(_ notification: Notification) {
        let _ = launchAction()
    }
#endif
    
    
    func launchAction() -> Bool {
        UNUserNotificationCenter.current().delegate = self
        
        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current()
            .requestAuthorization(
                options: authOptions,
                completionHandler: {_, _ in
                    // Possibility handle the result of the authorization
                }
            )
        return true
    }
    
    func userNotificationCenter(_: UNUserNotificationCenter, didReceive response: UNNotificationResponse) async {
        NotificationHandler.shared.handle(notification: response)
    }
}


struct NotificationViewModifier: ViewModifier {
 
    private let onNotification: (UNNotificationResponse) -> Void
 
    init(onNotification: @escaping (UNNotificationResponse) -> Void) {
        self.onNotification = onNotification
    }
 
    func body(content: Content) -> some View {
        content
            .onReceive(NotificationHandler.shared.$latestNotification) { notification in
                guard let notification else { return }
                onNotification(notification)
            }
    }
}

extension View {
    func onNotification(perform action: @escaping (UNNotificationResponse) -> Void) -> some View {
        modifier(NotificationViewModifier(onNotification: action))
    }
}
