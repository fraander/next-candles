//
//  SheetType.swift
//  Next Candles
//
//  Created by Frank Anderson on 11/25/23.
//

import Foundation

enum SheetType: Identifiable, Codable {
    case custom, hidden
    
    var id: Self {
        return self
    }
}
