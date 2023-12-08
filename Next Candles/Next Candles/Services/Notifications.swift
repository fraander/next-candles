//
//  Notifications.swift
//  Next Candles
//
//  Created by Frank Anderson on 12/8/23.
//

import Foundation
import UserNotifications

extension UNMutableNotificationContent {
    convenience init(title: String, body: String) {
        self.init()
        self.title = title
        self.body = body
    }
}

struct NotificationsHelper {
    
    static let nc = UNUserNotificationCenter.current()
    
    /// Request access from the user to provide notifications
    /// - Returns: True if the user authorizes, false otherwise
    static private func requestAccess() async -> Bool {
        let result = try? await nc.requestAuthorization(options: [.alert, .badge, .sound])
        return result ?? false
    }
    
    static func hasAccess() async -> Bool {
        let settings = await nc.notificationSettings()
        switch settings.authorizationStatus {
        case .notDetermined:
            // If not asked for before, ask now.
            return (await requestAccess() ? await hasAccess() : false)
        case .denied:
            return false
        case .authorized:
            return true
        case .provisional:
            return true
        case .ephemeral:
            return true
        default:
            return false
        }
    }
    
    
    /// Sets a notification for the given person on the given day/month
    /// - Parameters:
    ///   - name: Name of the person
    ///   - birthdateComponents: Month/Day of their birthday
    /// - Returns: <#description#>
    static func scheduleNotification(name: String, birthdateComponents: DateComponents) async throws -> String {
        #warning("note in TODO")
        // TODO: More work required becuase the notification should be set x days before their birthday. Perhaps start with on their birthday, and then adjust.
        let date = Calendar.current.nextDate(after: Date(), matching: birthdateComponents, matchingPolicy: .nextTime) ?? Date()

        let df = DateFormatter()
        df.locale = Locale.current
        df.setLocalizedDateFormatFromTemplate("M d")
        
        let range: Int = Calendar.current.dateComponents([.day], from: Date(), to: date).day ?? -1

        let title = "\(name.last == "s" ? name + "'" : name + "'s") birthday is approaching! 🥳"
        let body = "Their birthday is on \(df.string(from: date)), which is \(String(describing: range)) \(range == 1 ? "day" : "days") away."
        let notificationContent = UNMutableNotificationContent(title: title, body: body)
        
        let calendarTrigger = UNCalendarNotificationTrigger(
            dateMatching: birthdateComponents,
            repeats: true
        )
        let notificationIdentifier = UUID().uuidString
        
        // 9. Create a notification request object
        let notificationRequest = UNNotificationRequest(
            identifier: notificationIdentifier,
            content: notificationContent,
            trigger: calendarTrigger
        )
        
        // 10. Get the notification center shared instance
        let notificationCenter = UNUserNotificationCenter.current()
        
        // 11. Add the notification request to the notification center
        try await notificationCenter.add(notificationRequest)
        return notificationIdentifier
    }
}

// TODO: When implementing the notifications, will need to keep track of IDs for people who've had notifs set.

//        // MARK: See Pending
//        let notificationRequests = await notificationCenter.pendingNotificationRequests()
//        
//        for notification in notificationRequests {
//            
//            if let trigger = notification.trigger as? UNCalendarNotificationTrigger {
//                let triggerDate = trigger.nextTriggerDate()
//                print("> \(notification.identifier) - \(String(describing: triggerDate?.ISO8601Format()))")
//            }
//        }
//        
//        // MARK: Pending management
//        // Removing all delivered notifications
//        notificationCenter.removeAllDeliveredNotifications()
//
//        // Removing all pending notifications
//        notificationCenter.removeAllPendingNotificationRequests()
//
//        // Removing pending notifications wiht specific identifiers
//        let notificationIdentifiers = ["weekly-morning-notification"]
//        notificationCenter.removePendingNotificationRequests(withIdentifiers: notificationIdentifiers)
//        
//
//    }
