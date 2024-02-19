//
//  Notifications.swift
//  Next Candles
//
//  Created by Frank Anderson on 12/8/23.
//

import Foundation
import UserNotifications

extension UNMutableNotificationContent {
    convenience init(title: String, body: String, link: String) {
        self.init()
        self.title = title
        self.body = body
        self.targetContentIdentifier = link
    }
}

class NotificationsHelper: ObservableObject {
    
    @Published var notifsCache: [NotifWrapper] = []
    
    init() {
        self.notifsCache = []
    }
    
    let nc = UNUserNotificationCenter.current()
    
    /// Request access from the user to provide notifications
    /// - Returns: True if the user authorizes, false otherwise
    private func requestAccess() async -> Bool {
        let result = try? await nc.requestAuthorization(options: [.alert, .badge, .sound])
        return result ?? false
    }
    
    func hasAccess() async -> Bool {
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
    func scheduleNotification(name: String, dateComponents: DateComponents, distanceFromBD: Int, id: String, hour: Int, minute: Int) async throws -> String {
        
        let ndComps = DateComponents(month: dateComponents.month, day: dateComponents.day, hour: hour, minute: minute)
        
        var date = Date()
        if let nextBd = Calendar.current.nextDate(after: Date(), matching: ndComps, matchingPolicy: .nextTime) {
            if let notifDate = Calendar.current.date(byAdding: .day, value: -1 * distanceFromBD, to: nextBd) {
                if notifDate < Date() { // if notifDate has already passed
                    // calculate again
                    if let nextNextBd = Calendar.current.nextDate(after: nextBd, matching: ndComps, matchingPolicy: .nextTime) {
                        if let nextNotifDate = Calendar.current.date(byAdding: .day, value: -1 * distanceFromBD, to: nextNextBd) {
                            // schedule at nextNotifDate
                            date = nextNotifDate
                        }
                    }
                } else {
                    // schedule at notifDate
                    date = notifDate
                }
            }
        }
        
        guard let birthdate = Calendar.current.nextDate(after: Date(), matching: dateComponents, matchingPolicy: .nextTime) else {
            throw GeneralizedError("Invalid birthdate.")
        }
//        guard var date = Calendar.current.date(byAdding: .day, value: (-1 * distanceFromBD), to: birthdate) else {
//            throw GeneralizedError("Invalid birthdate or invalid distance.")
//        }
//        
//        if date < Date() {
//            
//            guard let yearLater = Calendar.current.date(byAdding: .year, value: 1, to: Date()) else {
//                throw GeneralizedError("Invalid date 1 year from today")
//            }
//            
//            guard let newBirthdate = Calendar.current.nextDate(after: yearLater, matching: dateComponents, matchingPolicy: .nextTime) else {
//                throw GeneralizedError("Invalid birthdate.")
//            }
//            
//            guard let newDate = Calendar.current.date(byAdding: .day, value: (-1 * distanceFromBD), to: newBirthdate) else {
//                throw GeneralizedError("Invalid birthdate or invalid distance.")
//            }
//            
//            date = newDate
//        }
        
        var newDateComponents = Calendar.current.dateComponents([.day, .month, .year], from: date)
        newDateComponents.hour = hour
        newDateComponents.minute = minute
        
        // format the date into [M]/[D]
        let df = DateFormatter()
        df.locale = Locale.current
        df.setLocalizedDateFormatFromTemplate("M d")
        
        // set the title
        let title = "Birthday alert! 🥳"
        let body = distanceFromBD == 0 ? "\(name.last == "s" ? name + "'" : name + "'s") birthday is today." : "\(name.last == "s" ? name + "'" : name + "'s") birthday is on \(df.string(from: birthdate)), which is \(distanceFromBD) \(distanceFromBD == 1 ? "day" : "days") away."
        
        var components = URLComponents()
        components.scheme = "nextcandles"
        components.host = "action"
        components.queryItems = [
            URLQueryItem(name: "id", value: id),
            URLQueryItem(name: "day", value: String(describing: newDateComponents.day ?? 0)),
            URLQueryItem(name: "month", value: String(describing: newDateComponents.month ?? 0)),
            URLQueryItem(name: "hour", value: String(describing: newDateComponents.hour ?? 0)),
            URLQueryItem(name: "minute", value: String(describing: newDateComponents.minute ?? 0))
        ]
        
        
        guard let url = components.url?.absoluteString else {
            throw GeneralizedError("Invalid URL")
        }
        let notificationContent = UNMutableNotificationContent(title: title, body: body, link: url)
        
        let calendarTrigger = UNCalendarNotificationTrigger(
            dateMatching: newDateComponents,
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
        await refreshCache()
        return notificationIdentifier
    }
    
    func refreshCache() async {
        let update = await nc.pendingNotificationRequests().compactMap {
            NotifWrapper(id: $0.identifier, url: $0.content.targetContentIdentifier ?? "")
        }
        DispatchQueue.main.async {
            self.notifsCache = update
        }
    }
    
    func printAllPendingNotifs() async {
        let notificationRequests = await nc.pendingNotificationRequests()
        
        for notification in notificationRequests {
            
            if let trigger = notification.trigger as? UNCalendarNotificationTrigger {
                let triggerDate = trigger.nextTriggerDate()
                print("> \(notification.identifier) - \(String(describing: triggerDate?.ISO8601Format()))")
            } else {
                print("unk notif exists")
            }
        }
    }
    
    func removeNotifs(notifIds: [String]?) {
        nc.removePendingNotificationRequests(withIdentifiers: notifIds ?? [])
    }
    
    func removeAllNotifs() {
        nc.removeAllPendingNotificationRequests()
        nc.removeAllDeliveredNotifications()
        notifsCache = []
    }
    
    func notifsFor(contact: Contact) async -> [NotifWrapper] {
        let requests = await nc.pendingNotificationRequests()
        let identifiers = requests.compactMap {
            NotifWrapper(id: $0.identifier, url: $0.content.targetContentIdentifier ?? "")
        }
        let filtered = identifiers.filter { $0.url.contains(contact.identifier) }
        
        var output: [NotifWrapper] = []
        filtered.forEach { nw in
            if !(output.contains { $0.url == nw.url }) {
                output.append(nw)
            } else {
                removeNotifs(notifIds: [nw.id])
            }
        }
        
        return sortNotifWrappers(output, contact: contact)
    }
    
    func sortNotifWrappers(_ notifs: [NotifWrapper], contact: Contact) -> [NotifWrapper] {
        return notifs.sorted {
            if let lhs = notifDate(from: $0.url),
               let rhs = notifDate(from: $1.url),
               let lhsDist = difference(notifDate: lhs, birthMonth: contact.month, birthDay: contact.day),
               let rhsDist = difference(notifDate: rhs, birthMonth: contact.month, birthDay: contact.day) {
                return lhsDist < rhsDist
            } else {
                return false
            }
        }
    }
    
    func notifDate(from urlString: String) -> Date? {
        guard let url = URL(string: urlString),
              let components = URLComponents(
                url: url,
                resolvingAgainstBaseURL: true
              ),
              let dayString = components.queryItems?.first(where: {
                  $0.name == "day"
              })?.value,
              let monthString = components.queryItems?.first(where: {
                  $0.name == "month"
              })?.value,
              let hourString = components.queryItems?.first(where: {
                  $0.name == "hour"
              })?.value,
              let minuteString = components.queryItems?.first(where: {
                  $0.name == "minute"
              })?.value,
              let day = Int(dayString),
              let month = Int(monthString),
              let hour = Int(hourString),
              let minute = Int(minuteString),
              let result = Calendar.current.nextDate(
                after: Date(),
                matching: DateComponents(month: month, day: day, hour: hour, minute: minute),
                matchingPolicy: .nextTime
              ) else { return nil }
        
        return result
    }
    
    func difference(notifDate: Date, birthMonth: Int?, birthDay: Int?) -> Int? {
        
        let notifDateComponents = Calendar.current.dateComponents([.day, .month], from: notifDate)
        guard let notifDateWithoutTime = Calendar.current.date(from: notifDateComponents) else {
            return nil
        }
        if (notifDateComponents.day == birthDay && notifDateComponents.month == birthMonth) {
            return 0
        }
        
        let bdc = DateComponents(month: birthMonth, day: birthDay)
        guard let nextBd = Calendar.current.nextDate(after: notifDateWithoutTime, matching: bdc, matchingPolicy: .nextTime),
              let dist = Calendar.current.dateComponents([.day], from: notifDateWithoutTime, to: nextBd).day else {
            return nil
        }
        
        return dist
    }
    
    func setNotifFor(contact: Contact, distanceFromBD: Int, hour: Int, minute: Int) async throws {
        // Set notification for the day of
        let birthdateComponents = DateComponents(calendar: .current, month: contact.month, day: contact.day)
        do {
            let _ = try await scheduleNotification(name: contact.name, dateComponents: birthdateComponents, distanceFromBD: distanceFromBD, id: contact.identifier, hour: hour, minute: minute)
            await refreshCache()
        } catch {
            throw error
        }
    }
}
