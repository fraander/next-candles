//
//  ContactWrapper.swift
//  Next Candles
//
//  Created by Frank Anderson on 9/12/22.
//

import Foundation

// wrapper for a contact to make it easier to handle in SwiftUI
struct ContactWrapper: Identifiable, Comparable {
    
    var id = UUID()
    var firstName: String
    var lastName: String
    var month: Int
    var day: Int
    var year: Int?
    
    // birthdays with smaller days are smaller than birthdays with the same day
    static func < (lhs: ContactWrapper, rhs: ContactWrapper) -> Bool {
        return lhs.day < rhs.day
    }
    
    // throwing initializer that only works if all required fields exist.
    init(firstName: String?, lastName: String?, month: Int?, day: Int?, year: Int?) throws {
        // check for valid fields, otherwise throw an error
        guard let firstName = firstName, let month = month, let day = day else {
            throw ContactCodingError.initializer
        }
        
        // fields are valid, so set them all
        self.firstName = firstName
        self.lastName = lastName ?? ""
        self.month = month
        self.day = day
        self.year = year
        
        return // all done :)
    }
}
