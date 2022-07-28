//
//  MonthView.swift
//  Next Candles
//
//  Created by Frank Anderson on 7/28/22.
//

import SwiftUI

struct MonthView: View {
    @EnvironmentObject var settings: SettingsVM
    @Binding var birthdays: [BirthdayObject]
    
    var body: some View {
        Group {
            Text(birthdays.first?.date.formatted(.dateTime.month(.wide)) ?? "")
                .font(.system(.title, design: .rounded, weight: .bold))
            
            ForEach($birthdays) { $birthday in
                if (!settings.favoritesOnly
                    || (settings.favoritesOnly && birthday.favorite)) {
                    BirthdayView(birthday: $birthday)
                }
            }
            
            Spacer()
                .listRowSeparator(Visibility.hidden)
        }
    }
}

struct MonthView_Previews: PreviewProvider {
    static var previews: some View {
        MonthView(birthdays: .constant([
                BirthdayObject(name: "Johnny Appleseed", date: Date()),
                BirthdayObject(name: "Sammy Peachtree", date: Date()),
                BirthdayObject(name: "Elizabeth Grapevine", date: Date())
            ]))
    }
}
