//
//  MonthWrapper.swift
//  Next Candles
//
//  Created by Frank Anderson on 9/12/22.
//

import Foundation

struct MonthWrapper: Identifiable, Comparable {
    
    var id = UUID()
    var contacts: [ContactWrapper]
    var sortedContacts: [ContactWrapper] {
        contacts.sorted()
    }
    var monthInt: Int
    var month: String {
        switch monthInt {
            case 1:
                return "January"
            case 2:
                return "February"
            case 3:
                return "March"
            case 4:
                return "April"
            case 5:
                return "May"
            case 6:
                return "June"
            case 7:
                return "July"
            case 8:
                return "August"
            case 9:
                return "September"
            case 10:
                return "October"
            case 11:
                return "November"
            case 12:
                return "December"
            default:
                return "ERROR"
        }
    }
    
    // earlier months are smaller than later months
    static func < (lhs: MonthWrapper, rhs: MonthWrapper) -> Bool {
        lhs.monthInt < rhs.monthInt
    }
    
    // when the months have the same number they are the same
    static func == (lhs: MonthWrapper, rhs: MonthWrapper) -> Bool {
        return rhs.monthInt == lhs.monthInt
    }
    
    init(contacts: [ContactWrapper], monthInt: Int) {
        self.contacts = contacts
        self.monthInt = monthInt
    }
    
    // sort the birthdays within the month
    mutating func sort() {
        contacts.sort()
    }
}
