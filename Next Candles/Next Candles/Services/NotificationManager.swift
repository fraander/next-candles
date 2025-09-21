//
//  NotificationManager.swift
//  Next Candles
//
//  Created by frank on 7/27/25.
//


import Observation
import NotificationCenter
import SwiftUI

/// Observable notification manager that handles all local notification operations.
/// Provides a centralized interface for creating, monitoring, and managing notifications.
@Observable
class NotificationManager {
    private let center = UNUserNotificationCenter.current()
    
    /// Array of all pending notification requests, automatically updated when notifications change using Observation
    private(set) var pendingRequests: [UNNotificationRequest] = []
    
    /// Current notification authorization status (authorized, denied, notDetermined, etc.)
    private(set) var authorizationStatus: UNAuthorizationStatus = .notDetermined
    
    /// Requests notification permissions from the user
    /// - Note: Call this when the app first launches or when notifications are needed
    func requestPermission() async {
        do {
            let granted = try await center.requestAuthorization(options: [.alert, .sound, .badge])
            await updateAuthorizationStatus()
            print("Permission granted: \(granted)")
        } catch { // Use a better handling approach in a production app ...
            print("Permission error: \(error)")
        }
    }
    
    /// Updates the current authorization status by querying the system
    func updateAuthorizationStatus() async {
        let settings = await center.notificationSettings()
        authorizationStatus = settings.authorizationStatus
    }
    
    /// Refreshes the list of pending notifications from the system
    func updateNotifications() async {
        let pr = await center.pendingNotificationRequests()
        withAnimation {
            pendingRequests = pr
        }
    }
    
    /// Adds a new notification request and refreshes the pending list
    /// - Parameter request: The notification request to schedule
    func add(_ request: UNNotificationRequest) async throws {
        try await center.add(request)
        await updateNotifications()
    }
    
    /// Removes specific notifications by their identifiers
    /// - Parameter identifiers: Array of notification identifiers to remove
    func removePendingNotificationRequests(withIdentifiers identifiers: [String]) async {
        center.removePendingNotificationRequests(withIdentifiers: identifiers)
        await updateNotifications()
    }
    
    /// Creates a calendar trigger that fires yearly on the same date and time
    /// - Parameter date: The date/time to trigger on each year
    /// - Returns: A calendar trigger configured for yearly repetition
    /// - Note: Yearly repetition is achieved by only specifying month, day, hour, and minute components (no year)
    func createYearlyTrigger(for date: Date) -> UNCalendarNotificationTrigger {
        let calendar = Calendar.current
        // Extract only month, day, hour, minute - omitting year makes it repeat yearly
        let dateComponents = calendar.dateComponents([.month, .day, .hour, .minute], from: date)
        
        return UNCalendarNotificationTrigger(
            dateMatching: dateComponents,
            repeats: true
        )
    }
    
    /// Creates notification content with the provided title and body
    /// - Parameters:
    ///   - title: The notification title
    ///   - body: The notification body text
    /// - Returns: Configured notification content
    func createContent(title: String, body: String) -> UNMutableNotificationContent {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        
        return content
    }
    
    /// Creates and schedules a yearly repeating notification with custom content
    /// - Parameters:
    ///   - date: The date/time when the notification should first trigger and repeat yearly
    ///   - title: The notification title text
    ///   - body: The notification body message
    /// - Throws: Errors from the notification center if scheduling fails
    func createYearlyNotification(on date: Date, contact: Contact, title: String, body: String) async throws {
        let uuidString = contact.identifier + "%%%" + UUID().uuidString
        let content = createContent(title: title, body: body)
        let trigger = createYearlyTrigger(for: date)
        let request = UNNotificationRequest(identifier: uuidString, content: content, trigger: trigger)
        
        try await add(request)
    }
}
