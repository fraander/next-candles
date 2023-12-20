//
//  Contact.swift
//  Next Candles
//
//  Created by Frank Anderson on 11/20/23.
//

import Foundation
import SwiftData

@Model
class Contact: ObservableObject, Equatable {
    var identifier: String?
    var givenName: String?
    var familyName: String?
    var nickname: String?
    var month: Int?
    var day: Int?
    var year: Int?
    var hidden: Bool = false
    var notif: String?
    
    var name: String {
        let formatter = PersonNameComponentsFormatter()
        
        var components = PersonNameComponents()
        components.givenName = givenName
        components.familyName = familyName
        components.nickname = nickname
        
        return formatter.string(from: components)
    }
    
    var birthdate: Date? {
        var components = DateComponents()
        components.month = month
        components.day = day
        components.year = year ?? Calendar.current.component(.year, from: Date())
        
        return Calendar.current.date(from: components)
    }
    
    var hasNotifs: Bool {
        if notif == nil {
            return false
        } else {
            return true
        }
    }
    
    func withinNextXDays(x: Int) -> Bool {
        let currentDate = Date()
        let currentYear = Calendar.current.component(.year, from: Date())
        let currentMonth = Calendar.current.component(.month, from: Date())
        let currentDay = Calendar.current.component(.day, from: Date())
        
        if currentMonth == month && currentDay == day {
            return true
        }
        
        let givenComponents = DateComponents(
            year: currentYear + (
                (
                    month ?? 0
                ) < currentMonth ? 1 : 0
            ),
            month: month,
            day: day
        )
        guard let givenDate = Calendar.current.date(from: givenComponents) else { return false }
        
        var xDays = DateComponents()
        xDays.day = x
        
        if let futureDate = Calendar.current.date(byAdding: xDays, to: currentDate) {
            if (currentDate <= givenDate && givenDate <= futureDate) {
                return true
            }
        }
        
        return false
    }
    
    init(identifier: String? = nil,givenName: String? = nil, familyName: String? = nil, nickname: String? = nil, month: Int? = nil, day: Int? = nil, year: Int? = nil, notif: String? = nil) {
        self.identifier = identifier
        self.givenName = givenName
        self.familyName = familyName
        self.nickname = nickname
        self.month = month
        self.day = day
        self.year = year
        self.notif = notif
    }
    
    func setNotifs(dayRange: Int) async throws {
        // Set notification for the day of
        let birthdateComponents = DateComponents(calendar: .current, month: self.month, day: self.day)
        do {
            let notifId = try await NotificationsHelper.scheduleNotification(name: self.name, dateComponents: birthdateComponents, distanceFromBD: 0)
            DispatchQueue.main.async {
                self.notif = notifId
            }
        } catch {
            throw error
        }
    }
}
