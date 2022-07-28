//
//  BirthdayObject.swift
//  Next Candles
//
//  Created by Frank Anderson on 7/28/22.
//

import Foundation

struct BirthdayObject: Identifiable, Hashable {
    var id = UUID()
    var favorite: Bool = false
    let name: String
    let date: Date
}
