//
//  Contact.swift
//  Next Candles
//
//  Created by Frank Anderson on 11/20/23.
//

import Foundation
import SwiftData

@Model
class Contact: ObservableObject {
    var identifier: String?
    var givenName: String?
    var familyName: String?
    var nickname: String?
    var month: Int?
    var day: Int?
    var year: Int?
    var hidden: Bool = false
    var notifs: [String]? = []
    
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
    
    func withinNextXDays(x: Int) -> Bool {
            let currentYear = Calendar.current.component(.year, from: Date())
            let currentMonth = Calendar.current.component(.month, from: Date())
            
        let givenComponents = DateComponents(year: currentYear + ((month ?? 0) < currentMonth ? 1 : 0), month: month, day: day)
            guard let givenDate = Calendar.current.date(from: givenComponents) else { return false }
            
            var xDays = DateComponents()
            xDays.day = x
            
            let currentDate = Date()
            if let futureDate = Calendar.current.date(byAdding: xDays, to: currentDate) {
                if (currentDate <= givenDate && givenDate <= futureDate) {
                    return true
                }
            }
            
            return false
        }
    
    init(identifier: String? = nil,givenName: String? = nil, familyName: String? = nil, nickname: String? = nil, month: Int? = nil, day: Int? = nil, year: Int? = nil, notifs: [String]? = []) {
        self.identifier = identifier
        self.givenName = givenName
        self.familyName = familyName
        self.nickname = nickname
        self.month = month
        self.day = day
        self.year = year
        self.notifs = notifs
    }
    
    func hasNotifs() -> Bool {
        if let notifs {
            if notifs.isEmpty {
                return false
            } else {
                return true
            }
        } else {
            return false
        }
    }
    
    func setNotifs(dayRange: Int) async throws {
        // Set notification for the day of
        let birthdateComponents = DateComponents(calendar: .current, month: self.month, day: self.day)
        do {
            let notifId = try await NotificationsHelper.scheduleNotification(name: self.name, dateComponents: birthdateComponents, distanceFromBD: 0)
            self.notifs = [notifId]
        } catch {
            throw error
        }
        
//        // Set notification for x days out
//        // remove dayRange days from the birthdate
//        if birthdateComponents.day != nil {
//            birthdateComponents.day = birthdateComponents.day! - dayRange
//        }
//        do { // set another notification
//            let notifId = try await NotificationsHelper.scheduleNotification(name: self.name, dateComponents: birthdateComponents, distanceFromBD: dayRange)
//            self.notifs?.append(notifId)
//        } catch {
//            throw error
//        }
        
    }
}
