//
//  MonthView.swift
//  Next Candles
//
//  Created by Frank Anderson on 7/28/22.
//

import SwiftUI

struct MonthView: View {
    @EnvironmentObject var settings: SettingsVM
    @Binding var birthdays: MonthWrapper
    
    var body: some View {
        Group {
            Text(birthdays.month)
                .font(.system(.title, design: .rounded, weight: .bold))
                .foregroundColor(isCurrentMonth(month: birthdays.monthInt) ? .pink : .primary)
            
            ForEach(birthdays.sortedContacts) { birthday in
                BirthdayView(birthday: birthday)
            }
            
            Spacer()
                .listRowSeparator(Visibility.hidden)
        }
    }
    
    func isCurrentMonth(month: Int) -> Bool {
        let nowComponents = Calendar.current.dateComponents([.month], from: Date())
        
        return nowComponents.month == month
    }
}
