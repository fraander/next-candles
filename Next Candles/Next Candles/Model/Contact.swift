//
//  Contact.swift
//  Next Candles
//
//  Created by Frank Anderson on 11/20/23.
//

import Foundation
import SwiftData

@Model
class Contact {
    var identifier: String?
    var givenName: String?
    var familyName: String?
    var nickname: String?
    var month: Int?
    var day: Int?
    var year: Int?
    var hidden: Bool = false
    
    var name: String {
        let formatter = PersonNameComponentsFormatter()
        
        var components = PersonNameComponents()
        components.givenName = givenName
        components.familyName = familyName
        components.nickname = nickname
        
        return formatter.string(from: components)
    }
    
    var birthdate: Date? {
        if let month, let day, let year {
            var components = DateComponents()
            components.month = month
            components.day = day
            components.year = year
            
            return Calendar.current.date(from: components)
        }
        
        return nil
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
    
    init(identifier: String? = nil,givenName: String? = nil, familyName: String? = nil, nickname: String? = nil, month: Int? = nil, day: Int? = nil, year: Int? = nil) {
        self.identifier = identifier
        self.givenName = givenName
        self.familyName = familyName
        self.nickname = nickname
        self.month = month
        self.day = day
        self.year = year
    }
}
