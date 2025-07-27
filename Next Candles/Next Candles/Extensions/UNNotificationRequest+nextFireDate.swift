//
//  UNNotificationRequest+nextFireDate.swift
//  Notifications
//
//  Created by frank on 7/27/25.
//

import NotificationCenter

extension UNNotificationRequest {
    /// Extracts the date components from a calendar notification trigger
    /// - Returns: DateComponents if the request has a calendar trigger, nil otherwise
    func getTriggerDateComponents() -> DateComponents? {
        guard let trigger = trigger as? UNCalendarNotificationTrigger else { return nil }
        return trigger.dateComponents
    }
    
    /// Calculates the next actual fire date for yearly repeating notifications
    /// - Returns: The next date when this notification will actually trigger
    /// - Note: This is more accurate than trigger.nextTriggerDate() for yearly repeating notifications
    var nextFireDate: Date? {
        guard let triggerDate = getTriggerDateComponents() else { return nil }
        return getNextOccurrence(of: triggerDate)
    }
    
    /// Finds the next occurrence of a date that matches the given components
    /// - Parameter dateComponents: Date components (typically month, day, hour, minute for yearly notifications)
    /// - Returns: Next future date matching these components, trying current year first, then next year
    private func getNextOccurrence(of dateComponents: DateComponents) -> Date? {
        let calendar = Calendar.current
        let now = Date()
        
        // Try this year first by adding current year to the components
        var components = dateComponents
        components.year = calendar.component(.year, from: now)
        
        if let thisYear = calendar.date(from: components), thisYear > now {
            return thisYear
        }
        
        // If this year's date has passed, try next year
        components.year = calendar.component(.year, from: now) + 1
        return calendar.date(from: components)
    }
}
