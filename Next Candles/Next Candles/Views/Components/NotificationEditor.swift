//
//  NotificationEditor.swift
//  Next Candles
//
//  Created by Frank Anderson on 7/8/25.
//

import SwiftUI

struct NotificationEditor: View {
    
    var contact: Contact
    
    @State var newTime: Date = Calendar.current.date(bySettingHour: 9, minute: 0, second: 0, of: Date())!
    @State var newDaysBefore: Int = 0
    
    var notificationDates: [Date] {
        let calendar = Calendar.current
        let nextYear = calendar.component(.year, from: Date()) + 1

        return [
           calendar.date(from: DateComponents(year: nextYear, month: 2, day: 14))!, // Valentine's Day
           calendar.date(from: DateComponents(year: nextYear, month: 3, day: 17))!, // St. Patrick's Day
           calendar.date(from: DateComponents(year: nextYear, month: 5, day: 12))!, // Random May date
           calendar.date(from: DateComponents(year: nextYear, month: 7, day: 4))!,  // July 4th
           calendar.date(from: DateComponents(year: nextYear, month: 9, day: 22))!, // Random September
           calendar.date(from: DateComponents(year: nextYear, month: 10, day: 31))!, // Halloween
           calendar.date(from: DateComponents(year: nextYear, month: 12, day: 25))! // Christmas
        ]
    }
    
    var body: some View {
        VStack {
            HStack {
                DatePicker("Time", selection: $newTime, displayedComponents: .hourAndMinute)
                    .labelsHidden()

                
                Picker("Days before", selection: $newDaysBefore) {
                    ForEach(0..<366) { day in
                        Text("^[\(day) day](inflect: true) before")
                            .tag(day)
                    }
                }
                .labelsHidden()
                .tint(.primary)
                .background(Color(uiColor: UIColor.tertiarySystemGroupedBackground), in: .rect(cornerRadius: 8.0))
                
                Spacer()
                
                Button("Set", systemImage: "bell.fill") {
                    //
                }
                .bold()
            }
            .padding()
            .background(.white, in: .rect(cornerRadius: 16))
            .padding([.top, .horizontal])
            
            VStack(alignment: .leading) {
                ForEach(notificationDates, id: \.self) { date in
                    HStack {
                        Text(date.formatted(.relative(presentation: .numeric, unitsStyle: .wide)))
                        
                        Spacer()
                        
                        Button("Delete", systemImage: "xmark", role: .destructive) {}
                            .labelStyle(.iconOnly)
                    }
                    .padding(.horizontal, 5)
                    .padding(.top, date == notificationDates.first ? 2 : 5)
                    .padding(.bottom, date == notificationDates.last ? 2 : 5)
                    
                    if (date != notificationDates.last) {
                        Divider()
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
            .padding()
            .background(.white, in: .rect(cornerRadius: 16))
            .padding([.bottom, .horizontal])
        }
    }
}

#Preview {
    ContactDetailView(contact: Contact.examples.randomElement()!)
        .applyEnvironment(prePopulate: true)
}
