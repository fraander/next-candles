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
            
            ForEach($birthdays.contacts) { $birthday in
                BirthdayView(birthday: $birthday)
            }
            
            Spacer()
                .listRowSeparator(Visibility.hidden)
        }
    }
}

//struct MonthView_Previews: PreviewProvider {
//    static var previews: some View {
//        MonthView(birthdays: .constant([
//                BirthdayObject(name: "Johnny Appleseed", date: Date()),
//                BirthdayObject(name: "Sammy Peachtree", date: Date()),
//                BirthdayObject(name: "Elizabeth Grapevine", date: Date())
//            ]))
//    }
//}
