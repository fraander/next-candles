//
//  DateComponents+XDaysBefore.swift
//  Next Candles
//
//  Created by Frank Anderson on 1/27/24.
//

import Foundation

extension DateComponents {
    func dateXDaysBeforeNext(days: Int, after: Date, original: Date? = nil) throws -> Date {
        let originalVar = original ?? after
        
        let currentComponents = DateComponents(month: self.month, day: self.day) // birthdate, without year
        
        guard let next = Calendar.current.nextDate(after: after, matching: currentComponents, matchingPolicy: .nextTimePreservingSmallerComponents) else {
            throw GeneralizedError("Could not find a next date matching the current DateComponents object.")
        } // next Date after `after`
        
        guard let shiftedBack = Calendar.current.date(byAdding: .day, value: (-1 * days), to: next) else {
            throw GeneralizedError("Could not shift.")
        }
        
        if shiftedBack > originalVar {
            print(shiftedBack)
            return shiftedBack
        }
        
        guard let newAfter = Calendar.current.date(byAdding: .year, value: 1, to: after) else {
            throw GeneralizedError("Could not shift after back one year.")
        }
        print(newAfter)
        
        if let again = try? dateXDaysBeforeNext(days: days, after: newAfter, original: originalVar) {
            return again
        } else {
            throw GeneralizedError("Could not math this one out.")
        }
    }
}
