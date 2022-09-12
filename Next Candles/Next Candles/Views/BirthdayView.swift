//
//  BirthdayView.swift
//  Next Candles
//
//  Created by Frank Anderson on 7/28/22.
//

import SwiftUI

struct BirthdayView: View {
    @EnvironmentObject var settings: SettingsVM
    var birthday: ContactWrapper
    
    var body: some View {
        HStack(alignment: .center) {
            
            ZStack {
                Text("00/00")
                    .foregroundColor(.clear)
                
                Text("\(birthday.month)/\(birthday.day)")
                    .font(.system(.caption, design: .monospaced, weight: .bold))
                    .foregroundColor(withinNextXDays() ? .pink : .secondary)
            }
            
            Text("\(birthday.firstName) \(birthday.lastName)")
                .font(.system(.body, design: .rounded, weight: .regular))
            
            Spacer()
        }
        .font(.system(.headline, design: .monospaced, weight: .bold))
    }
    
    func withinNextXDays() -> Bool {
        let currentYear = Calendar.current.dateComponents([.year], from: Date()).year
        
        let givenComponents = DateComponents(year: currentYear, month: birthday.month, day: birthday.day)
        guard let givenDate = Calendar.current.date(from: givenComponents) else { return false }
        
        var xDays = DateComponents()
        xDays.day = Int(settings.nextUpDays)
        
        let currentDate = Date()
        if let futureDate = Calendar.current.date(byAdding: xDays, to: currentDate) {
            if (currentDate <= givenDate && givenDate <= futureDate) {
                return true
            }
        }
        
        return false
    }
}
