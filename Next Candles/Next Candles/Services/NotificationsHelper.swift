//
//  Notifications.swift
//  Next Candles
//
//  Created by Frank Anderson on 12/8/23.
//

import Foundation
import UserNotifications

struct GeneralizedError: LocalizedError {
    let description: String
    
    init(_ description: String) {
        self.description = description
    }
    
    var errorDescription: String? {
        description
    }
}

extension UNMutableNotificationContent {
    convenience init(title: String, body: String, link: String) {
        self.init()
        self.title = title
        self.body = body
        self.targetContentIdentifier = link
    }
}

class NotificationsHelper: ObservableObject {
    
    @Published var notifsIdCache: [String] = []
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
    ///   - dateComponents: Month/Day of their birthday
    /// - Returns: ID of the notification which has been set
    static func scheduleNotification(name: String, dateComponents: DateComponents, distanceFromBD: Int, id: String) async throws -> String {

        guard let birthdate = Calendar.current.nextDate(after: Date(), matching: dateComponents, matchingPolicy: .nextTime) else {
            throw GeneralizedError("Invalid birthdate.")
        }
        guard var date = Calendar.current.date(byAdding: .day, value: (-1 * distanceFromBD), to: birthdate) else {
            throw GeneralizedError("Invalid birthdate or invalid distance.")
        }
        if date < Date() {
            if let d = Calendar.current.date(byAdding: .year, value: 1, to: date) {
                date = d
            }
        }
        
        // format the date into [M]/[D]
        let df = DateFormatter()
        df.locale = Locale.current
        df.setLocalizedDateFormatFromTemplate("M d")
        
        // set the title
        let title = "Birthday alert! 🥳"
        let body = distanceFromBD == 0 ? "\(name.last == "s" ? name + "'" : name + "'s") birthday is today." : "\(name.last == "s" ? name + "'" : name + "'s") birthday is on \(df.string(from: date)), which is \(distanceFromBD) \(distanceFromBD == 1 ? "day" : "days") away."
        let url = "nextcandles://open?contact=" + id
        let notificationContent = UNMutableNotificationContent(title: title, body: body, link: url)
        
        let calendarTrigger = UNCalendarNotificationTrigger(
            dateMatching: dateComponents,
            repeats: true
        )
        let notificationIdentifier = UUID().uuidString
        
        // 9. Create a notification request object
        
        let notificationRequest = UNNotificationRequest(
            identifier: notificationIdentifier,
            content: notificationContent,
            trigger: calendarTrigger
        )
        
        // 11. Add the notification request to the notification center
        try await nc.add(notificationRequest)
        return notificationIdentifier
    }
    
    static func printAllPendingNotifs() async {
        let notificationRequests = await NotificationsHelper.nc.pendingNotificationRequests()
        
        for notification in notificationRequests {
            
            if let trigger = notification.trigger as? UNCalendarNotificationTrigger {
                let triggerDate = trigger.nextTriggerDate()
                print("> \(notification.identifier) - \(String(describing: triggerDate?.ISO8601Format()))")
            } else {
                print("unk notif exists")
            }
        }
    }
    
    static func removeNotifs(notifIds: [String]?) {
        nc.removePendingNotificationRequests(withIdentifiers: notifIds ?? [])
    }
    
    static func removeAllNotifs() {
        nc.removeAllPendingNotificationRequests()
    }
    
    func notifFor(id: String) async -> Bool {
        let requests = await NotificationsHelper.nc.pendingNotificationRequests()
        return requests.contains { $0.identifier == id }
    }
    
    static func fetchAllPending() async -> [String] {
        return await NotificationsHelper.nc.pendingNotificationRequests().map(\.identifier)
    }
}
