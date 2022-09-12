//
//  SettingsVM.swift
//  Next Candles
//
//  Created by Frank Anderson on 9/12/22.
//

import Foundation

/**
 Store all Settings such as to show only favorites.
 */
class SettingsVM: ObservableObject {
    @Published var nextUpDays: Double = 20
}
