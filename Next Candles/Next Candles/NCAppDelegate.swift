//
//  NCAppDelegate.swift
//  Next Candles
//
//  Created by Frank Anderson on 12/21/23.
//

import Foundation
import UIKit
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

class NCAppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil
    ) -> Bool {
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
