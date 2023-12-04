//
//  isNunber.swift
//  Next Candles
//
//  Created by Frank Anderson on 12/3/23.
//

import Foundation

extension Formatter {
    static let valueFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.zeroSymbol  = ""     // Show empty string instead of zero
        return formatter
    }()
}
