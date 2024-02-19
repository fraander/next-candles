//
//  GeneralizedError.swift
//  Next Candles
//
//  Created by Frank Anderson on 1/27/24.
//

import Foundation

struct GeneralizedError: LocalizedError {
    let description: String
    
    init(_ description: String) {
        self.description = description
    }
    
    var errorDescription: String? {
        description
    }
    
    var localizedDescription: String? {
        description
    }
}
