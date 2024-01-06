//
//  Date+DaysRelative.swift
//  Next Candles
//
//  Created by Frank Anderson on 1/6/24.
//

import Foundation

extension Date {
    static func daysRelative(primaryDate: Date, otherDate: Date) -> Int {
        let days = Calendar.current.dateComponents([.day], from: primaryDate, to: otherDate)
        
        return days.day ?? -1
    }
}
