//
//  TestDateCalculations.swift
//  Next Candles Tests
//
//  Created by Frank Anderson on 1/27/24.
//

import XCTest

final class NC_DateCalcTests: XCTestCase {

    func testXDaysBeforeNext() throws {
        
        let sample = DateComponents(year: 1978, month: 1, day: 20)
        
        let todayComponents = DateComponents(year: 2024, month: 1, day: 27)
        let today = Calendar.current.date(from: todayComponents)!
        
        do {
            let result = try sample.dateXDaysBeforeNext(days: 14, after: today)
            print("RESULT:", result)
            
            assert(result == Calendar.current.date(from: DateComponents(year: 2025, month: 1, day: 6)))
        } catch {
            throw error
        }
        
    }

    
    func printComponent(_ message: String = "", _ dc: DateComponents) {
        let date = Calendar.current.date(from: dc)!
        let formatter = DateFormatter()
        formatter.dateFormat = "DD MMMM YYYY"
        let dateString = formatter.string(from: date)
        
        print(message, dateString)
    }
}
