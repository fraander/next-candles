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
    var givenName: String?
    var familyName: String?
    var month: Int?
    var day: Int?
    var year: Int?
    var hidden: Bool = false
    
    var name: String {
        let formatter = PersonNameComponentsFormatter()
        
        var components = PersonNameComponents()
        components.givenName = givenName
        components.familyName = familyName
        
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
    
    init(givenName: String? = nil, familyName: String? = nil, month: Int? = nil, day: Int? = nil, year: Int? = nil) {
        self.givenName = givenName
        self.familyName = familyName
        self.month = month
        self.day = day
        self.year = year
    }
}
